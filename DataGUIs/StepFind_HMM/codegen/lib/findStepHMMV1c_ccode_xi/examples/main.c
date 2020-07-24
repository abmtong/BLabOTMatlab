/*
 * File: main.c
 *
 * MATLAB Coder version            : 3.1
 * C/C++ source code generated on  : 28-Mar-2019 14:32:46
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/
/* Include Files */
#include "rt_nonfinite.h"
#include "findStepHMMV1c_ccode_xi.h"
#include "main.h"
#include "findStepHMMV1c_ccode_xi_terminate.h"
#include "findStepHMMV1c_ccode_xi_emxAPI.h"
#include "findStepHMMV1c_ccode_xi_initialize.h"

/* Function Declarations */
static emxArray_real_T *argInit_1xUnbounded_real_T(void);
static double argInit_real_T(void);
static emxArray_real_T *c_argInit_UnboundedxUnbounded_r(void);
static void main_findStepHMMV1c_ccode_xi(void);

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : emxArray_real_T *
 */
static emxArray_real_T *argInit_1xUnbounded_real_T(void)
{
  emxArray_real_T *result;
  static int iv0[2] = { 1, 2 };

  int idx1;

  /* Set the size of the array.
     Change this size to the value that the application requires. */
  result = emxCreateND_real_T(2, iv0);

  /* Loop over the array to initialize each element. */
  for (idx1 = 0; idx1 < result->size[1U]; idx1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result->data[result->size[0] * idx1] = argInit_real_T();
  }

  return result;
}

/*
 * Arguments    : void
 * Return Type  : double
 */
static double argInit_real_T(void)
{
  return 0.0;
}

/*
 * Arguments    : void
 * Return Type  : emxArray_real_T *
 */
static emxArray_real_T *c_argInit_UnboundedxUnbounded_r(void)
{
  emxArray_real_T *result;
  static int iv1[2] = { 2, 2 };

  int idx0;
  int idx1;

  /* Set the size of the array.
     Change this size to the value that the application requires. */
  result = emxCreateND_real_T(2, iv1);

  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < result->size[0U]; idx0++) {
    for (idx1 = 0; idx1 < result->size[1U]; idx1++) {
      /* Set the value of the array element.
         Change this value to the value that the application requires. */
      result->data[idx0 + result->size[0] * idx1] = argInit_real_T();
    }
  }

  return result;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void main_findStepHMMV1c_ccode_xi(void)
{
  emxArray_real_T *xi;
  emxArray_real_T *tr;
  emxArray_real_T *al;
  emxArray_real_T *a;
  emxArray_real_T *y;
  emxArray_real_T *be;
  emxArray_real_T *lb;
  emxArray_real_T *ub;
  emxArray_real_T *wid;
  emxInitArray_real_T(&xi, 2);

  /* Initialize function 'findStepHMMV1c_ccode_xi' input arguments. */
  /* Initialize function input argument 'tr'. */
  tr = argInit_1xUnbounded_real_T();

  /* Initialize function input argument 'al'. */
  al = c_argInit_UnboundedxUnbounded_r();

  /* Initialize function input argument 'a'. */
  a = argInit_1xUnbounded_real_T();

  /* Initialize function input argument 'y'. */
  y = argInit_1xUnbounded_real_T();

  /* Initialize function input argument 'be'. */
  be = c_argInit_UnboundedxUnbounded_r();

  /* Initialize function input argument 'lb'. */
  lb = argInit_1xUnbounded_real_T();

  /* Initialize function input argument 'ub'. */
  ub = argInit_1xUnbounded_real_T();

  /* Initialize function input argument 'wid'. */
  wid = argInit_1xUnbounded_real_T();

  /* Call the entry-point 'findStepHMMV1c_ccode_xi'. */
  findStepHMMV1c_ccode_xi(tr, al, a, y, be, lb, ub, wid, argInit_real_T(), xi);
  emxDestroyArray_real_T(xi);
  emxDestroyArray_real_T(wid);
  emxDestroyArray_real_T(ub);
  emxDestroyArray_real_T(lb);
  emxDestroyArray_real_T(be);
  emxDestroyArray_real_T(y);
  emxDestroyArray_real_T(a);
  emxDestroyArray_real_T(al);
  emxDestroyArray_real_T(tr);
}

/*
 * Arguments    : int argc
 *                const char * const argv[]
 * Return Type  : int
 */
int main(int argc, const char * const argv[])
{
  (void)argc;
  (void)argv;

  /* Initialize the application.
     You do not need to do this more than one time. */
  findStepHMMV1c_ccode_xi_initialize();

  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
  main_findStepHMMV1c_ccode_xi();

  /* Terminate the application.
     You do not need to do this more than one time. */
  findStepHMMV1c_ccode_xi_terminate();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
