#include "mex.h"
#include "math.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
// outxi = C_xi(tr, al, be, a, sig)
//xi (t,i,j) = al(t, i)* a(i,j) * be(t+1,j) * P(t+1,j)
    //Declarations:
    //Loop variable, vector length
    int i,len;
    //Mean, variance, data point, ptr to inData(1), ptr to output
//     double mean,var,val,*x,*out;
    
    double xi[];
    
//     if( !mxIsDouble(prhs[0]) )
//     {
//         mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notDouble",
//             "Input matrix must be type double.");
//     }
    //Most expensive line in @findStepHMM is:
   //  tempxi = aa .* bsxfun(@times, tempal.',tempbe .* npdf2(i+1));
   //which is:
    //xi(i,j) = al(i) aij gauss(t+1) be(j) / sum(numerator over ij)
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

    lent = mxGetNumberOfElements(prhs[0])
    lenal = mxGetNumberOfElements(prhs[1])
    lenbe = mxGetNumberOfElements(prhs[2])
    lena = mxGetNumberOfElements(prhs[3])

    for (t=0, t<len-1, t++)
		for(i=0, i<
    
}
