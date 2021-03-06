function [DS] = Mask_Full_Data(AVA,DS,mask,fullMask)
  % keep data where mask == true
  % if mask has a whole (like in wound data) but the area should be 
  % calculated without the hole, then supply the fullMask with the correct 
  % area...

  if (nargin < 4)
    fullMask = mask;
  end

  startTic = tic;
  AVA.VPrintF('Masking vessel, segment and branch data...')

  if ~isequal(size(AVA.xy), size(mask))
    AVA.VPrintF('\n');
    short_warn('[AVA:Mask_Full_Data] Mask size does not match image size!');
    short_warn('[AVA:Mask_Full_Data] Masks will be ignore!');
    return;
  end

  if ~islogical(mask)
    AVA.VPrintF('\n');
    short_warn('[AVA:Mask_Full_Data] Mask was converted to logical!');
    mask = logical(mask);
  end

  % if sum(mask(:)) == numel(mask)
  %   AVA.VPrintF('\n');
  %   short_warn('[AVA:Mask_Full_Data] Mask == True everywhere!');
  %   short_warn('[AVA:Mask_Full_Data] Nothing to do...');
  %   return;
  % end

  if sum(mask(:)) == 0
    AVA.VPrintF('\n');
    short_warn('[AVA:Mask_Full_Data] Mask == False everywhere!');
  end

  % count segments, vessels and branches before removal
  nVesselPre = DS.nVessel;
  nSegmentsPre = DS.nSegments;
  nBranchesPre = DS.nBranches;

  % convert sub-pixel centers to x-y idx
  segCtrIdx = round(DS.segCenter); 
  vesCtrIdx = round(DS.vesCenter); 
  branchCtrIdx = round(DS.branchCenter); 

  % now convert x-y idx to linear idx, so we don't need for loops
  segCtrIdx = sub2ind(size(mask),segCtrIdx(1,:),segCtrIdx(2,:)); 
  vesCtrIdx = sub2ind(size(mask),vesCtrIdx(1,:),vesCtrIdx(2,:)); 
  branchCtrIdx = sub2ind(size(mask),branchCtrIdx(1,:),branchCtrIdx(2,:)); 

  % create false idx same size as centers
  segInMask = false(size(segCtrIdx,1),1);
  vesInMask = false(size(vesCtrIdx,1),1);
  branchInMask = false(size(branchCtrIdx,1),1);

  % only set the indicies inside the mask to be kept
  segInMask(mask(segCtrIdx)) = true;
  vesInMask(mask(vesCtrIdx)) = true;
  branchInMask(mask(branchCtrIdx)) = true;

  % keep old data for debug plotting below
  remSegCenter = DS.segCenter(:,~segInMask); 
  remVesCenter = DS.vesCenter(:,~vesInMask); 

  % only keep data for wanted segments
  DS.segCenter = DS.segCenter(:,segInMask); 
  DS.segCtrDistance = DS.segCtrDistance(:,segInMask); 
  DS.segDiameters = DS.segDiameters(segInMask);
  DS.segAngles = DS.segAngles(:,segInMask);
  DS.centerAngle = DS.centerAngle(:,segInMask);
  DS.angleDiff = DS.angleDiff(segInMask);
  DS.angleAlign = DS.angleAlign(segInMask);

  % only keep data for wanted vessels
  DS.lengthStraight = DS.lengthStraight(vesInMask); 
  DS.lengthCum = DS.lengthCum(vesInMask); 
  DS.turtosity = DS.turtosity(vesInMask); 
  DS.vesCenter = DS.vesCenter(:,vesInMask); 
  DS.vesCtrDistance = DS.vesCtrDistance(:,vesInMask); 
  DS.vesDiameter = DS.vesDiameter(vesInMask); 
  DS.angleRanges = DS.angleRanges(vesInMask);  
  DS.angleStd = DS.angleStd(vesInMask);
  DS.angleChange = DS.angleChange(vesInMask);
  
  % only keep data for wanted branches
  DS.branchCenter = DS.branchCenter(:,branchInMask); 
  
  % correct scalar values
  DS.totalLength = sum(DS.lengthCum(:));
  DS.nVessel = sum(vesInMask(:));
  DS.nSegments = sum(segInMask(:));
  DS.nBranches = sum(branchInMask(:));
  
  DS.area = sum(fullMask(:)); % size of entire, old wound area in pixels
  DS.area = DS.area.*AVA.pxToMu^2; % convert to square microns...
  DS.vesselDensity = DS.nVessel./DS.area;
  DS.branchDensity = DS.nBranches./DS.area;
  DS.lengthFraction = DS.totalLength./DS.area;
  if DS.lengthFraction > 1
    short_warn('we have more vessels than the image size...');
  end

  DS.growthArea = sum(mask(:)); % size of area where vessels are growing 
  DS.growthArea = DS.growthArea.*AVA.pxToMu^2; % size of area where vessels are growing 
  DS.vesselGrowthDensity = DS.nVessel./DS.growthArea;
  DS.branchGrowthDensity = DS.nBranches./DS.growthArea;
  DS.lengthGrowthFraction = DS.totalLength./DS.growthArea;
  
  % get some simple overall statistics, so we don't have to extract them from the
  % table later...
  DS.meanDiameter =     mean(DS.segDiameters);
  DS.meanLength =       mean(DS.lengthCum);
  DS.meanTurtosity =    mean(DS.turtosity);
  DS.meanAngleDiff =    mean(DS.angleDiff);
  DS.meanAngleAlign =   mean(DS.angleAlign);
  DS.meanAngleChange =  mean(DS.angleChange);

  DS.medianDiameter =     median(DS.vesDiameter);
  DS.medianLength =       median(DS.lengthCum);
  DS.medianTurtosity =    median(DS.turtosity);
  DS.medianAngleDiff =    median(DS.angleDiff);
  DS.medianAngleAlign =   median(DS.angleAlign);
  DS.medianAngleChange =  median(DS.angleChange);

  % done, lets print some info
  AVA.Done(startTic);

  % plot how much we removed
  vesRemovedAbs = nVesselPre - DS.nVessel;
  vesRemovedPer = (1- DS.nVessel./nVesselPre)*100;
  segRemovedAbs = nSegmentsPre - DS.nSegments;
  segRemovedPer = (1- DS.nSegments./nSegmentsPre)*100;
  branchRemovedAbs = nBranchesPre - DS.nBranches;
  branchRemovedPer = (1- DS.nBranches./nBranchesPre)*100;
  AVA.VPrintF('   Removed %i (%2.2f %%) vessels.\n',vesRemovedAbs,vesRemovedPer);
  AVA.VPrintF('   Removed %i (%2.2f %%) segments.\n',segRemovedAbs,segRemovedPer);
  AVA.VPrintF('   Removed %i (%2.2f %%) branchpoints.\n',branchRemovedAbs,branchRemovedPer);

  if AVA.verbosePlotting && 1
    tic;
    AVA.PrintF('[Mask_Full_Data] Generating debug plot...');

    maskedImage = AVA.xy;
    maskedImage(~mask) = 0;

    dFig = figure();
    TL = tiledlayout(dFig,'flow');
    TL.Padding = 'compact'; % remove uneccesary white space...

    nexttile(); 
    imagescj(maskedImage); axis off;  colorbar off;
    title('Masked Image');

    % plot segments -------------------------------------------------------
    nexttile();
    imagescj(AVA.xy); axis off;  colorbar off;
    hold on;
    markerSize = 10;
    scatter(remSegCenter(2,:),remSegCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
    scatter(DS.segCenter(2,:),DS.segCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkGreen);
    title('Removed / Kept Segments');

    % plot vessels -------------------------------------------------------
    nexttile();
    imagescj(AVA.xy); axis off; colorbar off;
    hold on;
    scatter(remVesCenter(2,:),remVesCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
    scatter(DS.vesCenter(2,:),DS.vesCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkGreen);
    title('Removed / Kept Vessels');
  end

  if AVA.verbosePlotting && 0

    % plot vessel segAngles-------------------------------------------------------
    figure()
    tiledlayout('flow','TileSpacing','compact');

    cMap = hsv(20);
    t = nexttile();
    data =  DS.segAngles;
    center = DS.segCenter;
    scatter_plot_vessel_segments(center,data,cMap,10,0.75);
    colormap(t,cMap);
    CBar = colorbar(t);
    nDepthLabels = 9;
    tickLocations = linspace(0, 1, nDepthLabels); % juuuust next to max limits
    tickValues = linspace(min(data), max(data), nDepthLabels);
    for iLabel = nDepthLabels:-1:1
      zLabels{iLabel} = sprintf('%2.2f', tickValues(iLabel));
    end
    CBar.TickLength = 0;
    CBar.Ticks = tickLocations;
    CBar.TickLabels = zLabels;
    title('measure angle');

    t = nexttile();
    cMap = make_linear_colormap(Colors.PureRed,Colors.BrightGreen,20);
    data =  DS.angleDiff;
    center = DS.segCenter;
    scatter_plot_vessel_segments(center,data,cMap,10,0.75);
    colormap(t,cMap);
    CBar = colorbar(t);
    nDepthLabels = 9;
    tickLocations = linspace(0, 1, nDepthLabels); % juuuust next to max limits
    tickValues = linspace(min(data), max(data), nDepthLabels);
    for iLabel = nDepthLabels:-1:1
      zLabels{iLabel} = sprintf('%2.2f', tickValues(iLabel));
    end
    CBar.TickLength = 0;
    CBar.Ticks = tickLocations;
    CBar.TickLabels = zLabels;
    title('target angle');


    % done(toc);
  end
end