function [DS] = Mask_Full_Data(AVA,DS,mask)
  % keep data where mask == true

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

  if sum(mask(:)) == numel(mask)
    AVA.VPrintF('\n');
    short_warn('[AVA:Mask_Full_Data] Mask == True everywhere!');
    short_warn('[AVA:Mask_Full_Data] Nothing to do...');
    return;
  end

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
  remBranchCenter = DS.branchCenter(:,~branchInMask); 

  % only keep data for wanted segments
  DS.segCenter = DS.segCenter(:,segInMask); 
  DS.angles = DS.angles(:,segInMask);
  DS.segDiameters = DS.segDiameters(:,segInMask);

  % only keep data for wanted vessels
  DS.vesCenter = DS.vesCenter(:,vesInMask); 
  DS.turtosity = DS.turtosity(:,vesInMask); 
  DS.vesDiameter = DS.vesDiameter(:,vesInMask); 
  DS.lengthCum = DS.lengthCum(:,vesInMask); 
  
  % only keep data for wanted branches
  DS.branchCenter = DS.branchCenter(:,branchInMask); 
  
  % correct scalar values
  DS.area = sum(mask); % TODO fixme just count the pixels in the mask
  DS.totalLength = sum(DS.lengthCum);
  DS.nVessel = sum(vesInMask);
  DS.nSegments = sum(segInMask);
  DS.nBranches = sum(branchInMask);
  DS.vesselDensity = DS.nVessel./DS.area;
  DS.branchDensity = DS.nBranches./DS.area;

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

  if AVA.verbosePlotting
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

    nexttile();
    imagescj(AVA.xy); axis off;  colorbar off;
    hold on;
    markerSize = 10;
    scatter(remSegCenter(2,:),remSegCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
    scatter(DS.segCenter(2,:),DS.segCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkGreen);
    title('Removed / Kept Segments');

    nexttile();
    imagescj(AVA.xy); axis off; colorbar off;
    hold on;
    scatter(remVesCenter(2,:),remVesCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
    scatter(DS.vesCenter(2,:),DS.vesCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkGreen);
    title('Removed / Kept Vessels');

    nexttile();
    imagescj(AVA.xy); axis off; colorbar off;
    hold on;
    scatter(remBranchCenter(2,:),remBranchCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
    scatter(DS.branchCenter(2,:),DS.branchCenter(1,:),...
      markerSize,'filled','MarkerFaceColor',Colors.DarkGreen);
    title('Removed / Kept Branches');


    done(toc);
  end





end