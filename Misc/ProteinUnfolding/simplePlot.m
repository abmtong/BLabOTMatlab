function simplePlot(infp)

if nargin < 1
    [f p] = uigetfile('.mat', 'Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    cellfun(@(x) simplePlot(fullfile(p,x)),f);
    return
end

Fs = 25e3;
dsamp = 1e2;



cd = load(infp);
fn = fieldnames(cd);
cd = renametophage(cd.(fn{1}), fn{1});

%Just plot f-t
tt = windowFilter(@mean,[cd.time{:}], [], dsamp);
ff = windowFilter(@mean,[cd.force{:}],[],dsamp);

[~,f,~] = fileparts(infp);
figure('Name', f), hold on
plot(tt,ff)



