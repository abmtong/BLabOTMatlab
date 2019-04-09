function mexSetupMinGW()
% mexSetupMinGW sets a required Windows enviroment variable for MinGW-w64
%
%  This function configures MEX to use the MinGW-w64 C/C++ compiler from TDM-GCC
%  for 64-bit Windows by setting a required Windows system enviroment variable.

%  Copyright 2015-2016 The MathWorks, Inc.
%

% Register the Message Catalog if not registered already
try
    
    m = message('mingw:mingw_msgs:setxFailed');
    m.getString();
    
catch
    
    thisDir = fileparts(mfilename('fullpath'));
    resourceDir = [thisDir filesep '..' filesep '..' filesep '..'  filesep '..'];
    [~] = registerrealtimecataloglocation(resourceDir);
    
end

% ExecutionDir is the user's current directory
executionDir = pwd;
thisDir = fileparts(mfilename('fullpath'));

% InstallDir is the directory where all the SPKG files are extracted
installDir = [thisDir filesep '..' filesep '..' filesep '..'  filesep '..'];

%     pkgInfo = hwconnectinstaller.PackageInfo;
%     spPkg   = pkgInfo.getSpPkgInfo('mingw');
%     tpLoc   = '';
%     if(~isempty(spPkg))
%         tpLoc = pkgInfo.getTpPkgRootDir('GNU Binutils', spPkg);
%     end

folderName = getFolderName();

% Full path to the MinGW installation directory
mingw_install_dir = [installDir, filesep, folderName];


folderIsPresent = exist(mingw_install_dir, 'dir');

% Determine if the MinGW installation folder is present
if(folderIsPresent == 7)
    
    % Get the absolute path to MinGW installation directory
    cd(mingw_install_dir);
    mingw_install_dir = pwd;
    cd(executionDir);
    
    envVarName = getEnvVarName();
    cmd = ['setx  -m ', envVarName, ' ', mingw_install_dir];
    try
        [status, msg] = hwconnectinstaller.internal.systemExecute(cmd);
        % Display an error dialog box to the user if the environment
        % variable is not set.
        if(status ~= 0)
            h = errordlg([message('mingw:mingw_msgs:setxFailed').getString(), msg],...
                message('mingw:mingw_msgs:compilerSetupFailedTitle').getString(), 'modal');
            uiwait(h);
            return;
        end
        setenv(getEnvVarName(), mingw_install_dir);
        
        % Catch an exception if user does not grant access privileges
    catch ME
        if(strcmp(ME.identifier, 'hwconnectinstaller:setup:SystemExecuteServerFail'))
            
            h = errordlg(message('mingw:mingw_msgs:insufficientAccessPrivilege').getString(),...
                message('mingw:mingw_msgs:insufficientAccessPrivilegeTitle').getString(),'modal');
            uiwait(h);
        end
    end
    % Display an error dialog box to the user if the MinGW installation
    % folder is absent.
else
    h = errordlg(message('mingw:mingw_msgs:compilerNotFound').getString(),...
        message('mingw:mingw_msgs:compilerSetupFailedTitle').getString(),'modal');
    uiwait(h);
end
end

function folderName = getFolderName()
% This is a helper function which returns the name of the folder where
% the compiler is extracted.

%  Copyright 2015-2016 The MathWorks, Inc.

 folderName = 'MW_MinGW_4_9';
 
end

function envVarName = getEnvVarName()

% This is a helper function which returns the name of the environment
% variable

%  Copyright 2015-2016 The MathWorks, Inc.

   envVarName = 'MW_MINGW64_LOC';
   
end
