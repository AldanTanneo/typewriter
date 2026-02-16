package Typewriter.UTF8
  with Pure
is
   pragma Extensions_Allowed (On);

   subtype ASCII is Byte range 0 .. 127;
   type Code_Point is mod 16#11_0000#;

   subtype Continuation_Byte is Byte range 2#10_000000# .. 2#10_111111#;

   subtype Invalid_Range is Code_Point range 16#D800# .. 16#DFFF#;
   subtype Valid_Code_Point is Code_Point
   with Static_Predicate => not (Valid_Code_Point in Invalid_Range);

   Replacement_Character : constant Code_Point := 16#FFFD#;

   function To_Code_Point (WWC : Wide_Wide_Character) return Code_Point
   is (Code_Point (Wide_Wide_Character'Pos (WWC)))
   with Inline_Always;

   subtype Encoding_Size is Natural range 1 .. 4;
   subtype Encoding is Byte_Array
   with
     Dynamic_Predicate =>
       Encoding'First = 1 and then Encoding'Last in Encoding_Size;

   function Encoding_Length (C : Code_Point) return Encoding_Size
   with No_Raise, Inline;

   function Encode (C : Valid_Code_Point) return Encoding
   with No_Raise;

   function Decode (Arr : Byte_Array; Read : out Natural) return Code_Point
   with No_Raise;

   function Checked_Decode
     (Arr : Byte_Array; Read : out Natural) return Valid_Code_Point;

   Decoding_Error : exception;

end Typewriter.UTF8;
