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

    % Ask user if they want to save the selection for next time
    % Check if the user has previously chosen to skip this question
    config_file = 'vicPipSync_temp/config.txt';
    skip_save_question = false;

    if exist(config_file, 'file')
        fid = fopen(config_file, 'r');
        config = textscan(fid, '%s %d');
        fclose(fid);
        if strcmp(config{1}{1}, 'skip_save_question') && config{2}(1) == 1
            skip_save_question = true;
        end
    end

    if skip_save_question
        choice = 'Yes';
    else
        d = dialog('Position', [300, 300, 250, 150], 'Name', 'Save Selection');

        txt = uicontrol('Parent', d, ...
            'Style', 'text', ...
            'Position', [20, 80, 210, 40], ...
            'String', 'Would you like to save this selection for next time?');

        chk = uicontrol('Parent', d, ...
            'Style', 'checkbox', ...
            'Position', [20, 60, 210, 20], ...
            'String', 'Don''t ask this again and remember choice');

        btn_yes = uicontrol('Parent', d, ...
            'Position', [35, 20, 70, 25], ...
            'String', 'Yes', ...
            'Callback', 'uiresume(gcbf)');

        btn_no = uicontrol('Parent', d, ...
            'Position', [135, 20, 70, 25], ...
            'String', 'No', ...
            'Callback', 'delete(gcbf)');

        uiwait(d);

        if ishandle(d)
            choice = 'Yes';
            skip_save_question = get(chk, 'Value');
            delete(d);
        else
            choice = 'No';
        end

        if skip_save_question
            fid = fopen(config_file, 'w');
            fprintf(fid, 'skip_save_question 1\n');
            fclose(fid);
        end
    end

    if strcmp(choice, 'Yes')
        % Save the selection to a file
        if ~exist('vicPipSync_temp', 'dir')
            mkdir('vicPipSync_temp');
        end
        fid = fopen('vicPipSync_temp/prev_selection.txt', 'w');
        fprintf(fid, '%s\n%s\n%s\n', vic_path, ext_path, inst_path);
        fclose(fid);
    end
end
