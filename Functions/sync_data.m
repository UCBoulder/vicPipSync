function synced_force_disp = sync_data(vic_snap,ext_data,inst_data,trim_tf,targ_var,targ_var_name)
    % sync_data.m
    %
    % Francisco Lopez Jimenez Lab, AMReC
    %
    % Samuel Hatton
    %
    % Inputs
    %     vic_snap      - Table containing VIC data with fields 'Count', 'PIPCount', and 'Time_0_1'
    %     ext_data      - Table containing extensometer data with fields 'Index' and target variable (e.g., 'ΔL')
    %     inst_data     - Table containing Instron data with fields 'PIPCount', 'Time', and 'Force'
    %     trim_tf       - Boolean flag to trim data outside the Instron test period (default: true)
    %     targ_var      - Name of the target variable in ext_data (default: "ΔL")
    %     targ_var_name - Name of the target variable for output table (default: 'Displacement')
    %
    % Outputs
    %     synced_force_disp - Table containing synchronized data with fields 'Index', target variable, 'Force', and 'Time'
    %
    % Methodology
    %     1. Ensure trim_tf, targ_var, and targ_var_name have default values if not provided.
    %     2. Convert targ_var_name to char array if it is a string.
    %     3. Truncate vic_snap or ext_data to ensure they have the same length.
    %     4. Identify match points using PIPCount and adjust vic_snap time to match inst_data time.
    %     5. Trim vic_snap and ext_data based on trim_tf flag.
    %     6. Create truncated instron data that matches 1-to-1 with ext_data.
    %     7. Combine synchronized data into a new table.
    %
    % Dependencies
    %     None


    if ~exist("trim_tf","var") || isempty(trim_tf)
        trim_tf = true;
        % Default behavior here is to throw away any data from a time
        % before the start of the instron data. In effect, this gets
        % rid of data points from things like shape images or images
        % taken in the few seconds before the Instron test started.
        % Similarly, vic-based data after the end of the Instron data
        % is discarded as well.
    end

    if ~exist("targ_var","var")
        targ_var = "ΔL";
        % Default behavior gets and outputs delta L from extensometer
    end
    if ~exist("targ_var_name","var")
        targ_var_name = 'Displacement';
        % Default behavior gets and outputs delta L from extensometer
    end

    % Enforce that targ_var_name input is a char array not a string.
    if isa(targ_var_name,'string')
        targ_var_name = char(targ_var_name);
    end

    % Enforce that vic and ext datas be the same length:
    if length(vic_snap.Count) > length(ext_data.Index)
        d = length(vic_snap.Count)-length(ext_data.Index);
        vic_snap = vic_snap(d+1:end,:); % truncate vic_snap to match ext_data
    elseif length(vic_snap.Count) < length(ext_data.Index)
        d = length(ext_data.Index) - length(vic_snap.Count);
        ext_data = ext_data(d+1:end,:); % truncate ext_data to match vic_snap
    end

    % Use the PIPCount from each data stream to identify the "match point"
    % between the two:
    inst_pip_loc = find(inst_data.PIPCount);
    vic_pip_loc = find(vic_snap.PIPCount);

    % get measured times at match point:
    inst_match_time = inst_data.Time(inst_pip_loc(1));
    vic_match_time = vic_snap.Time_0_1(vic_pip_loc(1));

    % adjust vic time to match inst time:
    time_diff = inst_match_time - vic_match_time;
    vic_snap.Time = vic_snap.Time_0_1 + time_diff;

    if trim_tf
        % identify vic data indeces with negative time:
        fake_time = vic_snap.Time < 0;

        % trim vic data:
        vic_snap(fake_time,:) = [];
        ext_data(fake_time,:) = [];

        % Use inst end time to trim away extra VIC data:
        inst_end_time = inst_data.Time(end);
        extra_time = vic_snap.Time > inst_end_time;
        vic_snap(extra_time,:) = [];
        ext_data(extra_time,:) = [];

        % zero out vic time:
        vic_snap.Time = vic_snap.Time - vic_snap.Time(1);

        % zero out displacement data
        ext_data.(targ_var) = ext_data.(targ_var) - ext_data.(targ_var)(1);
    end

    % create truncated instron data that matches 1to1 w/ ext. data

    % locate starting index
    zero_idx = find(vic_snap.Time >=0,1);

    % Preallocate index array for matching Instron data points
    idx = zeros(length(vic_snap.Count(zero_idx:end)),1);

    % Initialize counter for vic points before Instron start
    num_nans = 0;
    for i = 1:length(vic_snap.Count) % Loop through each image index
        if vic_snap.Time(i) < 0
            % Count vic points with negative time
            num_nans = num_nans + 1;
        else
            % Find matching time in Instron data
            tf = round(inst_data.Time,1) == round(vic_snap.Time(i),1);
            if sum(tf) == 0
                error("No Matching Time for time " + string(vic_snap.Time(i)))
            end
            % Get the location of the matching time
            locs = find(tf);
            % Store the index of the matching time
            idx(i - zero_idx + 1) = locs(1);
        end
    end

    % Build a buffer table containing any negative times, accounting for time before
    % Instron start
    buffer = nan(num_nans,1);
    buffer_time = vic_snap.Time(vic_snap.Time < 0);
    buffer_tab = table(buffer_time,buffer,buffer,buffer,'VariableNames',inst_data.Properties.VariableNames);

    % grab only relevant instron data
    inst_data = inst_data(idx,:);
    inst_data = [buffer_tab;inst_data];

    if ~(length(vic_snap.Time) == length(inst_data.Time))
        error("Data matching failed to create tables of equal length")
    end

    % combine into a new table
    synced_force_disp = table(ext_data.Index,ext_data.(targ_var),inst_data.Force,vic_snap.Time,'VariableNames',{'Index',targ_var_name,'Force','Time'});

end
