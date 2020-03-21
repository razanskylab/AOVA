classdef Vessel_Data < hgsetget
    % VESSEL_DATA A container for all relevant data required to analyse
    % blood vessels in a 2D image.
    %   Holds display settings, images (raw, binary and mask), a vessel
    %   list, image file name and an index to a selected vessel in the
    %   list.

    %% Properties

    properties
        settings;  % Vessel_Settings object

        im_orig;   % Original image - may be colour, integer or real
        im;        % Grayscale image (main image for processing), should be real
        bw_mask;   % Mask image
        bw;        % Segmented image
        bw_branches; % branch pixels

        % new properties added by JR
        branchCenters; % center points of bw_branches
        nBranches; 
        segments; % skeleton of bw
        distTrans; % distance of "on" pixels to background

        dark_vessels = false; % TRUE if vessel is dark,
                             % i.e. represented by a 'valley' rather than a 'hill'
                             % Individual Vessels in a list have their own
                             % dark property, which override this one if set

        file_name; % Name of currently-open file
        file_path; % Path of currently-open file

        args;      % Structure containing the arguments used when processing the image originally, or else empty
        dR; % pixel size in mm
    end

    properties (Dependent = true)
        selected_vessel_ind = -1; % Index in vessel_list of a vessel (just one)
        selected_vessel;   % Vessel corresponding to selected_vessel_ind
        calibration_value; % Calibration_value from Vessel_Settings
        num_vessels;       % Total number of vessels in list
        total_diameters;   % Total number of diameters in all vessels
    end

    properties (SetAccess = protected)
        vessel_list;       % Array of Vessel objects
    end

    % Store a unique (for this MATLAB session) ID in order to identify
    % whether a displayed figure is showing this Vessel_Data
    properties (SetAccess = private, Hidden = true, Transient = true)
        id_val = 0;
        % Store selected_vessel_ind in a separate variable
        val_selected_vessel_ind = -1;
    end
    properties (Dependent = true)
        id;
    end

    %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods

        % Constructor
        function obj = Vessel_Data(settings)
            if nargin == 0
                obj.settings = Vessel_Settings;
                return;
            end
            if ~isa(settings, 'Vessel_Settings')
                throw(MException('Vessel_Data:Settings', ...
                    'Invalid settings passed to Vessel_Data constructor'));
            end
            obj.settings = settings;
        end

    end

    %% VESSEL_LIST functions
    methods

        % Remove NaNs from vessels and remove vessels with < MIN_DIAMETERS
        % valid diameter measurements
        function clean_vessel_list(obj, min_diameters)
            % remove NANS
            for ii = 1:obj.num_vessels
                obj.vessel_list(ii).remove_nans;
            end
            if nargin == 1
                min_diameters = [];
            end
            obj.remove_short_vessels(min_diameters);
        end

        % Add vessels to vessel list
        function add_vessels(obj, v)
            for ii = 1:numel(v)
                v(ii).vessel_data = obj;
            end
            if isempty(obj.vessel_list)
                obj.vessel_list = v;
            else
                obj.vessel_list = [obj.vessel_list, v(:)'];
            end
            %             obj.vessel_list = [obj.vessel_list v];
        end


        % Remove vessels specified by INDS (no error checking)
        % If INDS is empty or not supplied, deletes all vessels
        function delete_vessels(obj, inds)
            if nargin == 1 || isempty(inds)
                obj.vessel_list = [];
            else
                obj.vessel_list(inds) = [];
            end
        end


        % Keep only vessels in list specified by INDS (no error checking)
        function trim_vessels(obj, inds)
            obj.vessel_list = obj.vessel_list(inds);
        end


        % Remove vessels with <= MIN_DIAMETERS valid diameter measurements
        function remove_short_vessels(obj, min_diameters)
            if isempty(obj.vessel_list)
                return;
            end
            if nargin == 1 || isempty(min_diameters)
                min_diameters = 0;
            end
            inds_remove = [obj.vessel_list.num_diameters] <= min_diameters;
            obj.delete_vessels(inds_remove);
        end



        % Sort the vessel list so that longest is first
        function sort_by_length(obj)
            n = obj.num_vessels;
            if n <= 1
                return;
            end
            len = zeros(n, 1);
            for ii = 1:n
                len(ii) = obj.vessel_list(ii).offset(end);
            end
            % Get selected vessel to reselect after sorting
            sel_ind = obj.val_selected_vessel_ind;
            % Temporarily deselect any vessel
            obj.val_selected_vessel_ind = -1;
            % There's a chance vessels already sorted, then don't need to
            % repaint
            [~, inds] = sort(len,'descend');
            if ~issorted(inds)
                obj.vessel_list = obj.vessel_list(inds);
                % Reset selected vessel
                if sel_ind > 0
                    obj.val_selected_vessel_ind = find(inds == sel_ind);
                end
            end
        end



        % Sort the vessel list by average diameter, so widest is first
        function sort_by_diameter(obj)
            n = obj.num_vessels;
            if n <= 1
                return;
            end
            d = zeros(n, 1);
            for ii = 1:n
                d(ii) = mean(obj.vessel_list(ii).diameters);
            end
            % Get selected vessel to reselect after sorting
            sel_ind = obj.val_selected_vessel_ind;
            % Temporarily deselect any vessel
            obj.val_selected_vessel_ind = -1;
            % There's a chance vessels already sorted, then don't need to
            % repaint
            [~, inds] = sort(d,'descend');
            if ~issorted(inds)
                obj.vessel_list = obj.vessel_list(inds);
                % Reset selected vessel
                if sel_ind > 0
                    obj.val_selected_vessel_ind = find(inds == sel_ind);
                end
            end
        end
    end

    %% GET and SET methods
    methods

       function val = get.id(obj)
            persistent counter;
            if obj.id_val <= 0
                if isempty(counter)
                    counter = 1;
                else
                    counter = counter + 1;
                end
                obj.id_val = counter;
            end
            val = ['vessel_data:', num2str(obj.id_val)];
        end


        % Ensure ARGS is a STRUCT or empty
        function set.args(obj, val)
            if isstruct(val) || isempty(val)
                obj.args = val;
            end
        end

        function val = get.selected_vessel(obj)
            ind = obj.selected_vessel_ind;
            if ind > 0 && ind <= numel(obj.vessel_list)
                val = obj.vessel_list(ind);
            else
                val = [];
            end
        end

        function val = get.calibration_value(obj)
            val = obj.settings.calibration_value;
        end


        function val = get.num_vessels(obj)
            val = numel(obj.vessel_list);
        end

        function val = get.total_diameters(obj)
            if obj.num_vessels <= 0
                val = 0;
            else
                val = sum([obj.vessel_list.num_diameters]);
            end
        end

    end

end
