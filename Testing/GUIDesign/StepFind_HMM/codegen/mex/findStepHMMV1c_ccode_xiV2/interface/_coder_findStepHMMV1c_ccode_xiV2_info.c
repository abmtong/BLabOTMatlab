/*
 * _coder_findStepHMMV1c_ccode_xiV2_info.c
 *
 * Code generation for function '_coder_findStepHMMV1c_ccode_xiV2_info'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "findStepHMMV1c_ccode_xiV2.h"
#include "_coder_findStepHMMV1c_ccode_xiV2_info.h"

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
  xInputs = emlrtCreateLogicalMatrix(1, 11);
  emlrtSetField(xEntryPoints, 0, "Name", mxCreateString(
    "findStepHMMV1c_ccode_xiV2"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs", mxCreateDoubleScalar(11.0));
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
  const char * data[20] = {
    "789ced1d4d6fdcc695aa3fe2004d630471dba4496ab74090c48598d84092d608227fc9bbb164ab96acca90dd15979cd50e4cced0245759e7c4b640e1632f2d7a"
    "0890f452f86c04487ae84fe829c90f4951c437a39c2557bb3b4bef8cc821972bbd0516d293e6cdbccf99f766de90da5c7d598b3e3f8abe0b5f68dad1e8e7b1e8",
    "fb032dfe1c49e0b9e87b2ef919fffdb0f65c02ff31fa9a9404a81bc4ff248683b4fec7a20e260609d6eebb48f3904fed1d64f5fed3c2365ac30e5aa243400d47"
    "80b338f4af5d80fdcb6bfbbb3d6bf630107f181f7fd7067c1c4ee1637b888fe309bc79f9cec5dfe8377de4f93a8e58f1fc00d9b6e1e91768f7e4ea7d62ea3790",
    "af2f9f5f5b3a7f415f437e80c9b67ee566fd12f2f136d15703e42e6262356acbcb7a2bfa85fd21fa7dfd1db3619ad4428d2e5e3f33eff4e8ab09e83bc1d177a2"
    "275f0b79f33dca8861cfdb886c07ed84dfb727f4d7ff0cf7d7975328a0e31a87c7e0cdfad2464f542b1eddf60ce72453ceae606e9c79fb9d770d3da0d46ed2ae",
    "8e1cbbf73ddda35e3fdd275f8fc98fc4d1a3e3fd213a8ea6d0313744c7b3bb7c855ffe70e9dbf3d9f107729836fe1b43f87329f8dad0cf2cedabee0fef0be87b"
    "86a38fc1847a8e6bb5a4f08f72f80cb668a769a3583eae00ff430e9fc19b757937f00323f07b8e90509dc2f71eece67f677ff70dd8bd44fb69e95534bfbfc08d",
    "cbe01dc3c696112023083cdcec04c81ff031697e9f4bfe36e8efb066469ecaf01e08f06e7274dcd432ccef366eea8e11d84653b78d680e1867844df379e6f9bf"
    "3d2630cfcbb4af9abe5704f4bccad1c3602ecec1fe0af5eb2458358d68f149d14396f95e24a7750e7f3d8b9c52e39e5176f2c53fdabfbe07bf50e21765eb5be4",
    "172f73f43078cc2f869d22450f45f8c52a87bfaa504e23424ae1670f76f508fc428d5f4c53df69f41ce1e86170cba654d5ba100af0eb1c7e3d8b3c86d64f64b7"
    "3a44ef7190482197dd2c6fbd0e762fd33ed4aaa167d13af0738e0e068fad03173ad80eeae45ac7411e364b59073638fc8d2cf279cabc30cacebc93c39ebe79eb",
    "3f9027ef277ff819470783397ff0e335a5bf2ae4db1f2d259f4af583d3311f4332ca913fbfdb7c09d68559f2832d011d6f72743098f303c375edfb7180b5d821"
    "668029a99315db30d1d0380b82719ee7c661702be9add13688152d1832fbcb4dae9f6616b9a5fac9d3d9ec0b3487dd3d797216fc46a67dd5f55fd4ba52749c05",
    "ebcbfef21391be6721dfc63e262d49fceae5dbd12f7a8f0315f9f639b0fbaac655e97a867c1bf2ed2af84329ebfe1ecee9f67cbedc36bc3c78a1004ff57ce007"
    "1e4bb4d8f00ae6fdf0b53682795fa67d55eb2f7ecc8dcb603edeef1ab64dcd72e29ceb1cfe754dd5fc9eb091afdee83d8873d4c43965e95964ff3fe1e860706a",
    "be7b79bb14fb5fe1f057d4c9256123575cf3c5e3eb60ff2aecbf2c3d2f08e8788ea383c1d82771081cb032f5199af7599cd3c25d64b93412873ec247be79ffd7"
    "30efcf96dd8becf518470783b1dfc25198dc2ec3de3fe2f03fca2287317b8fe957b0df0ff62ed9fe813659cfc5ed570cecfd540b7b7ed0c259f25066332aecbd",
    "2bc05fe4f017b3c821c5de73d68d829d4bb69fb67e1704e3cbc63145edd340fcb23fecbc6af3b9689ffe358e1e0647dd37a26e1b2dead994ba0dba83bc964d3f"
    "6e986d64decd5707f417013d5b1cde5616f90c9f5fc4e29ac04f9e7c3684732bc9f65f6993f5fe676d54ef0c2e5aefa7263768b491ed222fdbbcdf8f8b6a023c",
    "89fd234c2cd4ad93a012eb28ac1fe02793fc244b1e1075ed18dd62e32b65f9f2e8b9788f7205f932ac2392ed0faa7f6032abfe8109f8c700bf68ff08b5c97a2e"
    "ebdc4c519d28eabae7e3c3e314f917511fb4c6e1afa993cf103bb147c039f2f4f3f1b2f5bd21a0e7171c3d0c9ee017d7e8c538274fd34716ff10e5e79b1cfe66",
    "21f24ad8ca7d7f39fcf44f87c14f64da8bf4fe7b6d54ef0c2ec24f4ea17b1dc3f6f12748aece14f6af60ffaa0cff9856fddd5ee37dff9e1794711e57e3f06b9a"
    "8afb7b8cfa5cf545706f5fb2fdb4f52b9ad75fe1c667f0d8fd814bd43130b9ec79f1453299733ed97b98a2b8b1b8fb64236ce5bc4fa6b57cf08799f0879a60fc",
    "17b9f119ccf9031af683a2f68996393a96b3c821d5ee91027b0fffe0c27d8299b07705cfed4aee11b33e077c15f57c8ae2f609faf78763d9f4e981fbc3fbdbfe"
    "b704e3c37329e0b91455f297aaebbfa8f56476cf1b605d3948fb4459ee2b389e8577b08554d87928c0577dbe4c5d5fefd33fef0ee49fd13e96ba9f4fd5be3f50",
    "e55f45db77a8554fcf6974a4bde720e946c9bc2e9283ea7bf74c0e7d3128b877ffdeebbf85f95c85bd97a56778de0a3c6f05fc614087c81f4e72743038bd8ee2"
    "22755c23c0914597513f718bc3bf95453e93ced107eca8782e17d41949b60fb56af8454d4047dafb7238bf887a4d977b1171d2550eff6a16b9a4fa43c446fefa",
    "211de224b9f655ad8f383432ee212d9a2195d8b568fff80a877f4553b17f1c519fef1e27d44748b69fb67e45f1cd4bdcf80c4edfcf64163fe0aba8f3b1e29eb7"
    "dadfc78c65d3a707f631f7b7fd6f09c687f331381fab92bf545dff45ad2745ef1fc1bab2bffc645a79424d30ae445e4c0c32e0a3a8fabae2f2e188fcfcef037c",
    "f8ef25d82755b11e4cfb3de170af06eed554c14f66fd3e7fd6e7c288e2a6231cdf0c8e483a7b4693cbcf1639fcc5ac7283e7c0c0fa91b27eec75dfd5efc8d529"
    "e53d4f507dce621981d1abdced382aea2efe812cb07f99f6a1560d3d8bf2869f727430782c6ff0b63131db778b8c8f6e7378b7f72a0f3f4a5090a5c75943923b",
    "8ca7100927b9eb493fbb7403f20899f6b3a077d9f805de2fbe6b3f700e27d93ed4aab10e64a9378dfa703d6ae5da2f7a20c05be7c65d4ff85fc92b00d7c33b46"
    "80f484897c717ff8f02ec43d52edaba66fa83b85ba53f08b71bf10e50569ef458bf04de4fb8da4ab06266e27f0f39d2788f609104707522d9774a6f2dee3ffe7",
    "230ceb854cfbaaeb5fe427903f43fe7c90fd634340df2f39fa18ccf98749891f5ca36415936d1b05945cc2f2ef2517c55985fbcd53e3ac34b6e01e731fffa0fb"
    "8d685d81f772eec9aee0bd9c92edab968764d997c27eef21aba5d8bd927aa6f1e7cac71ce4afdbfbeb7f7ff535d8bd44fb50ab869e1704741ce7e8e8ad4dac9c",
    "23eea96152af947b9e7738fc3b5ace792016487f16e059cafb9cc847dfc1fc2fd5beaa7a17c5439067439e7d90e2a26cf981d3c4043576901950af816ce42012"
    "f852eb8eaa7b422dae9f966a393d85c99ce77ba74c38df936a5f75fd435d38d485cf829f4cbbfe55943f1ce3e863303c6f6fd78ee0797b12edff0fe0a01888",
    "" };

  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(data, 46160U, &nameCaptureInfo);
  return nameCaptureInfo;
}

/* End of code generation (_coder_findStepHMMV1c_ccode_xiV2_info.c) */
