# vicPipSync

vicPipSync is a tool for temporaly syncing DIC data from VIC-SNAP and VIC-3D with Instron data. It can sync datasets that contain a PIP signal in both the VIC and Instron data outputs.

## How to get vicPipSync

### For Users Not Familiar with Git

If you are not familiar with Git and just want to download the repository folder to use it as you normally would any other MATLAB code, follow these steps:

1. Go to the [vicPipSync repository](https://github.com/samuelhattonCU/vicPipSync) on GitHub.
2. Click on the green "Code" button located at the top-right corner of the repository page.
3. In the dropdown menu, click on "Download ZIP".
4. Once the ZIP file is downloaded, extract its contents to a folder on your computer.
5. You can now open and use the MATLAB code in the extracted folder as you normally would.

### For Users Familiar with Git

If you are familiar with Git and prefer to clone the repository yourself, follow these steps:

1. Open your terminal or command prompt.
2. Navigate to the directory where you want to clone the repository.
3. Run the following command to clone the repository:
   ```bash
   git clone https://github.com/samuelhattonCU/vicPipSync.git
   ```
4. Navigate into the cloned repository:
   ```bash
   cd vicPipSync
   ```
5. You can now open and use the MATLAB code in the cloned repository as you normally would.

# Usage

## How to Get a PIP Signal in Your Data

## How to Export Your Data for Syncing

## How to Sync Your Data

# Contributions
If you would like to submit a bug fix or feature addition, please open an issue, make a pull request, or email samuel.hatton@colorado.edu.

# Code Overview

The vicPipSync codebase consists of several MATLAB functions designed to load, process, and save synchronized data from various sources. Below is a summary of the key functions:

### `vicPipSync.m`
This is the main script that orchestrates the data synchronization process. It performs the following steps:
1. Sets up the working directory.
2. Prompts the user to select data files using `sample_select`.
3. Loads and synchronizes the data using `load_data`.
4. Saves the synchronized data using `save_data`.

### `sample_select.m`
This function provides an interactive dialog for the user to select the VIC-SNAP, VIC-3D, and Instron data files. It supports loading previous selections and saves the current selection for future use.

### `load_data.m`
This function loads the data from the selected files and synchronizes them. It performs the following steps:
1. Loads VIC-SNAP data using `get_vic_snap`.
2. Loads VIC-3D extensometer data using `get_ext_data`.
3. Loads Instron data using `get_inst_data`.
4. Interpolates missing values in the extensometer data.
5. Synchronizes the data using `sync_data` (not shown in the provided context).
6. Outputs the synchronized data.

### `get_vic_snap.m`
This function loads VIC-SNAP data from a CSV file, removes calibration images, extracts relevant columns, and locates the PIP signal. It outputs a table containing the PIP data.

### `get_ext_data.m`
This function loads VIC-3D extensometer data from a CSV file, assigns standardized variable names, and outputs a table containing the extensometer data.

### `get_inst_data.m`
This function loads Instron data from a CSV file, suppresses formatting warnings, and outputs a table containing the Instron test data.

### `save_data.m`
This function saves the synchronized data to various file formats (.mat, .csv, .txt) based on user selection. It performs the following steps:
1. Validates the input data.
2. Prompts the user to select file formats.
3. Opens file save dialogs for each selected format.
4. Saves the data in the selected formats.
5. Handles errors and user cancellations gracefully.



