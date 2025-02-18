with Typewriter.Strings;
with Typewriter.Strings.IO;

procedure Tests is
   use Typewriter.Strings;

   A : constant Slice := "emoji ✨✨";
   B : constant Slice := "just a string";
   C : Slice          := A;
   D : Slice;
begin
   IO.Put_Line (A);
   IO.Put_Line (B);
   IO.Put_Line (C);
   C := B;
   IO.Put_Line (C);
   C := A;
   IO.Put_Line (C);
   D := C;
   IO.Put_Line (C);
   IO.Put_Line (D);

   D := A (2, 6);

   C := D (1, 0);

   IO.Put ("""");
   IO.Put (C);
   IO.Put_Line ("""");

   IO.Put ("""");
   IO.Put (D);
   IO.Put_Line ("""");

   C := D.Clone;

   IO.Put ("""");
   IO.Put (C);
   IO.Put_Line ("""");
end Tests;
