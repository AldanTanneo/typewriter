with Interfaces.C_Streams;
with IO_Exceptions;
with GNAT.IO;

package body Typewriter.Strings.IO is

   procedure Put (S : Slice) is
      use Interfaces.C_Streams;
      use UTF8;

      Written : size_t;
   begin
      Written := fwrite (S.Ptr.Data'Address, 1, size_t (S.Ptr.Len), stdout);
      if Count_Type (Written) /= S.Ptr.Len then
         raise IO_Exceptions.Device_Error;
      end if;
   end Put;

   procedure Put_Line (S : Slice) is
      use Interfaces.C_Streams;
      use UTF8;

      Written : size_t;
   begin
      Written := fwrite (S.Ptr.Data'Address, 1, size_t (S.Ptr.Len), stdout);
      if Count_Type (Written) /= S.Ptr.Len then
         raise IO_Exceptions.Device_Error;
      end if;
      GNAT.IO.New_Line;
   end Put_Line;

end Typewriter.Strings.IO;
