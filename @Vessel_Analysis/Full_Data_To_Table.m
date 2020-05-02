function [DataTable, DataCell] = Full_Data_To_Table(AVA, DS)
  startTic = tic;

  AVA.VPrintF('Converting full data into table...')

  % store vessel and segment data in structs for easier access later...
  VesselData.vesCenter = DS.vesCenter;
  VesselData.vesCtrDistance = DS.vesCtrDistance;
  VesselData.vesDiameter = DS.vesDiameter;
  VesselData.turtosity = DS.turtosity;
  VesselData.lengthCum = DS.lengthCum;
  VesselData.lengthStraight = DS.lengthStraight;

  SegmentData.segCenter = DS.segCenter;
  SegmentData.segCtrDistance = DS.segCtrDistance;
  SegmentData.segDiameters = DS.segDiameters;
  SegmentData.segAngles = DS.segAngles;
  SegmentData.centerAngle = DS.centerAngle;
  SegmentData.angleDiff = DS.angleDiff;

  DataCell = {...
    DS.nBranches, ...
    DS.nVessel, ...
    DS.nSegments, ...
    DS.branchDensity, ...
    DS.vesselDensity, ...
    DS.totalLength, ...
    DS.lengthFraction, ...
    DS.vesselGrowthDensity, ...
    DS.branchGrowthDensity, ...
    DS.lengthGrowthFraction, ...
    DS.meanDiameter, ...
    DS.meanLength, ...
    DS.meanTurtosity, ...
    DS.meanAngleDiff, ...
    DS.medianDiameter, ...
    DS.medianLength, ...
    DS.medianTurtosity, ...
    DS.medianAngleDiff, ...
    DS.area, ...
    DS.growthArea, ...
    DS.imageCenter, ...
    DS.imageSize, ...
    VesselData, ...
    SegmentData, ...
    };

  DataTable = cell2table(DataCell);

  DataTable.Properties.VariableNames = {...
    'nBranches', ...
    'nVessel', ...
    'nSegments', ...
    'branchDensity', ...
    'vesselDensity', ...
    'totalLength', ...
    'lengthFraction', ...
    'vesselGrowthDensity', ...
    'branchGrowthDensity', ...
    'lengthGrowthFraction', ...
    'meanDiameter', ...
    'meanLength', ...
    'meanTurtosity', ...
    'meanAngleDiff', ...
    'medianDiameter', ...
    'medianLength', ...
    'medianTurtosity', ...
    'medianAngleDiff', ...
    'area', ...
    'growthArea', ...
    'imageCenter', ...
    'imageSize', ...
    'VesselData', ...
    'SegmentData'};

  DataTable.Properties.VariableDescriptions = {...
    'nBranches', ...
    'nVessel', ...
    'nSegments', ...
    'branchDensity', ...
    'vesselDensity', ...
    'totalLength', ...
    'total length / area', ...
    'vesselGrowthDensity', ...
    'branchGrowthDensity', ...
    'lengthGrowthFraction', ...
    'average diameter of all vessel segments', ...
    'average length of all vessels', ...
    'average turtosity of all vessels', ...
    'average angular deviation of all vessel segments', ...
    'median diameter of all vessel segments', ...
    'median length of all vessels', ...
    'median turtosity of all vessels', ...
    'median angular deviation of all vessel segments', ...
    'area', ...
    'area where actual vessels are growing', ...
    'location of wound center', ...
    'size of original image in Pixel', ...
    'struct with vessel data', ...
    'struct with segment data', ...
    };

  DataTable.Properties.VariableUnits{'area'} =  'Px^2';
  DataTable.Properties.VariableUnits{'branchDensity'} =  'branches/Px^2';
  DataTable.Properties.VariableUnits{'vesselDensity'} =  'vessels/Px^2';

  AVA.Done(startTic);

end
