function removeMinGW()
%  Copyright 2015-2016 The MathWorks, Inc.

% Register the Message Catalog if not registered already
try
    
    m = message('mingw:mingw_msgs:setxFailed');
    m.getString();
    
catch
    
    thisDir = fileparts(mfilename('fullpath'));
    resourceDir = [thisDir filesep '..' filesep '..' filesep '..'  filesep '..'];
    [~] = registerrealtimecataloglocation(resourceDir);
    
end


% Remove the system environment variable
env_var = getEnvVarName();

try
    % Query the Windows registry for the environment variable
    sys_mingw_loc = winqueryreg('HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', env_var);
    
    if(~isempty(strcmp(sys_mingw_loc, '')))
        
        % Compiler installation directory
        compilerDir = sys_mingw_loc;
        % Initialize the environment variable location in registry
        env_var_loc = '"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"';
        % Initialize the removal flags 
        remove_flags = ' /F /V ';
        % Setup the command to execute in the Windows Shell
        cmd = ['REG delete ', env_var_loc , remove_flags, env_var ];
        [status, ~] = hwconnectinstaller.internal.systemExecute(cmd);
        if(status == 0)
            % Set the environment variable in local MATLAB session to an
            % empty value
            setenv('MW_MINGW64_LOC', '');
            
            if(exist(compilerDir, 'dir') == 7)
              [status, msg, msgid] = rmdir(compilerDir,'s');
              
              if(status ~= 1)
                  box_msg = [message('mingw:mingw_msgs:compilerRemovalFailed').getString(), ' ', msg ];
                  errordlg(box_msg, message('mingw:mingw_msgs:compilerRemovalFailedTitle').getString(), 'modal');
              end
            end
            return;
        else
            % Inform the user that the variable was not successfully
            % deleted
           box_msg = message('mingw:mingw_msgs:uninstallFailed').getString();
           errordlg(box_msg, message('mingw:mingw_msgs:uninstallTitle').getString(), 'modal');
            return;
        end
    end
    
catch ME
    % 'MATLAB:WINQUERYREG:queryerror' could also be used in future for displaying
    % additional message to the user.
        
             
     % Catch the exception if the user did not consent to grant the UAC 
     % elevation privileges.  
    if(strcmp(ME.identifier, 'hwconnectinstaller:setup:SystemExecuteServerFail'))
        errordlg(message('mingw:mingw_msgs:envarDeletionFailed').getString(),...
                 message('mingw:mingw_msgs:insufficientAccessPrivilegeTitle').getString(), 'modal');       
    end
end


end

function envVarName = getEnvVarName()

% This is a helper function which returns the name of the environment
% variable

%  Copyright 2015-2016 The MathWorks, Inc.

   envVarName = 'MW_MINGW64_LOC';
   
end