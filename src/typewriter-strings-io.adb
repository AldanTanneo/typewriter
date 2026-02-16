with Ada.IO_Exceptions;
with Interfaces.C_Streams; use Interfaces.C_Streams;

package body Typewriter.Strings.IO is
   use type size_t;

   procedure Put (S : Str) is
      Written : size_t;
   begin
      Written := fwrite (S.Bytes'Address, 1, size_t (S.Length), stdout);
      if Written /= size_t (S.Length) then
         raise Ada.IO_Exceptions.Device_Error;
      end if;
   end Put;

   procedure Put_Line (S : Str) is
      Newline : constant int := 16#0A#;
   begin
      Put (S);
      if fputc (Newline, stdout) = EOF then
         raise Ada.IO_Exceptions.Device_Error;
      end if;
   end Put_Line;

end Typewriter.Strings.IO;
