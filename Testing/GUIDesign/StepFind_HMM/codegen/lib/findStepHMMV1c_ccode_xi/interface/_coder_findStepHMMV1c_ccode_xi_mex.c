/*
 * File: _coder_findStepHMMV1c_ccode_xi_mex.c
 *
 * MATLAB Coder version            : 3.1
 * C/C++ source code generated on  : 28-Mar-2019 14:32:46
 */

/* Include Files */
#include "_coder_findStepHMMV1c_ccode_xi_api.h"
#include "_coder_findStepHMMV1c_ccode_xi_mex.h"

/* Function Declarations */
static void c_findStepHMMV1c_ccode_xi_mexFu(int32_T nlhs, mxArray *plhs[1],
  int32_T nrhs, const mxArray *prhs[9]);

/* Function Definitions */

/*
 * Arguments    : int32_T nlhs
 *                const mxArray *plhs[1]
 *                int32_T nrhs
 *                const mxArray *prhs[9]
 * Return Type  : void
 */
static void c_findStepHMMV1c_ccode_xi_mexFu(int32_T nlhs, mxArray *plhs[1],
  int32_T nrhs, const mxArray *prhs[9])
{
  int32_T n;
  const mxArray *inputs[9];
  const mxArray *outputs[1];
  int32_T b_nlhs;
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 9) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 9, 4,
                        23, "findStepHMMV1c_ccode_xi");
  }

  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 23,
                        "findStepHMMV1c_ccode_xi");
  }

  /* Temporary copy for mex inputs. */
  for (n = 0; n < nrhs; n++) {
    inputs[n] = prhs[n];
  }

  /* Call the function. */
  findStepHMMV1c_ccode_xi_api(inputs, outputs);

  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }

  emlrtReturnArrays(b_nlhs, plhs, outputs);

  /* Module termination. */
  findStepHMMV1c_ccode_xi_terminate();
}

/*
 * Arguments    : int32_T nlhs
 *                const mxArray * const plhs[]
 *                int32_T nrhs
 *                const mxArray * const prhs[]
 * Return Type  : void
 */
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(findStepHMMV1c_ccode_xi_atexit);

  /* Initialize the memory manager. */
  /* Module initialization. */
  findStepHMMV1c_ccode_xi_initialize();

  /* Dispatch the entry-point. */
  c_findStepHMMV1c_ccode_xi_mexFu(nlhs, plhs, nrhs, prhs);
}

/*
 * Arguments    : void
 * Return Type  : emlrtCTX
 */
emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/*
 * File trailer for _coder_findStepHMMV1c_ccode_xi_mex.c
 *
 * [EOF]
 */
