function out = testlighting(opt2, rng2, opt1, rng1)
%Tests what things look under lighting, for optimizing object properties + colors

if ~iscell(rng1)
    rng1 = num2cell(rng1);
end
if ~iscell(rng2)
    rng2 = num2cell(rng2);
end

[x, y, z] = sphere(80);

wid = length(rng1);
hei = length(rng2);

fg = figure('Name', sprintf('TestLighting %s x %s', opt1, opt2));

%Set default color, material, lighting pos

%Color
col = [1 1 .2];

%.2 red .1 blue?

%Lighting
ligpos = [5 5 5];
%Camera
campos = [5 0 0];
camtar = [0 0 0];
%Material
mat = [0.4, 0.9, 0, 10, 1.0];
%{
Defaults:
allMaterials={  %ka     %kd     %ks     %n      %sc
    'Shiny',	0.3,	0.6,	0.9,	20,		1.0
    'Dull',		0.3,	0.8,	0.0,	10,		1.0
    'Metal',	0.3,	0.3,	1.0,	25,		.5
%}

opt = {opt2 opt1};
rng = [rng2 cell(1, max(wid-hei, 0)); rng1 cell(1, max(hei-wid, 0))];
for i = 1:wid
    for j = 1:hei
        for k = 1:2
            %Change property of interest
            if k == 1
                newind = j;
            else
                newind = i;
            end
            switch opt{k}
                case 'col'
                    col = rng{k, newind};
                case 'colr'
                    col(1) = rng{k,newind};
                case 'colg'
                    col(2) = rng{k,newind};
                case 'colb'
                    col(3) = rng{k,newind};
                case 'matka'
                    mat(1) = rng{k, newind};
                case 'matkd'
                    mat(2) = rng{k, newind};
                case 'matks'
                    mat(3) = rng{k, newind};
                case 'hsvh'
                    col = hsv2rgb([rng{k, newind}, .7, 1]);
            end
        
        end
        
        %Generate axis
        ax = subplot2(fg, [hei wid], sub2ind([hei, wid], j, i) , 0);
        ax.CameraPosition = campos;
        ax.CameraTarget = camtar;
        axis(ax, 'equal')
        %Add lighting
        light(ax, 'Position', ligpos)
        %Plot sphere
        surface(x,y,z, 'EdgeColor', 'none')
        %Set color
        colormap(ax, [col; col])
        %Set material properties
        material(mat)
        
    end 
end




