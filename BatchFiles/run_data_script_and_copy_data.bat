@echo off
setlocal enabledelayedexpansion

REM Get the directory of the original batch file
set "BASE_DIR=%~dp0"

REM Define settings file location
set "SETTINGS_FILE=%BASE_DIR%settings.conf"

REM Check if settings file exists
if exist "%SETTINGS_FILE%" (
    echo Reading settings from existing settings.conf...
    for /f "tokens=1,* delims==" %%A in (%SETTINGS_FILE%) do set "%%A=%%B"
) else (
    echo settings.conf not found. Please provide the required directories.

    REM Ask user for input
    set /p "SCRIPT_DIR=Enter the path to the Conversion Script directory: "
    set /p "OUTPUT_DIR=Enter the path to the Output directory: "
    set /p "DEST_DIR=Enter the path to the Inputdata directory: "

    REM Save to settings.conf properly using delayed expansion
    (
        echo SCRIPT_DIR=!SCRIPT_DIR!
        echo OUTPUT_DIR=!OUTPUT_DIR!
        echo DEST_DIR=!DEST_DIR!
    ) > "%SETTINGS_FILE%"

    echo Settings saved in settings.conf.
)

REM Read settings from file again to ensure values are set
for /f "tokens=1,* delims==" %%A in (%SETTINGS_FILE%) do set "%%A=%%B"

REM Verify that variables were loaded correctly
if "%SCRIPT_DIR%"=="" (
    echo ERROR: SCRIPT_DIR not set properly.
    pause
    exit /b 1
)
if "%OUTPUT_DIR%"=="" (
    echo ERROR: OUTPUT_DIR not set properly.
    pause
    exit /b 1
)
if "%DEST_DIR%"=="" (
    echo ERROR: DEST_DIR not set properly.
    pause
    exit /b 1
)

REM Show selection screen
echo.
echo Please choose a processing option:
echo [1] Parameters only (default)
echo [2] Both parameters and timeseries
echo.
set /p "PROCESSING_OPTION=Enter your choice (1/2): "

REM Set processing option based on user input
if "%PROCESSING_OPTION%"=="2" (
    set "PROCESSING_OPTION=both"
) else (
    set "PROCESSING_OPTION=parameters_only"
)

REM Define Python script path
set "PYTHON_SCRIPT=%SCRIPT_DIR%\temp_script.py"

REM Write Python script
(
echo # -*- coding: utf-8 -*- 
echo settings_file = 'Set_filter_file.xlsx' 
echo output_file_format = 'excel' 
echo output_format = 'long' 
echo processing_option = '%PROCESSING_OPTION%' 
echo scenario_option = 'Europe_EnVis_NECPEssentials' 
echo debugging_output = False 
echo from functions.function_import import master_function 
echo scenarios = ["Europe_EnVis_Green","Europe_EnVis_Trinity","Europe_EnVis_REPowerEU++","Europe_EnVis_NECPEssentials"] 
echo for s in scenarios: 
echo     print("Currently performing operation for scenario: ", s) 
echo     master_function(settings_file, output_file_format, output_format, processing_option, s, debugging_output) 
) > "%PYTHON_SCRIPT%"

REM Change to script directory
cd /d "%SCRIPT_DIR%"

REM Run Python script
python "%PYTHON_SCRIPT%"

REM Check for errors
if %errorlevel% neq 0 (
    echo Error executing Python script!
    pause
    exit /b %errorlevel%
)

REM Copy output files
for %%F in (Europe_EnVis_NECPEssentials Europe_EnVis_REPowerEU++ Europe_EnVis_Trinity Europe_EnVis_Green) do (
    xcopy "%OUTPUT_DIR%\RegularParameters_%%F.xlsx" "%DEST_DIR%\" /Y
)

REM Show exit menu
echo.
echo Process completed! What would you like to do next?
echo [1] Exit (default)
echo [2] Run "all_pathways_combined_dataload.bat"
echo.
set /p "EXIT_OPTION=Enter your choice (1/2): "

REM Run additional batch file if option 2 is selected
if "%EXIT_OPTION%"=="2" (
    if exist "%BASE_DIR%all_pathways_combined_dataload.bat" (
        echo Changing directory to %BASE_DIR%...
        cd /d "%BASE_DIR%"
        echo Running all_pathways_combined_dataload.bat...
        call "all_pathways_combined_dataload.bat"
    ) else (
        echo ERROR: all_pathways_combined_dataload.bat not found in %BASE_DIR%!
        pause
    )
)

echo Exiting script...
exit /b 0
