#include "mex.h"
#include "math.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //Declarations:
    //Loop variable, vector length
    int i,len;
    //Mean, variance, data point, ptr to inData(1), ptr to output
    float mean,var,val,*x,*out;
    
    if( !mxIsSingle(prhs[0]) )
    {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notSingle",
            "Input matrix must be type single.");
    }

    len=mxGetNumberOfElements(prhs[0]);
    mean=0;
    x=mxGetData(prhs[0]);
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
    
    plhs[0]=mxCreateNumericMatrix(1,1,mxSINGLE_CLASS, mxREAL);
    out=mxGetData(plhs[0]);
    *(out)=var;
}