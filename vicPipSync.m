% vicPipSync.m
%
% vicPipSync is a tool for temporaly syncing DIC data from VIC-SNAP and VIC-3D with Instron data.
% It can sync datasets that contain a PIP signal in both the VIC and Instron data outputs.
%
% To sync your data, either run this script in MATLAB or run it from the commandline or
% inside another script using the `run("path/to/this/script/vicPipSync.m")` command
%
% For more usage instructions, please visit ######################
%
% Samuel Hatton
% Francisco Lopez Jimenez Lab
% AMReC
% Boulder, CO
%
% March 2025
%
%
% Dependencies:
%
%

%% Initial setup
current_dir = pwd;

% Check for temp directory
if ~exist('vicPipSync_temp', 'dir')
    mkdir('vicPipSync_temp');
end

%% Get User Input

% Get locations of data files to be synced:
target = sample_select;


%% Load and Sync Data

synced_force_disp = load_data(target);

%% Output Synced Data

save_data(synced_force_disp);
