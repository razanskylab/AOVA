function Plot_Stats(AVA)
  vList = AVA.Data.vessel_list;

  % get all corresponding diameters
  fun = @(x) cat(1, x, NaN);
  diameters = cellfun(fun, {vList.diameters}, 'UniformOutput', false);
  for iVessel = numel(vList):-1:1
    meanDiameter(iVessel) = mean(diameters{iVessel},'omitnan');
  end
  allDiameters = cell2mat(diameters');


  fun = @(x) cat(1, x, NaN);
  cumLength = cellfun(fun, {vList.length_cumulative}, 'UniformOutput', false);
  cumLength = cell2mat(cumLength');

  fun = @(x) cat(1, x, NaN);
  straightLength = cellfun(fun, {vList.length_straight_line}, 'UniformOutput', false);
  straightLength = cell2mat(straightLength');

  % fun = @(x) cat(1, x, NaN);
  % angles = cellfun(fun, {vList.angles}, 'UniformOutput', false);
  % angles = cell2mat(angles');


  figure();
  subplot(3,2,1)
  histogram(allDiameters);
  subplot(3,2,2)
  histogram(meanDiameter);
  subplot(3,2,3)
  scatter(cumLength,straightLength);


end
