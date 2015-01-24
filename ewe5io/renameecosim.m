function renameecosim(folder, basename, ver)
%RENAMEECOSIM Rename the default Ecosim output files
%
% renameecosim(folder, basename, ver)
%
% Ecosim output data is automatically saved to a set of 8 .csv files.  The
% names of these files are fixed, so this utility allows you to quickly
% rename the files to a base name of your choice.
%
% Input variables:
%
%   folder:     folder where output files were saved.
%
%   basename:   new base name for files
%
%   ver:        5 or 6, Ecosim version

% Copyright 2007 Kelly Kearney

if ver == 6
    files = {'EwE6-Simplot_biomass.csv', ...
             'EwE6-Simplot_cons_biom.csv', ...
             'EwE6-Simplot_feedingtime.csv', ...
             'EwE6-Simplot_mortality.csv', ...
             'EwE6-Simplot_predation.csv', ...
             'EwE6-Simplot_prey.csv', ...
             'EwE6-Simplot_weight.csv', ...
             'EwE6-Simplot_yield.csv'};
elseif ver == 5
    files = {'Simplot_biomass.csv', ...
             'Simplot_cons_biom.csv', ...
             'Simplot_feedingtime.csv', ...
             'Simplot_mortality.csv', ...
             'Simplot_predation.csv', ...
             'Simplot_prey.csv', ...
             'Simplot_weight.csv', ...
             'Simplot_yield.csv'};
else
    error('Version must be 5 or 6');
end
     
oldfiles = cellfun(@(x) fullfile(folder,x), files, 'uni', 0);
if ver == 6
    newfiles = regexprep(files, 'EwE6-Simplot', basename);
else
    newfiles = regexprep(files, 'Simplot', basename);
end
cellfun(@(x,y) movefile(x,y), oldfiles, newfiles);
