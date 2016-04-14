function S = saveecosimseries(simfolder)
%SAVEECOSIMSERIES An interactive program to save Ecosim runs
%
% S = saveecosimseries(simfolder)
%
% This is an interactive program that allows you to run multiple
% simulations of Ecosim and save all data from all groups.  It requires a
% back-and-forth process between Ecosim and this program, prompting you to
% run simulations and save plot data.
%
% Note: If you only want to save the variables that do not change between
% functional groups, simply enter 1 for the number of functional groups.
%
% Input variables:
%
%   simfolder:  folder where Ecosim results are saved (same as database
%               location)
%
% Output variables:
%
%   S:          1 x n structure, where n is the number of simulations to be
%               run.  See allecosimread.m for description of fields.

% Copyright 2007 Kelly Kearney

narginchk(1,1);

if ~exist(simfolder,'dir')
    error('Cannot find input folder');
end

nsim = input('How many simulations will you be running? ');
ngroup = input('How many functionl groups are there in this model? '); 

S(1:nsim) = struct('database', [], 'ecopathModel', [], 'ecosimModel', [], ...
                   'groupName', [], 'biomass', [], 'qb', [], 'feeding', [], ...
                   'mortality', [], 'weight', [], 'yield', [], ...
                   'predation', [], 'prey', []);

for isim = 1:nsim

    fprintf('\nRun simulation %d, then press any key\n', isim);
    pause;
    
    for igroup = 1:ngroup
        fprintf('    Plot results for group %d, save, then press any key\n', igroup);
        pause;

        if igroup == 1
            S(isim) = allecosimread(simfolder);
        else
            S(isim) = allecosimread(simfolder, S(isim));
        end
    end
    
end
    

