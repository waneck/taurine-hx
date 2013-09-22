package taurine.mem;

/**
	A class that implements taurine.mem.Struct will automatically be built-in with support for array of structs
	and stack-allocation modes - to be used with taurine.mem.StructArray and taurine.mem.StackAlloc

	Any use of the implementing class that does not use StructArray and StackAlloc will behave exactly like
	a normal class.
	This interface is only a shortcut to the metadata @:build( taurine.mem.StructBuild.build() ) - and there is no difference
	in calling @:build directly
**/
@:autoBuild(taurine.mem.StructBuild.build())
interface Struct
{
}
