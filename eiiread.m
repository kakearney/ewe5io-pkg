function S = eiiread(filename)
%EIIREAD Reads an Ecopath II text file
%
%  S = eiiread(filename)
%
% This function reads in the data from a .eii (Ecopath II) text file.
% These files are produced via the "Export text" option in the File menu of
% an Ecopath simulation.  The file stores all the input data for the
% Ecopath model, but does not include remarks or Ecosim scenarios.
%
% Note: These files have been discontinued in the Version 6 release of EwE,
% so I am now relying on the cut-and-paste method of ewecsv2ewein to get
% data from an EwE model into Matlab, and am no longer updating this file
% to match changes in ecopathlite and ecosimlite.
%
% Input variables:
%
%   filename:       name of .eii file
%
% Output variables:
%
%   S:              1 x 1 structure holding variables stored in the file.
%                   Variable names match those used in the VB6 code, with a
%                   few minor modifications to avoid Matlab keywords.
% 
%                   ngroup:         scalar
%                                   number of functional groups in model
% 
%                   nlive:          scalar
%                                   number of live, non-detrital groups
% 
%                   currUnit:       string
%                                   currency unit ('J/m^2', 'kcal/m^2',
%                                   'g/m^2', 't/km^2', 'mg N/m^2', 'mg
%                                   P/m^2', or other)  
% 
%                   currUnitIndex:  scalar
%                                   index of currency unit
%
%                   specie:         ngroup x 1 cell array of strings
%                                   names of functional groups
% 
%                   dtImp:          ngroup x 1 array
%                                   detrital import into the system
%                                   currUnit/timeUnit
% 
%                   ex:             ngroup x 1 array
%                                   exports (including catches) out of 
%                                   system
%                                   currUnit/timeUnit
% 
%                   catches:        ngroup x 1 array
%                                   total fishery catches
%                                   currUnit/timeUnit
%
%                   dci_c0:         ngroup + 1 x 1 array
%                                   imports into system for each group
% 
%                   bi:             ngroup x 1 array
%                                   average biomass per unit area in the
%                                   habitat area 
%                                   currUnit
% 
%                   pbi:            ngroup x 1 array
%                                   production/biomass ratio, equivalent to
%                                   the instantaneous rate of total
%                                   mortality, P/B = Z = F + M2 + NM + BA +
%                                   M0   
%                                   /timeUnit
% 
%                   eei:            ngroup x 1 array
%                                   ecotrophic efficiency, fraction of the
%                                   production that is used by the system
%                                   for biomass accumulation, migration, or
%                                   export, between 0 and 1
%                                   dimensionless
% 
%                   gei:            ngroup x 1 array
%                                   production/consumption, gross food
%                                   conversion efficiency
%                                   dimensionless
% 
%                   qbi:            ngroup x 1 array
%                                   consumption/biomass ratio
%                                   /timeUnit
%
%                   pp:             ngroup x 1 array
%                                   1 = is primary producer, 0 = is not 
%                                   primary producer
%
%                   dci:            ngroup+1 x ngroup+1 array
%                                   dc(i,j) tells the fraction of
%                                   functional group group{i}'s diet that
%                                   is composed of function group group{j}.
%                                   All values in dc(i,:) are 0 if group{i}
%                                   is a primary producer; otherwise,
%                                   dc(i,:) sums to 1.
%                                   dimensionless
% 
%                   gs:             1 x ngroup array
%                                   fraction of food that is not 
%                                   assimilated
%                                   dimensionless
% 
%                   timeUnitName:   string
%                                   time unit ('year', 'day', other)
%
%                   timeUnitIndex:  scalar
%                                   index of time unit (1, 2 ,3)
% 
%                   modelRemarks:   string
%                                   user-entered comments regarding the
%                                   model
% 
%                   bai:            1 x ngroup array
%                                   biomass accumulation (if ba ~= 0, 
%                                   Ecopath is not a steady-state model)
%                                   currUnit/timeUnit
% 
%                   df:             ngroup x (ngroup - nlive) array
%                                   detritus fate, where detritus left over
%                                   after detritivores have covered food
%                                   intake is directed. (1 - df) is
%                                   exported out of the system.   
%                                   dimensionless
% 
%                   emigrationi:    1 x ngroup array
%                                   migration out of the area covered by 
%                                   the model
%                                   currUnit/timeUnit
% 
%                   immigi:         1 x ngroup array
%                                   migration into the area covered by the
%                                   model
%                                   currUnit/timeUnit
% 
%                   ngear:          scalar
%                                   number of fishing fleets/gears
% 
%                   gearName:       ngear x 1 cell array of strings
%                                   names of fishing fleets
% 
%                   costPct:        ngear x 3 array
%                                   fixed costs, effort-related costs, and
%                                   spatially-related (sailing) costs,
%                                   expressed as percentages of total value
%                                   of the fishery in a given year   
% 
%                   landing:        ngear x ngroup array
%                                   total landings per gear and group
%                                   (catch = landing + discard)
%                                   currUnit/timeUnit
% 
%                   discard:        ngear x ngroup array
%                                   discards per gear and group
%                                   currUnit/timeUnit
% 
%                   discardFate:    ngear x (ngroup - nlive) array
%                                   fraction of discards that go to each
%                                   detrital group
%                                   dimensionless
% 
%                   market:         ngear x ngroup array
%                                   market value of each group for each
%                                   gear 
%                                   monetary unit/unit catch
% 
%                   shadow:         1 x ngroup array
%                                   shadow (non-market) price of a resource
%                                   for non-exploitative uses
% 
%                   areas:          1 x ngroup array
%                                   fraction of total area in which each
%                                   group occurs 
%                                   dimensionless
% 
%                   bhi:            1 x ngroup array
%                                   habitat biomass, biomass per unit area
%                                   (bh = b/area)


% Copyright 2007 Kelly Kearney

%----------------------------
% Read in file as cell array
%----------------------------

if ~exist(filename, 'file')
    error('File %s does not exist', filename);
end

fid = fopen(filename, 'rt');
fileText = textscan(fid, '%s', 'delimiter', '\n');
fileText = fileText{1};
fclose(fid);

%----------------------------
% Read header line
%----------------------------

% Parse header line

[ngroup, nlive, currUnit, currUnitIndex] = strread(fileText{1}, ...
                                           '%d%d%s%d', 'delimiter', ',');
currUnit = removequotes(currUnit{1});

% Line markers
        
line1  = 2;                   % Begin basic input
line2  = ngroup + 1;          % End basic input
line3  = line2 + 1;           % Begin diet composition
line4  = line3 + ngroup - 1;  % End diet composition
line5  = line4 + 2;           % Unassimilated food
line6  = line5 + 2;           % Time unit
line7  = line6 + 1;           % Remarks
line8  = line7 + 1;           % Biomass accumulation
line9  = line8 + 1;           % Begin detritus fate
line10 = line9 + ngroup - 1;  % End detritus fate
line11 = line10 + 2;          % Emmigration
line12 = line11 + 2;          % Immigration
line13 = line12 + 2;          % Number of gear

%----------------------------
% Preallocate variables 
% (RedimEiiData, 
% RedimGearVariables)
%----------------------------

% All variables here are indexed to the same maximum number as in the VB
% script for simplicity, rather than redefining all variables for an
% index-from-1 language.  If I encounter variables that actually use the
% 0th row or column, I'll create a new variable to hold that row/column.  

ndetritus = ngroup - nlive;

[estimateWhat, ex, catches, b, bi, bh, bhi, ba, bai, babi, pb, ee, ge, ...
 qb, pbi, eei, gei, qbi, pp, gs, mis, noBqb, tlSim, sumDc, bqb, resp, ...
 p, e, dtImp, detEaten, detPassedOn, detPassedProp, inputToDet, m0, m2, ...
 immig, immigi, emigration, emigrationi, emigi, shadow] = ...
                                                   deal(zeros(ngroup,1));
                                                      
areas = ones(ngroup,1);

[dc, dci] = deal(zeros(ngroup+1));
dci_c0 = zeros(ngroup+1,1);

specie = cell(ngroup,1);

df = zeros(ngroup,ndetritus);

%----------------------------
% Basic input
%----------------------------

temp = regexp(fileText(line1:line2), '(?<=").*(?=")', 'match');
temp = cellfun(@(a) a{1}, temp, 'uni', 0);
specie(1:ngroup) = temp;

temp = regexprep(fileText(line1:line2), '".*"', '');
temp = str2num(strvcat(temp));

% From file

pvar              = temp(:,1);
dtImp(1:ngroup)   = temp(:,2);
ex(1:ngroup)      = temp(:,3);  
catches(1:ngroup) = temp(:,4);
dci_c0(1:ngroup)  = temp(:,5); 
bi(1:ngroup)      = temp(:,6);
pbi(1:ngroup)     = temp(:,7);
eei(1:ngroup)     = temp(:,8);
gei(1:ngroup)     = temp(:,9);
qbi(1:ngroup)     = temp(:,10);

pp(1:ngroup) = pvar - 2;
pp(nlive+1:end) = 2;
gei(gei == 0) = -9;

%----------------------------
% Diet composition
%----------------------------

dci(1:ngroup,1:ngroup) = str2num(strvcat(fileText(line3:line4)));

%----------------------------
% Other biology-related 
% variables
%----------------------------

% Unassimilated food

temp = reshape(str2num(fileText{line5}), 2, []);
gs(1:ngroup) = temp(2,:);
ispos = temp(1,:) > 0;
gs(ispos) = gs(ispos) + temp(1,ispos)';
gs(gs > 1) = gs(gs > 1)/100;

% Time unit

timeUnitName = lower(removequotes(fileText{line6}));
[tf, timeUnitIndex] = ismember(timeUnitName, {'year', 'day'});
if ~tf
    timeUnitIndex = 3;
end

% Remarks

modelRemarks = removequotes(fileText{line7});

% Biomass accumulation

bai(1:ngroup) = str2num(fileText{line8});

% Detritus fate

df(1:ngroup,1:ndetritus) = str2num(strvcat(fileText(line9:line10)));

% Emmigration and immigration

emigrationi(1:ngroup) = str2num(fileText{line11});
immigi(1:ngroup)      = str2num(fileText{line12});

%----------------------------
% Fishing gear 
% variables
%----------------------------

ngear = str2num(fileText{line13});

%----------------------------
% Preallocate more variables
% (RedimGearVariables)
%----------------------------

[cost, costPct] = deal(zeros(ngear,3));

% gearName = cell(ngear+1);

[landing, discard, propLanded, propDiscard, market] = ...
                                             deal(zeros(ngear,ngroup));

discardFate = zeros(ngear, ndetritus);

% More line markers

line14 = line13 + 2;          % Begin gear names
line15 = line14 + ngear - 1;  % End gear names
line16 = line15 + 2;          % Begin cost
line17 = line16 + ngear - 1;  % End cost
line18 = line17 + 2;          % Begin landings
line19 = line18 + ngear - 1;  % End landings
line20 = line19 + 2;          % Begin discards
line21 = line20 + ngear - 1;  % End discards
line22 = line21 + 2;          % Begin discard fate
line23 = line22 + ngear - 1;  % End discard fate
line24 = line23 + 2;          % Begin market price
line25 = line24 + ngear - 1;  % End market price
line26 = line25 + 2;          % Shadow
line27 = line26 + 2;          % Area and biomass habitat

% Gear names

gearName = removequotes(fileText(line14:line15));

% Fixed cose, effort-related cost, sailing-related cost

costPct(1:ngear,1:3) = str2num(strvcat(fileText(line16:line17)));

% Landings

landing(1:ngear,1:ngroup) = str2num(strvcat(fileText(line18:line19)));

% Discards

discard(1:ngear,1:ngroup) = str2num(strvcat(fileText(line20:line21)));

% Discard fate

discardFate(1:ngear,1:ndetritus)=str2num(strvcat(fileText(line22:line23)));

% Market price

market(1:ngear,1:ngroup) = str2num(strvcat(fileText(line24:line25)));

%----------------------------
% Recently-added-to-EwE
% variables
%----------------------------

% Shadow

shadow(1:ngroup) = str2num(fileText{line26});

% Area and Habitat biomass

temp = reshape(str2num(fileText{line27}), 2, []);
areas(1:ngroup) = temp(1,:);
bhi(1:ngroup)  = temp(2,:);

%----------------------------
% Assign variables to output
% structures
%----------------------------

S = var2struct(ngroup, nlive, currUnit, currUnitIndex, ...
               specie, dtImp, ex, catches, dci_c0, bi, pbi, ...
               eei, gei, qbi, pp, dci, gs, timeUnitName, ...
               timeUnitIndex, modelRemarks, bai, df, ...
               emigrationi, immigi, ngear, gearName, costPct, ...
               landing, discard, discardFate, market, shadow, ...
               areas, bhi);

%----------------------------
% Subfunction: Remove double 
% quotes around strings
%----------------------------

function unquotestr = removequotes(quotestr)
unquotestr = regexprep(quotestr, '^"|"$', '');

%----------------------------
% Subfunction: Create 
% structure from variables
%----------------------------

function S = var2struct(varargin)
 
for ivar = 1:nargin
  args(:,ivar) = {inputname(ivar); varargin{ivar}};
  if iscell(varargin{ivar})
      args{2,ivar} = args(2,ivar);
  end
end
S = struct(args{:});