function Data = ecosimread(simfile)
%ECOSIMREAD Reads the data from an Ecosim .csv file
%
% function [data, colnames, header] = ecosimread(simfile)
%
% This function reads the data from an Ecosim data file, which is produced
% by pressing the Save button after running an Ecosim simulation.
%
% Note: This function was designed for EwE version 5.  Later versions of
% EwE involved a full redesign of the GUI interface, and I have not updated
% this function for that interface.
%
% Input variables:
%
%   simfile:    name of Ecosim plot file
%
% Output variables:
%
%   Data:       1 x 1 structure with the following fields
%
%               header:     1 x 3 cell array of strings, holding EwE
%                           database name, Ecopath model name, and Ecosim
%                           simulation name
%
%               colnames:   1 x n cell array of strings, names of
%                           functional groups in simulation, corresponding
%                           to columns of data array
%
%               data:       m x n array of data values, where m is the
%                           number of time steps and n is the number of
%                           functional groups.  Data may be biomass,
%                           consumption over biomass, feeding time,
%                           mortality,  predation, prey, or weight.

% Copyright 2007 Kelly Kearney


%-----------------------------
% Check input
%-----------------------------

error(nargchk(1,1,nargin));

if ~exist(simfile, 'file')
    error('Cannot find input file');
end

fid = fopen(simfile, 'rt');

%-----------------------------
% Read file
%-----------------------------

line1 = fgetl(fid);
line2 = fgetl(fid);

% Read header line

if regexp(line1, '"')
    line1 = [',' line1 ','];
    Data.header = regexp(line1, '(?<=,)[^"]*(?=,)|(?<=,\s*")[^"]*(?="\s*,)', 'match');
else
    Data.header = strread(line1, '%s', 'delimiter', ',')';
end
    

% Read column names

if regexp(line2, '"')
    line2 = [',' line2 ','];
    Data.colnames = regexp(line2, '(?<=,)[^"]*(?=,)|(?<=,\s*")[^"]*(?="\s*,)', 'match');
else
    Data.colnames = strread(line2, '%s', 'delimiter', ',')';
end
    
ncol = length(Data.colnames);

% Read data

data = textscan(fid, '%s', 'delimiter', '\n');
data = data{1};
data = cellfun(@str2num, data, 'uni', 0); 
Data.data = cell2mat(data);

% NOTE EwE 6 doesn't print detritus results, so this old code doesn't work
% anymore

% data = textscan(fid, '%s', 'delimiter', '\n');
% Data.data = reshape(data{1}, ncol, [])';
    