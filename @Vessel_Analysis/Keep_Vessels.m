% remove vessels which don't have more than minSegments ---------------------
function [AVA] = Keep_Vessels(AVA,diaRange)
  
  % keep vessels based on average diameter -------------------------------------
  tStart = tic;
  minDia = diaRange(1);
  maxDia = diaRange(2);
  nVesselsPre = AVA.nVessels;

  AVA.VPrintF('Keeping vessels with diameters in range %2.1f-%2.1f:\n',minDia,maxDia);
  
  AVA.Data.sort_by_diameter(); % make sure vessels are sorted (large vessels first)
  dias = AVA.averageDiameters;
  % make sure vessels are sorted properly 
  if ~issorted(dias,'descend')
    error('Vessels are not sorted in descending order!');
  end

  AVA.VPrintF('   Vessels had diameters in range %2.1f-%2.1f.\n',dias(end),dias(1));

  % find idx of vessel which is closest to the desired diameter
  [vesselDia,startIdx] = find_nearest(maxDia,dias); % first vessel to keep 
  if vesselDia > maxDia % the vessel we found is too large, so skip that one
    startIdx = startIdx+1;
  end
  [vesselDia,endIdx] = find_nearest(minDia,dias); % last vessel to keep
  if vesselDia < minDia % the vessel we found is too small, so skip that one as well
    endIdx = endIdx-1;
  end

  removeVessels = true(1,AVA.nVessels);
  removeVessels(startIdx:endIdx) = false;
  AVA.Data.delete_vessels(removeVessels);
  
  dias = AVA.averageDiameters;
  AVA.VPrintF('   Vessels now have diameters in range %2.1f-%2.1f.\n',dias(end),dias(1));
  vesRemovedAbs = nVesselsPre - AVA.nVessels;
  vesRemovedPer = (1- AVA.nVessels./nVesselsPre)*100;
  AVA.VPrintF('   Removed %i (%2.2f %%) vessels...',vesRemovedAbs,vesRemovedPer);
  AVA.Done(tStart);

  % TODO: keep vessels based on vessel length (NOT number of segments)
  
end
