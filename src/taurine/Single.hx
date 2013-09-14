package taurine;

#if (cs || java)
typedef Single = std.Single;
#else
abstract Single(Float) from Float to Float {}
#end
