function save_data(synced_force_disp)
    % save_data.m
    %
    % Francisco Lopez Jimenez Lab, AMReC
    %
    % Samuel Hatton
    %
    % Inputs
    %     synced_force_disp     table containing synced data
    % Outputs
    %     Data file(s) named and placed in directories based on interactive GUI
    % Methodology
    %     1. Opens a dialogue box to determine how the user wants to save the data
    %           - supports .mat, .csv, .txt file types
    %     2. Opens native os window that allows the user to select the save directory
    %        and file name.
    %           - One window per selected file type, sequentially one after the other
    %           - Remembers the input name from file type to file type, so user doesn't
    %             have to type it more than once
    %           - Remembers previous save location choice from file type to file type, so
    %             user doesn't need to navigate there more than once
    % Dependencies
    %     None
    %
    % Developed in part by Claude 3.5 Sonnet via Github Copilot in VS-Code based on requirements written in part
    % by Claude 3.7 Sonnet Concise.
    
    % Input validation
    if ~istable(synced_force_disp)
        error('Input must be a MATLAB table');
    end
    
    % % Define available file types
    % fileTypes = struct('mat', '.mat', 'csv', '.csv', 'txt', '.txt');
    
    % Create format selection dialog
    warning off
    [formats, ok] = listdlg('ListString', {'MATLAB (.mat)', 'CSV (.csv)', 'Text (.txt)'}, ...
        'SelectionMode', 'multiple', ...
        'Name', 'Select File Formats', ...
        'PromptString', 'Select formats to save:', ...
        'ListSize', [200 100]);
    warning on
    if ~ok || isempty(formats)
        return;  % User cancelled or made no selection
    end
    
    % Initialize variables for remembering path and filename
    lastPath = pwd;
    lastName = 'data';
    
    % Map selected indices to file extensions
    extensions = {'.mat', '.csv', '.txt'};
    selectedExtensions = extensions(formats);
    
    % Save in each selected format
    for i = 1:length(selectedExtensions)
        ext = selectedExtensions{i};
        [fileName, filePath] = uiputfile(...
            ['*' ext], ...
            ['Save as ' ext ' file'], ...
            fullfile(lastPath, [lastName ext]));
        
        if fileName == 0
            continue;  % User cancelled this format
        end
        
        % Update remembered path and name for next iteration
        lastPath = filePath;
        [~, lastName] = fileparts(fileName);
        
        fullPath = fullfile(filePath, fileName);
        
        try
            switch ext
                case '.mat'
                    save(fullPath, 'synced_force_disp');
                case '.csv'
                    writetable(synced_force_disp, fullPath, 'Delimiter', ',');
                case '.txt'
                    writetable(synced_force_disp, fullPath, 'Delimiter', '\t');
            end
        catch ME
            errordlg(sprintf('Error saving %s: %s', fileName, ME.message), 'Save Error');
        end
    end
end