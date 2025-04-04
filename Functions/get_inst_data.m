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

    % % Load data without formatting warnings:
    % warning off
    % % inst_data = readtable(file_path,"NumHeaderLines",8,"VariableNamesLine",7,"VariableUnitsLine",8);
    % warning on

    % Determine the file format and load the data accordingly
    fid = fopen(file_path, 'r');
    if fid == -1
        error('Could not open file: %s', file_path);
    end
    
    % Read first line to check format
    firstLine = fgetl(fid);
    fclose(fid);
    
    % Determine file format based on first line content
    if contains(firstLine, 'Results Table')
        % Format 1 (Image 1) - has headers and summary before raw data
        inst_data = loadFormat1(file_path);
    else
        % Format 2 (Image 2) - starts directly with column headers
        inst_data = loadFormat2(file_path);
    end

    fprintf("Instron data loaded successfully\n")

    function data = loadFormat1(file_path)
        % Read the file line by line to find the "Raw Data" section
        fid = fopen(file_path, 'r');
        lineNum = 0;
        rawDataLine = 0;
        
        while ~feof(fid)
            line = fgetl(fid);
            lineNum = lineNum + 1;
            
            if contains(line, 'Raw Data')
                rawDataLine = lineNum;
                break;
            end
        end
        
        if rawDataLine == 0
            fclose(fid);
            error('Could not find "Raw Data" section in file');
        end
        
        % Read variable names (row after "Raw Data")
        varNamesLine = fgetl(fid);
        % Read variable units (next row)
        varUnitsLine = fgetl(fid);
        fclose(fid);
        
        % Process the variable names and units lines
        varNames = strsplit(varNamesLine, ',');
        varUnits = strsplit(varUnitsLine, ',');
        
        % Clean up
        varNames = cellfun(@strtrim, varNames, 'UniformOutput', false);
        varUnits = cellfun(@strtrim, varUnits, 'UniformOutput', false);
        
        % Remove empty names
        validIdx = ~cellfun(@isempty, varNames);
        varNames = varNames(validIdx);
        
        % Ensure units array is compatible
        if length(varUnits) >= length(varNames)
            varUnits = varUnits(validIdx);
        else
            % Pad with empty strings if needed
            varUnits = [varUnits, repmat({''}, 1, length(varNames) - length(varUnits))];
        end
        
        % Make valid MATLAB variable names
        validVarNames = matlab.lang.makeValidName(varNames);
        
        % Read the data
        opts = detectImportOptions(file_path);
        opts.DataLines = [rawDataLine + 3, Inf];
        opts.VariableNames = validVarNames;
        
        data = readtable(file_path, opts);
        
        % Set units
        for i = 1:length(validVarNames)
            data.Properties.VariableUnits{validVarNames{i}} = varUnits{i};
        end
    end
    
    function data = loadFormat2(file_path)
        % Read the first few lines to get variable names and units
        fid = fopen(file_path, 'r');
        fgetl(fid); % Skip the first line
        varNamesLine = fgetl(fid); % Read variable names (line 2)
        varUnitsLine = fgetl(fid); % Read variable units (line 3)
        fclose(fid);
        
        % Process the variable names and units lines
        varNames = strsplit(varNamesLine, ',');
        varUnits = strsplit(varUnitsLine, ',');
        
        % Clean up
        varNames = cellfun(@strtrim, varNames, 'UniformOutput', false);
        varUnits = cellfun(@strtrim, varUnits, 'UniformOutput', false);
        
        % Remove empty names
        validIdx = ~cellfun(@isempty, varNames);
        varNames = varNames(validIdx);
        
        % Ensure units array is compatible
        if length(varUnits) >= length(varNames)
            varUnits = varUnits(validIdx);
        else
            % Pad with empty strings if needed
            varUnits = [varUnits, repmat({''}, 1, length(varNames) - length(varUnits))];
        end
        
        % Make valid MATLAB variable names
        validVarNames = matlab.lang.makeValidName(varNames);
        
        % Read the data
        opts = detectImportOptions(file_path);
        opts.DataLines = [4, Inf];
        opts.VariableNames = validVarNames;
        
        data = readtable(file_path, opts);
        
        % Set units
        for i = 1:length(validVarNames)
            data.Properties.VariableUnits{validVarNames{i}} = varUnits{i};
        end
    end
end