function save_options = get_save_options()
    % get_save_options.m
    %
    % Francisco Lopez Jimenez Lab, AMReC
    %
    % Samuel Hatton
    %
    % Inputs
    %     None          Interactive dialog-based options selection
    % Outputs
    %     save_options  List containing save preferences including file name,
    %                   type(s), and save location.
    % Methodology
    %     1. Opens a dialogue box with user choice options
    %     2. Outputs the choices
    % Dependencies
    %     None
    %
    % Developed in part using GPT-4o via GitHub Copilot in VS-Code

    % Create the UI figure
    fig = uifigure('Name', 'Save Options', 'Position', [100 100 400 300]);

    % Add a label with instructions
    uilabel(fig, 'Text', 'Please enter the file name and desired file types for the saving the synced output data:', ...
        'Position', [20 250 360 30]);

    % Add a text input box for the file name
    fileNameLabel = uilabel(fig, 'Text', 'File Name (without extension):', ...
        'Position', [20 200 200 30]);
    fileNameInput = uitextarea(fig, 'Position', [20 170 200 30]);

    % Add dynamic file extension display
    fileExtensionsLabel = uilabel(fig, 'Text', '', 'Position', [230 170 150 30]);

    % Add checkboxes for file type options
    csvCheckbox = uicheckbox(fig, 'Text', '.csv', 'Position', [20 130 100 30]);
    matCheckbox = uicheckbox(fig, 'Text', '.mat', 'Position', [20 100 100 30]);
    txtCheckbox = uicheckbox(fig, 'Text', '.txt', 'Position', [20 70 100 30]);

    % Add a button to confirm the selection
    confirmButton = uibutton(fig, 'Text', 'Confirm', 'Position', [150 20 100 30], ...
        'ButtonPushedFcn', @(btn, event) confirmSelection());

    % Wait for the user to confirm the selection
    uiwait(fig);

    % Nested function to handle the confirm button click
    function confirmSelection()
        save_options.name = fileNameInput.Value;
        save_options.csv = csvCheckbox.Value;
        save_options.mat = matCheckbox.Value;
        save_options.txt = txtCheckbox.Value;

        % Close the figure
        close(fig);
    end

    % Nested function to update the file extension display
    function updateFileExtensions()
        extensions = '';
        if csvCheckbox.Value
            extensions = [extensions '.csv '];
        end
        if matCheckbox.Value
            extensions = [extensions '.mat '];
        end
        if txtCheckbox.Value
            extensions = [extensions '.txt '];
        end
        fileExtensionsLabel.Text = extensions;
    end

    % Add listeners to update the file extension display when checkboxes are toggled
    addlistener(csvCheckbox, 'ValueChanged', @(src, event) updateFileExtensions());
    addlistener(matCheckbox, 'ValueChanged', @(src, event) updateFileExtensions());
    addlistener(txtCheckbox, 'ValueChanged', @(src, event) updateFileExtensions());

    % Initialize the file extension display
    updateFileExtensions();
end