fc /l D:\cron\patchadams\servers.txt D:\cron\patchadams\serverplus18.txt  > nul
if errorlevel 1 goto patching
if errorlevel 0 goto patchcounter

:patchcounter
if not exist D:\cron\patchadams\count18.txt echo 0 >count18.txt
for /f %%x in (D:\cron\patchadams\count18.txt) do (
set /a var=%%x+1
)
>D:\cron\patchadams\count18.txt echo %var%

if %var% GTR 2 GOTO :skip_patching
if %var% LSS 2 GOTO :patching

:patching
ECHO %date% %time% "Patching servers from servers.txt..." >>D:\cron\patchadams\status.txt
D:\cron\patchadams\psexec.exe -accepteula -d -s @D:\cron\patchadams\servers.txt \\vm-acme-01\netlogon\pspatch.bat
GOTO :EOF

:skip_patching
ECHO %date% %time% "Skip patching..." >>D:\cron\patchadams\status.txt
GOTO :EOF