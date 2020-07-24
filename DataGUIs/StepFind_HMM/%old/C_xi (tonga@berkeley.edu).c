#include "mex.h"
#include "math.h"
#include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //Usage: xi = C_xi(tr, al, be, a, sig)
    //xi (t,i,j) = al(t, i)* a(i,j) * be(t+1,j) * P(t+1,j)
    
    //Declarations:
    //Loop variable, vector length
    int t,i,j,len,wid,alen;
    //ptrs to trace, alpha, a, b, beta, out
    double *tr, *al, *a, *b, *be, *out;
    //non-pointer doubles
    double sig, txs;
    //Most expensive line in @findStepHMM is:
   //  tempxi = aa .* bsxfun(@times, tempal.',tempbe .* npdf2(i+1));
   //which is:
    //xi(i,j) = al(i) aij gauss(t+1) be(j) / sum(numerator over ij)
    
    len=mxGetNumberOfElements(prhs[0]);
    wid=mxGetNumberOfElements(prhs[1])/len;
    alen = mxGetNumberOfElements(prhs[3]);
    
    tr = (double *)mxGetPr(prhs[0]);
    al = (double *)mxGetPr(prhs[1]);
    a = (double *)mxGetPr(prhs[2]);
    be = (double *)mxGetPr(prhs[3]);
    sig = *mxGetPr(prhs[4]);
    
    //State vector
    double y[wid];
    for(i=0; i < wid; i++){
        y[i] = (i+1) * 0.1;
    }
    
    double xi[wid][wid];
    
    for(t=0; t<len; t++){
        double tempxi[wid][wid];
        txs = 0; //norm. factor
        b = (double *)npdf( y, wid, *(tr+t), sig);
        for(i=0; i<wid; i++){
            for(j=0; j<wid; j++){
                if(j - i >= 0){
                    if(j - i <= alen){
                        tempxi[i][j] = *(al + i * len + t) * *(a+j-i) * *(b+t) * *(be + j * len + t);
                        txs += tempxi[i][j];
                    }
                }
            }
        }
        for(i=0; i<wid; i++){
            for(j=0; j<wid; j++){
                    tempxi[i][j] /= txs;
                }
            }
        }
        xi += tempxi;
    }
    plhs[0] = mxCreateDoubleMatrix(wid, wid, mxREAL);
    out = mxGetPr(plhs[0]);
    *(out) = xi;
}

double npdf(double* y, int len, double mu, double sig){
    int out[len], i;
    double val, var;
    var = sig * sig;
    for(i=0; i<len; i++){
        val = mu - *(y+i);
        out[i] = exp( -val * val / 2 / var);
    }
    return *out;
}