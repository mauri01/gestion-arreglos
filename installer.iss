[Setup]
AppName=Gestión de Arreglos
AppVersion=1.0.0
AppPublisher=Tu Nombre
DefaultDirName={autopf}\GestionArreglos
DefaultGroupName=Gestión de Arreglos
OutputDir=installer_output
OutputBaseFilename=gestion_arreglos_setup_v1.0.0
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Gestión de Arreglos"; Filename: "{app}\gestion_arreglos.exe"
Name: "{autodesktop}\Gestión de Arreglos"; Filename: "{app}\gestion_arreglos.exe"

[Run]
Filename: "{app}\gestion_arreglos.exe"; Description: "Ejecutar Gestión de Arreglos"; Flags: nowait postinstall skipifsilent