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
    %     3. Outputs loaded data
    %
    % NOTE: Funtions assumes a file format and data units.


    % Load Data:
    ext_data = readtable(file_path,'NumHeaderLines',2);

    % Format variable names, assuming one of two output formats:

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

end
