function vic_snap = get_vic_snap(file_path)
    % get_vic_snap.m
    %
    % Francisco Lopez Jimenez Lab, AMReC
    %
    % Samuel Hatton
    %
    % Inputs:
    %     file_path   string containing the path to the VIC-SNAP
    %                 output .csv containing the PIP signal data,
    %                 frame id numbers, and frame capture time.
    % Outputs:
    %     vic_snap    Table containing the VIC-SNAP PIP data loaded
    %                 from the .csv file, with calibration images
    %                 removed from the list.
    %
    % Methodology:
    %     1. Reads in file as a table.
    %     2. Remoes calibration image entries.
    %     3. Extracts relevent data columns.
    %     4. Locates index of PIP signals
    %         - Uses a default voltage threshold and asks user for help
    %           if that doesn't work at first.
    %     5. Outputs loaded data.
    %         - Outputs empty array if no valid file is found.
    %        
    % Dependencies:
    %     None

    % Load Data, Supress file format warnings
    warning off
    data = readtable(file_path, "NumHeaderLines", 1,"VariableNamesLine",1);
    warning off

    % Trim out calibration images
    bad_rows = contains(data.Filename_0_1,"-cal-");
    data(bad_rows,:) = [];

    % Extract desired columns:
    if any("PIP" == string(data.Properties.VariableNames))
        vic_snap = [data(:,"Count"),data(:,"Time_0_1"),data(:,"PIP")];
    else
        warning("No PIP signal found in '" + file_name + "', skipping")
        vic_snap = [];
        return
    end

    % Adaptively locate PIP press in voltage output signal:
    signal_threshold_volts = 4.85;
    closed_threshold_volts = 0.15;
    signal_strt = find(vic_snap.PIP > signal_threshold_volts,1);
    answer = "def";
    while ~strcmp(answer,"Skip")
        if isempty(signal_strt)
            answer = questdlg("No PIP signal found at a threshold of " + string(signal_threshold_volts) + "V, would you like to skip, or try again with a new threshold value?","No PIP Found","Skip","Set new threshold","Skip");
            switch answer
                case "Skip"
                    warning("No PIP signal found in '" + file_name + "', skipping")
                    vic_snap = [];
                    return
                case "Set new threshold"
                    new_thresh = inputdlg("Please set a new PIP threshold value in Volts.","Input New Threshold");
                    new_thresh = new_thresh{1,1};
                    if ~isa(new_thresh,"double")
                        new_thresh = str2num(new_thresh);
                    end
                    signal_threshold_volts = new_thresh;
                    signal_strt = find(vic_snap.PIP > signal_threshold_volts(1),1);
            end
        else
            answer = "Skip";
        end
    end

    % Check that peak isn't noise
    idxs = find(vic_snap.PIP(signal_strt:end) < closed_threshold_volts); 
    if idxs(1) < signal_strt && signal_strt < idxs(end)
        pip_loc = signal_strt;
    else
        pip_loc = idxs(1);
    end

    % Generate PIP Count vector in format of Instron PIP output
    PIPCount = zeros(length(vic_snap.Count),1);
    PIPCount(pip_loc:end) = 1;

    % Output final data table
    vic_snap.PIPCount = PIPCount;
end