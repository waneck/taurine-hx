package taurine;

#if (cs || java)
typedef Single = StdTypes.Single;
#elseif cpp
typedef Single = cpp.Float32;
#else
typedef Single = Float;
#end
