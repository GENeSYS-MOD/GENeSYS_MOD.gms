@echo off
setlocal

REM Verzeichnisse definieren
set "SCRIPT_DIR=C:\Users\testbed\Documents\GENeSYS_MOD.data\Conversion Script"
set "OUTPUT_DIR=C:\Users\testbed\Documents\GENeSYS_MOD.data\Output\output_excel"
set "DEST_DIR=C:\Users\testbed\Documents\GENeSYS_MOD.gms\Inputdata"
set "PYTHON_SCRIPT=%SCRIPT_DIR%\temp_script.py"

REM Python-Skript in Datei schreiben
echo # -*- coding: utf-8 -*- > "%PYTHON_SCRIPT%"
echo settings_file = 'Set_filter_file.xlsx' >> "%PYTHON_SCRIPT%"
echo output_file_format = 'excel' >> "%PYTHON_SCRIPT%"
echo output_format = 'long' >> "%PYTHON_SCRIPT%"
echo processing_option = 'parameters_only' >> "%PYTHON_SCRIPT%"
echo scenario_option = 'Europe_EnVis_NECPEssentials' >> "%PYTHON_SCRIPT%"
echo debugging_output = False >> "%PYTHON_SCRIPT%"
echo from functions.function_import import master_function >> "%PYTHON_SCRIPT%"
echo scenarios = ["Europe_EnVis_Green","Europe_EnVis_Trinity","Europe_EnVis_REPowerEU++","Europe_EnVis_NECPEssentials"] >> "%PYTHON_SCRIPT%"
echo for s in scenarios: >> "%PYTHON_SCRIPT%"
echo     print("Currently performing operation for scenario: ", s) >> "%PYTHON_SCRIPT%"
echo     master_function(settings_file, output_file_format, output_format, processing_option, s, debugging_output) >> "%PYTHON_SCRIPT%"

REM In das Skriptverzeichnis wechseln
cd /d "%SCRIPT_DIR%"

REM Python-Skript ausführen
python "%PYTHON_SCRIPT%"

REM Warten, bis das Skript abgeschlossen ist
if %errorlevel% neq 0 (
    echo Fehler beim Ausführen des Python-Skripts!
    exit /b %errorlevel%
)

REM Dateien kopieren
xcopy "%OUTPUT_DIR%\RegularParameters_Europe_EnVis_NECPEssentials.xlsx" "%DEST_DIR%\" /Y
xcopy "%OUTPUT_DIR%\RegularParameters_Europe_EnVis_REPowerEU++.xlsx" "%DEST_DIR%\" /Y
xcopy "%OUTPUT_DIR%\RegularParameters_Europe_EnVis_Trinity.xlsx" "%DEST_DIR%\" /Y
xcopy "%OUTPUT_DIR%\RegularParameters_Europe_EnVis_Green.xlsx" "%DEST_DIR%\" /Y

REM Fertig
echo Vorgang abgeschlossen.
pause
exit /b 0
