with Typewriter.UTF8;

package body Typewriter.Strings is
   function Slice (S : Str; Idx_Start : Positive; Idx_End : Natural) return Str
   is
      use UTF8;
   begin
      if Idx_Start > Idx_End then
         return Empty;
      end if;
      if Idx_End > S.Length or else Idx_Start > S.Length then
         raise Constraint_Error with "invalid index: out of slice bounds";
      end if;
      if S.Bytes (Idx_Start) in UTF8.Continuation_Byte
        or else
          (Idx_End < S.Length
           and then S.Bytes (Idx_End + 1) in UTF8.Continuation_Byte)
      then
         raise Constraint_Error with "invalid index: not a character boundary";
      end if;
      return
        (Length => Idx_End - Idx_Start + 1,
         Bytes  => S.Bytes (Idx_Start .. Idx_End));
   end Slice;

   function From_Bytes (B : Byte_Array) return Str is
      Pos  : Positive := B'First;
      Read : Natural := 0;
      Chr  : UTF8.Valid_Code_Point
      with Unreferenced;
   begin
      while Pos <= B'Last loop
         Chr := UTF8.Checked_Decode (B (Pos .. B'Last), Read);
         Pos := Pos + Read;
      end loop;

      return (Length => B'Length, Bytes => B);
   end From_Bytes;

   function Literal (S : Wide_Wide_String) return Str is
      use UTF8;

      Enc_Size : Natural := 0;
      Pos      : Positive := 1;
   begin
      for Char of S loop
         Enc_Size := Enc_Size + Encoding_Length (To_Code_Point (Char));
      end loop;

      if Enc_Size = 0 then
         return Empty;
      end if;

      return Res : Str (Enc_Size) do
         for Char of S loop
            declare
               Enc : constant Encoding := Encode (To_Code_Point (Char));
            begin
               Res.Bytes (Pos .. Pos + Enc'Length - 1) := Enc;
               Pos := Pos + Enc'Length;
            end;
         end loop;
      end return;
   end Literal;
end Typewriter.Strings;
