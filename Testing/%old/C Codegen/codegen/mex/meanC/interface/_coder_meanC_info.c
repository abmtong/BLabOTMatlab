/*
 * _coder_meanC_info.c
 *
 * Code generation for function '_coder_meanC_info'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "meanC.h"
#include "_coder_meanC_info.h"

/* Function Definitions */
mxArray *emlrtMexFcnProperties(void)
{
  mxArray *xResult;
  mxArray *xEntryPoints;
  const char * fldNames[4] = { "Name", "NumberOfInputs", "NumberOfOutputs",
    "ConstantInputs" };

  mxArray *xInputs;
  const char * b_fldNames[4] = { "Version", "ResolvedFunctions", "EntryPoints",
    "CoverageInfo" };

  xEntryPoints = emlrtCreateStructMatrix(1, 1, 4, fldNames);
  xInputs = emlrtCreateLogicalMatrix(1, 1);
  emlrtSetField(xEntryPoints, 0, "Name", mxCreateString("meanC"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs", mxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs", mxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  xResult = emlrtCreateStructMatrix(1, 1, 4, b_fldNames);
  emlrtSetField(xResult, 0, "Version", mxCreateString("9.0.0.341360 (R2016a)"));
  emlrtSetField(xResult, 0, "ResolvedFunctions", (mxArray *)
                emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

const mxArray *emlrtMexFcnResolvedFunctionsInfo(void)
{
  const mxArray *nameCaptureInfo;
  const char * data[13] = {
    "789ced5bcd6fdc441477501acaa1507100aa1ed808a9028a3225486d0121e5a38db290344b3ea4a46db49db567b323ec1933e38d36b715a71eb92071a327fe80"
    "8a7f030989f22f70870bb78a99b59ddd4c9d1dc7f66ebcd158729cb79e37febdaf7933cf636baaba6e89e34d71feb1695933e27a599caf59e17129a2a7c4793d",
    "ba86bf4f5b5722fa0771da9404a813843709f490151f0ef5308124d83ef291c510a7ee21727a779ad845dbd8436b748058c582f056066e1d13f2166bf1e39e2d"
    "7790080f29c78f565f8ee904391e0ec87135a21fdddf5ffe02ec70c438587451071207b1ca3625076089762a5b47c4067b08b2ca7c650b798807e2ee3cd8441c",
    "ac2f6eaf2d2e816df11b16ad972bcbd4410788000f41b23ce7f571ddd5e07a5dc12569ccd1f76de8a6e29f51f8677ada6f375c143ebfabe1ff46e197f4a3eada"
    "6e4f3535460f18f42ad218c7426fcedffaf4360401a56e837600f25ce0e206f060e0c20640aef8074412448a50e59849c0313580e38de87781fea77f3ff97331",
    "3b7fb21dce83ffc301fea9047e6be09aa57dd72a879d173438ae2a38e429baae473dd56dca50117eaf1b0ff615fefd481fb57c0af1193e840102aa483d0de5f0"
    "a3e7ff6cfc65e22045fbb2da7d5583eb3d0597a46d9154d81c16499611116404b2034cecd677b2bf5b43fa8b8fc1fed2eae7b1c2f7d83ae338c15b902107f4b0",
    "477f6f46975812702c493870e4c80fbfdcdb7c61e22245fb49b07b12ae4b0a2e49375d4a594afebcf3a3aac25f3dab5e5e192e9a6d027a12c4d3c43cfeb3fee4"
    "86c90b45cc8fc665e79a06c7fb0a0e492b7900f3a53676832a79d0f610c3762171f054c3bfabf0ef66d18f3c5f19145471e6bc1cfef4e2e3df4d3eb848f1705d",
    "c12169251eb80d5dc8e6e2ac10f69b757ea48b831d856f278b5e12e3e06628c7808e72cc8b6e37ae99bc304971f04483e3230587a4953880beef1e6df59c68a5"
    "4dec005352253517da68e0390b9ae7bca53c47d2cda8b77a0b1247240cd9cfcf9a7e1a4a3f8d2c7a4b8c93d3c53cadee7606bf7bf9f233133769da97ddfea3ca",
    "2ba39e6799fc72b1e2e49935dcdeae75d2de921e693d6a3626437748d263da7538e6049294fce55b8787f56b214111ebf02f4d3c9475be956c67b30e37ebf032"
    "c44359df5b0f5b3f4f45bff5714d5bb28371e481af157e49e7191f1c1840b92293f80b583ffc6d3b260f149107c6656793074c1e30f1d0c7b1aac1f18e8243d2",
    "3ea336e2bccedb9ef8d7a963e2b7039e2d8fd82dc8d2d4179082035939d74db142e29553b25079d7cdbf3ec7263fa4695f76fbebe2c4ece7c8141f663f47caf6"
    "658f8f5d0dbe0f147c9256e2c3a684070f28d9124b15170594dcc3c9fb4947b13f3077dc9c3abf4a122b77dc987a6ccaf6658f1b5d5e7957c127e9c4f716f70f",
    "c65297ad29fc35aba83889c5c8b5fef8ed3fb36fb690f5c7b8ecbca0c17145c12169cc49b8540de4e726e3791fb1a1f06f64d1871c269ab8831c9f0a75801372"
    "88112187df7c6ef2c164f9bdce5f2f2b38248d79138b2cd39aa8baeb097f0ff117507735fe9eb2fd536bb89d475757ecfbfb6c13331e347196fa90f49922fcbd",
    "a3e15f51f857b2e821c1dfa5af1b3f1fbd9f9fb77d1734cf4f3b8fc95a3fed6af8ccfce562f879d71a6ee7f3785f6abe733eabbf98ef9c27cddf57353892eb34"
    "5e0313543f447640591db9c84324e063dd97dd54fa695a05d7b74e1132dfbca73b6bf6554c567c6459cf7accc187d829e4fbff71eb81fa1cc4f8e7fc643d9cc1",
    "5fd63acfced5dfbf2a6afe75d1fc3d8d9dd3ce7fa26e2672ffb4d443ac86fcfba7bb776e7c6bc6f722fc7d5c7636fbe6ccbe39130f7d1cba78a82838249df0de"
    "1675fc65eaf930c0c2a3c7b1cf614fe1dfcba29f53ebbd27c429e23b9b3ba62e345971b1aac1f1b68243d24a5c885e93f55eda3a51623c0831f2d789809927e9",
    "dbff0f50ea37ff", "" };

  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(data, 21216U, &nameCaptureInfo);
  return nameCaptureInfo;
}

/* End of code generation (_coder_meanC_info.c) */
