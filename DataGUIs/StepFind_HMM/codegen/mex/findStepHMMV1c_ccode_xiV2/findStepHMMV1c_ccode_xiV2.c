/*
 * findStepHMMV1c_ccode_xiV2.c
 *
 * Code generation for function 'findStepHMMV1c_ccode_xiV2'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "findStepHMMV1c_ccode_xiV2.h"
#include "findStepHMMV1c_ccode_xiV2_emxutil.h"
#include "findStepHMMV1c_ccode_xiV2_data.h"

/* Function Definitions */

/*
 * function xi = findStepHMMV1c_ccode_xiV2(tr, al, a, y, be, lb, ub, wid, lb2, maxwid2, sig)
 */
void findStepHMMV1c_ccode_xiV2(const emxArray_real_T *tr, const emxArray_real_T *
  al, const emxArray_real_T *a, const emxArray_real_T *y, const emxArray_real_T *
  be, const emxArray_int32_T *lb, const emxArray_int32_T *ub, const
  emxArray_int32_T *wid, const emxArray_int32_T *lb2, int32_T maxwid2, real_T
  sig, emxArray_real_T *xi)
{
  int32_T varargin_2;
  int32_T i0;
  int32_T k;
  int32_T t;
  emxArray_real_T *tempb;
  emxArray_real_T *tempxi;
  emxArray_real_T *ztemp;
  emxArray_real_T *b_ztemp;
  int32_T b_xi;
  real_T b_t;
  int32_T i;
  int32_T j;
  int32_T ind;
  int32_T indi;
  int32_T indj;
  emlrtHeapReferenceStackEnterFcnR2012b(emlrtRootTLSGlobal);

  /* declare output */
  /* 'findStepHMMV1c_ccode_xiV2:4' len = length(tr); */
  /* 'findStepHMMV1c_ccode_xiV2:5' lena = length(a); */
  varargin_2 = a->size[1];

  /*  hei = length(y); */
  /* 'findStepHMMV1c_ccode_xiV2:8' xi = zeros(1, lena); */
  i0 = xi->size[0] * xi->size[1];
  xi->size[0] = 1;
  xi->size[1] = a->size[1];
  emxEnsureCapacity((emxArray__common *)xi, i0, (int32_T)sizeof(real_T));
  k = a->size[1];
  for (i0 = 0; i0 < k; i0++) {
    xi->data[i0] = 0.0;
  }

  /*  tempal = zeros(1,maxwid2); */
  /*  tempbe = zeros(1,maxwid2); */
  /* 'findStepHMMV1c_ccode_xiV2:11' for t = 1:len-1 */
  t = 0;
  emxInit_real_T(&tempb, 2, true);
  emxInit_real_T(&tempxi, 2, true);
  emxInit_real_T(&ztemp, 2, true);
  emxInit_real_T(&b_ztemp, 2, true);
  while (t <= tr->size[1] - 2) {
    /* alpha, beta */
    /*      tempal = 0*tempal; */
    /*      tempal(lb(t)-lb2(t)+1:ub(t)-lb2(t)+1) = al(t,1:wid(t)); */
    /*      tempbe = 0*tempbe; */
    /* 'findStepHMMV1c_ccode_xiV2:16' tempb = normpdf(y(lb(t+1):ub(t+1)), tr(t+1), sig); */
    if (lb->data[t + 1] > ub->data[t + 1]) {
      i0 = 1;
      k = 1;
    } else {
      i0 = lb->data[t + 1];
      k = ub->data[t + 1] + 1;
    }

    b_xi = ztemp->size[0] * ztemp->size[1];
    ztemp->size[0] = 1;
    ztemp->size[1] = k - i0;
    emxEnsureCapacity((emxArray__common *)ztemp, b_xi, (int32_T)sizeof(real_T));
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
        b_t = (y->data[(i0 + k) - 1] - tr->data[t + 1]) / sig;
        tempb->data[k] = muDoubleScalarExp(-0.5 * b_t * b_t) /
          (2.5066282746310002 * sig);
      } else {
        tempb->data[k] = rtNaN;
      }
    }

    /*      tempbe(lb(t+1)-lb2(t)+1:ub(t+1)-lb2(t)+1) = be(t+1,1:wid(t+1)); */
    /* 'findStepHMMV1c_ccode_xiV2:18' tempxi = zeros(1,lena); */
    i0 = tempxi->size[0] * tempxi->size[1];
    tempxi->size[0] = 1;
    tempxi->size[1] = varargin_2;
    emxEnsureCapacity((emxArray__common *)tempxi, i0, (int32_T)sizeof(real_T));
    for (i0 = 0; i0 < varargin_2; i0++) {
      tempxi->data[i0] = 0.0;
    }

    /* 'findStepHMMV1c_ccode_xiV2:19' for i = 1:maxwid2 */
    i = 1;
    while (i <= maxwid2) {
      /* 'findStepHMMV1c_ccode_xiV2:20' for j = 1:maxwid2 */
      j = 1;
      while (j <= maxwid2) {
        /* 'findStepHMMV1c_ccode_xiV2:21' ind = j - i + 1; */
        ind = (j - i) + 1;

        /* 'findStepHMMV1c_ccode_xiV2:22' if ind > 0 && ind <= lena */
        if ((ind > 0) && (ind <= varargin_2)) {
          /* check if i is in bounds */
          /* 'findStepHMMV1c_ccode_xiV2:24' indi = lb(t)-lb2(t)+i; */
          indi = (lb->data[t] - lb2->data[t]) + i;

          /* 'findStepHMMV1c_ccode_xiV2:25' if indi >= 1 && indi <= wid(t) */
          if ((indi >= 1) && (indi <= wid->data[t])) {
            /* check if j is in bounds */
            /* 'findStepHMMV1c_ccode_xiV2:27' indj = lb(t+1)-lb2(t) + j; */
            indj = (lb->data[t + 1] - lb2->data[t]) + j;

            /* 'findStepHMMV1c_ccode_xiV2:28' if indj >= 1 && indj <= wid(t+1) */
            if ((indj >= 1) && (indj <= wid->data[t + 1])) {
              /* tempxi(ind) = tempxi(ind) + tempal(i) * a(ind) * tempb(j) * tempbe(j); */
              /* 'findStepHMMV1c_ccode_xiV2:30' tempxi(ind) = tempxi(ind) + al(t, indi) * a(ind) * tempb(indj) * be(t, indj); */
              tempxi->data[ind - 1] += al->data[t + al->size[0] * (indi - 1)] *
                a->data[ind - 1] * tempb->data[indj - 1] * be->data[t + be->
                size[0] * (indj - 1)];
            }
          }
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

    /* 'findStepHMMV1c_ccode_xiV2:36' xi = xi + tempxi / sum(tempxi); */
    if (tempxi->size[1] == 0) {
      b_t = 0.0;
    } else {
      b_t = tempxi->data[0];
      for (k = 2; k <= tempxi->size[1]; k++) {
        b_t += tempxi->data[k - 1];
      }
    }

    i0 = xi->size[0] * xi->size[1];
    xi->size[0] = 1;
    emxEnsureCapacity((emxArray__common *)xi, i0, (int32_T)sizeof(real_T));
    k = xi->size[0];
    b_xi = xi->size[1];
    k *= b_xi;
    for (i0 = 0; i0 < k; i0++) {
      xi->data[i0] += tempxi->data[i0] / b_t;
    }

    /*      %temp sum vector */
    /*      txi = zeros(wid); */
    /*      %calc npdf */
    /*      for i = 1:wid */
    /*          dw = lb(i+1)-lb(i); */
    /*          for j = 1:wid */
    /*              %check if a is in frame */
    /*              if j - i > 0 && j - i <= lena */
    /*                  %check if b is in frame w.r.t. a */
    /*                  jn = dw + i - j; */
    /*                  if dw + i - j >= 0 */
    /*                      %check if b is not out of width */
    /*  */
    /*                      txi(i,j) = al(t, i) * a(j+dw-i) * b(j+dw+lb(t+1)-1) * be(t+1, j+dw); */
    /*                  end */
    /*              end */
    /*          end */
    /*      end */
    /*  %     txi = txi / sum(txi); */
    /*      xi = xi + txi/sum(txi(:)); */
    t++;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(emlrtRootTLSGlobal);
    }
  }

  emxFree_real_T(&b_ztemp);
  emxFree_real_T(&ztemp);
  emxFree_real_T(&tempxi);
  emxFree_real_T(&tempb);
  emlrtHeapReferenceStackLeaveFcnR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (findStepHMMV1c_ccode_xiV2.c) */
