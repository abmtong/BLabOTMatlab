#include "mex.h"
#include "math.h"
#include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //Usage: xi = C_xi(tr, al, be, a, sig, hei, (int) lb)
    //xi (t,i,j) = al(t, i)* a(i,j) * be(t+1,j) * P(t+1,j)
    
    //Declarations:
    //Loop variable, vector length
    int t,i,j,len,wid,hei,alen;
    //ptrs to trace, alpha, a, b, beta, out
    double *tr, *al, *a, *b, *be, *out;
    //non-pointer doubles
    double sig, tempxi, txs, xi, y;
    //Most expensive line in @findStepHMM is:
   //  tempxi = aa .* bsxfun(@times, tempal.',tempbe .* npdf2(i+1));
   //which is:
    //xi(i,j) = al(i) aij gauss(t+1) be(j) / sum(numerator over ij)
    
    len=mxGetM(prhs[0]);
    wid=mxGetN(prhs[1])/len;
    alen = mxGetNumberOfElements(prhs[3]);
    
    tr = (double *)mxGetPr(prhs[0]);
    al = (double *)mxGetPr(prhs[1]);
    a = (double *)mxGetPr(prhs[2]);
    be = (double *)mxGetPr(prhs[3]);
    sig = *mxGetPr(prhs[4]);
    hei = *mxGetPr(prhs[5]);
    lb = (int *)mxGetPr(prhs[6]);
    
    //State vector
    double y[hei];
    for(i=0, i < hei, i++){
        y[i] = (i+1) * 0.1; //hardcoded bin size
    }
    
    double xi[wid][wid];
    
    for(t=0; t<len; t++){
        double tempxi[wid][wid];
        txs = 0; //norm. factor
        b = npdf( y, wid, *(tr+t), sig);
        for(i=0; i<wid; i++){
            for(j=0; j<wid; j++){
                if(j - i >= 0) && (j - i <= alen){
                    tempxi[i][j] = *(al + i * len + t) * *(*(a+t) + a+j-i) * *(*(a+t+1) + b+t) * *(*(a+t+1) + be + j * len + t);
                    txs += tempxi[i][j];
                }
            }
        }
        xi += tempxi/txs;
    }
    plhs[0] = mxCreateDoubleMatrix(wid, wid, mxREAL);
    memcpy(mxGetPr(plhs[0]), xi, wid * wid * sizeof(double)) ;
    free(xi);
    free(tempxi);
}

double[] function npdf(double* y, int len, double mu, double sig){
    int out[len];
    double val, var;
    var = sig * sig;
    for(i=0; i<len; i++){
        val = mu - *(y+i);
        out[i] = exp( -val * val / 2 / var);
    }
    return out;
}