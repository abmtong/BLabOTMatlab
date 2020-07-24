#include "mex.h"
#include "math.h"
//Returns the best dividing point of a vector, the one that minimizes QE.
//Output: [dQE, minInd]
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    //Declarations
    int j,k,len,minInd;
    double mean,qe,val,*x,*out,segQE,mindQE,qe1,qe2,testdQE;
    
    if( !mxIsDouble(prhs[0]) ) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notDouble",
            "Input matrix must be type double.");
    }
    
    len=mxGetNumberOfElements(prhs[0])-1;
    x=(double *)mxGetPr(prhs[0]);
    
    //calc full qe
    mean = 0;
    for (k=0; k < len; k++) {
        mean= mean + *(x+k);
    }
    mean = mean / len;
    qe = 0;
    for(k=0; k < len; k++) {
        val=*(x+k);
        qe=qe+(val-mean)*(val-mean);
    }
    //Initialize things
    mindQE = 0;
    minInd = 0;
    //loop over all pts from 2nd to len and test a step there
    for (j=1; j<len; j++) {
        //calc variance of first
        mean = 0;
        for (k=0; k < j; k++) {
            mean= mean + *(x+k);
        }
        mean = mean/j;
        qe1 = 0;
        for(k=0; k < j; k++) {
            val=*(x+k);
            qe1=qe1+(val-mean)*(val-mean);
        }
        //calc variance of second
        mean = 0;
        for (k=j; k < len; k++) {
            mean= mean + *(x+k);
        }
        mean = mean /(len-j);
        qe2 = 0;
        for (k=j; k < len; k++) {
            val=*(x+k);
            qe2=qe2+(val-mean)*(val-mean);
        }
        //Assemble
        testdQE = qe1 + qe2 - qe; //could subtract qe at end, but would need to make sure mindQE starts high enough (can I use inf?)
        //Check if its better or not
        if (mindQE > testdQE) {
            mindQE = testdQE;
            minInd = j;
        }
    }
    plhs[0]=mxCreateDoubleMatrix(1,2,mxREAL);
    out=mxGetPr(plhs[0]);
    *(out) = mindQE;
    *(out+1) = minInd;
   // *(out+2) = qe;
   // *(out+3) = qe1;
   // *(out+4) = qe2;
}