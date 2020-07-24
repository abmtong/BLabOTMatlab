function plotFT(data, samprate, guessfreq)
if(nargin < 2)
    samprate = 2500;
end

if(nargin < 3)
    guessfreq = 0;
end

f = (0:length(data)-1)*samprate/length(data);

ind = find(f>5, 1);
ind2 = find(f>100, 1);

% plotdata = data(ind:ind2);
% plotf = f(ind:ind2);
figure('Name',['FFT of ' inputname(1) ' loglog'])
loglog(f, data);
hold on
line(guessfreq*[1 1], max(data)/10 * [1 2],'Color',[1,0,0])
hold off

figure('Name',['FFT of ' inputname(1) ' normal plot'])
plot(f, data);
hold on
line(guessfreq*[1 1], max(data)/10 * [0 -1])
hold off

end