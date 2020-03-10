function Plot_Data_Overlay(AVA, whatOverlay)
  if nargin < 2
    whatOverlay = 'diameter';
  end
  
  vList = AVA.Data.vessel_list;


  fun = @(x) cat(1, x, [NaN NaN]);
  centers = cellfun(fun, {vList.centre}, 'UniformOutput', false);
  centers = cell2mat(centers');

  switch whatOverlay
  case 'angle' % per vessel-segment
    nColors = 180;
    % get all unit vecrtors
    fun = @(x) cat(1, x, [NaN NaN]);
    unitVectors = cellfun(fun, {vList.angles}, 'UniformOutput', false);
    unitVectors = cell2mat(unitVectors');
    angles = atan2d(unitVectors(:, 2), unitVectors(:, 1));
    angles(angles < 0) = angles(angles < 0) + 180; % only use 0 - 180 deg
    groups = discretize(angles, nColors);
    dataColorMap = hsv(nColors);
  case 'diameter' % per vessel-segment
    nColors = 90;
    % get all corresponding diameters
    fun = @(x) cat(1, x, NaN);
    diameters = cellfun(fun, {vList.diameters}, 'UniformOutput', false);
    diameters = cell2mat(diameters');
    groups = discretize(diameters, nColors);
    dataColorMap = make_linear_colormap(Colors.BrightGreen, Colors.PureRed, nColors);
  case 'turtuosity' % per vessel
    nColors = 90;
    fun = @(x) cat(1, x);
    cumLength = cellfun(fun, {vList.length_cumulative}, 'UniformOutput', false);
    cumLength = cell2mat(cumLength');
  
    fun = @(x) cat(1, x);
    straightLength = cellfun(fun, {vList.length_straight_line}, 'UniformOutput', false);
    straightLength = cell2mat(straightLength');

    turtuosity = cumLength./straightLength; 
    % cast outliers to minmax values
    upLim = std(turtuosity) * 1 + median(turtuosity);
    lowLim = std(turtuosity) * 1 - median(turtuosity);
    turtuosity(turtuosity >= upLim) = upLim;
    turtuosity(turtuosity <= lowLim) = lowLim;
    % split up diameters and corresponding center positions based on their plot color
    groups = discretize(turtuosity, nColors);
    dataColorMap = jet(nColors);
  end

  figure();

  cMap = AVA.colorMap;
  if ischar(cMap)
    eval(['cMap = ' cMap '(nColors);']); % turn string to actual colormap matrix
  end

  % plotImage = normalize(adapthisteq(normalize(AVA.xy), 'ClipLimit', 0.02));
  plotImage = normalize(AVA.xy);
  indexImage = gray2ind(plotImage, nColors);
  rgbImage = ind2rgb(indexImage, cMap);
  imagesc(rgbImage); 
  axis image; 
  title('combined');

  % now we can display whatever colorbar we want, it will not affect the xy map
  colormap(gca, dataColorMap);

  holdfig = ishold; % Get hold state
  hold on;
  areaScaling = 10;
  % loop trough all colors and plot
  if ~strcmp(whatOverlay, 'turtuosity')
    for iColor = 1:nColors
      plotCenters = centers(groups == iColor, :);
      if ~isempty(plotCenters)
        scatter(plotCenters(:, 2), plotCenters(:, 1), areaScaling, 'MarkerFaceColor', dataColorMap(iColor, :), 'MarkerEdgeColor', 'none');
      end
    end
  else
    for iColor = 1:nColors
      plotVessels = vList(groups == iColor);
      if ~isempty(plotVessels)
        fun = @(x) cat(1, x, [nan, nan]);
        temp = cellfun(fun, {plotVessels.centre}, 'UniformOutput', false);
        plotCenters = cell2mat(temp');
        line(plotCenters(:, 2), plotCenters(:, 1), 'LineStyle', '-', 'Color', dataColorMap(iColor, :), 'linewidth', 2);
      end
    end
  end 

  if not(holdfig)
    hold off;
  end % Restore hold state

  % c = colorbar;
  % vesDiameters = vesDiameters*AVA.dR*1e3;
  % change colorbar labels to indicate vessel sizes
  % c.Ticks = [0 0.5 1];
  % halfDia = (min(vesDiameters) + max(vesDiameters)) / 2;
  % labels{1} = [num2str(min(vesDiameters), '%2.0f'), ''];
  % labels{2} = [num2str(halfDia, '%2.0f'), ''];
  % labels{3} = ['>= ' num2str(max(vesDiameters), '%2.0f'), ''];
  % c.TickLabels = labels;

  title('Color-Coded Vessel Size');
  axis off;


end
