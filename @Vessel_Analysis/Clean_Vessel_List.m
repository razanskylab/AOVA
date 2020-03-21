% remove vessels which don't have more than minSegments ---------------------
function [AVA] = Clean_Vessel_List(AVA,minSegments)
  if nargin == 1
    minSegments = 0;
  end
  tic;
  AVA.VPrintF('Removing short (<= %i segments) and NaN vessels...',minSegments);
  nVesselsPre = AVA.nVessels;
  nSegmentsPre = AVA.nSegments;
  AVA.Data.clean_vessel_list(minSegments);
  done(toc);

  % plot how much clean up we did
  vesRemovedAbs = nVesselsPre - AVA.nVessels;
  vesRemovedPer = (1- AVA.nVessels./nVesselsPre)*100;
  segRemovedAbs = nSegmentsPre - AVA.nSegments;
  segRemovedPer = (1- AVA.nSegments./nSegmentsPre)*100;
  AVA.VPrintF('Removed %i (%2.2f %%) vessels and %i (%2.2f %%) segments!\n',...
    vesRemovedAbs,vesRemovedPer,segRemovedAbs,segRemovedPer);
end
