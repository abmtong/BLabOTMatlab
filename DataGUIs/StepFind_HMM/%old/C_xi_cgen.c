/*
 * findStepHMMV1c_ccode_xi.c
 *
 * Code generation for function 'findStepHMMV1c_ccode_xi'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "findStepHMMV1c_ccode_xi.h"
#include "findStepHMMV1c_ccode_xi_emxutil.h"
#include "findStepHMMV1c_ccode_xi_data.h"

/* Function Definitions */
void findStepHMMV1c_ccode_xi(const emxArray_real_T *tr, const emxArray_real_T
  *al, const emxArray_real_T *a, const emxArray_real_T *y, const emxArray_real_T
  *be, const emxArray_int32_T *lb, const emxArray_int32_T *ub, const
  emxArray_int32_T *wid, real_T sig, emxArray_real_T *xi)
{
  int32_T varargin_2;
  int32_T k;
  int32_T loop_ub;
  emxArray_real_T *tempal;
  emxArray_real_T *tempbe;
  int32_T t;
  emxArray_real_T *tempb;
  emxArray_real_T *tempxi;
  emxArray_real_T *ztemp;
  emxArray_real_T *b_ztemp;
  int32_T i0;
  real_T b_t;
  int32_T i;
  int32_T j;
  int32_T ind;
  emlrtHeapReferenceStackEnterFcnR2012b(emlrtRootTLSGlobal);

  /* len = length(tr): since len is only used once this is placed in for i = ... */
  
  /* lena = length(a) */
  varargin_2 = a->size[1];

  /* hei = length(y) */
  /*  xi = zeros(1, lena); */
  k = xi->size[0] * xi->size[1];
  xi->size[0] = 1;
  xi->size[1] = a->size[1];
  //
  emxEnsureCapacity((emxArray__common *)xi, k, (int32_T)sizeof(real_T));
  loop_ub = a->size[1];
  for (k = 0; k < loop_ub; k++) {
    xi->data[k] = 0.0;
  }

  emxInit_real_T(&tempal, 2, true);

  /*  tempal = zeros(1,hei); */
  k = tempal->size[0] * tempal->size[1];
  tempal->size[0] = 1;
  tempal->size[1] = y->size[1];
  emxEnsureCapacity((emxArray__common *)tempal, k, (int32_T)sizeof(real_T));
  loop_ub = y->size[1];
  for (k = 0; k < loop_ub; k++) {
    tempal->data[k] = 0.0;
  }

  emxInit_real_T(&tempbe, 2, true);

  /*  tempbe = zeros(1,hei); */
  k = tempbe->size[0] * tempbe->size[1];
  tempbe->size[0] = 1;
  tempbe->size[1] = y->size[1];
  emxEnsureCapacity((emxArray__common *)tempbe, k, (int32_T)sizeof(real_T));
  loop_ub = y->size[1];
  for (k = 0; k < loop_ub; k++) {
    tempbe->data[k] = 0.0;
  }

  /*  for t = 1:len-1 */
  t = 0;
  emxInit_real_T(&tempb, 2, true);
  emxInit_real_T(&tempxi, 2, true);
  emxInit_real_T(&ztemp, 2, true);
  emxInit_real_T(&b_ztemp, 2, true);
  while (t <= tr->size[1] - 2) {
    /* extract full alpha */
    k = tempal->size[0] * tempal->size[1];
    tempal->size[0] = 1;
    emxEnsureCapacity((emxArray__common *)tempal, k, (int32_T)sizeof(real_T));
    k = tempal->size[0];
    loop_ub = tempal->size[1];
    loop_ub *= k;
    for (k = 0; k < loop_ub; k++) {
      tempal->data[k] *= 0.0;
    }

    if (1 > wid->data[t]) {
      loop_ub = -1;
    } else {
      loop_ub = wid->data[t] - 1;
    }

    if (lb->data[t] > ub->data[t]) {
      k = 0;
    } else {
      k = lb->data[t] - 1;
    }

    for (i0 = 0; i0 <= loop_ub; i0++) {
      tempal->data[k + i0] = al->data[t + al->size[0] * i0];
    }

    /* extract full beta */
    k = tempbe->size[0] * tempbe->size[1];
    tempbe->size[0] = 1;
    emxEnsureCapacity((emxArray__common *)tempbe, k, (int32_T)sizeof(real_T));
    k = tempbe->size[0];
    loop_ub = tempbe->size[1];
    loop_ub *= k;
    for (k = 0; k < loop_ub; k++) {
      tempbe->data[k] *= 0.0;
    }

    if (1 > wid->data[t + 1]) {
      loop_ub = -1;
    } else {
      loop_ub = wid->data[t + 1] - 1;
    }

    if (lb->data[t + 1] > ub->data[t + 1]) {
      k = 0;
    } else {
      k = lb->data[t + 1] - 1;
    }

    for (i0 = 0; i0 <= loop_ub; i0++) {
      tempbe->data[k + i0] = be->data[(t + be->size[0] * i0) + 1];
    }

    /* make full b */
    k = ztemp->size[0] * ztemp->size[1];
    ztemp->size[0] = 1;
    ztemp->size[1] = y->size[1];
    emxEnsureCapacity((emxArray__common *)ztemp, k, (int32_T)sizeof(real_T));
    k = b_ztemp->size[0] * b_ztemp->size[1];
    b_ztemp->size[0] = 1;
    b_ztemp->size[1] = ztemp->size[1];
    emxEnsureCapacity((emxArray__common *)b_ztemp, k, (int32_T)sizeof(real_T));
    k = tempb->size[0] * tempb->size[1];
    tempb->size[0] = 1;
    tempb->size[1] = ztemp->size[1];
    emxEnsureCapacity((emxArray__common *)tempb, k, (int32_T)sizeof(real_T));
    for (k = 0; k < b_ztemp->size[1]; k++) {
      if (sig > 0.0) {
        b_t = (y->data[k] - tr->data[t + 1]) / sig;
        tempb->data[k] = muDoubleScalarExp(-0.5 * b_t * b_t) /
          (2.5066282746310002 * sig);
      } else {
        tempb->data[k] = rtNaN;
      }
    }

    /* make tempxi */
    k = tempxi->size[0] * tempxi->size[1];
    tempxi->size[0] = 1;
    tempxi->size[1] = varargin_2;
    emxEnsureCapacity((emxArray__common *)tempxi, k, (int32_T)sizeof(real_T));
    for (k = 0; k < varargin_2; k++) {
      tempxi->data[k] = 0.0;
    }

    /* for i = lb(t):ub(t) */
    i = lb->data[t];
    while (i <= ub->data[t]) {
      /*          for j = lb(t+1):ub(t+1) */
      j = lb->data[t + 1];
      while (j <= ub->data[t + 1]) {
        ind = (j - i) + 1;
        if ((ind > 0) && (ind <= varargin_2)) {
          tempxi->data[ind - 1] += tempal->data[i - 1] * a->data[ind - 1] *
            tempb->data[j - 1] * tempbe->data[j - 1];
        }

        j++;
        if (*emlrtBreakCheckR2012bFlagVar != 0) {
          emlrtBreakCheckR2012b(emlrtRootTLSGlobal);
        }
      }

      i++;
      if (*emlrtBreakCheckR2012bFlagVar != 0) {
        emlrtBreakCheckR2012b(emlrtRootTLSGlobal);
      }
    }

    /*      xi = xi + tempxi / sum(tempxi); */
    if (tempxi->size[1] == 0) {
      b_t = 0.0;
    } else {
      b_t = tempxi->data[0];
      for (k = 2; k <= tempxi->size[1]; k++) {
        b_t += tempxi->data[k - 1];
      }
    }

    k = xi->size[0] * xi->size[1];
    xi->size[0] = 1;
    emxEnsureCapacity((emxArray__common *)xi, k, (int32_T)sizeof(real_T));
    k = xi->size[0];
    loop_ub = xi->size[1];
    loop_ub *= k;
    for (k = 0; k < loop_ub; k++) {
      xi->data[k] += tempxi->data[k] / b_t;
    }

    t++;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(emlrtRootTLSGlobal);
    }
  }

  emxFree_real_T(&b_ztemp);
  emxFree_real_T(&ztemp);
  emxFree_real_T(&tempxi);
  emxFree_real_T(&tempb);
  emxFree_real_T(&tempbe);
  emxFree_real_T(&tempal);
  emlrtHeapReferenceStackLeaveFcnR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (findStepHMMV1c_ccode_xi.c) */
