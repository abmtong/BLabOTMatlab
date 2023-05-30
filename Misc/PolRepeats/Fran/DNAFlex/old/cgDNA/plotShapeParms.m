function [] = plotShapeParms(configuration, seq)

%-------------------------------------------------------
% cgDNA function: [] = plotShapeParms(configuration, seq)
%-------------------------------------------------------
% This function plots the ground-state coordinates
% to the screen.
%
% Input: 
%
%   seq      sequence along reference strand
%
%   configuration  ground-state coordinate vector 
%            [size N x 1].
%
% Output:
%
%   panels 1...12  plot of each intra- and inter-
%                   basepair coordinate along the 
%                   molecule
%
%   where N = 12*nbp - 6 and nbp is the length 
%   of the sequence seq (number of basepairs).
%   Note that labeling for the graphics is optimised
%   for up to 20 or so base pairs.
%
%
% If you find this code useful, please cite:
%
% D. Petkeviciute, M. Pasi, O. Gonzalez and J.H. Maddocks. 
%  cgDNA: a software package for the prediction of 
%  sequence-dependent coarse-grain free energies of B-form 
%  DNA. Nucleic Acids Research 2014; doi: 10.1093/nar/gku825.
%
%-------------------------------------------------------

    % Define font size, line width and line style
    fontsize = 12;
    lwidth = 2;
    lsty = 'r-';

    names =  ['Buckle   '; 'Propeller'; 'Opening  '; ...
              'Shear    '; 'Stretch  '; 'Stagger  '; ...
              'Tilt     '; 'Roll     '; 'Twist    '; ...         
              'Shift    '; 'Slide    '; 'Rise     '];

    % Assemble intra- and inter-basepair coords for plots
    seq = upper(seq);
    nbp = numel(seq);

    [Buckle_Propeller_Opening, ...
     Shear_Stretch_Stagger, ...
     Tilt_Roll_Twist, ...
     Shift_Slide_Rise] = vector2shapes(configuration);

    intra = [Buckle_Propeller_Opening, ...
             Shear_Stretch_Stagger];
    inter = [Tilt_Roll_Twist, ...
             Shift_Slide_Rise];
    allCoordinates = [intra [inter; NaN(1,6)]];

    xlim = [0 nbp+1];
    xtick = [1:nbp];
    xticklabel = cellstr(seq(:))';

    hsize = get(0,'ScreenSize');
    h = figure('Position',[hsize(3)/10,hsize(4)/10,hsize(3)/2,hsize(4)/2]); 

    for j=1:12
       coor = allCoordinates(:,j);
       subplot(4,3,j);
       x = 1:nbp;
       if j>6
          x = x+0.5;
       end
       plot(x, coor, lsty, 'LineWidth', lwidth);
       set(gca,'XLim',xlim,'XTick',xtick,'XTickLabel',xticklabel,...
               'Fontsize',fontsize);
       title(names(j,:));
    end    
    
    % Text comment, bottom right
    ax = axes('Position',[0,0,1,1],'visible','off');
    tx = text(0.5, 0.05 ,[ 'Translations in Angstroms, rotations in degrees ' ...
               '(in the precise sense of Curves+)' ]);
    set(tx,'Fontweight','bold','HorizontalAlignment','center');
end    
