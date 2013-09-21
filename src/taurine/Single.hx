package taurine;

#if (cs || java)
typedef Single = StdTypes.Single;
#else
typedef Single = Float;
//abstract Single(Float) from Float to Float {}
#end
