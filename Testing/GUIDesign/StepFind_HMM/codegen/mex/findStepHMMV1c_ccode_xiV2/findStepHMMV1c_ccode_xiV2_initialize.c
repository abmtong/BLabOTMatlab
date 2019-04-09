/*
 * findStepHMMV1c_ccode_xiV2_initialize.c
 *
 * Code generation for function 'findStepHMMV1c_ccode_xiV2_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "findStepHMMV1c_ccode_xiV2.h"
#include "findStepHMMV1c_ccode_xiV2_initialize.h"
#include "_coder_findStepHMMV1c_ccode_xiV2_mex.h"
#include "findStepHMMV1c_ccode_xiV2_data.h"

/* Function Definitions */
void findStepHMMV1c_ccode_xiV2_initialize(void)
{
  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  emlrtClearAllocCountR2012b(emlrtRootTLSGlobal, false, 0U, 0);
  emlrtEnterRtStackR2012b(emlrtRootTLSGlobal);
  emlrtLicenseCheckR2012b(emlrtRootTLSGlobal, "Statistics_Toolbox", 2);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (findStepHMMV1c_ccode_xiV2_initialize.c) */
