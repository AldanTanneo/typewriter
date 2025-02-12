with Ada.Text_IO;

package body Typewriter.Strings is
   function Lit (S : Wide_Wide_String) return Slice is
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
      return (Ada.Finalization.Limited_Controlled with Ptr);
   exception
      when Encoding_Error =>
         Free_String (Ptr); --  not yet controlled
         raise;
   end Lit;

   function Clone (S : Slice) return Slice is
      Ptr : constant String_Data_Access := S.Ptr;
   begin
      Ada.Text_IO.Put_Line
        ("clone in: " & S.Ptr'Image & ", " & S.Ptr.Refc'Image);
      Counter.Increment (Ptr.Refc);
      Ada.Text_IO.Put_Line
        ("clone out: " & S.Ptr'Image & ", " & S.Ptr.Refc'Image);
      return (Ada.Finalization.Limited_Controlled with Ptr);
   end Clone;

   function Move (S : in out Slice) return Slice is
      Ptr : constant String_Data_Access := S.Ptr;
   begin
      S.Ptr := Empty.Ptr;
      Counter.Increment (S.Ptr.Refc);
      return (Ada.Finalization.Limited_Controlled with Ptr);
   end Move;

   procedure Assign (S : in out Slice; Other : Slice) is
   begin
      if S.Ptr /= Other.Ptr then
         Finalize (S);
         S.Ptr := Other.Ptr;
         Counter.Increment (S.Ptr.Refc);
      end if;
   end Assign;

   overriding procedure Initialize (S : in out Slice) is
   begin
      Ada.Text_IO.Put_Line ("init in: " & S.Ptr'Image);
      if S.Ptr = null then
         S.Ptr := Empty.Ptr;
         Counter.Increment (S.Ptr.Refc);
      end if;
      Ada.Text_IO.Put_Line
        ("init out: " & S.Ptr'Image & ", " & S.Ptr.Refc'Image);
   end Initialize;

   overriding procedure Finalize (S : in out Slice) is
   begin
      Ada.Text_IO.Put_Line
        ("final in: " & S.Ptr'Image & ", " & S.Ptr.Refc'Image);
      if S.Ptr /= null and then Counter.Decrement (S.Ptr.Refc) then
         Free_String (S.Ptr);
      end if;
      Ada.Text_IO.Put_Line ("final out: " & S.Ptr'Image);
   end Finalize;
end Typewriter.Strings;
