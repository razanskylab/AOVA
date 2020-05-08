function [DS] = Get_Full_Data(AVA)
  pxToMu = AVA.pxToMu;
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
  % centerAngle
  % segAngles
  % angleDiff
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
  % meanAngleDiff
  % medianDiameter
  % medianLength
  % medianTurtosity
  % medianAngleDiff
  % growthArea  % size of area where vessels are growing 
  % vesselGrowthDensity 
  % branchGrowthDensity 
  % lengthGrowthFraction 
  %
  % TODO calculate total vessel area and coverage 
  % (vessel segment length * diameter? / total area)
  % TODO make sure that what we are doing here makes sense

  % TODO transfer angleRanges and angleWiggle to table
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
  DS.segCtrDistance = sqrt((DS.segCenter(2,:)-xCtr).^2 + (DS.segCenter(1,:)-yCtr).^2);

  % diameter of ind. segments  
  DS.segDiameters = cellfun(fun, {vList.diameters}, 'UniformOutput', false);
  DS.segDiameters = cell2mat(DS.segDiameters')';
  DS.segDiameters = DS.segDiameters.*pxToMu;

  % get angle the segment SHOULD have when pointing at image center point
  xDist = DS.segCenter(1,:)-xCtr;
  yDist = DS.segCenter(2,:)-yCtr;
  centerAngle = atan2d(xDist,yDist);
  centerAngle(centerAngle > 90) = centerAngle(centerAngle > 90) - 180; % only use +/- 90 deg
  centerAngle(centerAngle < -90) = centerAngle(centerAngle < -90) + 180; % only use +/- 90 deg
  DS.centerAngle = centerAngle;

  % extract the actual angle that the individual vessel segment had
  unitVectors = cellfun(fun, {vList.angles}, 'UniformOutput', false);
  unitVectors = cell2mat(unitVectors');
  DS.segAngles = -atan2d(unitVectors(:, 2), unitVectors(:, 1))';
  DS.segAngles(DS.segAngles > 90) = DS.segAngles(DS.segAngles > 90) - 180; % only use +/- 90 deg
  DS.segAngles(DS.segAngles < -90) = DS.segAngles(DS.segAngles < -90) + 180; % only use +/- 90 deg
  
  % calculate difference between target and actual angle
  angleDiff = DS.segAngles - DS.centerAngle; 
  angleDiff(angleDiff > 90) = 180 - angleDiff(angleDiff > 90);
  angleDiff(angleDiff < -90) = 180 + angleDiff(angleDiff < -90); % only use +/- 90 deg
  DS.angleDiff = abs(angleDiff);

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
  
  DS.area = AVA.imageArea.*pxToMu^2;
  DS.vesselDensity = DS.nVessel./DS.area;

  DS.segCtrDistance = DS.segCtrDistance.*pxToMu;
  DS.segDiameters = DS.segDiameters.*pxToMu;
  DS.lengthStraight = DS.lengthStraight .*pxToMu;
  DS.lengthCum = DS.lengthCum.*pxToMu;
  DS.vesCtrDistance = DS.vesCtrDistance.*pxToMu;
  DS.vesDiameter =  DS.vesDiameter.*pxToMu;
  DS.totalLength = DS.totalLength.*pxToMu;
  DS.vesselDensity = AVA.vesselDensity.*pxToMu;

  DS.lengthFraction = DS.totalLength./DS.area; 
  if DS.lengthFraction > 1
    short_warn('we have more vessels than the image size...');
  end

  % NOTE imageCenter stays in Pixel for various reasons related to plotting...
  DS.imageCenter = AVA.imageCenter; 
  [nY,nX] = size(AVA.xy);
  DS.imageSize = [nX nY];

  % get some simple overall statistics, so we don't have to extract them from the
  % table later...
  DS.meanDiameter = mean(DS.segDiameters);
  DS.meanLength = mean(DS.lengthCum);
  DS.meanTurtosity = mean(DS.turtosity);
  DS.meanAngleDiff = mean(DS.angleDiff);

  DS.medianDiameter = median(DS.segDiameters);
  DS.medianLength = median(DS.lengthCum);
  DS.medianTurtosity = median(DS.turtosity);
  DS.medianAngleDiff = median(DS.angleDiff);
  DS.angleRanges = AVA.angleRanges;
  DS.angleStd = AVA.angleStd;
  DS.angleChange = AVA.angleChange;

  % branch related 
  % first get into correct shape to match (x1,y1; x2, y2) form like other centers
  DS.nBranches = AVA.nBranches;
  DS.branchDensity = DS.nBranches./DS.area;
  DS.branchCenter = AVA.Data.branchCenters';
  DS.branchCenter = flipud(DS.branchCenter);
  AVA.Done(startTic);
  
  % these are just here for completeness, they are used in mask data...
  % and to make sure that coversion to table works...
  DS.growthArea = []; % size of area where vessels are growing 
  DS.vesselGrowthDensity = [];
  DS.branchGrowthDensity = [];
  DS.lengthGrowthFraction = [];
  
  
  % if AVA.verbosePlotting
  %   tic;
  %   AVA.PrintF('[Get_Full_Data] Generating debug plot...');

  %   dFig = figure();
  %   TL = tiledlayout(dFig,'flow');
  %   TL.Padding = 'compact'; % remove uneccesary white space...

  %   nexttile();
  %   imagescj(AVA.xy); axis off;  colorbar off;
  %   hold on;
  %   markerSize = 10;
  %   scatter(DS.segCenter(2,:),DS.segCenter(1,:),...
  %     markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
  %   title('Segments');

  %   % nexttile();
  %   % imagescj(AVA.xy); axis off; colorbar off;
  %   % hold on;
  %   % scatter(remVesCenter(2,:),remVesCenter(1,:),...
  %   %   markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
  %   % scatter(DS.vesCenter(2,:),DS.vesCenter(1,:),...
  %   %   markerSize,'filled','MarkerFaceColor',Colors.DarkGreen);
  %   % title('Removed / Kept Vessels');

  %   % nexttile();
  %   % imagescj(AVA.xy); axis off; colorbar off;
  %   % hold on;
  %   % scatter(remBranchCenter(2,:),remBranchCenter(1,:),...
  %   %   markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
  %   % scatter(DS.branchCenter(2,:),DS.branchCenter(1,:),...
  %   %   markerSize,'filled','MarkerFaceColor',Colors.DarkGreen);
  %   % title('Removed / Kept Branches');

  %   done(toc);
  % end

end

