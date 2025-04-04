function synced_force_disp = load_data(target,verb)
    % load_data.m
    %
    % Francisco Lopez Jimenez Lab, AMReC
    %
    % Samuel Hatton
    %
    % Inputs
    %     target        List containing the paths to the VIC-SNAP, VIC-3D,
    %                   and Instron output files to be synced. Format:
    %                   `target = [vic_path, ext_path, inst_path];`
    %     verb          optional, if == "verbose", plots and stuff get
    %                   output
    % Outputs
    %     synced_force_disp     table containing synced data
    %
    % Methodology
    %     1. Loads VIC-SNAP, VIC-3D Extensometer, and Instron data specified in target
    %     2. Syncs data using `sync_data` function
    %     3. Outputs saved data
    % Dependencies
    %     get_vic_snap.m
    %     get_ext_data.m
    %     get_inst_data.m
    %     sync_data.m

    % check for verb:
    if ~exist("verb","var")
        verb = [];
    end

    % Load in data files:
    vic_snap  = get_vic_snap(target{1},verb);
    ext_data  = get_ext_data(target{2});
    inst_data = get_inst_data(target{3});

    % If vic-snap data is missing, simply output the instron data
    if ~isempty(vic_snap)
        synced_force_disp = sync_data(vic_snap,ext_data,inst_data);
    else
        synced_force_disp = inst_data;
    end


end
