with Ada.Finalization;
with Ada.Unchecked_Deallocation;
with System.Atomic_Counters;

with Typewriter.UTF8;

package Typewriter.Strings is
   type Slice is tagged limited private with
     String_Literal => Lit;
   --  reference counted utf-8 string slice

   Empty : constant Slice;
   --  empty slice

   function Lit (S : Wide_Wide_String) return Slice;
   --  create a slice out of a Wide_Wide_String (to use with a string literal)

   function Clone (S : Slice) return Slice;
   --  increment the reference count, returning a new copy of the slice
   function Move (S : in out Slice) return Slice;
   --  move out of the slice, replacing the original with the empty slice
   procedure Assign (S : in out Slice; Other : Slice);
   --  assign a new value to this string slice

private
   package Counter renames System.Atomic_Counters;
   package UTF8 renames Typewriter.UTF8;

   subtype Count_Type is UTF8.Count_Type;
   subtype Byte_Array is UTF8.Byte_Array;

   type String_Data (Len : Count_Type := 0) is limited record
      Refc : Counter.Atomic_Counter;
      Data : Byte_Array (1 .. Len);
   end record;

   type String_Data_Access is access String_Data;

   procedure Free_String is new Ada.Unchecked_Deallocation
     (String_Data, String_Data_Access);

   type Slice is new Ada.Finalization.Limited_Controlled with record
      Ptr : String_Data_Access;
   end record;

   overriding procedure Initialize (S : in out Slice);
   overriding procedure Finalize (S : in out Slice);

   Empty : constant Slice :=
     (Ada.Finalization.Limited_Controlled with Ptr => new String_Data);

end Typewriter.Strings;
