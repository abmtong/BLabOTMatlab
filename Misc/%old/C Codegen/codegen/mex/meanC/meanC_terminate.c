/*
 * meanC_terminate.c
 *
 * Code generation for function 'meanC_terminate'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "meanC.h"
#include "meanC_terminate.h"
#include "_coder_meanC_mex.h"
#include "meanC_data.h"

/* Function Definitions */
void meanC_atexit(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

void meanC_terminate(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (meanC_terminate.c) */
