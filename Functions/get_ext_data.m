function ext_data = get_ext_data(file_path)
    % get_ext_data.m
    %
    % Francisco Lopez Jimenez Lab, AMReC
    %
    % Samuel Hatton
    %
    % Inputs
    %     file_path     File path of VIC-3D output extensometer data .csv.
    % Outputs
    %     ext_data     Table containing extensometer data with Index and
    %                  displacement measurements (ΔL/L0, ΔL, L1, L0)
    %
    % Methodology
    %     1. Loads data from file path
    %     2. Assigns standardized variable names based on data columns
    %     3. Linearly interpolates over any missing data indexes
    %     4. Outputs loaded data
    %
    % NOTE: Funtions assumes a file format and data units.


    % Load Data:
    ext_data = readtable(file_path,'NumHeaderLines',2,"VariableNamesLine",2,"VariableUnitsLine",1);

    % Format variable names, assuming one of two output formats:

    sz = size(ext_data);
    
    % Check for multiple extensometer outputs
    if sz(2) ~= 5 && sz(2) ~=2 % indicates more than one extensometer output
        choice = questdlg("Load more than one extensometer?","Multiple E's Detected","No","Yes","No");
        % find start indices of each output extensometer
        r1 = string(ext_data.Properties.VariableUnits);
        n = 0;
        for i = 1:length(r1)
            n = n + ~strcmp(r1(i),"");
        end
        idx = zeros(1,n);
        c = 1;
        for i = 1:length(r1)
            if ~strcmp(r1(i),"")
                idx(c) = i;
                c = c + 1;
            end
        end
    else % there is only one extensometer, proceed with extraction:
        choice = "Skip";
        if sz(2) == 5
            ext_data.Properties.VariableNames = ["Index","ΔL/L0","ΔL","L1","L0"];
            ext_data.Properties.VariableUnits = ["1","1","mm","mm","mm"];
        elseif sz(2) == 2
            ext_data.Properties.VariableNames = ["Index","ΔL"];
            ext_data.Properties.VariableUnits = ["1","mm"];
        else
            error("Extensometer data load failed: input table doesn't have the expected size (nx5 or nx2)")
        end
    end

    switch choice
        case "Yes"
            fprintf("Loading data for %d extensometers\n",c)
            temp = ext_data;
            
            % Extract the first extensometer, with the "Index" column
            d = temp(:,idx(1):idx(2)-1);
            szd = size(d);
            if szd(2) == 5
                d.Properties.VariableNames = ["Index","ΔL/L0_0","ΔL_0","L1_0","L0_0"];
                d.Properties.VariableUnits = ["1","1","mm","mm","mm"];
            elseif szd(2) == 2
                d.Properties.VariableNames = ["Index","ΔL_0"];
                d.Properties.VariableUnits = ["1","mm"];
            end
            Index = d.Index;
            ext_data = d;

            % Extract the remaining extensometers, without index columns:
            if n > 2
                for i = 2:n-1
                    d = temp(:,idx(i):idx(i+1)-1);
                    szd = size(d);
                    if szd(2) == 4
                        d.Properties.VariableNames = ["ΔL/L0_" + string(i-1),"ΔL_" + string(i-1),"L1_" + string(i-1),"L0_" + string(i-1)];
                        d.Properties.VariableUnits = ["1","mm","mm","mm"];
                    elseif szd(2) == 1
                        d.Properties.VariableNames = "ΔL_" + string(i-1);
                        d.Properties.VariableUnits = "mm";
                    else
                        error("Extensometer data load failed: input table doesn't have the expected size (nx4 or nx1)")
                    end
                    d.Index = Index;
                    ext_data = join(ext_data,d);
                end
            end

            % Extract the final extensometer without index column
            d = temp(:,idx(n):end);
            szd = size(d);
            if szd(2) == 4
                d.Properties.VariableNames = ["ΔL/L0_" + string(n-1),"ΔL_" + string(n-1),"L1_" + string(n-1),"L0_" + string(n-1)];
                d.Properties.VariableUnits = ["1","mm","mm","mm"];
            elseif szd(2) == 1
                d.Properties.VariableNames = "ΔL_" + string(n-1);
                d.Properties.VariableUnits = "mm";
            else
                error("Extensometer data load failed: input table doesn't have the expected size (nx4 or nx1)")
            end
            d.Index = Index;
            ext_data = join(ext_data,d,"LeftKeys","Index","RightKeys","Index");

        case "No" % just take the first one
            fprintf("Loading data for the 1st of %d extensometers\n",c)
            c = 1;
            ext_data = ext_data(:,1:idx(2)-1);
            sz = size(ext_data);
            if sz(2) == 5
                ext_data.Properties.VariableNames = ["Index","ΔL/L0","ΔL","L1","L0"];
                ext_data.Properties.VariableUnits = ["1","1","mm","mm","mm"];
            elseif sz(2) == 2
                ext_data.Properties.VariableNames = ["Index","ΔL"];
                ext_data.Properties.VariableUnits = ["1","mm"];
            else
                error("Extensometer data load failed: input table doesn't have the expected size (nx5 or nx2)")
            end
        case "Skip"
            c = 1;
    end

    % Check for and interpolate over empty indexes in ext_data
    
    % Get number of columns in ext_data:
    w = width(ext_data);
    names = ext_data.Properties.VariableNames;
    for i = 2:w % loop through non 'Index' columns

        % Find nan values
        tf = isnan(ext_data.(names{i}));

        % determin if nans exist, initialize count
        if sum(tf)
            bad = 1;
            dl = ext_data.(names{i});
            nan_count = 0;
        else
            bad = 0;
        end
    
        % Remove nan values
        while bad
            st_idx = find(tf,1); % location of first nan
            for j = st_idx+1:length(tf)
                if ~tf(j)
                    end_idx = j-1; % end of nan string (for more than one in a row)
                    break
                end
            end
            % linearly interpolate across nan area
            prec_val = dl(st_idx-1);
            fol_val = dl(end_idx+1);
            x = [st_idx-1, end_idx+1];
            v = [prec_val, fol_val];
            xq = st_idx:end_idx;
            vq = interp1(x,v,xq);
            dl(xq) = vq;

            % recompute nan boolean vector
            tf = isnan(dl);

            % add to nan count
            nan_count = nan_count + length(xq);
            if ~sum(tf) % check for completion of nan removal
                bad = 0;
                ext_data.(names{i}) = dl;
            end
        end
    end

    fprintf("Data for %d extensometer(s) loaded successfully\n",c)

end
