#pragma once
#include <cstdio>
#define CHECK(expression) do { if (!(expression)) { std::fprintf(stderr,"line %d: %s\n",__LINE__,#expression); return 1; } } while (false)
