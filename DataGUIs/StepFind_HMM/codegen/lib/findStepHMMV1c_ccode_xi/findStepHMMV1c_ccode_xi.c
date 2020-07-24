/*
 * File: findStepHMMV1c_ccode_xi.c
 *
 * MATLAB Coder version            : 3.1
 * C/C++ source code generated on  : 28-Mar-2019 14:32:46
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "findStepHMMV1c_ccode_xi.h"
#include "findStepHMMV1c_ccode_xi_emxutil.h"

/* Function Definitions */

/*
 * declare output
 * Arguments    : const emxArray_real_T *tr
 *                const emxArray_real_T *al
 *                const emxArray_real_T *a
 *                const emxArray_real_T *y
 *                const emxArray_real_T *be
 *                const emxArray_real_T *lb
 *                const emxArray_real_T *ub
 *                const emxArray_real_T *wid
 *                double sig
 *                emxArray_real_T *xi
 * Return Type  : void
 */
void findStepHMMV1c_ccode_xi(const emxArray_real_T *tr, const emxArray_real_T
  *al, const emxArray_real_T *a, const emxArray_real_T *y, const emxArray_real_T
  *be, const emxArray_real_T *lb, const emxArray_real_T *ub, const
  emxArray_real_T *wid, double sig, emxArray_real_T *xi)
{
  int varargin_2;
  int b_varargin_2;
  int b_xi;
  int k;
  int t;
  emxArray_real_T *tempal;
  emxArray_real_T *tempbe;
  emxArray_real_T *tempb;
  emxArray_real_T *tempxi;
  emxArray_real_T *ztemp;
  emxArray_real_T *b_ztemp;
  int i0;
  double b_t;
  int i;
  double b_i;
  int j;
  double b_j;
  double ind;
  varargin_2 = a->size[1];
  b_varargin_2 = y->size[1];
  b_xi = xi->size[0] * xi->size[1];
  xi->size[0] = 1;
  xi->size[1] = a->size[1];
  emxEnsureCapacity((emxArray__common *)xi, b_xi, (int)sizeof(double));
  k = a->size[1];
  for (b_xi = 0; b_xi < k; b_xi++) {
    xi->data[b_xi] = 0.0;
  }

  t = 0;
  emxInit_real_T(&tempal, 2);
  emxInit_real_T(&tempbe, 2);
  emxInit_real_T(&tempb, 2);
  emxInit_real_T(&tempxi, 2);
  emxInit_real_T(&ztemp, 2);
  emxInit_real_T(&b_ztemp, 2);
  while (t <= tr->size[1] - 2) {
    /* extract full alpha, beta, as sparse */
    b_xi = tempal->size[0] * tempal->size[1];
    tempal->size[0] = 1;
    tempal->size[1] = b_varargin_2;
    emxEnsureCapacity((emxArray__common *)tempal, b_xi, (int)sizeof(double));
    for (b_xi = 0; b_xi < b_varargin_2; b_xi++) {
      tempal->data[b_xi] = 0.0;
    }

    if (1.0 > wid->data[t]) {
      k = -1;
    } else {
      k = (int)wid->data[t] - 1;
    }

    if (lb->data[t] > ub->data[t]) {
      b_xi = 0;
    } else {
      b_xi = (int)lb->data[t] - 1;
    }

    for (i0 = 0; i0 <= k; i0++) {
      tempal->data[b_xi + i0] = al->data[t + al->size[0] * i0];
    }

    b_xi = tempbe->size[0] * tempbe->size[1];
    tempbe->size[0] = 1;
    tempbe->size[1] = b_varargin_2;
    emxEnsureCapacity((emxArray__common *)tempbe, b_xi, (int)sizeof(double));
    for (b_xi = 0; b_xi < b_varargin_2; b_xi++) {
      tempbe->data[b_xi] = 0.0;
    }

    b_xi = ztemp->size[0] * ztemp->size[1];
    ztemp->size[0] = 1;
    ztemp->size[1] = y->size[1];
    emxEnsureCapacity((emxArray__common *)ztemp, b_xi, (int)sizeof(double));
    b_xi = b_ztemp->size[0] * b_ztemp->size[1];
    b_ztemp->size[0] = 1;
    b_ztemp->size[1] = ztemp->size[1];
    emxEnsureCapacity((emxArray__common *)b_ztemp, b_xi, (int)sizeof(double));
    b_xi = tempb->size[0] * tempb->size[1];
    tempb->size[0] = 1;
    tempb->size[1] = ztemp->size[1];
    emxEnsureCapacity((emxArray__common *)tempb, b_xi, (int)sizeof(double));
    for (k = 0; k < b_ztemp->size[1]; k++) {
      if (sig > 0.0) {
        b_t = (y->data[k] - tr->data[t + 1]) / sig;
        tempb->data[k] = exp(-0.5 * b_t * b_t) / (2.5066282746310002 * sig);
      } else {
        tempb->data[k] = rtNaN;
      }
    }

    if (1.0 > wid->data[t + 1]) {
      k = -1;
    } else {
      k = (int)wid->data[t + 1] - 1;
    }

    if (lb->data[t + 1] > ub->data[t + 1]) {
      b_xi = 0;
    } else {
      b_xi = (int)lb->data[t + 1] - 1;
    }

    for (i0 = 0; i0 <= k; i0++) {
      tempbe->data[b_xi + i0] = be->data[(t + be->size[0] * i0) + 1];
    }

    b_xi = tempxi->size[0] * tempxi->size[1];
    tempxi->size[0] = 1;
    tempxi->size[1] = varargin_2;
    emxEnsureCapacity((emxArray__common *)tempxi, b_xi, (int)sizeof(double));
    for (b_xi = 0; b_xi < varargin_2; b_xi++) {
      tempxi->data[b_xi] = 0.0;
    }

    b_xi = (int)(ub->data[t] + (1.0 - lb->data[t]));
    for (i = 0; i < b_xi; i++) {
      b_i = lb->data[t] + (double)i;
      i0 = (int)(ub->data[t + 1] + (1.0 - lb->data[t + 1]));
      for (j = 0; j < i0; j++) {
        b_j = lb->data[t + 1] + (double)j;
        ind = (b_j - b_i) + 1.0;
        if ((ind > 0.0) && (ind <= varargin_2)) {
          tempxi->data[(int)ind - 1] += tempal->data[(int)b_i - 1] * a->data
            [(int)ind - 1] * tempb->data[(int)b_j - 1] * tempbe->data[(int)b_j -
            1];
        }
      }
    }

    if (tempxi->size[1] == 0) {
      b_t = 0.0;
    } else {
      b_t = tempxi->data[0];
      for (k = 2; k <= tempxi->size[1]; k++) {
        b_t += tempxi->data[k - 1];
      }
    }

    b_xi = xi->size[0] * xi->size[1];
    xi->size[0] = 1;
    emxEnsureCapacity((emxArray__common *)xi, b_xi, (int)sizeof(double));
    k = xi->size[0];
    b_xi = xi->size[1];
    k *= b_xi;
    for (b_xi = 0; b_xi < k; b_xi++) {
      xi->data[b_xi] += tempxi->data[b_xi] / b_t;
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
  }

  emxFree_real_T(&b_ztemp);
  emxFree_real_T(&ztemp);
  emxFree_real_T(&tempxi);
  emxFree_real_T(&tempb);
  emxFree_real_T(&tempbe);
  emxFree_real_T(&tempal);
}

/*
 * File trailer for findStepHMMV1c_ccode_xi.c
 *
 * [EOF]
 */
