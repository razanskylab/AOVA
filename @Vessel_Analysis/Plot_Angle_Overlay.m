function Plot_Angle_Overlay(AVA)
  vList = AVA.Data.vessel_list;

  % use scattered data interpolation and nearest neighbor the create a 2d map
  % of whatever vessel data we want to overlay
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
    % here we draw lines between the fitted borders ---------------------------
    for iSeg = 1:nSegments
      [x, y] = xiaolinwu(side1(iSeg, 1), side1(iSeg, 2), ...
      side2(iSeg, 1), side2(iSeg, 2));
      linIdx = sub2ind(imSize, x, y);
      outIm(linIdx) = angles(iSeg);
    end
  end
  fprintf('done!\n');
  
  % create background RGB image ------------------------------------------------
  num_colors = 256;
  maskBackCMap = gray(256);
  maskFrontCMap = hsv(256);
  % back = adapthisteq(normalize(AVA.xy)); % already normalized at this point
  back = normalize(AVA.xy); % already normalized at this point
  % scale the background image from 0 to num_colors
  % back = imadjust(back);
  back = round(back .* num_colors);
  % convert the background image to true color
  back = ind2rgb(back, maskBackCMap);

  % smooth and make wider to cover more vessels
  outIm = ndnanfilter(outIm,@rectwin,[3 3]); 
  outIm = ndnanfilter(outIm,@rectwin,[3 3]); 
  outIm = outIm./180; % normalize to 0-1
  frontIm = round(outIm .* num_colors);
  % convert the depth mask to true color
  frontIm = ind2rgb(frontIm, maskFrontCMap);
  for iCol = 1:3
      temp = frontIm(:,:,iCol);
      temp(isnan(outIm)) = 1;
      frontIm(:,:,iCol) = temp;
  end
  
  depthImage = back.*frontIm;
  
  figure();
  subplot(2,3,1)
  imagesc(back); axis image;
  
  subplot(2,3,4)
  imagesc(frontIm); axis image;
  
  s3H = subplot(2,3,[2 6]);
  imagesc(depthImage); axis image;

  colormap(s3H, maskFrontCMap);
  c = colorbar(s3H);
  % get depth labels and update deph-colorbar ----------------------------------
  nDepthLabels = 10;
  tickLocations = linspace(0.025, 0.975, nDepthLabels); % juuuust next to max limits
  tickValues = linspace(0, 180, nDepthLabels);
  for iLabel = nDepthLabels:-1:1
    zLabels{iLabel} = sprintf('%2.2f', tickValues(iLabel));
  end
  c.TickLength = 0;
  c.Ticks = tickLocations;
  c.TickLabels = zLabels;
  c.Label.String = 'angle';

  % figure(); 
  % iH = imagesc(outIm);
  % axis image;
  % colormap('hsv');
  % % outIm = inpaint_nans(outIm);
  % set(iH, 'cData', outIm);
  % drawnow();



end
