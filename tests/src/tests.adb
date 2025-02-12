with Typewriter.Strings;
with Typewriter.Strings.IO;
procedure Tests is
   use Typewriter.Strings;

   A : constant Slice := Lit ("emoji ✨✨");
   B : constant Slice := Lit ("just a string");
   C : Slice          := A.Clone;
   D : Slice;
begin
   IO.Put_Line (A);
   IO.Put_Line (B);
   IO.Put_Line (C);
   C.Assign (B.Clone);
   IO.Put_Line (C);
   C.Assign (A);
   IO.Put_Line (C);
   D.Assign (C.Move);
   IO.Put_Line (C);
   IO.Put_Line (D);
end Tests;
