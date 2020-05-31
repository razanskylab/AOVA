function fH = plot_masked_overview(DataStruct,rawImage,maskPath)
  if nargin < 2
    maskPath = [];
  end

  f1 = figure();
  tiledlayout('flow',  'TileSpacing',  'compact');
  th1 = nexttile();
  imagescj(rawImage); 
  hold on;
  s1 = scatter(DataStruct.segCenter(2,:),DataStruct.segCenter(1,:),'.r');
  s2 = scatter(DataStruct.vesCenter(2,:),DataStruct.vesCenter(1,:),'.g');
  hold on;
  % s3 = scatter(imCenter(1),imCenter(2),'ob','MarkerFaceColor','b');
  legend([s1 s2],{'segment ctr','vessel ctr'});
  title('Data Overlay');


  if isempty(maskPath)
    return
  end
  Masks = jpg2masks(maskPath, size(rawImage),90);

  fullRedRGB = zeros(size(rawImage,1),size(rawImage,2),3);
  fullRedRGB(:,:,1) = 1; % make it red by setting the R in RGB
  maskEdges = edge(Masks.woundArea);
  SE = strel('disk',5);
  maskEdges = imdilate(maskEdges,SE);


  % plot mask as overlay over background image to indicate borders %%%%%%%%%%%%%%
  th2 = nexttile();
  imagescj(rawImage); 
  hold on;
  imagesc(fullRedRGB,'AlphaData',maskEdges);
  imCenter = DataStruct.imageCenter; % stored as y-x (same as scatter)
  % imCenter = fliplr(imCenter); % flip to x-y format for crosshair
  plot_crosshair(imCenter,[0 0 1]); 
  title('Mask Overlay');

  if 0 % show angle and crosshair?
    th3 = nexttile();
    cMap = cmocean('phase', 9);
    data =  DataStruct.segAngles;
    center = DataStruct.segCenter;
    scatter_plot_vessel_segments(center,data,cMap,10,0.75);
    colormap(th3,cMap);
    CBar = colorbar(th3);
    nDepthLabels = 9;
    tickLocations = linspace(0, 1, nDepthLabels); % juuuust next to max limits
    tickValues = linspace(-90, 90, nDepthLabels);
    for iLabel = nDepthLabels:-1:1
      zLabels{iLabel} = sprintf('%2.2f', tickValues(iLabel));
    end
    CBar.TickLength = 0;
    CBar.Ticks = tickLocations;
    CBar.TickLabels = zLabels;
    title('measure angle');
    hold on;
    plot_crosshair(imCenter,[0 0 1]); 

    th4 = nexttile();
    cMap = brewermap(64, 'OrRd'); % low values red, high values white
    data =  DataStruct.angleDiff;
    center = DataStruct.segCenter;
    scatter_plot_vessel_segments(center,data,cMap,10,0.75);
    colormap(th4,cMap);
    CBar = colorbar(th4);
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
    hold on;
    plot_crosshair(imCenter,[0 0 1]); 
    linkaxes([th1, th2, th3, th4]);
  end

  if nargout
    fH = [f1];
  end

end


% plot function
% TODO
% for both raw and masked data
% plot CLAHE filtered background image
% plot vessel centerlines
% plot scatter centers
% plot image center


% tic;
% AVA.PrintF('[Mask_Full_Data] Generating debug plot...');

% maskedImage = rawImage;
% maskedImage(~mask) = 0;

% dFig = figure();
% TL = tiledlayout(dFig,'flow');
% TL.Padding = 'compact'; % remove uneccesary white space...

% nexttile(); 
% imagescj(maskedImage); axis off;  colorbar off;
% title('Masked Image');

% % plot segments -------------------------------------------------------
% nexttile();
% imagescj(rawImage); axis off;  colorbar off;
% hold on;
% markerSize = 10;
% scatter(remSegCenter(2,:),remSegCenter(1,:),...
%   markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
% scatter(DS.segCenter(2,:),DS.segCenter(1,:),...
%   markerSize,'filled','MarkerFaceColor',Colors.DarkGreen);
% title('Removed / Kept Segments');

% % plot vessels -------------------------------------------------------
% nexttile();
% imagescj(rawImage); axis off; colorbar off;
% hold on;
% scatter(remVesCenter(2,:),remVesCenter(1,:),...
%   markerSize,'filled','MarkerFaceColor',Colors.DarkRed);
% scatter(DS.vesCenter(2,:),DS.vesCenter(1,:),...
%   markerSize,'filled','MarkerFaceColor',Colors.DarkGreen);
% title('Removed / Kept Vessels');


% maskEdges = edge(rotMask);
% SE = strel('disk',5);
% maskEdges = imdilate(maskEdges,SE);