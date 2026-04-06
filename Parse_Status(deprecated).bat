@echo off
:: %* passes any arguments you give the .bat file (like -a) into the .ps1 script
powershell.exe -ExecutionPolicy Bypass -Command "& { & """%~dp0Parse_Status.ps1""" %* }"
pause