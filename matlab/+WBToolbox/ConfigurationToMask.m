% Copyright (C) 2018 Istituto Italiano di Tecnologia (IIT). All rights reserved.
% This software may be modified and distributed under the terms of the
% GNU Lesser General Public License v2.1 or any later version.

function ConfigurationToMask(configBlock, WBTConfigObjectName)
%CONFIGURATIONTOMASK Summary of this function goes here
%   Detailed explanation goes here

% Assign names to labels
item_ConfigSource = 1;
item_ConfigObject = 2;
item_RobotName = 3;
item_UrdfFile = 4;
item_BaseLink = 5;
item_ControlledJoints = 6;
item_ControlBoardsNames = 7;
item_LocalName = 8;
item_GravityVector = 9;

% Get the mask of the Config Block
try
    mask = Simulink.Mask.get(configBlock);
catch
    error('[ConfigurationToMask] Impossible to gather Config Block: %s', configBlock);
end


% Remove apices if present
if (strcmp(WBTConfigObjectName(1),'''') && strcmp(WBTConfigObjectName(end),''''))
    WBTConfigObjectName = WBTConfigObjectName(2:end-1);
end

% Try to get the object from the workspace
try
    WBTConfigHandle = evalin('base', WBTConfigObjectName); % Get the handle
    WBTConfigObject = copy(WBTConfigHandle); % Shallow copy the handle
catch
    error('[ConfigurationToMask] Failed to get %s object from the workspace', WBTConfigObjectName);
end

try
    if (isa(WBTConfigObject,'WBToolbox.Configuration') && WBTConfigObject.ValidConfiguration)
        SetParamFromReadOnly(...
            configBlock,'RobotName',...
            strcat('''',WBTConfigObject.RobotName,''''),...
            mask.Parameters(item_RobotName));
        SetParamFromReadOnly(...
            configBlock,'UrdfFile',...
            strcat('''',WBTConfigObject.UrdfFile,''''),mask.Parameters(item_UrdfFile));
        SetParamFromReadOnly(...
            configBlock,'BaseLink',...
            strcat('''',WBTConfigObject.BaseLink,''''),mask.Parameters(item_BaseLink));
        SetParamFromReadOnly(...
            configBlock,'ControlledJoints',...
            WBTConfigObject.serializeCellArray1D(WBTConfigObject.ControlledJoints),mask.Parameters(item_ControlledJoints));
        SetParamFromReadOnly(...
            configBlock,'ControlBoardsNames',...
            WBTConfigObject.serializeCellArray1D(WBTConfigObject.ControlBoardsNames),mask.Parameters(item_ControlBoardsNames));
        SetParamFromReadOnly(...
            configBlock,'GravityVector',...
            WBTConfigObject.serializeVector1D(WBTConfigObject.GravityVector),mask.Parameters(item_GravityVector))
        SetParamFromReadOnly(...
            configBlock,'LocalName',...
            strcat('''',WBTConfigObject.LocalName,''''),mask.Parameters(item_LocalName));
    else
        error('[ConfigurationToMask] Failed to get the %s object', WBTConfigObjectName);
    end
catch
    SetParamFromReadOnly(...
        configBlock,'RobotName',...
        '''NonValid''',mask.Parameters(item_RobotName));
    SetParamFromReadOnly(...
        configBlock,'UrdfFile',...
        '''NonValid''',mask.Parameters(item_UrdfFile));
    SetParamFromReadOnly(...
        configBlock,'BaseLink',...
        '''NonValid''',mask.Parameters(item_UrdfFile));
    SetParamFromReadOnly(...
        configBlock,'ControlledJoints',...
        '''NonValid''',mask.Parameters(item_ControlledJoints));
    SetParamFromReadOnly(...
        configBlock,'ControlBoardsNames',...
        '''NonValid''',mask.Parameters(item_ControlBoardsNames));
    SetParamFromReadOnly(...
        configBlock,'LocalName',...
        '''NonValid''',mask.Parameters(item_LocalName));
    SetParamFromReadOnly(...
        configBlock,'GravityVector',...
        '''NonValid''',mask.Parameters(item_GravityVector));
end

end

function SetParamFromReadOnly(block, parameterName, parameterValue, maskParameter)
if ~strcmp(get_param(block,parameterName),parameterValue)
    maskParameter.ReadOnly = 'off';
    maskParameter.Enabled  = 'on';
    set_param(block,parameterName,parameterValue);
    maskParameter.ReadOnly = 'on';
end
end
