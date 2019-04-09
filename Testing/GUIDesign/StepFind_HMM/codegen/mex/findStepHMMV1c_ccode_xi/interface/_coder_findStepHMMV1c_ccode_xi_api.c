/*
 * _coder_findStepHMMV1c_ccode_xi_api.c
 *
 * Code generation for function '_coder_findStepHMMV1c_ccode_xi_api'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "findStepHMMV1c_ccode_xi.h"
#include "_coder_findStepHMMV1c_ccode_xi_api.h"
#include "findStepHMMV1c_ccode_xi_emxutil.h"
#include "findStepHMMV1c_ccode_xi_data.h"

/* Function Declarations */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_real_T *y);
static void c_emlrt_marshallIn(const mxArray *al, const char_T *identifier,
  emxArray_real_T *y);
static void d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_real_T *y);
static void e_emlrt_marshallIn(const mxArray *lb, const char_T *identifier,
  emxArray_int32_T *y);
static void emlrt_marshallIn(const mxArray *tr, const char_T *identifier,
  emxArray_real_T *y);
static const mxArray *emlrt_marshallOut(const emxArray_real_T *u);
static void f_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_int32_T *y);
static real_T g_emlrt_marshallIn(const mxArray *sig, const char_T *identifier);
static real_T h_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId);
static void i_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_real_T *ret);
static void j_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_real_T *ret);
static void k_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_int32_T *ret);
static real_T l_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId);

/* Function Definitions */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_real_T *y)
{
  i_emlrt_marshallIn(emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static void c_emlrt_marshallIn(const mxArray *al, const char_T *identifier,
  emxArray_real_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  d_emlrt_marshallIn(emlrtAlias(al), &thisId, y);
  emlrtDestroyArray(&al);
}

static void d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_real_T *y)
{
  j_emlrt_marshallIn(emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static void e_emlrt_marshallIn(const mxArray *lb, const char_T *identifier,
  emxArray_int32_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  f_emlrt_marshallIn(emlrtAlias(lb), &thisId, y);
  emlrtDestroyArray(&lb);
}

static void emlrt_marshallIn(const mxArray *tr, const char_T *identifier,
  emxArray_real_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  b_emlrt_marshallIn(emlrtAlias(tr), &thisId, y);
  emlrtDestroyArray(&tr);
}

static const mxArray *emlrt_marshallOut(const emxArray_real_T *u)
{
  const mxArray *y;
  const mxArray *m0;
  static const int32_T iv0[2] = { 0, 0 };

  y = NULL;
  m0 = emlrtCreateNumericArray(2, iv0, mxDOUBLE_CLASS, mxREAL);
  mxSetData((mxArray *)m0, (void *)u->data);
  emlrtSetDimensions((mxArray *)m0, u->size, 2);
  emlrtAssign(&y, m0);
  return y;
}

static void f_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_int32_T *y)
{
  k_emlrt_marshallIn(emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static real_T g_emlrt_marshallIn(const mxArray *sig, const char_T *identifier)
{
  real_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = h_emlrt_marshallIn(emlrtAlias(sig), &thisId);
  emlrtDestroyArray(&sig);
  return y;
}

static real_T h_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId)
{
  real_T y;
  y = l_emlrt_marshallIn(emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void i_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_real_T *ret)
{
  static const int32_T dims[2] = { 1, -1 };

  boolean_T bv0[2] = { false, true };

  int32_T iv1[2];
  emlrtCheckVsBuiltInR2012b(emlrtRootTLSGlobal, msgId, src, "double", false, 2U,
    dims, &bv0[0], iv1);
  ret->size[0] = iv1[0];
  ret->size[1] = iv1[1];
  ret->allocatedSize = ret->size[0] * ret->size[1];
  ret->data = (real_T *)mxGetData(src);
  ret->canFreeData = false;
  emlrtDestroyArray(&src);
}

static void j_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_real_T *ret)
{
  static const int32_T dims[2] = { -1, -1 };

  boolean_T bv1[2] = { true, true };

  int32_T iv2[2];
  emlrtCheckVsBuiltInR2012b(emlrtRootTLSGlobal, msgId, src, "double", false, 2U,
    dims, &bv1[0], iv2);
  ret->size[0] = iv2[0];
  ret->size[1] = iv2[1];
  ret->allocatedSize = ret->size[0] * ret->size[1];
  ret->data = (real_T *)mxGetData(src);
  ret->canFreeData = false;
  emlrtDestroyArray(&src);
}

static void k_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_int32_T *ret)
{
  static const int32_T dims[2] = { 1, -1 };

  boolean_T bv2[2] = { false, true };

  int32_T iv3[2];
  emlrtCheckVsBuiltInR2012b(emlrtRootTLSGlobal, msgId, src, "int32", false, 2U,
    dims, &bv2[0], iv3);
  ret->size[0] = iv3[0];
  ret->size[1] = iv3[1];
  ret->allocatedSize = ret->size[0] * ret->size[1];
  ret->data = (int32_T *)mxGetData(src);
  ret->canFreeData = false;
  emlrtDestroyArray(&src);
}

static real_T l_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId)
{
  real_T ret;
  static const int32_T dims = 0;
  emlrtCheckBuiltInR2012b(emlrtRootTLSGlobal, msgId, src, "double", false, 0U,
    &dims);
  ret = *(real_T *)mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

void findStepHMMV1c_ccode_xi_api(const mxArray * const prhs[9], const mxArray
  *plhs[1])
{
  emxArray_real_T *tr;
  emxArray_real_T *al;
  emxArray_real_T *a;
  emxArray_real_T *y;
  emxArray_real_T *be;
  emxArray_int32_T *lb;
  emxArray_int32_T *ub;
  emxArray_int32_T *wid;
  emxArray_real_T *xi;
  real_T sig;
  emlrtHeapReferenceStackEnterFcnR2012b(emlrtRootTLSGlobal);
  emxInit_real_T(&tr, 2, true);
  emxInit_real_T(&al, 2, true);
  emxInit_real_T(&a, 2, true);
  emxInit_real_T(&y, 2, true);
  emxInit_real_T(&be, 2, true);
  emxInit_int32_T(&lb, 2, true);
  emxInit_int32_T(&ub, 2, true);
  emxInit_int32_T(&wid, 2, true);
  emxInit_real_T(&xi, 2, true);

  /* Marshall function inputs */
  emlrt_marshallIn(emlrtAlias(prhs[0]), "tr", tr);
  c_emlrt_marshallIn(emlrtAlias(prhs[1]), "al", al);
  emlrt_marshallIn(emlrtAlias(prhs[2]), "a", a);
  emlrt_marshallIn(emlrtAlias(prhs[3]), "y", y);
  c_emlrt_marshallIn(emlrtAlias(prhs[4]), "be", be);
  e_emlrt_marshallIn(emlrtAlias(prhs[5]), "lb", lb);
  e_emlrt_marshallIn(emlrtAlias(prhs[6]), "ub", ub);
  e_emlrt_marshallIn(emlrtAlias(prhs[7]), "wid", wid);
  sig = g_emlrt_marshallIn(emlrtAliasP(prhs[8]), "sig");

  /* Invoke the target function */
  findStepHMMV1c_ccode_xi(tr, al, a, y, be, lb, ub, wid, sig, xi);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(xi);
  xi->canFreeData = false;
  emxFree_real_T(&xi);
  wid->canFreeData = false;
  emxFree_int32_T(&wid);
  ub->canFreeData = false;
  emxFree_int32_T(&ub);
  lb->canFreeData = false;
  emxFree_int32_T(&lb);
  be->canFreeData = false;
  emxFree_real_T(&be);
  y->canFreeData = false;
  emxFree_real_T(&y);
  a->canFreeData = false;
  emxFree_real_T(&a);
  al->canFreeData = false;
  emxFree_real_T(&al);
  tr->canFreeData = false;
  emxFree_real_T(&tr);
  emlrtHeapReferenceStackLeaveFcnR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (_coder_findStepHMMV1c_ccode_xi_api.c) */
