@echo off
setlocal enabledelayedexpansion

REM Get the directory of the original batch file
set "BASE_DIR=%~dp0"

REM Define settings file location
set "SETTINGS_FILE=%BASE_DIR%settings.conf"

REM Read settings from file or ask user for input
if exist "%SETTINGS_FILE%" (
    echo Reading settings from settings.conf...
    for /f "tokens=1,* delims==" %%A in (%SETTINGS_FILE%) do set "%%A=%%B"
) else (
    echo settings.conf not found. Asking for directories...
    set /p "SCRIPT_DIR=Enter the path to the Conversion Script directory: "
    set /p "OUTPUT_DIR=Enter the path to the Output directory: "
    set /p "DEST_DIR=Enter the path to the Inputdata directory: "

    REM Ask user if Anaconda should be used (accepts yes/y or no/n)
    :ask_anaconda
    set /p "USE_ANACONDA=Do you want to use a specific Anaconda/Python environment (otherwise the base environment will be used)? (yes/y or no/n): "
    set "USE_ANACONDA=!USE_ANACONDA:~0,1!"  REM Extract first character (case insensitive)
    if /I "!USE_ANACONDA!"=="y" (
        set "USE_ANACONDA=yes"
        set /p "ANACONDA_PATH=Enter the path to the Anaconda installation folder (usually C:\\Users\username\anaconda3): "
        set /p "ENV_NAME=Enter the name of the Conda environment: "
    ) else if /I "!USE_ANACONDA!"=="n" (
        set "USE_ANACONDA=no"
    ) else (
        echo Invalid input! Please enter yes, y, no, or n.
        goto ask_anaconda
    )

    REM Save to settings.conf
    (
        echo SCRIPT_DIR=!SCRIPT_DIR!
        echo OUTPUT_DIR=!OUTPUT_DIR!
        echo DEST_DIR=!DEST_DIR!
        echo USE_ANACONDA=!USE_ANACONDA!
        if /I "!USE_ANACONDA!"=="yes" (
            echo ANACONDA_PATH=!ANACONDA_PATH!
            echo ENV_NAME=!ENV_NAME!
        )
    ) > "%SETTINGS_FILE%"

    echo Settings saved in settings.conf.
)

REM Verify directories
if "%SCRIPT_DIR%"=="" (
    echo ERROR: SCRIPT_DIR is empty!
    pause
    exit /b 1
)
if "%OUTPUT_DIR%"=="" (
    echo ERROR: OUTPUT_DIR is empty!
    pause
    exit /b 1
)
if "%DEST_DIR%"=="" (
    echo ERROR: DEST_DIR is empty!
    pause
    exit /b 1
)

echo SCRIPT_DIR=%SCRIPT_DIR%
echo OUTPUT_DIR=%OUTPUT_DIR%
echo DEST_DIR=%DEST_DIR%

REM Ensure SCRIPT_DIR exists
if not exist "%SCRIPT_DIR%" (
    echo ERROR: SCRIPT_DIR does not exist! Falling back to BASE_DIR.
    set "SCRIPT_DIR=%BASE_DIR%"
)

REM Define Python script path
set "PYTHON_SCRIPT=%SCRIPT_DIR%\temp_script.py"

REM Delete old script if it exists
if exist "%PYTHON_SCRIPT%" del "%PYTHON_SCRIPT%"

REM Prompt user for processing option
echo.
echo Please choose a processing option:
echo [1] Parameters only (default)
echo [2] Both parameters and timeseries
echo [3] Only timeseries
echo.
set /p "PROCESSING_OPTION=Enter your choice (1/2/3): "

REM Set processing option based on user input
if "%PROCESSING_OPTION%"=="2" (
    set "PROCESSING_OPTION=both"
) else if "%PROCESSING_OPTION%"=="3" (
    set "PROCESSING_OPTION=timeseries_only"
) else (
    set "PROCESSING_OPTION=parameters_only"
)

REM Writing Python script line by line
echo Writing temp_script.py...
echo # -*- coding: utf-8 -*- > "%PYTHON_SCRIPT%"
echo settings_file = 'Set_filter_file.xlsx' >> "%PYTHON_SCRIPT%"
echo output_file_format = 'excel' >> "%PYTHON_SCRIPT%"
echo output_format = 'long' >> "%PYTHON_SCRIPT%"
echo processing_option = '%PROCESSING_OPTION%' >> "%PYTHON_SCRIPT%"
echo scenario_option = 'Europe_EnVis_NECPEssentials' >> "%PYTHON_SCRIPT%"
echo debugging_output = False >> "%PYTHON_SCRIPT%"
echo data_base_region = 'DE' >> "%PYTHON_SCRIPT%"
echo from functions.function_import import master_function >> "%PYTHON_SCRIPT%"
echo scenarios = ["Europe_EnVis_Green","Europe_EnVis_Trinity","Europe_EnVis_REPowerEU++","Europe_EnVis_NECPEssentials"] >> "%PYTHON_SCRIPT%"
echo for s in scenarios: >> "%PYTHON_SCRIPT%"
echo     print("Currently performing operation for scenario: ", s) >> "%PYTHON_SCRIPT%"
echo     master_function(settings_file, output_file_format, output_format, processing_option, s, debugging_output, data_base_region) >> "%PYTHON_SCRIPT%"

REM Check if Python script was created
if not exist "%PYTHON_SCRIPT%" (
    echo ERROR: Failed to create temp_script.py!
    pause
    exit /b 1
)

REM Activate Anaconda environment if needed
if /I "%USE_ANACONDA%"=="yes" (
    if "%ANACONDA_PATH%"=="" (
        echo ERROR: ANACONDA_PATH is empty!
        pause
        exit /b 1
    )
    if "%ENV_NAME%"=="" (
        echo ERROR: ENV_NAME is empty!
        pause
        exit /b 1
    )

    echo Activating Anaconda environment: %ENV_NAME%
    call "%ANACONDA_PATH%\Scripts\activate.bat" "%ANACONDA_PATH%"
    call conda activate "%ENV_NAME%"
)

REM Change to script directory
cd /d "%SCRIPT_DIR%"

REM Run the Python script
echo Running Python script...
python "%PYTHON_SCRIPT%"
if %errorlevel% neq 0 (
    echo ERROR: Python script failed!
    pause
    exit /b 1
)

REM Define file lists based on processing option
set "FILES_TO_COPY=RegularParameters_Europe_EnVis_NECPEssentials.xlsx RegularParameters_Europe_EnVis_REPowerEU++.xlsx RegularParameters_Europe_EnVis_Trinity.xlsx RegularParameters_Europe_EnVis_Green.xlsx"
if "%PROCESSING_OPTION%"=="both" (
    set "FILES_TO_COPY=%FILES_TO_COPY% Timeseries_Europe_EnVis_NECPEssentials.xlsx Timeseries_Europe_EnVis_REPowerEU++.xlsx Timeseries_Europe_EnVis_Trinity.xlsx Timeseries_Europe_EnVis_Green.xlsx"
)
if "%PROCESSING_OPTION%"=="timeseries_only" (
    set "FILES_TO_COPY=Timeseries_Europe_EnVis_NECPEssentials.xlsx Timeseries_Europe_EnVis_REPowerEU++.xlsx Timeseries_Europe_EnVis_Trinity.xlsx Timeseries_Europe_EnVis_Green.xlsx"
)

REM Copy output files
echo Copying output files...
for %%F in (%FILES_TO_COPY%) do (
    if exist "%OUTPUT_DIR%\%%F" (
        copy "%OUTPUT_DIR%\%%F" "%DEST_DIR%\" /Y
    ) else (
        echo WARNING: File %%F not found!
    )
)

REM Prompt user to exit or run all_pathways_combined_dataload.bat
echo.
echo What would you like to do next?
echo [1] Exit (default)
echo [2] Run all_pathways_combined_dataload.bat
echo.
set /p "NEXT_ACTION=Enter your choice (1/2): "

if "%NEXT_ACTION%"=="2" (
    echo Running all_pathways_combined_dataload.bat...
    cd /d "%BASE_DIR%"
    call all_pathways_combined_dataload.bat
)

echo Done.
pause
exit /b 0
