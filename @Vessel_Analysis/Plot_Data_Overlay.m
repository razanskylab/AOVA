function Plot_Data_Overlay(AVA, whatOverlay,plotSize)
  if nargin < 2
    whatOverlay = 'diameter';
  end
  if nargin < 3
    plotSize = 16;
  end
  
  vList = AVA.Data.vessel_list;

  fun = @(x) cat(1, x, [NaN NaN]);
  switch whatOverlay
  case 'angle' % per vessel-segment
    nColors = 180;
    % get all unit vecrtors
    fun = @(x) cat(1, x, [NaN NaN]);
    unitVectors = cellfun(fun, {vList.angles}, 'UniformOutput', false);
    unitVectors = cell2mat(unitVectors');
    angles = atan2d(unitVectors(:, 2), unitVectors(:, 1));
    angles(angles < 0) = angles(angles < 0) + 180; % only use 0 - 180 deg
    data = angles;
    dataColorMap = hsv(nColors);
  case 'diameter' % per vessel-segment
    nColors = 90;
    % get all corresponding diameters
    fun = @(x) cat(1, x, NaN);
    diameters = cellfun(fun, {vList.diameters}, 'UniformOutput', false);
    diameters = cell2mat(diameters');
    data = diameters;
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
    % upLim = std(turtuosity) * 1 + median(turtuosity);
    % lowLim = std(turtuosity) * 1 - median(turtuosity);
    % turtuosity(turtuosity >= upLim) = upLim;
    % turtuosity(turtuosity <= lowLim) = lowLim;

    data = turtuosity;
    % dataColorMap = jet(nColors);
    % dataColorMap = brewermap(nColors,  'OrRd'); % low values red, high values white
    dataColorMap = brewermap(nColors,  '*RdYlGn'); % low values red, high values white
  case 'angleRanges' % per vessel
    nColors = 45;
    data = AVA.angleRanges;
    dataColorMap = brewermap(nColors,  '*RdYlGn'); % low values red, high values white
  case 'angleStd' % per vessel
    nColors = 45;
    data = AVA.angleStd;
    dataColorMap = brewermap(nColors,  '*RdYlGn'); % low values red, high values white
  case 'angleChange' % per vessel
    nColors = 45;
    data = AVA.angleChange;
    dataColorMap = brewermap(nColors,  '*RdYlGn'); % low values red, high values white
  case 'segDistanceChange' % per vessel
    nColors = 45;
    data = AVA.segDistanceChange;
    dataColorMap = brewermap(nColors,  '*RdYlGn'); % low values red, high values white
  end

  switch whatOverlay
  case 'angle' % per vessel-segment
    % nothing to do
  otherwise % remove outlier
    [data] = wrap_outlier_data(data,[0 95]);
  end
  mean(data)
  groups = discretize(data, nColors);
  centers = cellfun(fun, {vList.centre}, 'UniformOutput', false);
  centers = cell2mat(centers');

  cMap = AVA.colorMap;
  if ischar(cMap)
    eval(['cMap = ' cMap '(nColors);']); % turn string to actual colormap matrix
  end

  % plotImage = normalize(adapthisteq(normalize(AVA.xy), 'ClipLimit', 0.02));
  if ~isempty(AVA.xy)
    plotImage = normalize(AVA.xy);
    indexImage = gray2ind(plotImage, nColors);
    rgbImage = ind2rgb(indexImage, cMap);
    imagesc(rgbImage); 
  end
  axis image; 
  
  % now we can display whatever colorbar we want, it will not affect the xy map
  colormap(gca, dataColorMap);
  
  holdfig = ishold; % Get hold state
  hold on;
  % loop trough all colors and plot
  if strcmp(whatOverlay, {'diameter','aangle'})
    for iColor = 1:nColors
      plotCenters = centers(groups == iColor, :);
      if ~isempty(plotCenters)
        scatter(plotCenters(:, 2), plotCenters(:, 1), plotSize, 'MarkerFaceColor', dataColorMap(iColor, :), 'MarkerEdgeColor', 'none');
      end
    end
  else
    for iColor = 1:nColors
      plotVessels = vList(groups == iColor);
      if ~isempty(plotVessels)
        fun = @(x) cat(1, x, [nan, nan]);
        temp = cellfun(fun, {plotVessels.centre}, 'UniformOutput', false);
        plotCenters = cell2mat(temp');
        line(plotCenters(:, 2), plotCenters(:, 1), 'LineStyle', '-', 'Color', dataColorMap(iColor, :), 'linewidth', sqrt(plotSize));
        % scatter(plotCenters(:, 2), plotCenters(:, 1), 'k.');
      end
    end
  end 
  
  CBar = colorbar();
  nDepthLabels = 9;
  tickLocations = linspace(0, 1, nDepthLabels); % juuuust next to max limits
  tickValues = linspace(min(data), max(data), nDepthLabels);
  for iLabel = nDepthLabels:-1:1
    zLabels{iLabel} = sprintf('%2.2f', tickValues(iLabel));
  end
  CBar.TickLength = 0;
  CBar.Ticks = tickLocations;
  CBar.TickLabels = zLabels;
  
  if not(holdfig)
    hold off;
  end % Restore hold state
  axis off;
  title(whatOverlay);
  

end
