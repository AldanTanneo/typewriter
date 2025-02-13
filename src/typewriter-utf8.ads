package Typewriter.UTF8 with
  Pure
is
   type Byte is mod 256;
   type Code_Point is mod 16#11_0000#;

   type Count_Type is new Natural;
   subtype Index_Type is Count_Type range 1 .. Count_Type'Last;

   type Byte_Array is array (Index_Type range <>) of Byte;

   subtype Continuation_Byte is Byte range 2#10_000000# .. 2#10_111111#;

   subtype Invalid_Range is Code_Point range 16#D800# .. 16#DFFF#;
   subtype Valid_Code_Point is Code_Point with
       Dynamic_Predicate => not (Valid_Code_Point in Invalid_Range);

   Replacement_Character : constant Code_Point := 16#FFFD#;

   function To_Code_Point (WWC : Wide_Wide_Character) return Code_Point is
     (Code_Point (Wide_Wide_Character'Pos (WWC)));

   type Encoding_Size is range 1 .. 4;
   type Encoding is array (Encoding_Size range <>) of Byte with
     Dynamic_Predicate => Encoding'First = 1;

   function Encoding_Length (C : Code_Point) return Encoding_Size;

   function Encode (C : Code_Point) return Encoding;

   function Decode (Arr : Byte_Array; Read : out Count_Type) return Code_Point;

   function Checked_Decode
     (Arr : Byte_Array; Read : out Count_Type) return Valid_Code_Point;

   Encoding_Error : exception;
   Decoding_Error : exception;

end Typewriter.UTF8;
