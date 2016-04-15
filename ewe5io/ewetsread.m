function Data = ewetsread(filename)
%EWETSREAD Reads a EwE-formatted time series file
%
% Data = ewetsread(filename)
%
% This function reads in Ecopath with Ecosim (EwE) time-series data.  EwE
% uses specifically-formatted .csv files for this purpose; see the EwE
% documentation for details.
%
% Input variables:
%
%   filename:   name of EwE .csv file
%
% Output variable:
%
%   Data:       structure with the following fields:
%               
%               titles:     1 x n cell array, titles of data columns
%               
%               poolCodes:  1 x n array of indices indicating the
%                           functional groups to which each data column
%                           applies (unless type = 2; then this is the
%                           number of the new forcing function, from 4
%                           upwards)  
%
%               types:      1 x n array defining type of data in each
%                           column
%                           -1 Force biomass
%                            0 Relative biomass
%                            1 Absolute biomass
%                            2 Time forcing data
%                            3 Effort data by gear type
%                            4 Fishing mortality (F) by pool
%                            5 Total mortality (Z) by pool
%                           -5 Forced total mortality (Z)
%                            6 Catches
%                           -6 Forced catches
%                            7 Average weight (stanza/split groups only)
%
%               years:      m x 1 array of years to which data rows
%                           correspond
%
%               data:       m x n array of data values

% Copyright 2007 Kelly Kearney

%-------------------
% Check input
%-------------------

narginchk(1,1);

if ~exist(filename, 'file')
    error('Cannot find file');
end

%-------------------
% Read file
%-------------------

fid = fopen(filename, 'rt');
allFile = textscan(fid, '%s', 'delimiter', '\n');
allFile = allFile{1};
fclose(fid);

% Temporarily replace commas within cells and remove quotes

for iline = 1:length(allFile)
    commaStr = regexp(allFile{iline}, '(?<=,\s*)"[^"]*"(?=\s*,)', 'match');
    for istr = 1:length(commaStr)
        commaStrNew = regexprep(commaStr{istr}, ',', 'COMMA');
        commaStrNew = regexprep(commaStrNew, '"', '');
        allFile{iline} = regexprep(allFile{iline}, commaStr, commaStrNew);
    end
end

% Read comma-separated values

fileData = cellfun(@(x) textscan(x, '%s', 'delimiter', ','), allFile);
fileData = fileData';
fileData = cat(2, fileData{:});
fileData = fileData';

% Replace comma placeholder with comma

fileData = regexprep(fileData, 'COMMA', ',');

% Header lines

temp = cellfun(@str2double, fileData(:,1));
headerLines = fileData(isnan(temp),:);
dataLines = fileData(~isnan(temp), :);

titleLine = find(strcmpi('Title', headerLines(:)));
poolCodeLine = find(strcmpi('Group', headerLines(:)) | strcmpi('Pool code', headerLines(:)));
weightLine = find(strcmpi('Weight', headerLines(:)));
typeLine = find(strcmpi('Type', headerLines(:)));

Data.titles = headerLines(titleLine, 2:end);
Data.poolCodes = cellfun(@str2num, headerLines(poolCodeLine, 2:end));
Data.types = cellfun(@str2num, headerLines(typeLine, 2:end));
if ~isempty(weightLine)
    Data.weight = cellfun(@str2num, headerLines(weightLine, 2:end));
end

% Data

Data.years = cellfun(@str2num, dataLines(:,1));
temp = dataLines(:,2:end);
Data.data = NaN(size(temp));
isemp = cellfun(@isempty, temp);
Data.data(~isemp) = cellfun(@str2num, temp(~isemp));

% fid = fopen(filename, 'rt');
% allFile = textscan(fid, '%s', 'Delimiter', ',');
% allFile = allFile{1};
% 
% [tf, lineTwoStart] = ismember('Pool code', allFile);
% ncol = lineTwoStart - 1;
% 
% allFile = reshape(allFile, ncol, [])';
% 
% Data.titles    = allFile(1,2:end);
% Data.poolCodes = cellfun(@str2num, allFile(2,2:end));
% Data.types     = cellfun(@str2num, allFile(3,2:end));
% Data.years     = cellfun(@str2num, allFile(4:end,1));
% 
% temp = allFile(4:end, 2:end);
% Data.data = NaN(size(temp));
% isemp = cellfun(@isempty, temp);
% Data.data(~isemp) = cellfun(@str2num, temp(~isemp));