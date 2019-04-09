/*
 * _coder_findStepHMMV1c_ccode_xi_info.c
 *
 * Code generation for function '_coder_findStepHMMV1c_ccode_xi_info'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "findStepHMMV1c_ccode_xi.h"
#include "_coder_findStepHMMV1c_ccode_xi_info.h"

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
  xInputs = emlrtCreateLogicalMatrix(1, 9);
  emlrtSetField(xEntryPoints, 0, "Name", mxCreateString(
    "findStepHMMV1c_ccode_xi"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs", mxCreateDoubleScalar(9.0));
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
  const char * data[21] = {
    "789ced5d5b8fe44615ae21bbcb2211088800e112768814018bc649564ab845ec75b63b99d91d76668789264b8fdbae9e2ead5de5d8eea197a70624b48fbc8078"
    "40025e509e5791b848fc843c117e080891b70857db3dedaef67455db65b77be6b4d49a393375ec73fbaacea98b8d569a9b28fa7c2afa0efe8ed085e8e7c5e8fb",
    "31147fce27f44af47d3df919fffd1c7a3aa17f117d2d4643dc0fe37f52d3c568f4b1994ba849c39d471e463e0e987384ede17f3ac4c13bc4c51b2c45344844b8"
    "eba97f1d13fc5f7e3738be3272d244fce17afc0e8df53897a1074ee9f14c42efdf7a70e37bc6fd00fb81412255fc20c48e63fac675d6bfb4fd885ac63d1c189b",
    "d77636ae5d37767010127a68dcbedfbc890372488ded107beb84daadc6e6a6d1897ee17f887edf7dd96a5916b371ab4fd6dc44be8644be6705f99e1ddad7c6fe"
    "da50326a3a6b0ea6876137b9de4b33ae37faa4af37b2d34022c71d818fd3fbcd8dbda1a9b67c76e89bee25ee9c63c3dc7be5a5975f358d9031a7cdfa06769de1",
    "f7f2507ae3f2487c23169f1b84cbf19d941c1732e45849c9f18963bd067ff9e4c6bfaee5e71fdb61d1fcdf48f1af64f0a3d4cf3ced971d0f9f11e4e37414562d"
    "378c3a85a0d5c58e87fd94be79f1f05822c7b6c0c7e9b9f1e090b6e19aa163b60de605c6941e43ab14c2c50fdacf012e74e0c24493fee67409fe5eb598eb32da",
    "b2bad87a18a4e4db92c8f735413e4e0be30409aef7881336e99d9e8b7d624df925ebba1784eb72da66bdb683d570b227f0efe5b15be6b821aab3e61688b30fbe"
    "f5fe07801385f6751f3f64f1fc71413e4e53e6bb9eddd182074fc2ff43819fd3fb4d753804a1190e7b0e23913ad2bc40dcfcf7ca8f21ee55da2fcaafb27ce8b3",
    "c27d397d643ac436436c86a14fdabd1007633d66e5432bc9dfc6d73b87ac08a92afdfc7d418efba8d8f8e898511f30ad4826cee7c8877efb21857c48a57dddfc"
    "2dcb7fbe2ac8c3e9a9fc678b054d1a6e5b6634f864f8a18cfc6757e0dfcd63a713f29fb43ac5ea67f4b7ff012eb4e0a26a7fcb70f125411e4e4fe1220d8a0c3f",
    "94810b2df5f309769a3052863e73c4d513c0851e5c2cd2df59f29c17e4e174c7614cd7b83090f03705fe661e7ba4c64fec747ad4186a9058a150dc6c1ebc0871"
    "afd27e80eae167981f82f921c0c3580e191ebe2cc8c169010f413ca68c468572d713b4d4539938b81ceb91b25181faf955584f582e1c1c48e4f8a62007a7051c",
    "989ee73c8a13acf51eb542c268936e39a68553f7b92ab9cfa785fb70ba935cadd535a91d0d182af3cb6de13aed3c76cbc4c9c96a8e0c5a20ee3efae80ae046a5"
    "7dddfd5fd6b852769e05e3cbe9c289ccdfcb506f9380d08e227ffdeaede81763a8818e7afbfb10f775cdabb2fd0cf536d4db75c04325e3fe1ceb7473af2f774d",
    "bf08df40c2a7bb3f08429f175afcf61afafdc1f35d0cfdbe4afbbaeebff8bc705f4e8bf97edf741c665593e7dc15f8ef225dfd7ba246b1fd46af419ea327cfa9"
    "cacfb2f8ff822007a733ebdd5b8795c4ff96c0bfa5cf2e891a85f29af73ebc0bf1af23feabf2f355891c4f0b72709a04344e81437ecc6989fa7d9ee774481fdb",
    "1e8bcc614ce851acdfff2ef4fbcb15f7b278bd28c8c169127448942677ab88f73704fe37f2d8612ade63f935ccf743bc2bb67f8c66fbb9bcf98a71bcaf76881f"
    "841d92a70ee531a323defb12fe75817f3d8f1d32e2bde0be518873c5f68bf6ef55c9fd55f398b2e669207f391d715eb7fe5c364fffbc200fa7f9b9cce8b2ad0e",
    "f31dc6bc163bc27ec7613f8d4f6516db07f46b893c0702df411efba4d72f6273cdd0a7483d3b80752bc5f67f45b3fdfe2b34e9774e97edf7d5d90d8e0fd317c9"
    "8b1a123e85f923426ddc6fd2b016e3288c1f80935938c95307449776cd7eb9f995b67a79725d7c28b9867a19c611c5f667151f842e2b3e08057c8cf9cbc6c700",
    "cdf67355eb669af689e2be772d5e3cceb07f19fb837604fe1d7df649a9132302d691175f8f57edef3d893c5f17e4e1f40c5cdc6137e29a3ccb1f79f021abcff7"
    "05fefd52ec95a855fcf95fbfffe539c0894a7b99df7f8226fdcee93270b28adfe9994e407e86d5f699c2fc15cc5f55818f45edbf9b37df0fdef1c32ad6e31a02",
    "7f03e938bfc7a52fb4bf08ceed2bb65fb47f65fdfa5784fb737aeafcc04de69a84def2fdf82099ca3a9fea394c59de58de79b209b50a9e27439d00f0b0147868"
    "48eeff39e1fe9c16f080d338286b9e68539063338f1d32e31e6b88f7c1cf3d384fb014f1aee1b95dc939627ecdb15e653d9fa2bc7982d1f9e1d8362379e0fcf0",
    "e98eff03c9fde1b914f05c8a3ae1a5eefe2f6b3c59def5061857ced23c519ef30aae6f932362631d713e90f0eb5e5fe6ef8f18c9bfe68ded9f333e36fa7f5c68"
    "7cbfae0b5f65c7f700d5cfcf597264bde720b98c967e5d6607dde7eeb91d4666d070eefeb5177f04fdb98e78afcacff0bc1578de0ae0612c870c0f970439389d",
    "bd8fe206733d3324514457b17fe22d81ffad3cf699b58e3e5647c773b9609f9162fb01aa072e1a1239b2de9723e022ba6ab6ddcbc893de14f8dfcc63974c3c44"
    "6a14df3f64409ea4d6beaefb239e9ab8ef5328ea21b5c4b56cfef8b6c07f1be9983f8ea42f768e13f64728b65fb47f65f9cd73c2fd399d3d9fc9237eac5759eb",
    "63e53d6f75348f19db66240fcc639eeef83f90dc1fd6c7607dac4e78a9bbffcb1a4fca9e3f8271e574e16451754243725f85ba989a74ac4759fbebcaab8723f1"
    "8bbf0ff0dd7f6cc03ca98ef100a3493f73bacaf784c3b91a385753079c2cfb79febccf8591e54de705bd391d8974e515a4569fad0bfceb79ed06cf8181f12363",
    "fc9877de35e8a9ed532aba9ea07b9dc5364373b873b7e7ead877f1276c43fcabb41fa07af85956377c519083d35375837f48a8d57d58667ef4b6c0f7f6bcf608"
    "a20205db465c3524b5c37409916852783fe91f6ede833a42a5fd32f85d357f81f78b1fc70facc329b61fa07a8c0379f69b46d7f07c66179a2f7a2ce1db15eebb",
    "9be8bf55d4009e4f8ecc101b8912c5f2fec1bb0f21ef516a5f377fc3be53d8770ab898c685ac2ec87a2f5ac46fe1206825976a11eaf5c2a0d87a42ae79029d76"
    "c956aae839fe3f3f21305ea8b4afbbff653881fa19eae7b38c8f3d897c2f08f2715ac087c56810de61749bd04307878cde24eaef2597e559a5e3e6c43c2b4b2d",
    "38c73ce23febb8918d2bf05eceb9e20adecba9d8be6e75489e7929120c1fb25a49dc6bd9cf34fd5cf95883e2fbf67ef39f6fff13e25ea1fd00d5c3cf5725723c"
    "23c8311c9bf8768ef84a2d8bf9959cf37c20f03f4005fb81d820a35e4054a9e873229ffc1bfa7fa5f675f5bb2c1f823a1beaecb39417e5ab0fdc36a1b87584ad",
    "90f92dec6017d330501a77749d13ea08d7e9e8b6d3094a165cdf5bb5607d4fa97dddfd0ffbc2615ff832e02473fea9c2fdafb2fae1a2201fa7e1797bc77104cf"
    "db5368ff7ff79ec063", "" };

  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(data, 47760U, &nameCaptureInfo);
  return nameCaptureInfo;
}

/* End of code generation (_coder_findStepHMMV1c_ccode_xi_info.c) */
