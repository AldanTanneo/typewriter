package body Typewriter.Strings is
   function Subslice (S : Slice; Idx_Start, Idx_End : Index_Type) return Slice
   is
      use UTF8;
   begin
      if Idx_End > S.Len or else Idx_Start > S.Len then
         raise Constraint_Error with "invalid index: out of slice bounds";
      end if;
      if Idx_Start > Idx_End then
         raise Constraint_Error with "invalid slice bounds: start > end";
      end if;
      if S.Ptr.Data (S.Start + (Idx_Start - 1)) in UTF8.Continuation_Byte
        or else (Idx_End < S.Len and then
                 S.Ptr.Data (S.Start + Idx_End) in UTF8.Continuation_Byte)
      then
         raise Constraint_Error with "invalid index: not a character boundary";
      end if;
      return
        (Ada.Finalization.Controlled with Start => S.Start + (Idx_Start - 1),
         Len => Idx_End - Idx_Start + 1, Ptr => S.Ptr);
   end Subslice;

   function Literal (S : Wide_Wide_String) return Slice is
      use UTF8;

      Enc_Size : Count_Type := 0;
      Ptr      : String_Data_Access;
      Pos      : Index_Type := 1;
   begin
      for WWC of S loop
         Enc_Size :=
           Enc_Size + Count_Type (Encoding_Length (To_Code_Point (WWC)));
      end loop;
      Ptr := new String_Data (Enc_Size);
      for WWC of S loop
         declare
            Enc : constant Encoding := Encode (To_Code_Point (WWC));
         begin
            for B of Enc loop
               Ptr.Data (Pos) := B;
               Pos            := Pos + 1;
            end loop;
         end;
      end loop;
      return
        (Ada.Finalization.Controlled with
         Start => 1, Len => Enc_Size, Ptr => Ptr);
   exception
      when Encoding_Error =>
         Free_String (Ptr); --  not yet controlled
         raise;
   end Literal;

   function Clone (S : Slice) return Slice is
      use UTF8;

      New_Ptr : constant String_Data_Access := new String_Data (S.Len);
   begin
      for I in 1 .. S.Len loop
         New_Ptr.Data (I) := S.Ptr.Data (S.Start + I - 1);
      end loop;
      return
        (Ada.Finalization.Controlled with
         Start => 1, Len => S.Len, Ptr => New_Ptr);
   end Clone;

   overriding function "=" (A, B : Slice) return Boolean is
      use UTF8;
   begin
      if A.Len /= B.Len then
         return False;
      end if;

      if A.Start = B.Start and then A.Ptr = B.Ptr then
         return True;
      end if;

      for I in 1 .. A.Len loop
         if A.Ptr.Data (A.Start + I - 1) /= B.Ptr.Data (B.Start + I - 1) then
            return False;
         end if;
      end loop;

      return True;
   end "=";

   overriding procedure Initialize (S : in out Slice) is
   begin
      if S.Ptr = null then
         S.Ptr := Empty.Ptr;
         Counter.Increment (S.Ptr.Refc);
      end if;
   end Initialize;

   overriding procedure Adjust (S : in out Slice) is
   begin
      Counter.Increment (S.Ptr.Refc);
   end Adjust;

   overriding procedure Finalize (S : in out Slice) is
   begin
      if S.Ptr /= null and then Counter.Decrement (S.Ptr.Refc) then
         Free_String (S.Ptr);
      end if;
   end Finalize;
end Typewriter.Strings;
