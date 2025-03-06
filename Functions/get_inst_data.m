function inst_data = get_inst_data(file_path)
    % get_inst_data.m
    %
    % Francisco Lopez Jimenez Lab, AMReC
    %
    % Samuel Hatton
    %
    % Inputs
    %     file_path     File path of Instron raw data .csv.
    % Outputs
    %     inst_data    Table containing Instron test data loaded from CSV file
    %                   with force, displacement, and PIP count data.
    %
    % Methodology
    %     1. Loads data from file path
    %     2. Outputs loaded data
    %
    % NOTE: Funtions assumes a file format! If header lines are different, this needs to be changed!

    % Load data without formatting warnings:
    warning off
    inst_data = readtable(file_path,"NumHeaderLines",8,"VariableNamesLine",7,"VariableUnitsLine",8);
    warning on

end