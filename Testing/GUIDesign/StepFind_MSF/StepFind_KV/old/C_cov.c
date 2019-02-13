#include "mex.h"
#include "math.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

//Declare everything
int ii;
double media,cov,media2,val;
double *x,*y;
int dimx,dimy;
int valore;
double *out;

//One arg: Just data
if (nrhs==1)
{
 dimx=mxGetNumberOfElements(prhs[0]);
 media=0;
 x=(double *)mxGetPr(prhs[0]);
 for (ii=0;ii<dimx;ii++)
  { media=media+*(x+ii);
  }
 media=media/dimx;

 cov=0;
 for(ii=0;ii<dimx;ii++)
  {
  val=*(x+ii);
  cov=cov+(val-media)*(val-media);
  }
 if(dimx>1)
  cov=cov/(dimx-1);
 else cov=0;
}

//Two args: either vectors or scalars
if(nrhs==2)
{
dimx=mxGetNumberOfElements(prhs[0]);
dimy=mxGetNumberOfElements(prhs[1]);

//Vector, scalar: 
if((dimy==1)&&(dimx>1))
{
valore=mxGetScalar(prhs[1]);
if(valore==0)
{

media=0;
x=(double *)mxGetPr(prhs[0]);
for (ii=0;ii<dimx;ii++)
{ media=media+*(x+ii);
}
media=media/dimx;
cov=0;
for(ii=0;ii<dimx;ii++)
{
val=*(x+ii);
cov=cov+(val-media)*(val-media);
}
cov=cov/(dimx-1);
}
if(valore==1)
{

x=(double *)mxGetPr(prhs[0]);
media=0;
for (ii=0;ii<dimx;ii++)
{ media=media+*(x+ii);
}
media=media/dimx;

cov=0;
for(ii=0;ii<dimx;ii++)
{
val=*(x+ii);
cov=cov+(val-media)*(val-media);
}
cov=cov/(dimx);
}


}

/*************************** due scalari  */

if((dimx==1)&&(dimy==1))
{
cov=0;
}
/*************************** due vettori  */
if((dimx==dimy)&&(dimx>1))
{
x=(double *)mxGetPr(prhs[0]);
y=(double *)mxGetPr(prhs[1]);

media=0;
media2=0;
for (ii=0;ii<dimx;ii++)
{ media=media+*(x+ii);
  media2=media2+*(y+ii);
}
media=media/dimx;
media2=media2/dimy;

cov=0;
for(ii=0;ii<dimx;ii++)
{
cov=cov+(*(x+ii)-media)*(*(y+ii)-media2);
}
cov=cov/(dimx-1);
}



}

/**************************************/
/*        tre argomenti               */
/**************************************/

if(nrhs==3)
{
dimx=mxGetNumberOfElements(prhs[0]);
dimy=mxGetNumberOfElements(prhs[1]);
x=(double *)mxGetPr(prhs[0]);
y=(double *)mxGetPr(prhs[1]);
valore=mxGetScalar(prhs[2]);
if((valore==0)&&(dimx==dimy)&&(dimx>1))
{
media=0;
media2=0;
for (ii=0;ii<dimx;ii++)
{ media=media+*(x+ii);
  media2=media2+*(y+ii);
}
media=media/dimx;
media2=media2/dimy;

cov=0;
for(ii=0;ii<dimx;ii++)
{
cov=cov+(*(x+ii)-media)*(*(y+ii)-media2);
}
cov=cov/(dimx-1);
}
if((valore==1)&&(dimx==dimy)&&(dimx>1))
{
media=0;
media2=0;
for (ii=0;ii<dimx;ii++)
{ media=media+*(x+ii);
  media2=media2+*(y+ii);
}
media=media/dimx;
media2=media2/dimy;

cov=0;
for(ii=0;ii<dimx;ii++)
{
cov=cov+(*(x+ii)-media)*(*(y+ii)-media2);
}
cov=cov/(dimx);
}
if((valore==1)&&(dimx==dimy)&&(dimx==1))
{
cov=0;
}
if((valore==0)&&(dimx==dimy)&&(dimx==1))
{
cov=0;
}

}


/***************************************************************************************/
/***************************************************************************************/	 
plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
out=mxGetPr(plhs[0]);
*(out)=cov;



}