with Ada.IO_Exceptions;
with Interfaces.C_Streams;
with GNAT.IO;

package body Typewriter.Strings.IO is

   procedure Put (S : Slice) is
      use Interfaces.C_Streams;
      use UTF8;

      Written : size_t;
   begin
      if S.Ptr = null then
         return;
      end if;
      Written :=
        fwrite
          (S.Ptr.Data (S.Start .. S.Start + S.Len - 1)'Address, 1,
           size_t (S.Len), stdout);
      if Count_Type (Written) /= S.Len then
         raise Ada.IO_Exceptions.Device_Error;
      end if;
   end Put;

   procedure Put_Line (S : Slice) is
      use Interfaces.C_Streams;
      use UTF8;

      Written : size_t;
   begin
      if S.Ptr /= null then
         Written :=
         fwrite
            (S.Ptr.Data (S.Start .. S.Start + S.Len - 1)'Address, 1,
            size_t (S.Len), stdout);
         if Count_Type (Written) /= S.Len then
            raise Ada.IO_Exceptions.Device_Error;
         end if;
      end if;
      GNAT.IO.New_Line;
   end Put_Line;

end Typewriter.Strings.IO;
