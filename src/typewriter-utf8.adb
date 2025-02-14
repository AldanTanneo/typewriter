package body Typewriter.UTF8 with
  Pure
is
   type U32 is mod 2**32;
   for U32'Size use 32;

   function Shift_Right (C : U32; Amount : Natural) return U32 with
     Import, Convention => Intrinsic, Inline_Always;
   function Shift_Left (C : U32; Amount : Natural) return U32 with
     Import, Convention => Intrinsic, Inline_Always;
   function Shr (C : Code_Point; Amount : Natural) return Code_Point is
     (Code_Point (Shift_Right (U32 (C), Amount))) with Inline_Always;
   function Shl (C : Code_Point; Amount : Natural) return Code_Point is
     (Code_Point (Shift_Left (U32 (C), Amount))) with Inline_Always;

   subtype Range_1 is Code_Point range 0 .. 16#7F#;
   --  range for 1 byte encoding
   subtype Range_2 is Code_Point range 16#80# .. 16#7FF#;
   --  range for 2 byte encoding
   subtype Range_3 is Code_Point range 16#800# .. 16#FFFF#;
   --  range for 3 byte encoding
   subtype Range_4 is Code_Point range 16#1_0000# .. 16#10_FFFF#;
   --  range for 4 byte encoding

   Prefix_N : constant := 2#10_000000#;
   --  prefix for continuation bytes
   Prefix_2 : constant := 2#110_00000#;
   --  prefix for 2 byte encoding
   Prefix_3 : constant := 2#1110_0000#;
   --  prefix for 3 byte encoding
   Prefix_4 : constant := 2#11110_000#;
   --  prefix for 4 byte encoding

   Mask_N : constant := 2#00_111111#;
   --  mask for continuation bytes
   Mask_2 : constant := 2#000_11111#;
   --  mask for 2 byte decoding
   Mask_3 : constant := 2#0000_1111#;
   --  mask for 3 byte decoding
   Mask_4 : constant := 2#00000_111#;
   --  mask for 4 byte decoding

   function Encoding_Length (C : Code_Point) return Encoding_Size is
   begin
      return (case C is
        when Range_1 => 1,
        when Range_2 => 2,
        when Range_3 => 3,
        when Range_4 => 4
      );
   end Encoding_Length;

   function Encode (C : Valid_Code_Point) return Encoding is
   begin
      case C is
         when Range_1 =>
            return [Byte (C)];
         when Range_2 =>
            return [
              Prefix_2 or Byte (Shr (C, 6)),
              Prefix_N or Byte (C and Mask_N)
            ];
         when Range_3 =>
            return [
              Prefix_3 or Byte (Shr (C, 12)),
              Prefix_N or Byte (Shr (C, 6) and Mask_N),
              Prefix_N or Byte (C and Mask_N)
            ];
         when Range_4 =>
            return [
              Prefix_4 or Byte (Shr (C, 18)),
              Prefix_N or Byte (Shr (C, 12) and Mask_N),
              Prefix_N or Byte (Shr (C, 6) and Mask_N),
              Prefix_N or Byte (C and Mask_N)
            ];
      end case;
   end Encode;

   function Checked_Decode
     (Arr : Byte_Array; Read : out Count_Type) return Valid_Code_Point
   is
      Res  : Code_Point := 0;
      Cont : Count_Type := 0;
      B    : Byte;
   begin
      if Arr'Length = 0 then
         raise Decoding_Error with "empty sequence";
      end if;

      B := Arr (Arr'First);
      case B is
         when 0 .. 127 =>
            Res := Code_Point (B);
         when Prefix_2 .. (Prefix_2 or Mask_2) =>
            Cont := 1;
            Res  := Code_Point (B and Mask_2);
         when Prefix_3 .. (Prefix_3 or Mask_3) =>
            Cont := 2;
            Res  := Code_Point (B and Mask_3);
         when Prefix_4 .. (Prefix_4 or Mask_4) =>
            Cont := 3;
            Res  := Code_Point (B and Mask_4);
         when others =>
            raise Decoding_Error with "invalid first byte";
      end case;
      Read := 1;

      for I in 1 .. Cont loop
         if Arr'First + I in Arr'Range then
            B := Arr (Arr'First + I);
            if B in Continuation_Byte then
               Read := Read + 1; --  only consume known valid bytes
               if Res > Shr (Code_Point'Last, 6) then
                  raise Decoding_Error
                    with "code point outside of unicode range";
               end if;
               Res := Shl (Res, 6) or Code_Point (B and Mask_N);
            else
               raise Decoding_Error with "invalid continuation byte";
            end if;
         else
            raise Decoding_Error with "missing continuation byte";
         end if;
      end loop;

      if Res in Invalid_Range then
         raise Decoding_Error with "code point in invalid unicode range";
      else
         return Res;
      end if;
   end Checked_Decode;

   function Decode (Arr : Byte_Array; Read : out Count_Type) return Code_Point
   is
      Res : Code_Point;
   begin
      Res := Checked_Decode (Arr, Read);
      return Res;
   exception
      when Decoding_Error =>
         return Replacement_Character;
   end Decode;
end Typewriter.UTF8;
