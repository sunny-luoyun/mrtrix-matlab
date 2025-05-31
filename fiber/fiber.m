classdef fiber < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        gaosmooth_CheckBox   matlab.ui.control.CheckBox
        useweight_CheckBox   matlab.ui.control.CheckBox
        smooth_EditField     matlab.ui.control.NumericEditField
        duibi_ButtonGroup    matlab.ui.container.ButtonGroup
        curvatureButton      matlab.ui.control.RadioButton
        fod_ampButton        matlab.ui.control.RadioButton
        invlengthButton      matlab.ui.control.RadioButton
        lengthButton         matlab.ui.control.RadioButton
        TDIButton            matlab.ui.control.RadioButton
        tck2niiCheckBox      matlab.ui.control.CheckBox
        decr_nunEditField    matlab.ui.control.EditField
        Label_11             matlab.ui.control.Label
        fibernumEditField    matlab.ui.control.EditField
        Label_10             matlab.ui.control.Label
        trytimeEditField     matlab.ui.control.NumericEditField
        Label_9              matlab.ui.control.Label
        FODEditField         matlab.ui.control.NumericEditField
        FODEditFieldLabel    matlab.ui.control.Label
        maxlength_EditField  matlab.ui.control.NumericEditField
        Label_8              matlab.ui.control.Label
        mixlength_EditField  matlab.ui.control.NumericEditField
        Label_7              matlab.ui.control.Label
        angle_EditField      matlab.ui.control.NumericEditField
        Label_6              matlab.ui.control.Label
        goin_EditField       matlab.ui.control.NumericEditField
        Label_5              matlab.ui.control.Label
        maskpath_EditField   matlab.ui.control.EditField
        Label_4              matlab.ui.control.Label
        addmask_Button       matlab.ui.control.Button
        roi_EditField        matlab.ui.control.EditField
        Label_3              matlab.ui.control.Label
        mode_ButtonGroup     matlab.ui.container.ButtonGroup
        maskButton           matlab.ui.control.RadioButton
        roiButton            matlab.ui.control.RadioButton
        brainButton          matlab.ui.control.RadioButton
        track_ButtonGroup    matlab.ui.container.ButtonGroup
        FACTButton           matlab.ui.control.RadioButton
        Tensor_ProbButton    matlab.ui.control.RadioButton
        Tensor_DetButton     matlab.ui.control.RadioButton
        SD_StreamButton      matlab.ui.control.RadioButton
        iFOD2Button          matlab.ui.control.RadioButton
        start_EditField      matlab.ui.control.EditField
        Label_2              matlab.ui.control.Label
        find_Button          matlab.ui.control.Button
        start_Button         matlab.ui.control.Button
        tckweight_CheckBox   matlab.ui.control.CheckBox
        sift_CheckBox        matlab.ui.control.CheckBox
        work_Button          matlab.ui.control.Button
        work_EditField       matlab.ui.control.EditField
        Label                matlab.ui.control.Label
        sub_TextArea         matlab.ui.control.TextArea
        fiberbuild_CheckBox  matlab.ui.control.CheckBox
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
            % 获取工作路径和文件夹名称
            workPath = app.work_EditField.Value; % 获取工作路径
            folderName = app.start_EditField.Value;    % 获取文件夹名称（起始文件夹）
            
            % 拼接完整路径
            fullPath = fullfile(workPath, folderName);
            
            % 检查路径是否存在
            if ~isfolder(fullPath)
                uialert(app.UIFigure, '指定的路径不存在，请检查输入路径是否正确。', '路径错误');
                return;
            end
            
            % 获取所有以 'sub' 开头的文件夹
            subFolders = dir(fullfile(fullPath, 'Sub*')); % 列出所有以 'sub' 开头的文件夹
            subFolderNames = {subFolders.name};          % 提取文件夹名称
        
            % 开始计时
            startTime = tic;
            
            % 遍历每个子文件夹
            for i = 1:length(subFolderNames)
                subFolder = subFolderNames{i};
                subFolderPath = fullfile(fullPath, subFolder); % 获取子文件夹的完整路径
                
                % 初始化当前处理路径
                currentPath = subFolderPath;
                startfloder = folderName;
                fodfolder = '';

                % 检查是否需要进行 纤维创建 处理
                if app.fiberbuild_CheckBox.Value
                    
                    option =  app.track_ButtonGroup.SelectedObject;
                    optiontest = option.Text;
                    mode = app.mode_ButtonGroup.SelectedObject;
                    modetest = mode.Text;
                    goin = app.goin_EditField.Value;
                    angle = app.angle_EditField.Value;
                    min = app.mixlength_EditField.Value;
                    max = app.maxlength_EditField.Value;
                    fod = app.FODEditField.Value;
                    trytime = app.trytimeEditField.Value;
                    fibernum = app.fibernumEditField.Value;
                    roi = app.roi_EditField.Value;
                    mask = app.maskpath_EditField.Value;

                    [currentPath,fodfolder] = fiberbuild(workPath,subFolder,currentPath,startfloder,optiontest,goin,angle,min,max,fod,trytime,fibernum,modetest,roi,mask); 
                    
                end

                % 检查是否需要进行 生成权重文件 处理
                if app.tckweight_CheckBox.Value

                    currentPath = weightc(workPath,subFolder,currentPath,startfloder,fodfolder);    
                
                end

                if app.sift_CheckBox.Value
                    decnum = app.decr_nunEditField.Value;
                    currentPath = sift(workPath,subFolder,currentPath,startfloder,fodfolder,decnum);
                end

                % 检查是否需要进行 格式转换 处理
                if app.tck2niiCheckBox.Value
                    method = app.duibi_ButtonGroup.SelectedObject;
                    methodtest = method.Text;
                    smooth = app.smooth_EditField.Value;
                    weight = app.useweight_CheckBox.Value;
                    gaosmooth = app.gaosmooth_CheckBox.Value;
                    currentPath = tck2nii(workPath,subFolder,currentPath,startfloder,fodfolder,methodtest,smooth,weight,gaosmooth);
                    
                end
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
        end

        % Value changed function: sift_CheckBox
        function sift_CheckBoxValueChanged(app, event)
            value = app.sift_CheckBox.Value;
            if value
                app.decr_nunEditField.Enable = "on";
                app.Label_11.Enable = "on";
            else
                app.decr_nunEditField.Enable = "off";
                app.Label_11.Enable = "off";
            end
        end

        % Value changed function: fiberbuild_CheckBox
        function fiberbuild_CheckBoxValueChanged(app, event)
            value = app.fiberbuild_CheckBox.Value;
            if value
                app.track_ButtonGroup.Enable = "on";
                app.mode_ButtonGroup.Enable = "on";
                app.goin_EditField.Enable = "on";
                app.Label_5.Enable = "on";
                app.angle_EditField.Enable = "on";
                app.Label_6.Enable = "on";
                app.mixlength_EditField.Enable = "on";
                app.Label_7.Enable = "on";
                app.maxlength_EditField.Enable = "on";
                app.Label_8.Enable = "on";
                app.FODEditField.Enable = "on";
                app.FODEditFieldLabel.Enable = "on";
                app.trytimeEditField.Enable = "on";
                app.Label_9.Enable = "on";
                app.fibernumEditField.Enable = "on";
                app.Label_10.Enable = "on";
            else
                app.track_ButtonGroup.Enable = "off";
                app.mode_ButtonGroup.Enable = "off";
                app.goin_EditField.Enable = "off";
                app.Label_5.Enable = "off";
                app.angle_EditField.Enable = "off";
                app.Label_6.Enable = "off";
                app.mixlength_EditField.Enable = "off";
                app.Label_7.Enable = "off";
                app.maxlength_EditField.Enable = "off";
                app.Label_8.Enable = "off";
                app.FODEditField.Enable = "off";
                app.FODEditFieldLabel.Enable = "off";
                app.trytimeEditField.Enable = "off";
                app.Label_9.Enable = "off";
                app.fibernumEditField.Enable = "off";
                app.Label_10.Enable = "off";
            end
        end

        % Value changed function: tckweight_CheckBox
        function tckweight_CheckBoxValueChanged(app, event)
            value = app.tckweight_CheckBox.Value;
            
        end

        % Button pushed function: find_Button
        function find_ButtonPushed(app, event)
            % 获取工作路径和文件夹名称
            workPath = app.work_EditField.Value; % 获取工作路径
            folderName = app.start_EditField.Value;    % 获取文件夹名称
        
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

        % Selection changed function: track_ButtonGroup
        function track_ButtonGroupSelectionChanged(app, event)
            selectedButton = app.track_ButtonGroup.SelectedObject;
        end

        % Selection changed function: mode_ButtonGroup
        function mode_ButtonGroupSelectionChanged(app, event)
            selectedButton = app.mode_ButtonGroup.SelectedObject;
            if strcmp(selectedButton.Text, '全脑追踪')
                app.roi_EditField.Enable = "off";
                app.addmask_Button.Enable = "off";
                app.maskpath_EditField.Enable = "off";
                app.Label_3.Enable = "off";
                app.Label_4.Enable = "off"; 

            elseif strcmp(selectedButton.Text, '基于种子点')
                app.roi_EditField.Enable = "on";
                app.Label_3.Enable = "on";
                app.addmask_Button.Enable = "off";
                app.maskpath_EditField.Enable = "off";
                app.Label_4.Enable = "off"; 

            elseif strcmp(selectedButton.Text, '基于mask')
                app.roi_EditField.Enable = "off";
                app.addmask_Button.Enable = "on";
                app.maskpath_EditField.Enable = "on";
                app.Label_3.Enable = "off";
                app.Label_4.Enable = "on"; 

            end
        end

        % Value changed function: roi_EditField
        function roi_EditFieldValueChanged(app, event)
            value = app.roi_EditField.Value;
            
        end

        % Value changed function: maskpath_EditField
        function maskpath_EditFieldValueChanged(app, event)
            value = app.maskpath_EditField.Value;
            
        end

        % Button pushed function: addmask_Button
        function addmask_ButtonPushed(app, event)
            
        end

        % Value changed function: goin_EditField
        function goin_EditFieldValueChanged(app, event)
            value = app.goin_EditField.Value;
            
        end

        % Value changed function: angle_EditField
        function angle_EditFieldValueChanged(app, event)
            value = app.angle_EditField.Value;
            
        end

        % Value changed function: mixlength_EditField
        function mixlength_EditFieldValueChanged(app, event)
            value = app.mixlength_EditField.Value;
            
        end

        % Value changed function: maxlength_EditField
        function maxlength_EditFieldValueChanged(app, event)
            value = app.maxlength_EditField.Value;
            
        end

        % Value changed function: FODEditField
        function FODEditFieldValueChanged(app, event)
            value = app.FODEditField.Value;
            
        end

        % Value changed function: trytimeEditField
        function trytimeEditFieldValueChanged(app, event)
            value = app.trytimeEditField.Value;
            
        end

        % Value changed function: fibernumEditField
        function fibernumEditFieldValueChanged(app, event)
            value = app.fibernumEditField.Value;
            
        end

        % Value changed function: decr_nunEditField
        function decr_nunEditFieldValueChanged(app, event)
            value = app.decr_nunEditField.Value;
            
        end

        % Value changed function: tck2niiCheckBox
        function tck2niiCheckBoxValueChanged(app, event)
            value = app.tck2niiCheckBox.Value;
            if value
                app.smooth_EditField.Enable = "on";
                app.useweight_CheckBox.Enable = "on";
                app.duibi_ButtonGroup.Enable = "on";
                app.gaosmooth_CheckBox.Enable = "on";
                
            else
                app.smooth_EditField.Enable = "off";
                app.useweight_CheckBox.Enable = "off";
                app.duibi_ButtonGroup.Enable = "off";
                app.gaosmooth_CheckBox.Enable = "off";
                
            end
        end

        % Value changed function: gaosmooth_CheckBox
        function gaosmooth_CheckBoxValueChanged(app, event)
            value = app.gaosmooth_CheckBox.Value;
            if value
                app.smooth_EditField.Enable = 'on';
                app.lengthButton.Enable = 'off';
                app.invlengthButton.Enable = 'off';
                app.fod_ampButton.Enable = "off";
                app.curvatureButton.Enable = "off";
                app.TDIButton.Value = true;
            else
                app.smooth_EditField.Enable = 'off';
                app.lengthButton.Enable = 'on';
                app.invlengthButton.Enable = 'on';
                app.fod_ampButton.Enable = "on";
                app.curvatureButton.Enable = "on";
            end
        
        end

        % Value changed function: smooth_EditField
        function smooth_EditFieldValueChanged(app, event)
            value = app.smooth_EditField.Value;
            
        end

        % Value changed function: useweight_CheckBox
        function useweight_CheckBoxValueChanged(app, event)
            value = app.useweight_CheckBox.Value;
            
        end

        % Selection changed function: duibi_ButtonGroup
        function duibi_ButtonGroupSelectionChanged(app, event)
            selectedButton = app.duibi_ButtonGroup.SelectedObject;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 561 486];
            app.UIFigure.Name = '纤维重建';

            % 设置窗口居中
            screenSize = get(0, 'ScreenSize');
            figureWidth = app.UIFigure.Position(3);
            figureHeight = app.UIFigure.Position(4);
            app.UIFigure.Position(1) = (screenSize(3) - figureWidth) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - figureHeight) / 2;

            % Create sub_TextArea
            app.sub_TextArea = uitextarea(app.UIFigure);
            app.sub_TextArea.Editable = 'off';
            app.sub_TextArea.Position = [133 326 256 65];

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [102 448 53 22];
            app.Label.Text = '工作路径';

            % Create work_EditField
            app.work_EditField = uieditfield(app.UIFigure, 'text');
            app.work_EditField.Editable = 'off';
            app.work_EditField.Position = [170 448 245 22];

            % Create work_Button
            app.work_Button = uibutton(app.UIFigure, 'push');
            app.work_Button.ButtonPushedFcn = createCallbackFcn(app, @work_ButtonPushed, true);
            app.work_Button.Position = [425 448 35 23];
            app.work_Button.Text = '...';

            % Create sift_CheckBox
            app.sift_CheckBox = uicheckbox(app.UIFigure);
            app.sift_CheckBox.ValueChangedFcn = createCallbackFcn(app, @sift_CheckBoxValueChanged, true);
            app.sift_CheckBox.Text = '缩减纤维数量SIFT';
            app.sift_CheckBox.Position = [177 110 119 22];

            % Create tckweight_CheckBox
            app.tckweight_CheckBox = uicheckbox(app.UIFigure);
            app.tckweight_CheckBox.ValueChangedFcn = createCallbackFcn(app, @tckweight_CheckBoxValueChanged, true);
            app.tckweight_CheckBox.Text = '生成纤维权重文件';
            app.tckweight_CheckBox.Position = [49 110 118 22];

            % Create start_Button
            app.start_Button = uibutton(app.UIFigure, 'push');
            app.start_Button.ButtonPushedFcn = createCallbackFcn(app, @start_ButtonPushed, true);
            app.start_Button.Position = [440 21 97 23];
            app.start_Button.Text = '开始处理';

            % Create find_Button
            app.find_Button = uibutton(app.UIFigure, 'push');
            app.find_Button.ButtonPushedFcn = createCallbackFcn(app, @find_ButtonPushed, true);
            app.find_Button.Position = [341 409 75 23];
            app.find_Button.Text = '检索';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [132 409 77 22];
            app.Label_2.Text = '被试文件夹名';

            % Create start_EditField
            app.start_EditField = uieditfield(app.UIFigure, 'text');
            app.start_EditField.Position = [224 409 100 22];

            % Create track_ButtonGroup
            app.track_ButtonGroup = uibuttongroup(app.UIFigure);
            app.track_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @track_ButtonGroupSelectionChanged, true);
            app.track_ButtonGroup.Title = '纤维追踪算法';
            app.track_ButtonGroup.Position = [42 178 123 136];
            app.track_ButtonGroup.Enable = "off";

            % Create iFOD2Button
            app.iFOD2Button = uiradiobutton(app.track_ButtonGroup);
            app.iFOD2Button.Text = 'iFOD2';
            app.iFOD2Button.Position = [11 90 56 22];
            app.iFOD2Button.Value = true;

            % Create SD_StreamButton
            app.SD_StreamButton = uiradiobutton(app.track_ButtonGroup);
            app.SD_StreamButton.Text = 'SD_Stream';
            app.SD_StreamButton.Position = [11 69 83 22];

            % Create Tensor_DetButton
            app.Tensor_DetButton = uiradiobutton(app.track_ButtonGroup);
            app.Tensor_DetButton.Text = 'Tensor_Det';
            app.Tensor_DetButton.Position = [11 46 82 22];

            % Create Tensor_ProbButton
            app.Tensor_ProbButton = uiradiobutton(app.track_ButtonGroup);
            app.Tensor_ProbButton.Text = 'Tensor_Prob';
            app.Tensor_ProbButton.Position = [11 25 89 22];

            % Create FACTButton
            app.FACTButton = uiradiobutton(app.track_ButtonGroup);
            app.FACTButton.Text = 'FACT';
            app.FACTButton.Position = [11 4 52 22];

            % Create mode_ButtonGroup
            app.mode_ButtonGroup = uibuttongroup(app.UIFigure);
            app.mode_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @mode_ButtonGroupSelectionChanged, true);
            app.mode_ButtonGroup.Title = '追踪模式';
            app.mode_ButtonGroup.Position = [175 224 123 90];
            app.mode_ButtonGroup.Enable = "off";

            % Create brainButton
            app.brainButton = uiradiobutton(app.mode_ButtonGroup);
            app.brainButton.Text = '全脑追踪';
            app.brainButton.Position = [11 44 70 22];
            app.brainButton.Value = true;

            % Create roiButton
            app.roiButton = uiradiobutton(app.mode_ButtonGroup);
            app.roiButton.Text = '基于种子点';
            app.roiButton.Position = [11 23 82 22];
            

            % Create maskButton
            app.maskButton = uiradiobutton(app.mode_ButtonGroup);
            app.maskButton.Text = '基于mask';
            app.maskButton.Position = [11 1 75 22];
            

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [312 289 92 22];
            app.Label_3.Text = '种子点坐标,半径';
            app.Label_3.Enable = "off";

            % Create roi_EditField
            app.roi_EditField = uieditfield(app.UIFigure, 'text');
            app.roi_EditField.ValueChangedFcn = createCallbackFcn(app, @roi_EditFieldValueChanged, true);
            app.roi_EditField.Position = [419 289 90 22];
            app.roi_EditField.Value = '0,0,0,0';
            app.roi_EditField.Enable = "off";

            % Create addmask_Button
            app.addmask_Button = uibutton(app.UIFigure, 'push');
            app.addmask_Button.ButtonPushedFcn = createCallbackFcn(app, @addmask_ButtonPushed, true);
            app.addmask_Button.Position = [503 258 36 23];
            app.addmask_Button.Text = '...';
            app.addmask_Button.Enable = "off";

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.Position = [314 258 58 22];
            app.Label_4.Text = 'mask文件';
            app.Label_4.Enable = "off"; 

            % Create maskpath_EditField
            app.maskpath_EditField = uieditfield(app.UIFigure, 'text');
            app.maskpath_EditField.ValueChangedFcn = createCallbackFcn(app, @maskpath_EditFieldValueChanged, true);
            app.maskpath_EditField.Editable = 'off';
            app.maskpath_EditField.Position = [377 258 112 22];
            app.maskpath_EditField.Enable = "off";

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.Position = [178 182 53 22];
            app.Label_5.Text = '步进长度';
            app.Label_5.Enable = "off";

            % Create goin_EditField
            app.goin_EditField = uieditfield(app.UIFigure, 'numeric');
            app.goin_EditField.ValueChangedFcn = createCallbackFcn(app, @goin_EditFieldValueChanged, true);
            app.goin_EditField.Position = [237 182 33 22];
            app.goin_EditField.Value = 0.5;
            app.goin_EditField.Enable = "off";

            % Create Label_6
            app.Label_6 = uilabel(app.UIFigure);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.Position = [277 182 53 22];
            app.Label_6.Text = '最大角度';
            app.Label_6.Enable = "off";

            % Create angle_EditField
            app.angle_EditField = uieditfield(app.UIFigure, 'numeric');
            app.angle_EditField.ValueChangedFcn = createCallbackFcn(app, @angle_EditFieldValueChanged, true);
            app.angle_EditField.Position = [338 182 24 22];
            app.angle_EditField.Value = 45;
            app.angle_EditField.Enable = "off";

            % Create Label_7
            app.Label_7 = uilabel(app.UIFigure);
            app.Label_7.HorizontalAlignment = 'right';
            app.Label_7.Position = [369 182 53 22];
            app.Label_7.Text = '最小长度';
            app.Label_7.Enable = "off";

            % Create mixlength_EditField
            app.mixlength_EditField = uieditfield(app.UIFigure, 'numeric');
            app.mixlength_EditField.ValueChangedFcn = createCallbackFcn(app, @mixlength_EditFieldValueChanged, true);
            app.mixlength_EditField.Position = [430 182 24 22];
            app.mixlength_EditField.Value = 2;
            app.mixlength_EditField.Enable = "off";

            % Create Label_8
            app.Label_8 = uilabel(app.UIFigure);
            app.Label_8.HorizontalAlignment = 'right';
            app.Label_8.Position = [461 182 53 22];
            app.Label_8.Text = '最大长度';
            app.Label_8.Enable = "off";

            % Create maxlength_EditField
            app.maxlength_EditField = uieditfield(app.UIFigure, 'numeric');
            app.maxlength_EditField.ValueChangedFcn = createCallbackFcn(app, @maxlength_EditFieldValueChanged, true);
            app.maxlength_EditField.Position = [520 182 32 22];
            app.maxlength_EditField.Value = 100;
            app.maxlength_EditField.Enable = "off";

            % Create FODEditFieldLabel
            app.FODEditFieldLabel = uilabel(app.UIFigure);
            app.FODEditFieldLabel.HorizontalAlignment = 'right';
            app.FODEditFieldLabel.Position = [45 147 77 22];
            app.FODEditFieldLabel.Text = '终止FOD振幅';
            app.FODEditFieldLabel.Enable = "off";

            % Create FODEditField
            app.FODEditField = uieditfield(app.UIFigure, 'numeric');
            app.FODEditField.ValueChangedFcn = createCallbackFcn(app, @FODEditFieldValueChanged, true);
            app.FODEditField.Position = [127 147 28 22];
            app.FODEditField.Value = 0.1;
            app.FODEditField.Enable = "off";

            % Create Label_9
            app.Label_9 = uilabel(app.UIFigure);
            app.Label_9.HorizontalAlignment = 'right';
            app.Label_9.Position = [165 147 89 22];
            app.Label_9.Text = '每个点最大试次';
            app.Label_9.Enable = "off";

            % Create trytimeEditField
            app.trytimeEditField = uieditfield(app.UIFigure, 'numeric');
            app.trytimeEditField.ValueChangedFcn = createCallbackFcn(app, @trytimeEditFieldValueChanged, true);
            app.trytimeEditField.Position = [260 147 44 22];
            app.trytimeEditField.Value = 1000;
            app.trytimeEditField.Enable = "off";

            % Create Label_10
            app.Label_10 = uilabel(app.UIFigure);
            app.Label_10.HorizontalAlignment = 'right';
            app.Label_10.Position = [305 147 65 22];
            app.Label_10.Text = '生成纤维数';
            app.Label_10.Enable = "off";

            % Create fibernumEditField
            app.fibernumEditField = uieditfield(app.UIFigure, 'text');
            app.fibernumEditField.ValueChangedFcn = createCallbackFcn(app, @fibernumEditFieldValueChanged, true);
            app.fibernumEditField.Position = [385 147 37 22];
            app.fibernumEditField.Value = '10m';
            app.fibernumEditField.Enable = "off";

            % Create Label_11
            app.Label_11 = uilabel(app.UIFigure);
            app.Label_11.HorizontalAlignment = 'right';
            app.Label_11.Position = [299 110 89 22];
            app.Label_11.Text = '缩减后纤维数量';
            app.Label_11.Enable = "off";

            % Create decr_nunEditField
            app.decr_nunEditField = uieditfield(app.UIFigure, 'text');
            app.decr_nunEditField.ValueChangedFcn = createCallbackFcn(app, @decr_nunEditFieldValueChanged, true);
            app.decr_nunEditField.Position = [403 110 29 22];
            app.decr_nunEditField.Value = '1m';
            app.decr_nunEditField.Enable = "off";

            % Create tck2niiCheckBox
            app.tck2niiCheckBox = uicheckbox(app.UIFigure);
            app.tck2niiCheckBox.ValueChangedFcn = createCallbackFcn(app, @tck2niiCheckBoxValueChanged, true);
            app.tck2niiCheckBox.Text = '将纤维文件转换为nii';
            app.tck2niiCheckBox.Position = [49 76 130 22];
            

            % Create duibi_ButtonGroup
            app.duibi_ButtonGroup = uibuttongroup(app.UIFigure);
            app.duibi_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @duibi_ButtonGroupSelectionChanged, true);
            app.duibi_ButtonGroup.Title = '对比度映射方法';
            app.duibi_ButtonGroup.Position = [43 14 372 53];
            app.duibi_ButtonGroup.Enable = "off";

            % Create TDIButton
            app.TDIButton = uiradiobutton(app.duibi_ButtonGroup);
            app.TDIButton.Text = 'tdi';
            app.TDIButton.Position = [11 7 40 22];
            app.TDIButton.Value = true;

            % Create lengthButton
            app.lengthButton = uiradiobutton(app.duibi_ButtonGroup);
            app.lengthButton.Text = 'length';
            app.lengthButton.Position = [58 7 55 22];

            % Create invlengthButton
            app.invlengthButton = uiradiobutton(app.duibi_ButtonGroup);
            app.invlengthButton.Text = 'invlength';
            app.invlengthButton.Position = [122 7 70 22];

            % Create fod_ampButton
            app.fod_ampButton = uiradiobutton(app.duibi_ButtonGroup);
            app.fod_ampButton.Text = 'fod_amp';
            app.fod_ampButton.Position = [197 7 69 22];

            % Create curvatureButton
            app.curvatureButton = uiradiobutton(app.duibi_ButtonGroup);
            app.curvatureButton.Text = 'curvature';
            app.curvatureButton.Position = [280 7 72 22];

            % Create smooth_EditField
            app.smooth_EditField = uieditfield(app.UIFigure, 'numeric');
            app.smooth_EditField.ValueChangedFcn = createCallbackFcn(app, @smooth_EditFieldValueChanged, true);
            app.smooth_EditField.Position = [270 76 21 22];
            app.smooth_EditField.Value = 6;
            app.smooth_EditField.Enable = "off";

            % Create useweight_CheckBox
            app.useweight_CheckBox = uicheckbox(app.UIFigure);
            app.useweight_CheckBox.ValueChangedFcn = createCallbackFcn(app, @useweight_CheckBoxValueChanged, true);
            app.useweight_CheckBox.Text = '使用纤维权重文件';
            app.useweight_CheckBox.Position = [306 76 118 22];
            app.useweight_CheckBox.Enable = "off";

            % Create fiberbuild_CheckBox
            app.fiberbuild_CheckBox = uicheckbox(app.UIFigure);
            app.fiberbuild_CheckBox.ValueChangedFcn = createCallbackFcn(app, @fiberbuild_CheckBoxValueChanged, true);
            app.fiberbuild_CheckBox.Text = '纤维重建';
            app.fiberbuild_CheckBox.Position = [49 325 118 22];

            % Create gaosmooth_CheckBox
            app.gaosmooth_CheckBox = uicheckbox(app.UIFigure);
            app.gaosmooth_CheckBox.ValueChangedFcn = createCallbackFcn(app, @gaosmooth_CheckBoxValueChanged, true);
            app.gaosmooth_CheckBox.Text = '高斯平滑';
            app.gaosmooth_CheckBox.Position = [190 76 80 22];
            app.gaosmooth_CheckBox.Enable = "off";
            

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = fiber

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