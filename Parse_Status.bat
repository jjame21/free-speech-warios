@echo off
:: This version handles spaces in folder paths correctly
powershell.exe -ExecutionPolicy Bypass -Command "& { & """%~dp0Parse_Status.ps1""" }"
pause