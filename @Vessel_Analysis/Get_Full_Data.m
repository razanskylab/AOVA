function [DS] = Get_Full_Data(AVA)
  % extracts vessel data in an easier to process way for statistics
  % not good for plotting, as we loose the information which vessel segments 
  % belong together... 
  % we extract the following info
  % area
  % imageCenter
  % totalLength
  % nVessel
  % nSegments
  % nBranches
  % vesselDensity
  % branchDensity
  % branchCenter
  % segCenter
  % segCtrDistance
  % segDiameters
  % segAngle
  % angles
  % ctrAngle
  % lengthStraight
  % lengthCum
  % turtosity
  % vesCenter
  % vesCtrDistance
  % vesDiameter
  % lengthFraction
  % meanDiameter
  % meanLength
  % meanTurtosity
  % meanCtrAngle
  % medianDiameter
  % medianLength
  % medianTurtosity
  % medianCtrAngle
  % growthArea  % size of area where vessels are growing 
  % vesselGrowthDensity 
  % branchGrowthDensity 
  % lengthGrowthFraction 
  %
  % TODO calculate total vessel area and coverage 
  % (vessel segment length * diameter? / total area)
  % TODO make sure that what we are doing here makes sense
  startTic = tic;
  AVA.VPrintF('Collecting full vessel, segment and branch data...')

  % calculate / extract all relevant vessel, branch and segment data and store 
  % in DS data struct...
  vList = AVA.Data.vessel_list; % all the raw data is in here...

  % calculate values with respect to image/mask center
  xCtr = AVA.imageCenter(1);
  yCtr = AVA.imageCenter(2);

  % get segment data -----------------------------------------------------------
  fun = @(x) cat(1, x);
  % get center points of individual segments
  DS.segCenter = cellfun(fun, {vList.centre}, 'UniformOutput', false);
  DS.segCenter = cell2mat(DS.segCenter')'; 
  % distance of ind. segments to center
  DS.segCtrDistance = sqrt((DS.segCenter(1,:)-xCtr).^2 + (DS.segCenter(2,:)-yCtr).^2);

  % diameter of ind. segments  
  DS.segDiameters = cellfun(fun, {vList.diameters}, 'UniformOutput', false);
  DS.segDiameters = cell2mat(DS.segDiameters')';

  % get angle the segment SHOULD have when pointing at image center point
  DS.segAngle = rad2deg(atan((DS.segCenter(1,:)-xCtr)./(DS.segCenter(2,:)-yCtr)));

  % extract the actual angle that the individual vessel segment had
  unitVectors = cellfun(fun, {vList.angles}, 'UniformOutput', false);
  unitVectors = cell2mat(unitVectors');
  DS.angles = atan2d(unitVectors(:, 2), unitVectors(:, 1))';
  DS.angles(DS.angles > 90) = DS.angles(DS.angles > 90) - 180; % only use +/- 90 deg
  DS.angles(DS.angles < -90) = DS.angles(DS.angles < -90) + 180; % only use +/- 90 deg
  
  % calculate difference between target and actual angle
  DS.ctrAngle = DS.angles-DS.segAngle; 

  % get vessel data ------------------------------------------------------------
  DS.lengthStraight = [vList(:, 1).length_straight_line];
  DS.lengthCum = [vList(:, 1).length_cumulative];
  DS.turtosity = calculate_turtosity(DS.lengthCum,DS.lengthStraight);

  DS.vesCenter = AVA.averageCenters; % average center of each vessel 
  DS.vesCtrDistance = sqrt((DS.vesCenter(1,:)-xCtr).^2 + (DS.vesCenter(2,:)-yCtr).^2);
  DS.vesDiameter = AVA.averageDiameters; % average diameter of each vessel

  % get general data (scalar) --------------------------------------------------
  DS.totalLength = sum(DS.lengthCum);
  DS.nVessel = AVA.nVessels;
  DS.nSegments = AVA.nSegments;
  
  DS.area = AVA.imageArea;
  DS.vesselDensity = AVA.vesselDensity;
  DS.imageCenter = AVA.imageCenter;
  [nY,nX] = size(AVA.xy);
  DS.imageSize = [nX nY];

  DS.lengthFraction = DS.totalLength./DS.area; 
  if DS.lengthFraction > 1
    short_warn('we have more vessels than the image size...');
  end

  % get some simple overall statistics, so we don't have to extract them from the
  % table later...
  DS.meanDiameter = mean(DS.segDiameters);
  DS.meanLength = mean(DS.lengthCum);
  DS.meanTurtosity = mean(DS.turtosity);
  DS.meanCtrAngle = mean(DS.ctrAngle);

  DS.medianDiameter = median(DS.segDiameters);
  DS.medianLength = median(DS.lengthCum);
  DS.medianTurtosity = median(DS.turtosity);
  DS.medianCtrAngle = median(DS.ctrAngle);

  % branch related 
  % first get into correct shape to match (x1,y1; x2, y2) form like other centers
  DS.nBranches = AVA.nBranches;
  DS.branchDensity = AVA.branchDensity;
  DS.branchCenter = AVA.Data.branchCenters';
  DS.branchCenter = flipud(DS.branchCenter);
  AVA.Done(startTic);
  
  % these are just here for completeness, they are used in mask data...
  % and to make sure that coversion to table works...
  DS.growthArea = []; % size of area where vessels are growing 
  DS.vesselGrowthDensity = [];
  DS.branchGrowthDensity = [];
  DS.lengthGrowthFraction = [];
  
end

