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
%     sample_select.m
%     load_data.m
%     save_data.m
%     get_vic_snap.m
%     get_ext_data.m
%     get_inst_data.m
%     sync_data.m
%
clear; close all; clc;
addpath("Functions\")

%% Get User Input

% Get locations of data files to be synced:
target = sample_select;


%% Load and Sync Data

synced_force_disp = load_data(target);

%% Output Synced Data

save_data(synced_force_disp);
