# Requirements Document for `save_data` Function

## 1. Overview

The `save_data` function allows users to save experimental data to various file formats through an interactive GUI experience. The function is designed for the Francisco Lopez Jimenez Lab at AMReC and handles synchronized force-displacement data.

## 2. Input Requirements

- **synced_force_disp**: Must be a MATLAB table containing synchronized force and displacement data
  - Input validation must be performed to ensure the parameter is a valid table
  - The table should maintain its structure and column names in the saved output

## 3. Functional Requirements

### 3.1 File Format Selection

- Function must present a dialog box allowing users to select one or more of the following file formats:
  - `.mat` (MATLAB data file)
  - `.csv` (Comma Separated Values)
  - `.txt` (Tab-delimited text file)
- Dialog must clearly present options and allow multiple selections
- Dialog must include a "Cancel" option to abort the entire save operation

### 3.2 File/Directory Selection

- For each selected file format, the function must:
  - Open the OS-native file save dialog
  - Allow users to navigate to and select a save directory
  - Allow users to specify a filename
  - Apply the appropriate extension to the filename automatically
- Function must present save dialogs sequentially for each selected format
- Function must preserve the user's directory location between save operations
- Function must preserve the user's filename between save operations (only changing the extension)

### 3.3 Data Saving

- For `.mat` files:
  - Save the table using the `save` function with appropriate variable names
- For `.csv` files:
  - Save using `writetable` with comma delimiter
- For `.txt` files:
  - Save using `writetable` with tab delimiter

## 4. Non-Functional Requirements

### 4.1 Error Handling

- Function must validate the input parameter before proceeding
- Function must handle user cancellation at any point gracefully
- Function must catch and handle file access/permission errors
- If errors occur during saving, appropriate error messages must be displayed
- Function must not crash under any circumstances, returning control to the caller

### 4.2 Performance

- Function should use native MATLAB functions for file operations
- Function should minimize memory usage when handling large datasets

### 4.3 Usability

- Dialog boxes must have clear instructions and intuitive interfaces
- Error messages must be informative and suggest solutions
- File types must be clearly labeled in the selection dialog

### 4.4 Compatibility

- Function must work on Windows, macOS, and Linux operating systems
- Function must use OS-native file dialogs via MATLAB's `uiputfile` function
- Function must handle path differences between operating systems

## 5. Dependencies

- MATLAB's built-in functions:
  - `uiputfile` and/or `uisave` for file dialogs
  - `save` for .mat files
  - `writetable` for .csv and .txt files
  - `istable` for input validation
  - `warning` and `errordlg` for error handling

## 6. Test Cases

1. Valid table input with various column types
2. Selection of all file formats
3. Selection of a single file format
4. User cancellation at format selection
5. User cancellation at file/directory selection
6. Saving to a location without write permission
7. Saving with special characters in filename
8. Verification of data integrity in saved files

## 7. Version History

- Initial development by Samuel Hatton with assistance from GPT-4o
