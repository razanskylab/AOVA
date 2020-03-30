function FullData = Get_Full_Data(AVA,mask, imageCenter)
  % extracts vessel data in an easier to process way for statistics
  % not good for plotting, as we loose the information which vessel segments 
  % belong together... 
  % if mask is supplied, make sure it fit's the image data, then apply to only 
  % keep information within the mask
  % TODO calculate total vessel area and coverage 
  % (vessel segment length * diameter? / total area)
  % TODO make sure that what we are doing here makes sense
  % ADD DEBUG plot option!!!

  if nargin < 2
    mask = [];
  end 
  if nargin < 3
    % assume center of image (for distance and angle calculation) 
     % as geo. center withhout a mask
    imageCenter = [mean(AVA.x), mean(AVA.y)];
  end 

  doApplyMask = ~isempty(mask);
  if doApplyMask && ~isequal(size(AVA.xy), size(mask))
    short_warn('[AVA:Get_Full_Data] Mask size does not match image size!');
    doApplyMask = false;
  end

  FullData = [];
  % before we apply the mask, we need to get all the data, so we know where
  % the vessels and vessel segments are. 

  % get segment data -----------------------------------------------------------
  vList = AVA.Data.vessel_list;
  fun = @(x) cat(1, x);
  segCenter = cellfun(fun, {vList.centre}, 'UniformOutput', false);
  segCenter = cell2mat(segCenter')';

  unitVectors = cellfun(fun, {vList.angles}, 'UniformOutput', false);
  unitVectors = cell2mat(unitVectors');
  angles = atan2d(unitVectors(:, 2), unitVectors(:, 1))';
  % angles(angles < 0) = angles(angles < 0) + 180; % only use 0 - 180 deg
  angles(angles > 90) = angles(angles > 90) - 180; % only use +/- 90 deg
  angles(angles < -90) = angles(angles < -90) + 180; % only use +/- 90 deg

  segDiameters = cellfun(fun, {vList.diameters}, 'UniformOutput', false);
  segDiameters = cell2mat(segDiameters')';

  % get vessel data ------------------------------------------------------------
  lengthStraight = [vList(:, 1).length_straight_line];
  lengthCum = [vList(:, 1).length_cumulative];
  turtosity = calculate_turtosity(lengthCum,lengthStraight);

  vesCenter = AVA.averageCenters; % average center of each vessel 
  vesDiameter = AVA.averageDiameters; % average diameter of each vessel

  % get general data (scalar) --------------------------------------------------
  totalLength = sum(lengthCum);
  area = AVA.imageArea;
  nVessel = AVA.nVessels;
  nBranches = AVA.nBranches;
  nSegments = AVA.nSegments;
  vesselDensity = AVA.vesselDensity;
  branchDensity = AVA.branchDensity;

  % branch related 
  branchCenter = AVA.Data.branchCenters';

  % if we have a valid mask, apply it to the vessel data to only keep data
  % within the masked areas
  if doApplyMask
    % convert sub-pixel centers to x-y idx
    segCtrIdx = round(segCenter); 
    vesCtrIdx = round(vesCenter); 
    branchCtrIdx = round(branchCenter); 

    % now convert x-y idx to linear idx, so we don't need for loops
    segCtrIdx = sub2ind(size(mask),segCtrIdx(2,:),segCtrIdx(1,:)); 
    vesCtrIdx = sub2ind(size(mask),vesCtrIdx(2,:),vesCtrIdx(1,:)); 
    branchCtrIdx = sub2ind(size(mask),branchCtrIdx(2,:),branchCtrIdx(1,:)); 

    % create false idx same size as centers
    segInMask = false(size(segCtrIdx,1),1);
    vesInMask = false(size(vesCtrIdx,1),1);
    branchInMask = false(size(branchCtrIdx,1),1);

    % only set the indicies inside the mask to be kept
    segInMask(mask(segCtrIdx)) = true;
    vesInMask(mask(vesCtrIdx)) = true;
    branchInMask(mask(branchCtrIdx)) = true;

    % only keep data for wanted segments
    segCenter = segCenter(:,segInMask); 
    angles = angles(:,segInMask);
    segDiameters = segDiameters(:,segInMask);

    % only keep data for wanted vessels
    vesCenter = vesCenter(:,vesInMask); 
    turtosity = turtosity(:,vesInMask); 
    vesDiameter = vesDiameter(:,vesInMask); 
    lengthCum = lengthCum(:,vesInMask); 
    
    % only keep data for wanted branches
    branchCenter = branchCenter(:,branchInMask); 
    
    % correct scalar values
    area = sum(mask); % just count the pixels in the 
    totalLength = sum(lengthCum);
    nVessel = sum(vesInMask);
    nSegments = sum(segInMask);
    nBranches = sum(branchInMask);
    vesselDensity = nVessel./area;
    branchDensity = nBranches./area;
  end

  % calculate values with respect to image/mask center
  xCtr = imageCenter(1);
  yCtr = imageCenter(2);
  % calculate angles and distances to center with respect to image center
  segAngle = rad2deg(atan((segCenter(1,:)-xCtr)./(segCenter(2,:)-yCtr)));
  ctrAngle = angles-segAngle; 

  vesCtrDistance = sqrt((vesCenter(1,:)-xCtr).^2 + (vesCenter(2,:)-yCtr).^2);
  segCtrDistance = sqrt((segCenter(1,:)-xCtr).^2 + (segCenter(2,:)-yCtr).^2);

  % now store all that data in the FullData struct... -------------------------
  % general (scalar) data
  FullData.area = area;
  FullData.totalLength = totalLength;
  FullData.nVessel = nVessel;
  FullData.nSegments = nSegments;
  FullData.nBranches = nBranches;
  FullData.vesselDensity = vesselDensity;
  FullData.branchDensity = branchDensity;

  % vessel data (n = nVessels)
  FullData.vesCenter = vesCenter;
  FullData.vesCtrDistance = vesCtrDistance;
  FullData.vesDiameter = vesDiameter;
  FullData.turtosity = turtosity;

  % segment data (n = nSegments)
  FullData.segCenter = segCenter;
  FullData.segDiameters = segDiameters;
  FullData.segCtrDistance = segCtrDistance;
  FullData.angles = angles;
  FullData.ctrAngle = ctrAngle;
  
  % branch data
  FullData.branchCenter = branchCenter;
  

end
