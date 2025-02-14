with Ada.Finalization;
with Ada.Unchecked_Deallocation;
with System.Atomic_Counters;

with Typewriter.UTF8; use Typewriter;

package Typewriter.Strings is
   subtype Index_Type is UTF8.Index_Type;
   subtype Count_Type is UTF8.Count_Type;
   subtype Byte_Array is UTF8.Byte_Array;

   type Slice is tagged private with
     Constant_Indexing => Subslice, String_Literal => Literal;
   --  reference counted utf-8 string slice

   Empty : constant Slice;
   --  empty slice

   function Subslice (S : Slice; Idx_Start, Idx_End : Index_Type) return Slice;
   --  return a subslice of the given slice

   function Literal (S : Wide_Wide_String) return Slice;
   --  create a slice out of a Wide_Wide_String (to use with a string literal)

   function Length (S : Slice) return UTF8.Count_Type with
     Inline;
   --  get the length of the slice

   function Clone (S : Slice) return Slice with
     Inline;
   --  duplicate the slice, allocating a new buffer

   overriding function "=" (A, B : Slice) return Boolean;

private
   package Counter renames System.Atomic_Counters;

   type String_Data (Len : Count_Type := 0) is limited record
      Refc : Counter.Atomic_Counter;
      Data : Byte_Array (1 .. Len);
   end record;

   type String_Data_Access is access String_Data;

   procedure Free_String is new Ada.Unchecked_Deallocation
     (String_Data, String_Data_Access);

   type Slice is new Ada.Finalization.Controlled with record
      Start : Index_Type         := 1;
      Len   : Count_Type         := 0;
      Ptr   : String_Data_Access := null;
   end record with
     Type_Invariant => Ptr /= null;
     -- to be enforced after initialization

   overriding procedure Initialize (S : in out Slice) with Inline;
   overriding procedure Adjust     (S : in out Slice) with Inline;
   overriding procedure Finalize   (S : in out Slice) with Inline;

   function Length (S : Slice) return Count_Type is (S.Len);

   Empty : constant Slice :=
     (Ada.Finalization.Controlled with
      Start => 1, Len => 0, Ptr => new String_Data);

end Typewriter.Strings;
