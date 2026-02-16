with Interfaces;

package Typewriter
  with Pure
is
   subtype Byte is Interfaces.Unsigned_8;
   type Byte_Array is array (Natural range <>) of aliased Byte;
end Typewriter;
