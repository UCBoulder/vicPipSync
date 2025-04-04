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
        fprintf("VIC-Snap file FAILED to load successfully\n")
        vic_snap = [];
        return
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
            % Set thresholds
            start_threshold = 4.8;
            close_threshold = 0.1;
            
            % find first threshold breach
            spike_start = find(vic_snap.PIP > start_threshold,1);
            
            % while isempty(spike_start)
            %     fprintf("No spike found with voltage threshold %.2f V, trying again.\n",start_threshold)
            %     start_threshold = start_threshold - 0.02;
            %     if start_threshold <= close_threshold
            %         error("No PIP signal found in " + file_path)
            %     end
            %     spike_start = find(vic_snap.PIP > start_threshold,1);
            % end
            % fprintf("Found signal spike above %.2f V\n", start_threshold);

            if isempty(spike_start)
                fprintf("No spike found with voltage threshold %f V, trying again.\n",start_threshold)
                [maxV,max_idx] = max(vic_snap.PIP);
                if maxV > close_threshold + 0.01
                    spike_start = max_idx;
                else
                    figure
                    plot(vic_snap.PIP)
                    hold on
                    yline(close_threshold + 0.01,'--')
                    grid on
                    legend("Signal","Threshold")
                    xlabel("Index")
                    ylabel("Voltage")
                    title("PIP Signal for " + file_path)
                    a = gca;
                    a.YLim = [a.YLim(1),close_threshold+0.015];

                    error("No PIP signal outside of the smallest threshold! Please see generated figure for reference.")
                end
                fprintf("Used maximum point (%.2f V) as PIP point\n", maxV);
                figure
                plot(vic_snap.PIP)
                hold on
                scatter(spike_start,vic_snap.PIP(spike_start),'xr')
                grid on
                legend("Signal","Detected Spike")
                xlabel("Index")
                ylabel("Voltage")
                title("PIP Signal for " + file_path)
            else
                fprintf("Found signal spike above %.2f V\n", start_threshold);
                if strcmp("verbose",verb)
                    figure
                    plot(vic_snap.PIP)
                    hold on
                    scatter(spike_start,vic_snap.PIP(spike_start),'xr')
                    grid on
                    legend("Signal","Detected Spike")
                    xlabel("Index")
                    ylabel("Voltage")
                    title("PIP Signal for " + file_path)
                end
            end
            
                    
        case "high open"
            fprintf("Searching for voltage dip from 5V to 0V\n")
            % set thresholds
            start_threshold = 0.1;
            close_threshold = 4.9;

            % find first threshold breach
            spike_start = find(vic_snap.PIP < start_threshold);

            % while isempty(spike_start)
            %     fprintf("No dip found with voltage threshold %f V, trying again.\n",start_threshold)
            %     start_threshold = start_threshold + 0.02;
            %     if start_threshold >= close_threshold
            %         error("No PIP signal found in " + file_path)
            %     end
            %     spike_start = find(vic_snap.PIP < start_threshold,1);
            % end
            
            if isempty(spike_start)
                fprintf("No dip found with voltage threshold %f V, trying again.\n",start_threshold)
                [minV,min_idx] = min(vic_snap.PIP);
                if minV < close_threshold - 0.01
                    spike_start = min_idx;
                else
                    figure
                    plot(vic_snap.PIP)
                    hold on
                    yline(close_threshold- 0.01,'--')
                    grid on
                    legend("Signal","Threshold")
                    xlabel("Index")
                    ylabel("Voltage")
                    title("PIP Signal for " + file_path)
                    a = gca;
                    a.YLim = [close_threshold-0.015,a.YLim(2)];

                    error("No PIP signal outside of the smallest threshold! Please see generated figure for reference.")
                end
                fprintf("Used minimum point (%.2f V) as PIP point\n", minV);
                figure
                plot(vic_snap.PIP)
                hold on
                scatter(spike_start,vic_snap.PIP(spike_start),'xr')
                grid on
                legend("Signal","Detected Dip")
                xlabel("Index")
                ylabel("Voltage")
                title("PIP Signal for " + file_path)
            else
                fprintf("Found signal dip below %.2f V\n", start_threshold);
                if strcmp("verbose",verb)
                    figure
                    plot(vic_snap.PIP)
                    hold on
                    scatter(spike_start,vic_snap.PIP(spike_start),'xr')
                    grid on
                    legend("Signal","Detected Dip")
                    xlabel("Index")
                    ylabel("Voltage")
                    title("PIP Signal for " + file_path)
                end
            end
            
    end


    % % Check that peak isn't noise
    % idxs = find(vic_snap.PIP(spike_start:end) < close_threshold); 
    % if idxs(1) > spike_start && spike_start < idxs(end)
    %     pip_loc = spike_start;
    % else
    %     pip_loc = idxs(1);
    % end
    
    pip_loc = spike_start;

    % Generate PIP Count vector in format of Instron PIP output
    PIPCount = zeros(length(vic_snap.Count),1);
    PIPCount(pip_loc:end) = 1;

    % Output final data table
    vic_snap.PIPCount = PIPCount;
    fprintf("VIC-Snap file loaded successfully\n")
end