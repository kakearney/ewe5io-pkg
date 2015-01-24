function B = ewets2arrays(A, ngroup, ngear)
%EWETS2ARRAYS Create full arrays of data from an EwE time series
%
% The file format required for input of timeseries to the original EwE gui
% is not very easy to work with.  This function creates ntime x ngroup (or
% ntime x ngear) arrays, using NaN placeholders where no data is available.
%
% Input variables:
%
%   A:      ewe timeseries structure (see ewetsread.m)
%
%   ngroup: number of functional groups in model
%
%   ngear:  number of fisheries gears in model
%
% Output variables:
%
%   B:      structure with the following fields:
%
%           forcedbio:          ntime x ngroup, biomass values used to
%                               force a model 
%
%           relbio:             ntime x ngroup, biomass relative to initial
%                               biomass
%
%           absbio:             ntime x ngroup, absolute biomass
%
%           timeforce:          ntime x ngroup, time forcing data (?)
%
%           effort:             ntime x ngear, effort data relative to initial 
%
%           fishmort:           ntime x ngroup, fishing mortality per unit
%                               biomass
%
%           totalmort:          ntime x ngroup, total mortality per unit
%                               biomass
%
%           forcedtotalmort:    ntime x ngroup, mortality values used to
%                               force a model
%
%           catches:            ntime x ngroup, fishing yield
%
%           forcedcatches:      ntime x ngroup, catch data used to force a
%                               model
%
%           weight:             ntime x ngroup, average weight

% Copyright 2008 Kelly Kearney

type = {'forcedbio', 'relbio', 'absbio', 'timeforce', 'effort', 'fishmort', ...
        'totalmort', 'forcedtotalmort', 'catches', 'forcedcatches', ...
        'weight'};
    
marker = [-1 0 1 2 3 4 5 -5 6 -6 7];
col = ones(size(type)) * ngroup;
col(5) = ngear;

for itype = 1:length(type)
    
    isin = A.types == marker(itype);
    index = A.poolCodes(isin);

    data = nan(size(A.data,1), col(itype));
    data(:, index) = A.data(:,isin);
    
    B.(type{itype}) = data;
end