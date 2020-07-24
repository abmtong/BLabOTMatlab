#include "mex.h"
#include "math.h"

//cor = acorr2(indata)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //Declarations:
    //Loop variables, lengths
    int i,j,len;
    //data pt, temps
    double t1, t2, t3, *x, pt1, pt2;
    
    len =mxGetNumberOfElements(prhs[0]);
    double out[len];
    
    if( !mxIsDouble(prhs[0]) ) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notDouble",
            "Input matrix must be type double.");
    }
    x = (double *)mxGetPr(prhs[0]);
    
    for (i=0; i < len; i++){
        tmp=0;
        tmp2=0;
        tmp3=0;
        for (j = 0; j < len-i+1; j++){
            pt1 = *(x+j);
            pt2 = *(x+i+j);
            tmp = tmp + pt1*pt2;
            tmp2 = tmp2 + pt1*pt1;
            tmp3 = tmp3 + pt2*pt2;
        }
        out[i] = tmp/sqrt(tmp2*tmp3);
    }
}