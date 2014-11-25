function S = allecosimread(varargin)
%ALLECOSIMREAD Saves all results from an Ecosim simulation
%
% S = allecosimread(basename)
% S = allecosimread(basename, S)
% S = allecosimread(basename, [], 0) <-- hack to ignore troublesome 
%                                        pred/prey files
%
% This function saves all the data from the eight .csv files produced by
% running and saving an Ecosim scenario (Run > Plot > Save).  Six of the
% eight files hold data for all functional groups in the model.  However,
% the other two (predation and prey) hold data only for the functional
% group that was visible at the time of saving.  Therefore, in order to
% collect all data for a simulation, this function will need to be run once
% for each functional group.  See savecosimseries.m for an automated way to
% do this.
%
% Note: This function was designed for EwE version 5.  Later versions of
% EwE involved a full redesign of the GUI interface, and I have not updated
% this function for that interface.
%
% Input variables:
%
%   base:   basename of files
%
%   S:      Previous structure created from the same model simulation but
%           for a different functional group.  New data will be added to
%           this structure.
%
%   
%
% Output variables:
%
%   S:      1 x 1 structure with the following fields (m = number of time
%           steps in model, n = number of functional groups): 
%
%           database:       string, database file
%
%           ecopathModel:   string, name of Ecopath model
%
%           ecosimModel:    string, name of Ecosim model
%
%           groupName:      1 x n cell array of strings, names of the
%                           functional groups
%
%           biomass:        m x n array of biomass values
%
%           qb:             m x n array of consumption over biomass values
%
%           feeding:        m x n array of feeding times
%
%           mortality:      m x n array of mortalities
%
%           weight:         m x n array of weights
%
%           yield:          m x n array of fishing yield values
%
%           predation:      1 x n cell array of m x n arrays, each cell
%                           represents one functional group.  Columns
%                           holding numeric data (as opposed to NaNs)
%                           represents predators of the functional group.
%
%           prey:           1 x n cell array of m x n arrays, each cell
%                           represents one functional group.  Columns
%                           holding numeric data (as opposed to NaNs)
%                           represent prey of the functional group.

% Copyright 2007 Kelly Kearney

basename = varargin{1};

if nargin > 2 && ~isempty(varargin{2})
    new = false;
    S = varargin{2};
else
    new = true;
    predprey = true;
end

if nargin == 3
    predprey = varargin{3};
end
    

%---------------------------
% Read files that include 
% data for all groups
%---------------------------

if new

    % Biomass file

    Bio = ecosimread([basename '_biomass.csv']);

    S.database     = Bio.header{1};
    S.ecopathModel = Bio.header{2};
    S.ecosimModel  = Bio.header{3};
    S.groupName    = Bio.colnames;
    S.biomass      = Bio.data;

    % Q/B file

    Qb = ecosimread([basename '_cons_biom.csv']);
    S.qb = Qb.data;

    % Feeding time file

    Feed = ecosimread([basename '_feedingtime.csv']);
    S.feeding = Feed.data;

    % Mortality file

    Mort = ecosimread([basename '_mortality.csv']);
    S.mortality = Mort.data;

    % Weight file

    Weight = ecosimread([basename '_weight.csv']);
    S.weight = Weight.data;

    % Yield file

    Yield = ecosimread([basename '_yield.csv']);
    S.yield = Yield.data;
    
end

[nyear, ngroup] = size(S.biomass); 

%---------------------------
% Read predator and prey 
% data
%---------------------------

if predprey
    if new
        S.predation = cell(1,ngroup);
        [S.predation{:}] = deal(NaN(nyear,ngroup));
        S.prey = cell(1,ngroup);
        [S.prey{:}] = deal(NaN(nyear,ngroup));
    end

    % Predation file

    Pred = ecosimread([basename '_predation.csv']);

    if ~isempty(Pred.colnames)
        [tf, iprey] = ismember(Pred.header{5}, S.groupName);
        [tf, ipred] = ismember(Pred.colnames, S.groupName);
        S.predation{iprey}(:,ipred) = Pred.data;
    end

    % Prey file

    Prey = ecosimread([basename '_prey.csv']);

    if ~isempty(Prey.colnames)
        [tf, ipred] = ismember(Prey.header{5}, S.groupName);
        [tf, iprey] = ismember(Prey.colnames, S.groupName);
        S.prey{ipred}(:,iprey) = Prey.data;
    end
end