function outPos = MirrorCalibrate()
[~, mp, ~] = fileparts(mfilename);
[f, p] = uigetfile([mp '\*.*'], 'Select some image(s)', 'MultiSelect', 'on');
if ~p
    return
end
if ~iscell(f)
    f = {f};
end

crp = ChooseCrop(p, f);

len = length(f);
outPos = zeros(len, 2);
for i = 1:len
    outPos(i,:) = FindBeadCentroid(imcrop(imread([p f{i}]), crp));
    %Pause a sec to check the result
    drawnow
    pause(.1)
end

figure, plot(1:len, outPos(:,1)), hold on, plot(1:len,outPos(:,2))