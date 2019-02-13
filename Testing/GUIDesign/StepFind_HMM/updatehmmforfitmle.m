function updatehmmforfitmle()

[f, p] = uigetfile('MultiSelect', 'on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end

len = length(f);
for i = 1:len
    fp = [p filesep f{i}];
    fcdata = load(fp);
    fcdata = fcdata.fcdata;
    %make all fields: fcdata should be:
    %{
    con, frc, tim (single/double arrays)
    opts (struct)
    hmm (1xn struct)
    hmmfinished (double, integer)
    %}
    if isfield(fcdata, 'hmm') && ~isempty(fcdata.hmm)
        if ~isfield(fcdata.hmm(1), 'fitmle')
            hei = length(fcdata.hmm);
            fitmle = fcdata.con(1)*ones(1,length(fcdata.con));
            fm = repmat({fitmle}, 1, hei);
            [fcdata.hmm.fitmle] = fm{:};
        end
    end
    save(fp, 'fcdata');
end