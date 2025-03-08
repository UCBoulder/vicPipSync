function synced_force_disp = load_data(target)
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
    % Outputs
    %     synced_force_disp     table containing synced data
    %
    % Methodology
    %     1. Loads VIC-SNAP, VIC-3D Extensometer, and Instron data specified in target
    %     2. Interpolates over empty indexes in extensometer data
    %     3. Syncs data using `sync_data` function
    %     4. Outputs saved data
    % Dependencies
    %     get_vic_snap.m
    %     get_ext_data.m
    %     get_inst_data.m
    %     sync_data.m

    % Load in data files:
    vic_snap  = get_vic_snap(target{1});
    ext_data  = get_ext_data(target{2});
    inst_data = get_inst_data(target{3});

    % Check for and interpolate over empty extensometer indexes
    tf = isnan(ext_data.("ΔL"));
    if sum(tf)
        bad = 1;
        dl = ext_data.("ΔL");
        nan_count = 0;
    else
        bad = 0;
    end

    while bad
        st_idx = find(tf,1);
        for j = st_idx+1:length(tf)
            if ~tf(j)
                end_idx = j-1;
                break
            end
        end
        prec_val = dl(st_idx-1);
        fol_val = dl(end_idx+1);
        x = [st_idx-1, end_idx+1];
        v = [prec_val, fol_val];
        xq = st_idx:end_idx;
        vq = interp1(x,v,xq);
        dl(xq) = vq;
        tf = isnan(dl);
        nan_count = nan_count + length(xq);
        if ~sum(tf)
            bad = 0;
            ext_data.("ΔL") = dl;
        end
    end

    % If vic-snap data is missing, simply output the instron data
    if ~isempty(vic_snap)
        synced_force_disp = sync_data(vic_snap,ext_data,inst_data);
    else
        synced_force_disp = inst_data;
    end


end
