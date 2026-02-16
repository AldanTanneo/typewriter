with Ada.Text_IO;
with Typewriter.Strings;
with Typewriter.Strings.IO;

procedure Tests is
   use Typewriter.Strings;

   A : constant Str := "emoji ✨✨";
   B : constant Str := "just a string";
   C : constant Str := A (2, 6);
   D : constant Str := C (1, 0);
begin
   Ada.Text_IO.Put_Line (A'Address'Img);

   IO.Put ("""");
   IO.Put (A);
   IO.Put_Line ("""");

   IO.Put ("""");
   IO.Put (B);
   IO.Put_Line ("""");

   IO.Put ("""");
   IO.Put (C);
   IO.Put_Line ("""");

   IO.Put ("""");
   IO.Put (D);
   IO.Put_Line ("""");
end Tests;
