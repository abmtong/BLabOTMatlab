function thesisExample5p1
%Pairwise distribution of a non-uniform step size

%DTS Hybrid is probably either four steps of 0.75nm each, or three at 0.85nm and one 0.45nm

%Generate these two traces
tropts.busz = 3.0; %Burst size, nm *The default unit is bp, but let's work in nm for now
tropts.ssz = 0.75; %Step size, nm
tropts.tdw = 40; %Dwell length, ms. Gamma-distributed, shape defined below
tropts.dwk = 5; %Dwell shape (Gamma shape factor)
tropts.tbu = 20; %Burst length, ms. Three per cycle (for four steps). Single-exponential
tropts.Fs = 2.5e3;

tropts1 = tropts;
tropts2 = tropts;
tropts2.ssz = 0.85; %Set the step size for trace 2 to be 0.85nm, which will make 0.85nm x3 plus 0.45nm steps
noi = 0.5; %nm, SD of gaussian noise

tr1 = simp29trace(noi, tropts1);
tr2 = simp29trace(noi, tropts2);

%Plot
tr1x = (1:length(tr1))/tropts.Fs;
tr2x = (1:length(tr2))/tropts.Fs;

figure, hold on
plot(tr1x, tr1, 'Color', [.7 .7 .7])
plot(tr2x, tr2, 'Color', [.7 .7 .7])
set(gca, 'ColorOrderIndex', 1);
plot(tr1x, windowFilter(@mean, tr1, 5, 1)); %Downsample to 250Hz
plot(tr2x, windowFilter(@mean, tr2, 5, 1)); %Downsample to 250Hz


%Generate PWDs for each of these
% sumPWDV1b( data, filspan, bin, pfilspan, tfsgolay )
pwdopts = {10 .01 5 0};
sumPWDV1b(tr1, pwdopts{:});
sumPWDV1b(tr2, pwdopts{:});

%Theoretical PWD at infinite resolution
%Let's say the burst subdwells are half the duration of the loading dwells
%So for 0.75x4 step:
tx1 = 0.75* (1:12);
ty1 = repmat([1 1 1 2], [1 3]);
%And for 0.85x3+0.45 step:
tx2 = sort([.85 * [1:3], .85 * [0:2] + .45 , 3]) ;
tx2 = [tx2 tx2+3 tx2+6];
ty2 = repmat( [.5 .75 .5 .75 .5 .75 2], [1 3]); %I feel the 0.45nm step peaks should be shorter?

%Plot
figure, subplot(2, 1, 1)
%Make a 'theoretical PWD' with @errorbar , with only lower errorbars
errorbar(tx1, ty1, ty1, zeros(size(tx1)), 'LineStyle', 'none');
ylim([0 2.5]);
subplot(2,1,2)
errorbar(tx2, ty2, ty2, zeros(size(tx2)), 'LineStyle', 'none');
ylim([0 2.5]);








