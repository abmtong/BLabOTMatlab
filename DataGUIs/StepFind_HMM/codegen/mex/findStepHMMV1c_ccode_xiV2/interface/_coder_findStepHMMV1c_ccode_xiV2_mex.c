/*
 * _coder_findStepHMMV1c_ccode_xiV2_mex.c
 *
 * Code generation for function '_coder_findStepHMMV1c_ccode_xiV2_mex'
 *
 */

/* Include files */
#include "findStepHMMV1c_ccode_xiV2.h"
#include "_coder_findStepHMMV1c_ccode_xiV2_mex.h"
#include "findStepHMMV1c_ccode_xiV2_terminate.h"
#include "_coder_findStepHMMV1c_ccode_xiV2_api.h"
#include "findStepHMMV1c_ccode_xiV2_initialize.h"
#include "findStepHMMV1c_ccode_xiV2_data.h"

/* Function Declarations */
static void c_findStepHMMV1c_ccode_xiV2_mex(int32_T nlhs, mxArray *plhs[1],
  int32_T nrhs, const mxArray *prhs[11]);

/* Function Definitions */
static void c_findStepHMMV1c_ccode_xiV2_mex(int32_T nlhs, mxArray *plhs[1],
  int32_T nrhs, const mxArray *prhs[11])
{
  int32_T n;
  const mxArray *inputs[11];
  const mxArray *outputs[1];
  int32_T b_nlhs;

  /* Check for proper number of arguments. */
  if (nrhs != 11) {
    emlrtErrMsgIdAndTxt(emlrtRootTLSGlobal, "EMLRT:runTime:WrongNumberOfInputs",
                        5, 12, 11, 4, 25, "findStepHMMV1c_ccode_xiV2");
  }

  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(emlrtRootTLSGlobal,
                        "EMLRT:runTime:TooManyOutputArguments", 3, 4, 25,
                        "findStepHMMV1c_ccode_xiV2");
  }

  /* Temporary copy for mex inputs. */
  for (n = 0; n < nrhs; n++) {
    inputs[n] = prhs[n];
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(emlrtRootTLSGlobal);
    }
  }

  /* Call the function. */
  findStepHMMV1c_ccode_xiV2_api(inputs, outputs);

  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }

  emlrtReturnArrays(b_nlhs, plhs, outputs);

  /* Module termination. */
  findStepHMMV1c_ccode_xiV2_terminate();
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(findStepHMMV1c_ccode_xiV2_atexit);

  /* Initialize the memory manager. */
  /* Module initialization. */
  findStepHMMV1c_ccode_xiV2_initialize();

  /* Dispatch the entry-point. */
  c_findStepHMMV1c_ccode_xiV2_mex(nlhs, plhs, nrhs, prhs);
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_findStepHMMV1c_ccode_xiV2_mex.c) */
