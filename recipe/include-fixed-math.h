#ifndef __MATH_H__

#if __FLT_EVAL_METHOD__ == 16
#undef __FLT_EVAL_METHOD__
#define __FLT_EVAL_METHOD__ 1
#include_next <math.h>
#undef __FLT_EVAL_METHOD__
#define __FLT_EVAL_METHOD__ 16
#else
#include_next <math.h>
#endif
#endif
