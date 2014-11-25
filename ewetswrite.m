function ewetswrite(filename, titles, poolCodes, types, varargin)
%EWETSWRITE Creates an EwE-formatted .csv file
%
% ewetswrite(filename, titles, poolCodes, types, year1, data1, year2,
%            data2, ...) 
%
% This function creates a .csv time series file formatted for use in
% Ecopath with Ecosim (EwE). 
%
% Input variables:
%
%   titles:     vector cell array, titles of data columns.  If only one
%               data column is used, this can be a string. 
%               
%   poolCodes:  vector array of indices indicating the
%               functional groups to which each data column
%               applies
% 
%   types:      vector array defining type of data in each
%               column
%               -1 Force biomass
%                0 Relative biomass
%                1 Absolute biomass
%                2 Time forcing data
%                3 Effort data by gear type
%                4 Fishing mortality (F) by pool
%                5 Total mortality (Z) by pool
%               -5 Forced total mortality (Z)
%                6 Catches
%               -6 Forced catches
%                7 Average weight (stanza/split groups only)
% 
%   year#:      vector array of years
% 
%   data#:      vector array of data values corresponding to preceding year
%               array

% Copyright 2007 Kelly Kearney

%-----------------
% Check input
%-----------------

if ~iscell(titles)
    titles = cellstr(titles);
end


if ~isequal(length(titles), length(poolCodes), length(types), length(varargin)/2)
    error('Number of titles, pool codes, types, and year/data sets must be equal)');
end

datasets = reshape(varargin, 2, []);
years = datasets(1,:);
data = datasets(2,:);

if ~isequal(cellfun(@length, years), cellfun(@length, data))
    error('Each year array must have the same number of elements as corresponding data array');
end

%-----------------
% Write file
%-----------------

titleString = ['Title,' sprintf('%s,', titles{:})];
titleString(end) = [];
poolString = ['Pool code,' sprintf('%d,', poolCodes)];
poolString(end) = [];
typeString = ['Type,' sprintf('%d,', types)];
typeString(end) = [];

ndata = length(data);
if ndata > 1    
    %allYears = union(years{:});
    allYears = unique(cell2mat(years));
    nyears = length(allYears);
    allData = cell(nyears, ndata);
    for idata = 1:length(data)
        [tf, loc] = ismember(years{idata}, allYears);
        allData(loc, idata) = num2cell(data{idata});
    end
else
    allYears = years{1};
    nyears = length(allYears);
    allData = num2cell(data{1});
    allData = reshape(allData, [], 1);
end

dataString = cell(nyears,1);
for iyear = 1:nyears
    temp = sprintf('%9.4f,', allData{iyear,:});
    temp(end) = [];
    temp = regexprep(temp, '\s', ''); % remove spaces
    temp = regexprep(temp, '0*(?=$)|0*(?=,)', ''); % remove trailing zeros
    temp = regexprep(temp, '\.(?=$)|0*(?=,)', ''); % remove trailing .
    dataString{iyear} = sprintf('%d,%s', allYears(iyear), temp);
end

printtextarray([{titleString}; {poolString}; {typeString}; dataString], 'temp', 1); 

changenewline('temp', filename);
delete('temp');
    
