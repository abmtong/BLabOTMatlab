function rz = plotForces(file, verbose)
%Loads a F-X curve and plots FA and FB
if nargin < 2
    verbose = 1;
end
if nargin < 1
    [file, path] = uigetfile('C:\Data\Analysis\Force*.mat');
    file = [path filesep file];
end
if file == 0
    return
end

load(file)

A = CalibratedData.ForceAX;
B = CalibratedData.ForceBX;
in = A>0.6*max(A);
aa = mean(A(in));
bb = mean(B(in));
rz = (aa-bb)/bb*100;

if verbose
A = smooth(-CalibratedData.ForceAX,50);
B = smooth(CalibratedData.ForceBX,50);
figure
plot(A)
hold on
plot(B)
hold off
end

fprintf('For the highest forces of %s, A is %0.2f%% larger than B on average\n',CalibratedData.file,rz)

end