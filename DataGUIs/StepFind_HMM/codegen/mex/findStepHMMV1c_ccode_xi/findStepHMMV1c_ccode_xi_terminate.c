/*
 * findStepHMMV1c_ccode_xi_terminate.c
 *
 * Code generation for function 'findStepHMMV1c_ccode_xi_terminate'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "findStepHMMV1c_ccode_xi.h"
#include "findStepHMMV1c_ccode_xi_terminate.h"
#include "_coder_findStepHMMV1c_ccode_xi_mex.h"
#include "findStepHMMV1c_ccode_xi_data.h"

/* Function Definitions */
void findStepHMMV1c_ccode_xi_atexit(void)
{
  mexFunctionCreateRootTLS();
  emlrtEnterRtStackR2012b(emlrtRootTLSGlobal);
  emlrtLeaveRtStackR2012b(emlrtRootTLSGlobal);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

void findStepHMMV1c_ccode_xi_terminate(void)
{
  emlrtLeaveRtStackR2012b(emlrtRootTLSGlobal);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (findStepHMMV1c_ccode_xi_terminate.c) */
