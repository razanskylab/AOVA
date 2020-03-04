function Plot_Data_Overlay(AVA)
  vList = AVA.Data.vessel_list;
  whatOverlay = 'angle';

  fun = @(x) cat(1, x, [NaN NaN]);
  centers = cellfun(fun, {vList.centre}, 'UniformOutput', false);
  allCenters = cell2mat(centers');

  switch whatOverlay
  case 'angle' % per vessel-segment
    % get all unit vecrtors
    fun = @(x) cat(1, x, [NaN NaN]);
    unitVectors = cellfun(fun, {vList.angles}, 'UniformOutput', false);
    unitVectors = cell2mat(unitVectors');
    angles = atan2d(unitVectors(:, 1), unitVectors(:, 2));

  case 'diameter' % per vessel-segment
    % get all corresponding diameters
    fun = @(x) cat(1, x, NaN);
    diameters = cellfun(fun, {vList.diameters}, 'UniformOutput', false);
    allDiameters = cell2mat(diameters');
  case 'turtuosity' % per vessel
    fun = @(x) cat(1, x);
    cumLength = cellfun(fun, {vList.length_cumulative}, 'UniformOutput', false);
    cumLength = cell2mat(cumLength');
  
    fun = @(x) cat(1, x);
    straightLength = cellfun(fun, {vList.length_straight_line}, 'UniformOutput', false);
    straightLength = cell2mat(straightLength');

    turtuosity = cumLength./straightLength; %
  end

  % use scattered data interpolation and nearest neighbor the create a 2d map
  % of whatever vessel data we want to overlay
  
  
  % FAIL - does not work as nearest interolation does not do what we want...
  if 0
    realXPos = allCenters(:,1);
    realYPos = allCenters(:,2);

    % remove potential nans
    realXPos(isnan(realYPos)) = []; 
    angles(isnan(realYPos)) = []; 
    realYPos(isnan(realYPos)) = [];

    F = scatteredInterpolant(realXPos, realYPos, angles);
    F.Method = 'nearest';
    F.ExtrapolationMethod = 'nearest';

    idealXPosVec = double(AVA.x);
    idealYPosVec = double(AVA.y);
    [Xq, Yq] = meshgrid(idealXPosVec, idealYPosVec);

    Vq = F(Xq, Yq);
  end

  
  fprintf('Drawing them lines...');
  outIm = nan(size(AVA.xy));
  imSize = size(outIm);
  nVessel = numel(vList);
  for iVessel = 1:nVessel
    vessel = vList(iVessel);
    side1 = vessel.side1(vessel.keep_inds,:);
    side2 = vessel.side2(vessel.keep_inds,:);
    angles = vessel.angles(vessel.keep_inds,:);
    angles = atan2d(angles(:, 2), angles(:, 1));
    angles(angles < 0) = angles(angles < 0) + 180; % only use 0 - 180 deg
    nSegments = size(side1,1);
    for iSeg = 1:nSegments
      % [x, y] = bresenham( side1(iSeg, 1), side1(iSeg, 2), ...
      %                     side2(iSeg, 1), side2(iSeg, 2));
      [x, y] = xiaolinwu(side1(iSeg, 1), side1(iSeg, 2), ...
      side2(iSeg, 1), side2(iSeg, 2));
      linIdx = sub2ind(imSize, x, y);
      outIm(linIdx) = angles(iSeg);
    end
  end
  fprintf('done!\n');

  fprintf('Filling them missing values...');
  % try and fill in missing values but do it fast...
  outIm1 = fillmissing(outIm, 'linear', 2, 'EndValues', 'nearest');
  outIm2 = fillmissing(outIm, 'linear', 1, 'EndValues', 'nearest');
    % outIm = imgaussfilt(outIm, depthMapSmooth);
  outIm = (outIm2 + outIm1)./2; 
  fprintf('done!\n');
  
  % create background RGB image ------------------------------------------------
  num_colors = 256;
  maskBackCMap = gray(256);
  maskFrontCMap = hsv(256);
  back = normalize(AVA.xy); % already normalized at this point
  % scale the background image from 0 to num_colors
  % back = imadjust(back);
  back = round(num_colors .* back);
  % convert the background image to true color
  back = ind2rgb(back, maskBackCMap);

  outIm = outIm./180; % normalize to 0-1
  frontIm = round(num_colors .* outIm);
  % convert the depth mask to true color
  frontIm = ind2rgb(frontIm, maskFrontCMap);
  
  depthImage = back .* frontIm;
  
  figure();
  subplot(2,3,1)
  imagesc(back); axis image;
  
  subplot(2,3,4)
  imagesc(frontIm); axis image;
  
  subplot(2,3,[2 6])
  imagesc(depthImage);
  colormap(maskFrontCMap); axis image;

  % figure(); 
  % iH = imagesc(outIm);
  % axis image;
  % colormap('hsv');
  % % outIm = inpaint_nans(outIm);
  % set(iH, 'cData', outIm);
  % drawnow();



end
