function Plot_All_Vessel_Measures(AVA,DS)
  background = AVA.xy;
  dFig = figure();
  TL = tiledlayout(dFig,'flow');
  TL.Padding = 'compact'; % remove uneccesary white space...

  nexttile(); 
  imagescj(background); axis off;  colorbar off;
  title('Raw Image');

  % plot segments -------------------------------------------------------
  nexttile();
  imagescj(AVA.xy); axis off;  colorbar off;
  hold on;
  markerSize = 10;
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

  if AVA.verbosePlotting 

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

    % t = nexttile();
    % data =  DS.centerAngle;
    % center = DS.segCenter;
    % scatter_plot_vessel_segments(center,data,cMap,10,0.75);
    % colormap(t,cMap);
    % CBar = colorbar(t);
    % nDepthLabels = 9;
    % tickLocations = linspace(0, 1, nDepthLabels); % juuuust next to max limits
    % tickValues = linspace(min(data), max(data), nDepthLabels);
    % for iLabel = nDepthLabels:-1:1
    %   zLabels{iLabel} = sprintf('%2.2f', tickValues(iLabel));
    % end
    % CBar.TickLength = 0;
    % CBar.Ticks = tickLocations;
    % CBar.TickLabels = zLabels;
    % title('target angle');

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