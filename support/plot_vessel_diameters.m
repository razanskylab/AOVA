function [allDiameters] = plot_vessel_diameters(vessel_list,cMap,areaScaling)
  % get all center positions
  fun = @(x) cat(1, x,[NaN NaN]);
  centers = cellfun(fun, {vessel_list.centre}, 'UniformOutput', false);
  centers = cell2mat(centers');

  % get all corresponding diameters
  fun = @(x) cat(1, x,NaN);
  diameters = cellfun(fun, {vessel_list.diameters}, 'UniformOutput', false);
  diameters = cell2mat(diameters');

  % create colormap based on diameters, the smaller the number of colors the faster
  nColors = size(cMap,1);

  diaStats = get_descriptive_stats(diameters);
  lowerBound = diaStats.mean-diaStats.std*1;
  upperBound = diaStats.mean+diaStats.std*1.5;
  diameters(diameters>upperBound)=upperBound;
  diameters(diameters<lowerBound)=lowerBound;
  allDiameters = diameters;
  % split up diameters and corresponding center positions based on their plot color
  groups = discretize(diameters,nColors);

  holdfig=ishold; % Get hold state
  hold on;

  % loop trough all colors and plot
  for iColor = 1:nColors
    % plotIdx = find(groups==iColor);
    plotCenters = centers(groups==iColor,:);
    % line(plotCenters(:,2), plotCenters(:,1),'LineStyle','-','Color', cMap(iColor,:),'linewidth', 1);
    scatter(plotCenters(:,2), plotCenters(:,1),iColor*areaScaling,'MarkerFaceColor', cMap(iColor,:),'MarkerEdgeColor','none');
  end

  if not(holdfig)
    hold off;
  end % Restore hold state

end
