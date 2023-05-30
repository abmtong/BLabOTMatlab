function cgDNAtests() 
%-------------------------------------------------------
% cgDNA, version 1.0.1 (2014), test suite.  
%
% Execute tests and compare with reference results stored
% in the "test_reference" subfolder.
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

    %-------------------------------------------------------
    %% RUN all commands and save their output
    %-------------------------------------------------------
    % see main.m for a detailed explanation of the following operations
    sequence = 'CGCGAATTCGCG';
    params = load('cgDNAparamset1.mat');

    [nondimshapes, stiff] = constructSeqParms(sequence, params);  
    curshapes = nondim2cur(nondimshapes);
    printShapeParms(curshapes, sequence, 'shapes.txt');  
    basepair = frames(nondimshapes);   
    makePDB(sequence, basepair, 'base_atoms.pdb');

    %% Save ground-state coordinates and stiffness to a mat file.
    save('constructed_seq_parms.mat','stiff','nondimshapes');

    %% Save Curves+ coordinates to a mat file.
    save('curshapes.mat','curshapes');

    %% Save the basepair structure to a mat file.
    save('absolute_coord.mat', 'basepair'); 

    %% Save the point and frame information to a text file.  
    %  See also: help print_frames
    printFrames(basepair, 'base_frames1.bfr', 1);
    printFrames(basepair, 'base_frames2.fra', 2);

    %-------------------------------------------------------
    %% see main_energy.m for a detailed explanation of the following operations
    lis = 'test_reference/1bna.lis';
    [configuration, S] = parseLis(lis);
    [nondimshapes, stiff] = constructSeqParms(S, params);
    modified_configuration = configuration;
    modified_configuration(45) = configuration(45) + 5.0;
    deltaU = freeEnergyDiff(cur2nondim( configuration ), ...
                            cur2nondim( modified_configuration ), ...
                            nondimshapes, stiff);

    %% save a .pdb file of the .lis information
    makePDB(S, frames(cur2nondim(configuration)), '1bna_bases.pdb');

    %% Save the deltaU value to a mat file.
    save('deltaU.mat', 'deltaU'); 
    %-------------------------------------------------------

    clear;
    %-------------------------------------------------------
    %% CHECK output against reference (test_reference/)
    %-------------------------------------------------------
    global anyfailed;
    anyfailed = 0;

    %% 1) constructSeqParms.m
    load('constructed_seq_parms.mat');
    constru = load('test_reference/constructed_seq_parms.mat');
    diff = [0.0 0.0];
    diff = asum(diff, nondimshapes - constru.shapes);
    testcheck( 1, 'Model construction (shapes)', diff(1)/diff(2), 1e-10);

    diff = [0.0 0.0];
    diff = asum(diff, stiff - constru.stiff);
    testcheck( 2, 'Model construction (stiffness)', diff(1)/diff(2), 1e-10);

    %% 2) frame.m
    load('absolute_coord.mat');
    abscoor = load('test_reference/absolute_coord.mat');
    diff = [0.0 0.0];
    for i=1:numel(basepair)
        diff = asum(diff, basepair(i).D  - abscoor.basepair(i).D);
        diff = asum(diff, basepair(i).Dc - abscoor.basepair(i).Dc);
        diff = asum(diff, basepair(i).r  - abscoor.basepair(i).r);
        diff = asum(diff, basepair(i).rc - abscoor.basepair(i).rc);
    end
    testcheck( 3, 'Frame reconstruction', diff(1)/diff(2), 1e-10);

    %% 3) nondim2cur
    load('curshapes.mat');
    redim = load('test_reference/curshapes.mat');
    diff = [0.0 0.0];
    diff = asum(diff, curshapes - redim.curshapes);
    testcheck( 4, 'Re-dimensionalisation', diff(1)/diff(2), 1e-10);

    %% 4) deltaU
    load('deltaU.mat');
    refdU = load('test_reference/deltaU.mat');
    diff = abs(deltaU - refdU.deltaU);
    testcheck( 5, 'Free energy difference calculation', diff, 1e-10);

    %% 5) full double Curves+ cycle
    % starting from a .pdb
    %  - run Curves+ on 1bna.pdb to obtain: 1bna.lis
    %  - parse 1bna.lis and write out a base-only pdb: 1bna_bases.pdb
    %  - run Curves+ on 1bna_bases.pdb to obtain: 1bna_bases.lis
    %  - parse 1bna_bases.lis and compare to 1bna.lis
    %% a) check .pdb's with molecular viewer: pymol
    % 
    % load ../examples/1bna.pdb
    % load 1bna_bases.pdb
    % align 1bna, 1bna_bases
    %
    %% b) check .lis's

    if(exist('1bna_bases.lis') == 2)
        [configuration, S] = parseLis('test_reference/1bna_bases.lis');
        [nu_configuration, nu_S] = parseLis('1bna_bases.lis');
        diff = [0.0 0.0];
        diff = asum(diff, configuration - nu_configuration);
        testcheck( 6, 'Curves+ interaction (1): sequence', S, nu_S, @(x,y) any(x ~= y));
        testcheck( 7, 'Curves+ interaction (2): coordinates', diff(1)/diff(2), 1e-1);
    else
        fprintf([...
            'WARNING: To check compatibility with your Curves+ installation,\n',... 
            '\tplease run Curves+ on test/1bna_bases.pdb and re-run "cgDNAtests".\n',...
            '\tFor more information, please see the README file.\n'
                ]);
    end

    %-------------------------------------------------------
    if anyfailed
        fprintf([...
            '\n\n',...
            'WARNING: Some tests have failed.\n',...
            '\tPlease check your installation.\n'
                ]);
    else
        fprintf([...
            '\n\n',...
            'All tests PASSED.\n',...
            '\tHappy modelling!.\n'
                ]);
    end
    %-------------------------------------------------------
    clear;
end

function s = asum(x,y)
    s = [x(1)+sum(abs(y(:))) x(2)+numel(y)];
end

function [] = testfail(id) 
    fprintf('--> FAILED\n\nWARNING: TEST FAILED.  [CODE %05d]\n\n',id);
end

function [] = testsuccess(id) 
    fprintf(' PASSED\n');
end

function [] = testcheck(id, m, v, co, varargin)
    global anyfailed;
    fail = 0;
    lambda = @(x,y) x>y;
    if nargin > 4
        lambda = varargin{1};
    end
    fprintf('Testing(%05d) %s\n', id, m);
    if lambda(v, co)
        anyfailed = 1;
        testfail(id);
    else
        testsuccess(id);
    end
end
