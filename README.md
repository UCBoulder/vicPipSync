# vicPipSync

vicPipSync is a tool for temporaly syncing DIC data from VIC-SNAP and VIC-3D with Instron data. It can sync datasets that contain a PIP signal in both the VIC and Instron data outputs.
---
# Getting Started

## Downloading vicPipSync

### For non-Git Users

If you are not familiar with Git and just want to download the repository folder to use it as you normally would any other MATLAB code, follow these steps:

1. Go to the [vicPipSync repository](https://github.com/samuelhattonCU/vicPipSync) on GitHub.
2. Click on the green "Code" button located at the top-right corner of the repository page.
3. In the dropdown menu, click on "Download ZIP".
4. Once the ZIP file is downloaded, extract its contents to a folder on your computer.
5. You can now open and use the MATLAB code in the extracted folder as you normally would.

### For Git Users

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
5. You can now open and use the MATLAB code in the cloned repository as you normally would any other piece of code.

## Give It a Try with Sample Data
([Or jump to the user guide below](#detailed-user-guide))

To get a quick feel for how vicPipSync works, you can try syncing up the data in the `Sample Data` folder. Go ahead and run the `vicPipSync` script in MATLAB, and see if you can follow the process. The GUI will prompt you for specific files, and the data in the sample folder is labeled to match. This data is a little messy, so you will need to help the sync function find the PIP signal in the VIC-SNAP data when it prompts you. You can play around with different voltage threshold values to see what works; Remember, the PIP signal is idealy a 5V spike in the data.

You can plot the synced sample data by running the `example_plots.m` script in the `Sample Data` folder. It should produce the plots below (my apologies if you're viewing this in dark mode).

Obviously, the displacements do not match at all! That's the primary driver for using the exetensometer derived displacement values instead of the measured crosshead displacement from the Instron. The two values usually don't match because of things like compliance in the load string or an improperly zeroed displacement reading on the Instron.

It's also useful to notice that the force vs. time data doesn't look that different zoomed out, but when you look closely, you can see that the "synced" data stream has the sampling frequency of the VIC data, which is much less than the Instron data. Generally, your VIC data needs to be more coarse than your Instron data for the syncing to work well.

<img src="Sample Data/sample_plot_fd.png" alt="Sample Force-Displacement Plot" width="75%">

<img src="Sample Data/sample_plot_ft.png" alt="Sample Force-Time Plot" width = "75%">

---

# Detailed User Guide

## How to Get a PIP Signal in Your Data
These instructions are fairly specific to the test setup in the Lopez Jimenez lab, where we have our DIC setup on a moble work bench and our Instron 5969 setup on a table in the middle of the lab. The ([first procedure](#general-procedure)) here is a general guide that should be applicable to any setup. The ([second procedure](#flj-lab-procedure)) is specific to our lab. The `vicPipSync` tool and guide all assume that the PIP or marker signal from the UTM can be measured as a voltage signal by the DIC-connected DAQ.

### General Procedure:
1. Setup your UTM test method to include a PIP or marker log, and add the counter to the working dashboard.
2. Connect your UTM's marker system (usually a push-button on the end of a cable) in series with the UTM's marker circuit and the DIC system's DAQ.
3. Open the `Analog Data` window in VIC-Snap
4. Press the marker button and ensure that both the UTM counter increments and the signal is registered in the analog data plot in VIC-Snap.
5. Ensure that the PIP or marker data is setup to be exported with the rest of the UTM data.
6. Ensure that the correct analog data signal is included in the VIC-Snap project output `.csv` file.
   - A way to check this is to start capturing images, trigger the signal, stop capturing images, hit `ctrl+s`, and then open the `project-name.csv` file in the `project-name/` directory. The file should contain a data column corresponding to the signal; try plotting it to ensure the signal is captured.
7. During any test where the Instron and VIC-Snap are both taking data, press the PIP button to add a temporal marker in both data sets. This is the marker that is used by the tool in post-processing to sync up the two data sets.

### FLJ Lab Procedure:
1. In the Instron Method editing screen:
   - Under the `Method/Console/Live Displays` tab, ensure `PIP count` is listed as a selected live display. 
   - Under the `Method/Workspace/Raw Data/Columns` tab, ensure `PIP count` is listed as a selected measurement. 
   - Save the method file and open it as a test; a PIP counter should now appear in the live display.
2. Ensure the BNC end of the PIP cable is plugged into the `AI 0` port of the DIC-connected DAQ (See reference images below).
3. Open the `Analog Data` window in VIC-Snap.
4. Lightly insert the audio jack end of the PIP cable into the Instron PIP port, just until you feel some resistance (you can pretty much just drop it in). 
   - If you push through the resistance to a point that feels stable, you've gone to far; back the plug out a little bit. 
   - The PIP port is on the left side of the Instron, near where the force transducers plug in (See reference images below).
5. Test the connection by pressing the button on the PIP cable. Each time the button is pressed, there should be a voltage jump in the VIC-Snap anaolg data window and the Instron PIP count should increment by one.
6. During any test where the Instron and VIC-Snap are both taking data, press the PIP button to add a temporal marker in both data sets. This is the marker that is used by the tool in post-processing to sync up the two data sets.

#### Reference Images:
##### PIP Cable: Instron end with audio jack and PIP button

<img src="Reference%20Images/pip-cable.jpg" alt="Image of the PIP cable" width="50%">

##### PIP Cable: BNC plugged into DAQ port AI 0

<img src="Reference%20Images/pip-daq.jpg" alt="Image of a DAQ" width="50%">

##### Instron PIP port location
<img src="Reference%20Images/pip-plug.jpg" alt="Image of an audio jack plugged into an Instron PIP port" width="50%">

## How to Export Your Data for Syncing

There are three separate data files needed to sync Instron data with VIC-3D data (See Sample Data files for reference):

- The Raw Data export `.csv` from the Instron, containing time, force, displacement, and PIP count data columns. 
- The `project_name.csv` file generated by VIC-Snap, containing image id, capture time, and PIP signal data columns.  
- The `extensometer_output.csv` file generated by VIC-3D when a user exports an extensometer data set. 

### Exporting Instron Data
- From the testing live display, press the data export button and save the raw data to an appropriately named `.csv` file. 
- Move this file to the computer you plan to run vicPipSync code on.

### Exporting VIC-Snap Data
It is a reasonable practice to press `ctrl+s` in VIC-Snap after ending data capture to ensure the software writes to the project spreadsheet. The file you need is usually the only `.csv` file in the VIC project folder associated with the test you're working on, and is named the same as all the other project files. The file will exist whether or not any data has been processed in VIC-3D, for example. 
- Open the file to ensure the PIP signal column is there. 
- Copy the file over to the computer you plan to run vicPipSync code on.

### Exporting VIC-3D Extensometer Data
- From the Inspection Panel in the upper left of VIC-3D, select the appropriate extraction plot and press the export button.
- Select which data to export, provide a file name, and press the export button [NOTE: this step needs more clarification, please talk to someone if you're using this and need help].
- Open the saved `.csv` file and ensure that it contains at least an index and a displacement column.

It is important to note that the `index` value associated with VIC-3D inspection extractions is NOT the same as the image index (The number in the `Count` data column) assigned to the actual data image frames. The following requirements aleviate problems related to this:

1. Extensometer outputs must be extracted from sequential data sets only.
   - This means that data sets where only every nth image is processed will not be easy to sync without lots of extra work.
   - Always process all the data frames before generating an extensometer extraction for export.
2. The first row of the extensometer output must correspond to the first row of the VIC-Snap output.
   - Calibration images listed in the VIC-Snap file are automatically ignored.
   - The first non-calibration image in the VIC-Snap file must correspond to the first row in the extensometer output.
   - This can be a problem if the first handful of speckle images weren't included in the analysis and extensometer extraction. If this is the case, the rows corresponding to the unused speckle images need to be removed from the VIC-Snap file before the data can be synced.

In general, `vicPipSync` assumes that `ith` row of the extensometer ouptut table contains data corresponding to the `ith` row of the VIC-Snap output table. In all cases, the sync process enforces that the VIC-Snap and extensometer data sets are the same length, truncating the longer of the two to match the length of the other. This leads to the two guidlines stated above.

The extensometer output index numbers are always numbered sequentially `1-n`, where `n` is the number of processed image frames included in the extraction. This can cause problems if, for example, only one of every five images were processed. This would result in extensometer indexes `1, 2, 3, 4, 5, ..., n` potentially corresponding to image numbers `0, 4, 9, 14, 19, ..., k` (where `k` is the number of the last frame with a number one off from a multiple of five). Another example could be a data set in which the first six images were discarded, and so frame `6` is the reference image for the analysis. If there are 100 total frames and all of them were included in the analysis and extraction, the processed image indexes would be `6, 7, 8, ..., 99, 100`, but the extraction indexes would be `1, 2, 3, ..., 94, 95`. The VIC-Snap file will include rows for images zero through five by default; if these aren't removed prior to syncing the algorithm will end up matching image index `6` with extensometer index `7`, when it should be matched with extensometer index `1`.

Getting this lined up correctly is important, as an index mismatch of only a few can result in a temporal sync error of a second or more; you could do better just clicking the buttons at the same time.

## How to Sync Your Data

### Using a Graphical User Interface (GUI)
1. Ensure you have the VIC-SNAP, VIC-3D, and Instron data files you want to sync.
2. Run the `vicPipSync` script in MATLAB.
   - You can run the script using the Run button, or by typing `vicPipSync` in the MATLAB command window.
   - You can run the script from another piece of MATLAB code using the `run` function.
3. Follow the prompts to select your data files.
   - Select the VIC-SNAP, VIC-3D, and Instron data files using the interactive dialog.
   - You can also load previous selections if available.
   - The script will usually just fail if you select the wrong files, so you can try again if needed.
4. The script will load and synchronize the data.
   - You may need to help the script locate the PIP signal in the VIC-SNAP data if it cannot find it automatically. The script will prompt you to do this if necessary.
5. Choose the file formats you want to save the synchronized data in.
   - You can select from .mat, .csv, and .txt formats.
6. The script will save the synchronized data in the selected formats.
7. You can now use the synchronized data for further analysis.

### Syncing Data Without the GUI
If you want to skip the interactive dialogs, you can use the `load_data` function directly with the file paths as input arguments. Take a look at the header comments in the `load_data` function for more information on how to use it.
---
# Contributions
You can help find bugs by opening an issue and including some steps to follow to make the bug show up. If you would like to submit a bug fix or feature addition, please open an issue, make a pull request, or email samuel.hatton@colorado.edu.

# Acknowledgements
Thanks to Claire Kent for their help writing the user guide.

# Code Overview

The vicPipSync codebase consists of several MATLAB functions designed to load, process, and save synchronized data from various sources. Below is a summary of the key functions. For more detail, please refer to the in-code function header comments.

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



