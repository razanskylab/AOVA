function [AVA] = Get_Data(AVA)

  fprintf('[AVA.Get_Data] Finding and analyzing vessels.\n');
  Data = Vessel_Data(AVA.VesselSettings);
  Data.im = single(AVA.xy);
  Data.im_orig = single(AVA.xy);

  % if binarized image was provided to AVA then use that one
  % otherwise
  binWasProvided = ~isempty(AVA.bin);
  if binWasProvided
    Data.bw = AVA.bin;
  end

  % Apply the acutal algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Segment the image using the isotropic undecimated wavelet transform
  [AVA.AviaSettings] = seg_iuwt(Data, AVA.AviaSettings);

  % Compute centre lines and profiles by spline-fitting
  jprintf('   Extracting vessel profiles...');
  [AVA.AviaSettings] = centre_spline_fit(Data, AVA.AviaSettings);
  done(toc);

  % Do the rest of the processing, and detect vessel edges using a gradient
  % method
  jprintf('   Calculating vessel widths...');
  [AVA.AviaSettings] = edges_max_gradient(Data, AVA.AviaSettings);
  done(toc);

  % Make sure NaNs are 'excluded' from summary measurements
  Data.vessel_list.exclude_nans();
  Data.vessel_list.clean_vessel_list();

  % Store the arguments so that they are still available if the VESSEL_DATA
  % object is saved later
  Data.args = AVA.AviaSettings;
  AVA.Data = Data;
  % vessel statistics also need binarzied mask, if none was supplied with the AVA class,
  % then AOVA created one. Store that mask as the new binary mask for the Map
  if ~binWasProvided
    AVA.bin = Data.bw;
  end
end
