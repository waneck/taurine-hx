package taurine;

#if (cs || java)
typedef Single = std.Single;
#else
typedef Single = Float;
//abstract Single(Float) from Float to Float {}
#end
