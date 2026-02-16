package Typewriter.Strings
  with Pure
is
   pragma Extensions_Allowed (On);

   type Str (Length : Natural) is tagged private
   with Constant_Indexing => Slice, String_Literal => Literal;
   --  a UTF-8

   Empty : constant Str;
   --  empty string constant

   function Slice
     (S : Str; Idx_Start : Positive; Idx_End : Natural) return Str;
   --  return a subslice of the given slice

   function Is_Empty (S : Str) return Boolean
   is (S.Length = 0)
   with Inline;

   function "=" (A, B : Str) return Boolean
   with Inline;
   function "<=" (A, B : Str) return Boolean
   with Inline;
   function ">=" (A, B : Str) return Boolean
   is (B <= A)
   with Inline;
   function "<" (A, B : Str) return Boolean
   is (not (A >= B))
   with Inline;
   function ">" (A, B : Str) return Boolean
   is (B < A)
   with Inline;

   function From_Bytes (B : Byte_Array) return Str;
   --  create a string out of a byte array, raise a Decoding_Error exception
   --  if the bytes are not a UTF-8 encoding
   function Literal (S : Wide_Wide_String) return Str
   with Inline;
   --  create a string out of a Wide_Wide_String (to use with a string literal)

private
   use all type Byte;

   type Str (Length : Natural) is tagged record
      Bytes : Byte_Array (1 .. Length);
   end record;

   function "=" (A, B : Str) return Boolean
   is (A.Length = B.Length
       and then (for all I in 1 .. A.Length => A.Bytes (I) = B.Bytes (I)));

   function "<=" (A, B : Str) return Boolean
   is (A.Length <= B.Length
       and then (for all I in 1 .. A.Length => A.Bytes (I) <= B.Bytes (I)));

   Empty : constant Str := (Length => 0, Bytes => []);

end Typewriter.Strings;
