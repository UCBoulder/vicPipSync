function target = sample_select
    % sample_select.m
    %
    % Francisco Lopez Jimenez Lab, AMReC
    %
    % Samuel Hatton
    %
    %
    % Inputs
    %     None          Interactive dialog-based specimen selection
    % Outputs
    %     target        List containing the paths to the VIC-SNAP, VIC-3D, 
    %                   and Instron output files to be synced. Format:
    %                   `target = [vic_path, ext_path, inst_path];`
    % Methodology
    %     1. Checks for a previous selection
    %     2. If using previous: loads saved path and specimen list
    %     3. If new selection:
    %        - Opens folder selection dialog
    %        - Shows specimen list for user selection
    %        - Saves selection for future use
    % Dependencies
    %     None

    % Check for previous selection:
    if exist('vicPipSync_temp/prev_selection.txt', 'file')
        prev_sel = fileread('vicPipSync_temp/prev_selection.txt');
        choice = questdlg(sprintf('Use previous selection?\n\n%s', prev_sel), ...
            'Previous Selection Found', ...
            'Use Previous', 'New Selection', 'Use Previous');
    else
        choice = 'New Selection';
    end

    % Get selection
    switch choice
        case 'Use Previous'
            target = prev_sel;
        case 'New Selection'
            % Select VIC-SNAP file
            choice = questdlg('Please select the VIC-SNAP project CSV file.', ...
            'File Selection', ...
            'Okay', 'Cancel', 'Okay');
            
            if strcmp(choice, 'Cancel')
                error('Selection cancelled by user');
            end
            
            [vic_file, vic_path] = uigetfile('*.csv', 'Select VIC-SNAP Output CSV');
            if vic_file == 0
                error('No file selected');
            end
            
            % Select VIC-3D Extensometer file
            choice = questdlg('Please select the VIC-3D extensometer output CSV file.', ...
            'File Selection', ...
            'Okay', 'Cancel', 'Okay');
            
            if strcmp(choice, 'Cancel')
                error('Selection cancelled by user');
            end
            
            [ext_file, ext_path] = uigetfile('*.csv', 'Select Extensometer Output CSV');
            if ext_file == 0
                error('No file selected');
            end
            
            % Select INSTRON data output file
            choice = questdlg('Please select the Instron data CSV file.', ...
            'File Selection', ...
            'Okay', 'Cancel', 'Okay');
            
            if strcmp(choice, 'Cancel')
                error('Selection cancelled by user');
            end
            
            [inst_file, inst_path] = uigetfile('*.csv', 'Select Instron data CSV');
            if inst_file == 0
                error('No file selected');
            end

            target = [vic_path, ext_path, inst_path];
        otherwise
            error("Selection cancelled by user.")
    end
end