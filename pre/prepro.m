classdef prepro < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        EditField            matlab.ui.control.EditField
        Label_2              matlab.ui.control.Label
        find_Button          matlab.ui.control.Button
        start_Button         matlab.ui.control.Button
        mask_CheckBox        matlab.ui.control.CheckBox
        T1corg_CheckBox      matlab.ui.control.CheckBox
        dwi_to_MNI_CheckBox  matlab.ui.control.CheckBox
        T1_to_MNI_CheckBox   matlab.ui.control.CheckBox
        bias_CheckBox        matlab.ui.control.CheckBox
        headmove_CheckBox    matlab.ui.control.CheckBox
        Gibbs_CheckBox       matlab.ui.control.CheckBox
        denoise_CheckBox     matlab.ui.control.CheckBox
        work_Button          matlab.ui.control.Button
        work_EditField       matlab.ui.control.EditField
        Label                matlab.ui.control.Label
        sub_TextArea         matlab.ui.control.TextArea
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: work_Button
        function work_ButtonPushed(app, event)
            path = uigetdir('选择工作路径');
            figure(app.UIFigure)
            if isempty(path) % 如果用户取消选择
                figure(app.UIFigure)
                return;
            end
            app.work_EditField.Value = path;
        end

        % Button pushed function: start_Button
        function start_ButtonPushed(app, event)
            
        end

        % Value changed function: denoise_CheckBox
        function denoise_CheckBoxValueChanged(app, event)
            value = app.denoise_CheckBox.Value;
            
        end

        % Value changed function: Gibbs_CheckBox
        function Gibbs_CheckBoxValueChanged(app, event)
            value = app.Gibbs_CheckBox.Value;
            
        end

        % Value changed function: headmove_CheckBox
        function headmove_CheckBoxValueChanged(app, event)
            value = app.headmove_CheckBox.Value;
            
        end

        % Value changed function: bias_CheckBox
        function bias_CheckBoxValueChanged(app, event)
            value = app.bias_CheckBox.Value;
            
        end

        % Value changed function: T1_to_MNI_CheckBox
        function T1_to_MNI_CheckBoxValueChanged(app, event)
            value = app.T1_to_MNI_CheckBox.Value;
            
        end

        % Value changed function: dwi_to_MNI_CheckBox
        function dwi_to_MNI_CheckBoxValueChanged(app, event)
            value = app.dwi_to_MNI_CheckBox.Value;
            
        end

        % Button pushed function: find_Button
        function find_ButtonPushed(app, event)
            % 获取工作路径和文件夹名称
            workPath = app.work_EditField.Value; % 获取工作路径
            folderName = app.EditField.Value;    % 获取文件夹名称
        
            % 拼接完整路径
            fullPath = fullfile(workPath, folderName);
        
            % 检查路径是否存在
            if ~isfolder(fullPath)
                uialert(app.UIFigure, '指定的路径不存在，请检查输入路径是否正确。', '路径错误');
                return;
            end
        
            % 获取所有以 'sub' 开头的文件夹
            subFolders = dir(fullfile(fullPath, 'sub*')); % 列出所有以 'sub' 开头的文件夹
            subFolderNames = {subFolders.name};          % 提取文件夹名称
        
            % 将文件夹名称添加到 sub_TextArea
            app.sub_TextArea.Value = strjoin(subFolderNames, newline); % 将文件夹名称用换行符连接后显示
        end

        % Value changed function: mask_CheckBox
        function mask_CheckBoxValueChanged(app, event)
            value = app.mask_CheckBox.Value;
            
        end

        % Value changed function: T1corg_CheckBox
        function T1corg_CheckBoxValueChanged(app, event)
            value = app.T1corg_CheckBox.Value;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 377 308];
            app.UIFigure.Name = '预处理';

            screenSize = get(0, 'ScreenSize');
            figureWidth = app.UIFigure.Position(3);
            figureHeight = app.UIFigure.Position(4);
            app.UIFigure.Position(1) = (screenSize(3) - figureWidth) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - figureHeight) / 2;

            % Create sub_TextArea
            app.sub_TextArea = uitextarea(app.UIFigure);
            app.sub_TextArea.Editable = 'off';
            app.sub_TextArea.Position = [47 148 277 65];

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [10 270 53 22];
            app.Label.Text = '工作路径';

            % Create work_EditField
            app.work_EditField = uieditfield(app.UIFigure, 'text');
            app.work_EditField.Editable = 'off';
            app.work_EditField.Position = [78 270 245 22];

            % Create work_Button
            app.work_Button = uibutton(app.UIFigure, 'push');
            app.work_Button.ButtonPushedFcn = createCallbackFcn(app, @work_ButtonPushed, true);
            app.work_Button.Position = [333 270 35 23];
            app.work_Button.Text = '...';

            % Create denoise_CheckBox
            app.denoise_CheckBox = uicheckbox(app.UIFigure);
            app.denoise_CheckBox.ValueChangedFcn = createCallbackFcn(app, @denoise_CheckBoxValueChanged, true);
            app.denoise_CheckBox.Text = '降噪';
            app.denoise_CheckBox.Position = [39 109 46 22];

            % Create Gibbs_CheckBox
            app.Gibbs_CheckBox = uicheckbox(app.UIFigure);
            app.Gibbs_CheckBox.ValueChangedFcn = createCallbackFcn(app, @Gibbs_CheckBoxValueChanged, true);
            app.Gibbs_CheckBox.Text = '消除Gibbs Ring';
            app.Gibbs_CheckBox.Position = [108 109 106 22];

            % Create headmove_CheckBox
            app.headmove_CheckBox = uicheckbox(app.UIFigure);
            app.headmove_CheckBox.ValueChangedFcn = createCallbackFcn(app, @headmove_CheckBoxValueChanged, true);
            app.headmove_CheckBox.Text = '头动矫正，变形矫正';
            app.headmove_CheckBox.Position = [236 109 130 22];

            % Create bias_CheckBox
            app.bias_CheckBox = uicheckbox(app.UIFigure);
            app.bias_CheckBox.ValueChangedFcn = createCallbackFcn(app, @bias_CheckBoxValueChanged, true);
            app.bias_CheckBox.Text = 'bias场矫正';
            app.bias_CheckBox.Position = [40 64 80 22];

            % Create T1_to_MNI_CheckBox
            app.T1_to_MNI_CheckBox = uicheckbox(app.UIFigure);
            app.T1_to_MNI_CheckBox.ValueChangedFcn = createCallbackFcn(app, @T1_to_MNI_CheckBoxValueChanged, true);
            app.T1_to_MNI_CheckBox.Text = 'T1_to_MNI';
            app.T1_to_MNI_CheckBox.Position = [133 64 80 22];

            % Create dwi_to_MNI_CheckBox
            app.dwi_to_MNI_CheckBox = uicheckbox(app.UIFigure);
            app.dwi_to_MNI_CheckBox.ValueChangedFcn = createCallbackFcn(app, @dwi_to_MNI_CheckBoxValueChanged, true);
            app.dwi_to_MNI_CheckBox.Text = 'dwi_to_MNI';
            app.dwi_to_MNI_CheckBox.Position = [237 64 86 22];

            % Create T1corg_CheckBox
            app.T1corg_CheckBox = uicheckbox(app.UIFigure);
            app.T1corg_CheckBox.ValueChangedFcn = createCallbackFcn(app, @T1corg_CheckBoxValueChanged, true);
            app.T1corg_CheckBox.Text = 'T1分割';
            app.T1corg_CheckBox.Position = [143 20 60 22];

            % Create mask_CheckBox
            app.mask_CheckBox = uicheckbox(app.UIFigure);
            app.mask_CheckBox.ValueChangedFcn = createCallbackFcn(app, @mask_CheckBoxValueChanged, true);
            app.mask_CheckBox.Text = '提取mask';
            app.mask_CheckBox.Position = [40 20 75 22];

            % Create start_Button
            app.start_Button = uibutton(app.UIFigure, 'push');
            app.start_Button.ButtonPushedFcn = createCallbackFcn(app, @start_ButtonPushed, true);
            app.start_Button.Position = [225 20 128 23];
            app.start_Button.Text = '开始处理';

            % Create find_Button
            app.find_Button = uibutton(app.UIFigure, 'push');
            app.find_Button.ButtonPushedFcn = createCallbackFcn(app, @find_ButtonPushed, true);
            app.find_Button.Position = [249 231 75 23];
            app.find_Button.Text = '检索';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [40 231 77 22];
            app.Label_2.Text = '处理文件夹';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'text');
            app.EditField.Position = [132 231 100 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = prepro

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end