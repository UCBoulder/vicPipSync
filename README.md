# vicPipSync

vicPipSync is a MATLAB package for syncing DIC data from VIC-SNAP and VIC-3D with Instron force-displacement data using a shared PIP signal.

---

# Getting Started

Go to [Documentation](Documentation/) for more detailed guides.

## Download

**Option 1: Download ZIP File**
1. Go to the [vicPipSync GitHub page](https://github.com/samuelhattonCU/vicPipSync).
2. Click "Code" > "Download ZIP".
3. Extract the ZIP and open the folder in MATLAB.

**Option 2: Clone with Git**
1. Open a terminal.
2. Run:  
   ```bash
   git clone https://github.com/samuelhattonCU/vicPipSync.git
   cd vicPipSync
   ```
3. Open the folder in MATLAB.

## Try Sample Data

- Run `vicPipSync` in MATLAB and follow the prompts to sync the sample data in the `Sample Data` folder.
- Plot the results with `example_plots.m` in the same folder.

<img src="Sample Data/sample_plot_fd.png" alt="Sample Force-Displacement Plot" width="75%">
<img src="Sample Data/sample_plot_ft.png" alt="Sample Force-Time Plot" width="75%">

---

# Detailed User Guide

## Getting a PIP Signal

- Ensure your test setup records a PIP (marker) signal in both the Instron and VIC-Snap data.
- Connect the marker button to both systems.
- Confirm the PIP signal appears in both the Instron and VIC-Snap outputs.

## Exporting Data

You need three CSV files:
- Instron raw data export (time, force, displacement, PIP count)
- VIC-Snap project CSV (image id, time, PIP signal)
- VIC-3D extensometer export (index, displacement)

**Tips:**
- Always export all frames for extensometer data.
- The first row of extensometer output must match the first non-calibration row in VIC-Snap.
- Ensure indexes align between files for accurate syncing.

## Syncing Data

**With GUI:**
1. Run `vicPipSync` in MATLAB.
2. Select your data files when prompted.
3. Choose output formats and save.

**Without GUI:**
- Call `load_data` directly with file paths. See `load_data.m` header for details.

---

# Contributions

Report bugs or suggest features by opening an issue or pull request, or email samuel.hatton@colorado.edu.

# Acknowledgements

Thanks to Claire Kent for help with the user guide. Thanks to Hide Nakanishi for help squashing bugs.

# Code Overview

The vicPipSync codebase consists of several MATLAB functions designed to load, process, synchronize, and save data from various sources. Below is a summary of the key scripts and functions. For more detail, please refer to the in-code function header comments.

### `vicPipSync.m`
Main script that orchestrates the data synchronization process:
1. Sets up the working directory.
2. Prompts the user to select data files using [`sample_select.m`](Functions/sample_select.m).
3. Loads and synchronizes the data using [`load_data.m`](Functions/load_data.m).
4. Saves the synchronized data using [`save_data.m`](Functions/save_data.m).

### `sample_select.m`
Interactive dialog for selecting the VIC-SNAP, VIC-3D, and Instron data files. Supports loading previous selections and saving the current selection for future use.

### `load_data.m`
Loads data from the selected files and synchronizes them:
1. Loads VIC-SNAP data using [`get_vic_snap.m`](Functions/get_vic_snap.m).
2. Loads VIC-3D extensometer data using [`get_ext_data.m`](Functions/get_ext_data.m).
3. Loads Instron data using [`get_inst_data.m`](Functions/get_inst_data.m).
4. Interpolates missing values in the extensometer data.
5. Synchronizes the data using [`sync_data.m`](Functions/sync_data.m).
6. Outputs the synchronized data.

### `get_vic_snap.m`
Loads VIC-SNAP data from a CSV file, removes calibration images, extracts relevant columns, and locates the PIP signal. Outputs a table containing the PIP data.

### `get_ext_data.m`
  Loads VIC-3D extensometer data from a CSV file, assigns standardized variable names, interpolates missing indexes, and outputs a table containing the extensometer data.

### `get_inst_data.m`  
  Loads Instron data from a CSV file, handles different file formats, and outputs a table containing the Instron test data.

### `sync_data.m`
Synchronizes the VIC-SNAP, extensometer, and Instron data tables based on PIP signals and time alignment. Outputs a table with synchronized force, displacement, and time data.

### `save_data.m`
Saves the synchronized data to various file formats (.mat, .csv, .txt) based on user selection:
1. Validates the input data.
2. Prompts the user to select file formats.
3. Opens file save dialogs for each selected format.
4. Saves the data in the selected formats.
5. Handles errors and user cancellations gracefully.

### `get_save_options.m`
Provides a GUI for the user to select file name and desired file types for saving the synchronized output data.

---

### Example Plot Script

#### `Sample Data/example_plots.m`
Quick script to plot the sample data. Assumes `synced_force_disp` and `target` variables exist in the workspace. Produces force vs. time and force vs. displacement plots for visual comparison of raw and synchronized data.

---



