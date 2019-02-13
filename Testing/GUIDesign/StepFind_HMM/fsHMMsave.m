function outflag = fsHMMsave(infilepath, nitermax, stopatlogp)
%current: fsHMMV1b

verboseflag = 2; %use 2 if you want fprintf updates [to get a sense of iter. time], 0 if not

%outflag: -1 (fsHMM error'd), 0 (unfinished), 1(finished)
outflag = 0;

if nargin < 1 || isempty(infilepath)
    [f, p] = uigetfile('C:\Data\pHMM*.mat');
    infilepath = [p filesep f];
end

if nargin < 2
    nitermax = 5;
end

if nargin < 3
    stopatlogp = 1; %whether to stop when logp becomes smaller (less probable) than the previous's or not
end

fcdata = load(infilepath, 'fcdata'); %loads struct called fcdata
fcdata = fcdata.fcdata;
tr = fcdata.con;
if isfield(fcdata, 'hmm')
    %check if file is not done (i.e. next iter would increase logp) or if stopatlogp == 0
    if ~fcdata.hmmfinished || ~stopatlogp && fcdata.hmmfinished ~= -1
        %load things
        iter = length(fcdata.hmm)+1;
        prelgp = fcdata.hmm(end).logp;
        preres = fcdata.hmm(end);
    else
        outflag = fcdata.hmmfinished;
        return
    end
else
    %start from scratch
    iter = 1;
end
%do stepfinding up to nitermax
while iter <= nitermax
    if iter == 1
        %protocol is slightly different for first run
        %check if there's an a seed, apply if there is
        mod = [];
        if isfield(fcdata, 'aseed')
            if ~isempty(fcdata.aseed)
                mod.a = fcdata.aseed;
            end
        end
        %do stepfinding
        try
            newres = findStepHMMV1b(tr, mod, verboseflag);
        catch
            newres = [];
            fcdata.hmm = newres;
            fcdata.hmmfinished = -1;
            outflag = -1;
            save(infilepath, 'fcdata')
            return
        end
        %update fcdata
        fcdata.hmm = newres;
        fcdata.hmmfinished = 0;
        %rename variables
        prelgp = newres.logp;
        preres = newres;
        %save results
        save(infilepath, 'fcdata')
        %increment iter
        iter = iter + 1;
    else
        %do stepfinding
        try
            newres = findStepHMMV1b(tr, preres, 0);
        catch
            fcdata.hmmfinished = -1;
            outflag = -1;
            save(infilepath, 'fcdata')
            return
        end
        %do housekeeping: update variables
        
        
        %check for convergence
        if newres.logp < prelgp
            %mark as finished, mark the best state in hmmfinished if not already marked
            if fcdata.hmmfinished <= 0
                fcdata.hmmfinished = length(fcdata.hmm);
            end
            fcdata.hmm(end+1) = newres;
            %save
            save(infilepath, 'fcdata')
            outflag = 1;
            iter = iter + 1;
            prelgp = newres.logp;
            %exit if sotpatlogp is flagged
            if stopatlogp
                return
            end
        else
            %update fcdata
            fcdata.hmm(end+1) = newres;
            %rename variables
            prelgp = newres.logp;
            preres = newres;
            %save
            iter = iter + 1;
            save(infilepath, 'fcdata')
        end
    end
end
end