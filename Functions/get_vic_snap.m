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

            % % Set thresholds
            % start_threshold = 4.8;
            % close_threshold = 0.1;
            % 
            % % find first threshold breach
            % spike_start = find(vic_snap.PIP > start_threshold,1);
            % 
            % % while isempty(spike_start)
            % %     fprintf("No spike found with voltage threshold %.2f V, trying again.\n",start_threshold)
            % %     start_threshold = start_threshold - 0.02;
            % %     if start_threshold <= close_threshold
            % %         error("No PIP signal found in " + file_path)
            % %     end
            % %     spike_start = find(vic_snap.PIP > start_threshold,1);
            % % end
            % % fprintf("Found signal spike above %.2f V\n", start_threshold);
            % 
            % if isempty(spike_start)
            %     fprintf("No spike found with voltage threshold %f V, trying again.\n",start_threshold)
            %     [maxV,max_idx] = max(vic_snap.PIP);
            %     if maxV > close_threshold + 0.01
            %         spike_start = max_idx;
            %     else
            %         figure
            %         plot(vic_snap.PIP)
            %         hold on
            %         yline(close_threshold + 0.01,'--')
            %         grid on
            %         legend("Signal","Threshold")
            %         xlabel("Index")
            %         ylabel("Voltage")
            %         title("PIP Signal for " + file_path)
            %         a = gca;
            %         a.YLim = [a.YLim(1),close_threshold+0.015];
            % 
            %         error("No PIP signal outside of the smallest threshold! Please see generated figure for reference.")
            %     end
            %     fprintf("Used maximum point (%.2f V) as PIP point\n", maxV);
            %     figure
            %     plot(vic_snap.PIP)
            %     hold on
            %     scatter(spike_start,vic_snap.PIP(spike_start),'xr')
            %     grid on
            %     legend("Signal","Detected Spike")
            %     xlabel("Index")
            %     ylabel("Voltage")
            %     title("PIP Signal for " + file_path)
            % else
            %     fprintf("Found signal spike above %.2f V\n", start_threshold);
            %     if strcmp("verbose",verb)
            %         figure
            %         plot(vic_snap.PIP)
            %         hold on
            %         scatter(spike_start,vic_snap.PIP(spike_start),'xr')
            %         grid on
            %         legend("Signal","Detected Spike")
            %         xlabel("Index")
            %         ylabel("Voltage")
            %         title("PIP Signal for " + file_path)
            %     end
            % end
            
                    
        case "high open"
            fprintf("Searching for voltage dip from 5V to 0V\n")
            % set thresholds
            % start_threshold = 0.1;
            % close_threshold = 4.9;

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

            % pip_loc = vic_snap.PIP(mIdx);
                

            % % group values by their magnitude using a prominance

            % currentGroup = 1;
            % groups = ones(10,1);
            % 
            % for i = 2:10
            %     % If current values is significantly larger than the
            %     % previous, start a new group:
            %     if mins(i) - mins(i-1) > 0.004
            %         currentGroup = currentGroup + 1;
            %     end
            %     groups(i) = currentGroup;
            % end
            % 
            % % For each group, find the earliest occurence:
            % candIdx = zeros(currentGroup,1);
            % candMin = zeros(currentGroup,1);
            % 
            % for i = 1:currentGroup
            %     members = mIdx(groups == i);
            %     [~,earliestIdx] = min(members);
            %     candIdx(i) = members(earliestIdx);
            %     candMin(i) = vic_snap.PIP(candIdx(i));
            % end
            % 
            % % choose the earliest value from the smallest group



            % % find first threshold breach
            % spike_start = find(vic_snap.PIP < start_threshold);
            % 
            % % while isempty(spike_start)
            % %     fprintf("No dip found with voltage threshold %f V, trying again.\n",start_threshold)
            % %     start_threshold = start_threshold + 0.02;
            % %     if start_threshold >= close_threshold
            % %         error("No PIP signal found in " + file_path)
            % %     end
            % %     spike_start = find(vic_snap.PIP < start_threshold,1);
            % % end
            % 
            % if isempty(spike_start)
            %     fprintf("No dip found with voltage threshold %f V, trying again.\n",start_threshold)
            %     [minV,min_idx] = min(vic_snap.PIP);
            %     if minV < close_threshold - 0.01
            %         spike_start = min_idx;
            %     else
            %         figure
            %         plot(vic_snap.PIP)
            %         hold on
            %         yline(close_threshold- 0.01,'--')
            %         grid on
            %         legend("Signal","Threshold")
            %         xlabel("Index")
            %         ylabel("Voltage")
            %         title("PIP Signal for " + file_path)
            %         a = gca;
            %         a.YLim = [close_threshold-0.015,a.YLim(2)];
            % 
            %         error("No PIP signal outside of the smallest threshold! Please see generated figure for reference.")
            %     end
            %     fprintf("Used minimum point (%.2f V) as PIP point\n", minV);
            %     figure
            %     plot(vic_snap.PIP)
            %     hold on
            %     scatter(spike_start,vic_snap.PIP(spike_start),'xr')
            %     grid on
            %     legend("Signal","Detected Dip")
            %     xlabel("Index")
            %     ylabel("Voltage")
            %     title("PIP Signal for " + file_path)
            % else
            %     fprintf("Found signal dip below %.2f V\n", start_threshold);
            %     if strcmp("verbose",verb)
            %         figure
            %         plot(vic_snap.PIP)
            %         hold on
            %         scatter(spike_start,vic_snap.PIP(spike_start),'xr')
            %         grid on
            %         legend("Signal","Detected Dip")
            %         xlabel("Index")
            %         ylabel("Voltage")
            %         title("PIP Signal for " + file_path)
            %     end
            % end
            
    end


    % % Check that peak isn't noise
    % idxs = find(vic_snap.PIP(spike_start:end) < close_threshold); 
    % if idxs(1) > spike_start && spike_start < idxs(end)
    %     pip_loc = spike_start;
    % else
    %     pip_loc = idxs(1);
    % end
    
    % pip_loc = spike_start;

    % Generate PIP Count vector in format of Instron PIP output
    PIPCount = zeros(length(vic_snap.Count),1);
    PIPCount(pip_loc:end) = 1;

    % Output final data table
    vic_snap.PIPCount = PIPCount;
    fprintf("VIC-Snap file loaded successfully\n")
end