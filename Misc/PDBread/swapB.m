function out = swapB()
%Inverts B-factor (pLDDT) on AlphaFold Colab structures to be low = good (like B-factor)

a = pdb2mat;
for i = 1:length(a)
    a(i).betaFactor = 100 - a(i).betaFactor;
end
mat2pdb(a);