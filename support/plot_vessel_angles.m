function plot_vessel_angles(vessel_list,cMap)
  % get all center positions
  fun = @(x) cat(1, x,[NaN NaN]);
  centers = cellfun(fun, {vessel_list.centre}, 'UniformOutput', false);
  centers = cell2mat(centers');

  % get all unit vecrtors 
  fun = @(x) cat(1, x,[NaN NaN]);
  unitVectors = cellfun(fun, {vessel_list.angles}, 'UniformOutput', false);
  unitVectors = cell2mat(unitVectors');
  angles = atan2d(unitVectors(:, 2), unitVectors(:, 1));

  % create colormap based on diameters, the smaller the number of colors the faster
  nColors = size(cMap,1);
  
  % split up diameters and corresponding center positions based on their plot color
  groups = discretize(angles, nColors);

  holdfig=ishold; % Get hold state
  hold on;

  % loop trough all colors and plot
  for iColor = 1:nColors
    % plotIdx = find(groups==iColor);
    plotCenters = centers(groups==iColor,:);
    % line(plotCenters(:,2), plotCenters(:,1),'LineStyle','-','Color', cMap(iColor,:),'linewidth', 1);
    scatter(plotCenters(:,2), plotCenters(:,1),100,'MarkerFaceColor', cMap(iColor,:),'MarkerEdgeColor','none');
  end

  if not(holdfig)
    hold off;
  end % Restore hold state

end
