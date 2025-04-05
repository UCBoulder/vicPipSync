function vic_snap = get_vic_snap(file_path,verb)
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
    %     verb        optional, if == "verbose", plots and stuff get
    %                 output
    %
    % Methodology:
    %     1. Reads in file as a table.
    %     2. Removes calibration image entries.
    %     3. Extracts relevent data columns.
    %     4. Locates index of PIP signals
    %         - Uses a grouping algorithm to find the earlist of the most 
    %           prominent peaks or troughs.
    %     5. Outputs loaded data.
    %         - errors if non "PIP" signal exists in the input file.
    %        
    % Dependencies:
    %     None

    if nargin ~= 2
        verb = "No";
    end

    % Load Data, Supress file format warnings
    warning off
    data = readtable(file_path, "NumHeaderLines", 1,"VariableNamesLine",1);
    warning on

    % Trim out calibration images
    bad_rows = contains(data.Filename_0_1,"-cal-");
    data(bad_rows,:) = [];

    % Extract desired columns:
    if any("PIP" == string(data.Properties.VariableNames))
        vic_snap = [data(:,"Count"),data(:,"Time_0_1"),data(:,"PIP")];
    else
        % warning("No PIP signal found in '" + file_name + "', skipping")
        % fprintf("VIC-Snap file FAILED to load successfully\n")
        % vic_snap = [];
        % return
        error("VIC-Snap file FAILED to load successfully: No PIP signal found in '" + file_name)
    end

    % Determine if signal is normally 5v or 0v:
    m = mode(vic_snap.PIP);
    if m <= 2 % if the mode value is below two, signal is 0 normally, 5 for button press
        gate = "low open";
    else % 5v normally, 0 for button press
        gate = "high open";
    end
    
    switch gate
        case "low open"
            fprintf("Searching for voltage spike from 0V to 5V\n")

            % Find largest values, one of which is our desired pip point
            [maxs,mIdx] = maxk(vic_snap.PIP,10);

            % use a prominence value to find the 1st grouping of values:
            c = 1;
            for i = 2:10
                if maxs(i-1) - maxs(i) < 0.004
                    c = c + 1;
                else
                    break
                end
            end
            
            % trim, keeping only the first group:
            mIdx = mIdx(1:c);

            % Pick the earliest of the first group:
            [~,earliestIdx] = min(mIdx);
            pip_loc = mIdx(earliestIdx);
            
            pip_voltage = vic_snap.PIP(pip_loc);

            if pip_voltage > 4.8
                warning("The deteceted PIP signal has a very small prominance, please double check that there is a discernible spike in the signal. Try using the 'verbose' key in your load_data call.")
            end

            if strcmp("verbose",verb)
                figure
                plot(vic_snap.PIP)
                hold on
                scatter(pip_loc,vic_snap.PIP(pip_loc),'xr')
                grid on
                legend("Signal","Detected Spike")
                xlabel("Index")
                ylabel("Voltage")
                title("PIP Signal for " + file_path)
            end                   
        case "high open"
            fprintf("Searching for voltage dip from 5V to 0V\n")
            
            % Find lowest values, one of which is our desired pip point
            [mins,mIdx] = mink(vic_snap.PIP,10);

            % use a prominence value to find the 1st grouping of values:
            c = 1;
            for i = 2:10
                if mins(i) - mins(i-1) < 0.004
                    c = c + 1;
                else
                    break
                end
            end
            
            % trim, keeping only the first group:
            mIdx = mIdx(1:c);

            % Pick the earliest of the first group:
            [~,earliestIdx] = min(mIdx);
            pip_loc = mIdx(earliestIdx);
            
            pip_voltage = vic_snap.PIP(pip_loc);

            if pip_voltage > 4.8
                warning("The deteceted PIP signal has a very small prominance, please double check that there is a discernible spike in the signal. Try using the 'verbose' key in your load_data call.")
            end

            if strcmp("verbose",verb)
                figure
                plot(vic_snap.PIP)
                hold on
                scatter(pip_loc,vic_snap.PIP(pip_loc),'xr')
                grid on
                legend("Signal","Detected Dip")
                xlabel("Index")
                ylabel("Voltage")
                title("PIP Signal for " + file_path)
            end            
    end

    % Generate PIP Count vector in format of Instron PIP output
    PIPCount = zeros(length(vic_snap.Count),1);
    PIPCount(pip_loc:end) = 1;

    % Output final data table
    vic_snap.PIPCount = PIPCount;
    fprintf("VIC-Snap file loaded successfully\n")
end