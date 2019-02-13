/*
 * meanC.c
 *
 * Code generation for function 'meanC'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "meanC.h"

/* Variable Definitions */
static emlrtRTEInfo emlrtRTEI = { 5, 1, "meanC",
  "C:\\Users\\Alexander Tong\\Box Sync\\Year 2 Semester 2\\Res\\MATLAB\\Testing\\C Codegen\\meanC.m"
};

/* Function Definitions */
real_T meanC(const emlrtStack *sp, real_T in)
{
  (void)in;

  /* MEAN Summary of this function goes here */
  /*    Detailed explanation goes here */
  emlrtErrorWithMessageIdR2012b(sp, &emlrtRTEI, "Coder:builtins:AssertionFailed",
    0);
  return 0.0;
}

/* End of code generation (meanC.c) */
