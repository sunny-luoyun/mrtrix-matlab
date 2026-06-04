classdef build_map < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        searchlength_EditField  matlab.ui.control.NumericEditField
        Label_4                 matlab.ui.control.Label
        brainnetnum_EditField   matlab.ui.control.EditField
        Label_3                 matlab.ui.control.Label
        getbrainnet_CheckBox    matlab.ui.control.CheckBox
        output_txt_CheckBox     matlab.ui.control.CheckBox
        tckweight_CheckBox      matlab.ui.control.CheckBox
        zero_diagonal_CheckBox  matlab.ui.control.CheckBox
        symmetric_CheckBox      matlab.ui.control.CheckBox
        assignzb_ButtonGroup    matlab.ui.container.ButtonGroup
        invnodevolButton        matlab.ui.control.RadioButton
        invlengthButton         matlab.ui.control.RadioButton
        lengthButton            matlab.ui.control.RadioButton
        assignrare_ButtonGroup  matlab.ui.container.ButtonGroup
        forwardButton           matlab.ui.control.RadioButton
        reverseButton           matlab.ui.control.RadioButton
        radialButton            matlab.ui.control.RadioButton
        voxelsButton            matlab.ui.control.RadioButton
        addmaskButton           matlab.ui.control.Button
        maskEditField           matlab.ui.control.EditField
        maskEditFieldLabel      matlab.ui.control.Label
        EditField               matlab.ui.control.EditField
        Label_2                 matlab.ui.control.Label
        find_Button             matlab.ui.control.Button
        start_Button            matlab.ui.control.Button
        work_Button             matlab.ui.control.Button
        work_EditField          matlab.ui.control.EditField
        Label                   matlab.ui.control.Label
        sub_TextArea            matlab.ui.control.TextArea
    end

    % Callbacks that handle component events
    methods (Access = private)
            
        % 控件开始状态
        function startupFcn(app)
            app.searchlength_EditField.Enable = "off";
            app.Label_4.Enable = "off";
            app.brainnetnum_EditField.Enable = "off";
            app.Label_3.Enable = "off";
        end

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
            app.start_Button.Enable = "off";
            % 获取工作路径和文件夹名称
            workPath = app.work_EditField.Value; % 获取工作路径
            folderName = app.EditField.Value; % 获取文件夹名称（起始文件夹）
            
            % 拼接完整路径
            fullPath = fullfile(workPath, folderName);
            
            % 检查路径是否存在
            if ~isfolder(fullPath)
                uialert(app.UIFigure, '指定的路径不存在，请检查输入路径是否正确。', '路径错误');
                app.start_Button.Enable = "on";
                return;
            end

            if app.getbrainnet_CheckBox.Value
                if strcmp(app.brainnetnum_EditField.Value, "")
                    uialert(app.UIFigure, '指定脑区不存在，请检查输入编号是否正确。', '脑区错误');
                    app.start_Button.Enable = "on";
                    return;
                else
                    
                end
            end
            
            
            % 获取所有以 'sub' 开头的文件夹
            subFolders = dir(fullfile(fullPath, 'Sub*')); % 列出所有以 'sub' 开头的文件夹
            subFolderNames = {subFolders.name}; % 提取文件夹名称
            
            % 开始计时
            startTime = tic;

            % 遍历每个子文件夹
            for i = 1:length(subFolderNames)
                subFolder = subFolderNames{i};
                subFolderPath = fullfile(fullPath, subFolder); % 获取子文件夹的完整路径
                
                % 初始化当前处理路径
                currentPath = subFolderPath;
                startname = folderName;

                maskpath = app.maskEditField.Value;
                sy = app.symmetric_CheckBox.Value;
                zero = app.zero_diagonal_CheckBox.Value;
                len = app.searchlength_EditField.Value;
                rare = app.assignrare_ButtonGroup.SelectedObject.Text;
                zb = app.assignzb_ButtonGroup.SelectedObject.Text;
                weigth = app.tckweight_CheckBox.Value;
                output = app.output_txt_CheckBox.Value;
                brainnet = app.brainnetnum_EditField.Value;

                buildmap(workPath, subFolder, currentPath,maskpath,sy,zero,len,rare,zb,weigth,output,brainnet)
            end

            % 结束计时
            elapsedTime = toc(startTime); % 获取处理总时间（秒）
            
            % 将处理时间转换为小时、分钟、秒
            hours = floor(elapsedTime / 3600);
            minutes = floor((elapsedTime - hours * 3600) / 60);
            seconds = mod(elapsedTime, 60);
            
            % 显示处理完成提示和处理时间
            uialert(app.UIFigure, ['处理完成' char(10) '共耗时：', num2str(hours), '小时 ', ...
                num2str(minutes), '分钟 ', num2str(seconds), '秒'], '完成提示');
            app.start_Button.Enable = "on";
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
            subFolders = dir(fullfile(fullPath, 'Sub*')); % 列出所有以 'Sub' 开头的文件夹
            subFolderNames = {subFolders.name};          % 提取文件夹名称
        
            % 将文件夹名称添加到 sub_TextArea
            app.sub_TextArea.Value = strjoin(subFolderNames, newline); % 将文件夹名称用换行符连接后显示
        end

        % Value changed function: getbrainnet_CheckBox
        function getbrainnet_CheckBoxValueChanged(app, event)
            value = app.getbrainnet_CheckBox.Value;
            if value
                app.brainnetnum_EditField.Enable = "on";
                app.Label_3.Enable = "on";
            else
                app.brainnetnum_EditField.Enable = "off";
                app.brainnetnum_EditField.Value = '';
                app.Label_3.Enable = "off";
            end
            
        end

        % Value changed function: output_txt_CheckBox
        function output_txt_CheckBoxValueChanged(app, event)
            value = app.output_txt_CheckBox.Value;
            
        end

        % Value changed function: tckweight_CheckBox
        function tckweight_CheckBoxValueChanged(app, event)
            value = app.tckweight_CheckBox.Value;
            
        end

        % Selection changed function: assignzb_ButtonGroup
        function assignzb_ButtonGroupSelectionChanged(app, event)
            selectedButton = app.assignzb_ButtonGroup.SelectedObject;
            
        end

        % Selection changed function: assignrare_ButtonGroup
        function assignrare_ButtonGroupSelectionChanged(app, event)
            selectedButton = app.assignrare_ButtonGroup.SelectedObject;
            if strcmp(selectedButton.Text, 'voxels')
                app.searchlength_EditField.Enable = "off";
                app.Label_4.Enable = "off";

            elseif strcmp(selectedButton.Text, 'radial')
                app.searchlength_EditField.Enable = "on";
                app.Label_4.Enable = "on";
            
            elseif strcmp(selectedButton.Text, 'reverse')
                app.searchlength_EditField.Enable = "on";
                app.Label_4.Enable = "on";

            elseif strcmp(selectedButton.Text, 'forward')
                app.searchlength_EditField.Enable = "on";
                app.Label_4.Enable = "on";
            
            end
            
        end

        % Button pushed function: addmask_Button
        function addmaskButtonPushed(app, event)
            [file, path] = uigetfile({'*.nii;*.nii.gz', 'NIfTI files'}, '选择工作文件');
            figure(app.UIFigure)
            if isequal(file, 0) % 如果用户取消选择
                figure(app.UIFigure)
                return;
            end
            app.maskEditField.Value = fullfile(path, file); % 显示完整的文件路径
        end

        % Value changed function: symmetric_CheckBox
        function symmetric_CheckBoxValueChanged(app, event)
            value = app.symmetric_CheckBox.Value;
            
        end

        % Value changed function: zero_diagonal_CheckBox
        function zero_diagonal_CheckBoxValueChanged(app, event)
            value = app.zero_diagonal_CheckBox.Value;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 522 376];
            app.UIFigure.Name = '纤维网络矩阵构建';

            screenSize = get(0, 'ScreenSize');
            figureWidth = app.UIFigure.Position(3);
            figureHeight = app.UIFigure.Position(4);
            app.UIFigure.Position(1) = (screenSize(3) - figureWidth) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - figureHeight) / 2;

            % Create sub_TextArea
            app.sub_TextArea = uitextarea(app.UIFigure);
            app.sub_TextArea.Editable = 'off';
            app.sub_TextArea.Position = [125 219 256 65];

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [94 341 53 22];
            app.Label.Text = '工作路径';

            % Create work_EditField
            app.work_EditField = uieditfield(app.UIFigure, 'text');
            app.work_EditField.Editable = 'off';
            app.work_EditField.Position = [162 341 245 22];

            % Create work_Button
            app.work_Button = uibutton(app.UIFigure, 'push');
            app.work_Button.ButtonPushedFcn = createCallbackFcn(app, @work_ButtonPushed, true);
            app.work_Button.Position = [417 341 35 23];
            app.work_Button.Text = '...';

            % Create start_Button
            app.start_Button = uibutton(app.UIFigure, 'push');
            app.start_Button.ButtonPushedFcn = createCallbackFcn(app, @start_ButtonPushed, true);
            app.start_Button.Position = [374 16 128 23];
            app.start_Button.Text = '开始构建';

            % Create find_Button
            app.find_Button = uibutton(app.UIFigure, 'push');
            app.find_Button.ButtonPushedFcn = createCallbackFcn(app, @find_ButtonPushed, true);
            app.find_Button.Position = [333 302 75 23];
            app.find_Button.Text = '检索';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [124 302 77 22];
            app.Label_2.Text = '被试文件夹名';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'text');
            app.EditField.Position = [216 302 100 22];

            % Create maskEditFieldLabel
            app.maskEditFieldLabel = uilabel(app.UIFigure);
            app.maskEditFieldLabel.HorizontalAlignment = 'right';
            app.maskEditFieldLabel.Position = [31 184 58 22];
            app.maskEditFieldLabel.Text = 'mask文件';

            % Create maskEditField
            app.maskEditField = uieditfield(app.UIFigure, 'text');
            app.maskEditField.Position = [95 184 82 22];

            % Create addmaskButton
            app.addmaskButton = uibutton(app.UIFigure, 'push');
            app.addmaskButton.ButtonPushedFcn = createCallbackFcn(app, @addmaskButtonPushed, true);
            app.addmaskButton.Position = [187 184 31 23];
            app.addmaskButton.Text = '...';

            % Create assignrare_ButtonGroup
            app.assignrare_ButtonGroup = uibuttongroup(app.UIFigure);
            app.assignrare_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @assignrare_ButtonGroupSelectionChanged, true);
            app.assignrare_ButtonGroup.Title = '纤维分配标准';
            app.assignrare_ButtonGroup.Position = [26 60 123 106];

            % Create voxelsButton
            app.voxelsButton = uiradiobutton(app.assignrare_ButtonGroup);
            app.voxelsButton.Text = 'voxels';
            app.voxelsButton.Position = [11 60 56 22];
            app.voxelsButton.Value = true;

            % Create radialButton
            app.radialButton = uiradiobutton(app.assignrare_ButtonGroup);
            app.radialButton.Text = 'radial';
            app.radialButton.Position = [11 41 51 22];

            % Create reverseButton
            app.reverseButton = uiradiobutton(app.assignrare_ButtonGroup);
            app.reverseButton.Text = 'reverse';
            app.reverseButton.Position = [11 22 61 22];

            % Create forwardButton
            app.forwardButton = uiradiobutton(app.assignrare_ButtonGroup);
            app.forwardButton.Text = 'forward';
            app.forwardButton.Position = [11 3 63 22];

            % Create assignzb_ButtonGroup
            app.assignzb_ButtonGroup = uibuttongroup(app.UIFigure);
            app.assignzb_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @assignzb_ButtonGroupSelectionChanged, true);
            app.assignzb_ButtonGroup.Title = '矩阵分配指标';
            app.assignzb_ButtonGroup.Position = [176 60 123 106];

            % Create lengthButton
            app.lengthButton = uiradiobutton(app.assignzb_ButtonGroup);
            app.lengthButton.Text = 'length';
            app.lengthButton.Position = [11 60 55 22];
            app.lengthButton.Value = true;

            % Create invlengthButton
            app.invlengthButton = uiradiobutton(app.assignzb_ButtonGroup);
            app.invlengthButton.Text = 'invlength';
            app.invlengthButton.Position = [11 38 70 22];

            % Create invnodevolButton
            app.invnodevolButton = uiradiobutton(app.assignzb_ButtonGroup);
            app.invnodevolButton.Text = 'invnodevol';
            app.invnodevolButton.Position = [11 16 80 22];

            % Create symmetric_CheckBox
            app.symmetric_CheckBox = uicheckbox(app.UIFigure);
            app.symmetric_CheckBox.ValueChangedFcn = createCallbackFcn(app, @symmetric_CheckBoxValueChanged, true);
            app.symmetric_CheckBox.Text = '矩阵对称';
            app.symmetric_CheckBox.Position = [230 184 70 22];

            % Create zero_diagonal_CheckBox
            app.zero_diagonal_CheckBox = uicheckbox(app.UIFigure);
            app.zero_diagonal_CheckBox.ValueChangedFcn = createCallbackFcn(app, @zero_diagonal_CheckBoxValueChanged, true);
            app.zero_diagonal_CheckBox.Text = '对角线为零';
            app.zero_diagonal_CheckBox.Position = [310 184 82 22];

            % Create tckweight_CheckBox
            app.tckweight_CheckBox = uicheckbox(app.UIFigure);
            app.tckweight_CheckBox.ValueChangedFcn = createCallbackFcn(app, @tckweight_CheckBoxValueChanged, true);
            app.tckweight_CheckBox.Text = '使用纤维权重文件';
            app.tckweight_CheckBox.Position = [315 144 118 22];

            % Create output_txt_CheckBox
            app.output_txt_CheckBox = uicheckbox(app.UIFigure);
            app.output_txt_CheckBox.ValueChangedFcn = createCallbackFcn(app, @output_txt_CheckBoxValueChanged, true);
            app.output_txt_CheckBox.Text = '将结果输出到txt文件';
            app.output_txt_CheckBox.Position = [315 119 132 22];

            % Create getbrainnet_CheckBox
            app.getbrainnet_CheckBox = uicheckbox(app.UIFigure);
            app.getbrainnet_CheckBox.ValueChangedFcn = createCallbackFcn(app, @getbrainnet_CheckBoxValueChanged, true);
            app.getbrainnet_CheckBox.Text = '提取指定脑区';
            app.getbrainnet_CheckBox.Position = [315 94 94 22];

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [310 67 53 22];
            app.Label_3.Text = '脑区编号';

            % Create brainnetnum_EditField
            app.brainnetnum_EditField = uieditfield(app.UIFigure, 'text');
            app.brainnetnum_EditField.Position = [370 67 132 22];

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.Position = [398 184 53 22];
            app.Label_4.Text = '检索长度';

            % Create searchlength_EditField
            app.searchlength_EditField = uieditfield(app.UIFigure, 'numeric');
            app.searchlength_EditField.Position = [455 184 17 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = build_map

            % Create UIFigure and components
            createComponents(app)

            % 控件初始化
            runStartupFcn(app, @startupFcn)

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