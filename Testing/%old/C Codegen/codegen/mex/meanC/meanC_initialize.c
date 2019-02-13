/*
 * meanC_initialize.c
 *
 * Code generation for function 'meanC_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "meanC.h"
#include "meanC_initialize.h"
#include "_coder_meanC_mex.h"
#include "meanC_data.h"

/* Function Definitions */
void meanC_initialize(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (meanC_initialize.c) */
