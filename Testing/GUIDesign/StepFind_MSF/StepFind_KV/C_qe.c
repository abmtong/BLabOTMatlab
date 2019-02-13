#include "mex.h"
#include "math.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //Declarations:
    //Loop variable, vector length
    int i,len;
    //Mean, variance, data point, ptr to inData(1), ptr to output
    double mean,var,val,*x,*out;
    
    if( !mxIsDouble(prhs[0]) )
    {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notDouble",
            "Input matrix must be type double.");
    }
    
    len=mxGetNumberOfElements(prhs[0]);
    mean=0;
    x=(double *)mxGetPr(prhs[0]);
    for (i=0;i<len;i++)
    {
        mean=mean+*(x+i);
    }
    mean=mean/len;

    var=0;
    for(i=0;i<len;i++)
    {
        val=*(x+i);
        var=var+(val-mean)*(val-mean);
    }
    
    plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
    out=mxGetPr(plhs[0]);
    *(out)=var;
}