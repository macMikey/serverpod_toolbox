; Script generated by Inno Setup Compiler
[Setup]
AppName=Serverpod Toolbox
AppVersion=1.0.0.0
DefaultDirName={pf}\Serverpod Toolbox
DefaultGroupName=Serverpod Toolbox
OutputDir=.\Output
OutputBaseFilename=serverpod_toolbox_installer
Compression=lzma
SolidCompression=yes
SetupIconFile="C:\Users\Damian\Documents\AndroidStudioProjects\FlutterProjects\serverpod_toolbox\windows\runner\resources\app_icon.ico" 

[Files]
Source: "C:\Users\Damian\Documents\AndroidStudioProjects\FlutterProjects\serverpod_toolbox\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Serverpod Toolbox"; Filename: "{app}\serverpod_toolbox.exe"

[Run]
Filename: "{app}\serverpod_toolbox.exe"; Description: "Launch Serverpod Toolbox"; Flags: nowait postinstall
