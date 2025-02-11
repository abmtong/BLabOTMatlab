function  plotSpectra(r,g,b,varargin)
%Input: Spectra data as [x(:), y(:)]

%Hard code lasers
las = [642 532 486];
laswid = [5 1 5];

figure, hold on

%Plot laser
lr = patch(las(1) + [-1 -1 1 1] * laswid(1), [0 1 1 0], 'r');
lg = patch(las(2) + [-1 -1 1 1] * laswid(2), [0 1 1 0], 'g');
lb = patch(las(3) + [-1 -1 1 1] * laswid(3), [0 1 1 0], 'b');

%Append zeroes to spectra
padspec = @(x) [x(1,1) 0; x; x(end,1), 0];

r = padspec(r);
g = padspec(g);
b = padspec(b);

%Plot spectra, as shaded boxes
pr = patch(r(:,1), r(:,2), 'r');
pg = patch(g(:,1), g(:,2), 'g');
pb = patch(b(:,1), b(:,2), 'b');

%Lighten
pr.FaceAlpha = 0.5;
pg.FaceAlpha = 0.5;
pb.FaceAlpha = 0.5;

xl = xlim;

%Plot transmission spectra of filters

len = length(varargin);
nam = cell(1,len);
for i = 1:len
    %Normalize
    varargin{i}(:,2) = varargin{i}(:,2)/max(varargin{i}(:,2));
    %Plot
    plot(varargin{i}(:,1), varargin{i}(:,2), 'LineWidth', 1)
    nam{i} = inputname(i+3);
end
xlim(xl)

xlabel('Wavelength (nm)')
ylabel('Emission / Transmittance')

legend([{'Red Laser' 'Green Laser' 'Blue Laser' 'Cy5 em' 'Cy3 em' 'Cy2 em'} nam])

