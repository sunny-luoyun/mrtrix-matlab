classdef fod < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        resp_CheckBox             matlab.ui.control.CheckBox
        fod_ButtonGroup           matlab.ui.container.ButtonGroup
        msmt_Button               matlab.ui.control.RadioButton
        smt_Button                matlab.ui.control.RadioButton
        next_fiber_num_EditField  matlab.ui.control.NumericEditField
        Label_11                  matlab.ui.control.Label
        fiber_num_EditField       matlab.ui.control.NumericEditField
        Label_10                  matlab.ui.control.Label
        intrate_change_EditField  matlab.ui.control.NumericEditField
        Label_9                   matlab.ui.control.Label
        intrate_num_EditField     matlab.ui.control.NumericEditField
        Label_8                   matlab.ui.control.Label
        fsr_EditField             matlab.ui.control.NumericEditField
        Label_7                   matlab.ui.control.Label
        FArange_EditField         matlab.ui.control.NumericEditField
        FAEditField_2Label        matlab.ui.control.Label
        wmvoxel_ButtonGroup       matlab.ui.container.ButtonGroup
        wmvoxel_faButton          matlab.ui.control.RadioButton
        wmvoxel_taxButton         matlab.ui.control.RadioButton
        wmvoxel_tournierButton    matlab.ui.control.RadioButton
        voxel_EditField           matlab.ui.control.NumericEditField
        Label_6                   matlab.ui.control.Label
        maxFA_EditField           matlab.ui.control.NumericEditField
        FAEditFieldLabel          matlab.ui.control.Label
        csfvoxel_EditField        matlab.ui.control.NumericEditField
        Label_5                   matlab.ui.control.Label
        gmvoxel_EditField         matlab.ui.control.NumericEditField
        Label_4                   matlab.ui.control.Label
        wmvoxel_EditField         matlab.ui.control.NumericEditField
        Label_3                   matlab.ui.control.Label
        wm_fa_EditField           matlab.ui.control.NumericEditField
        faEditFieldLabel          matlab.ui.control.Label
        maskedit_EditField        matlab.ui.control.NumericEditField
        maskEditFieldLabel        matlab.ui.control.Label
        resp_ButtonGroup          matlab.ui.container.ButtonGroup
        resp_tournier_Button      matlab.ui.control.RadioButton
        resp_tax_Button           matlab.ui.control.RadioButton
        resp_msmt_5tt_Button      matlab.ui.control.RadioButton
        resp_fa_Button            matlab.ui.control.RadioButton
        resp_dhollander_Button    matlab.ui.control.RadioButton
        start_EditField           matlab.ui.control.EditField
        Label_2                   matlab.ui.control.Label
        find_Button               matlab.ui.control.Button
        start_Button              matlab.ui.control.Button
        f2m_CheckBox              matlab.ui.control.CheckBox
        norm_CheckBox             matlab.ui.control.CheckBox
        fod_CheckBox              matlab.ui.control.CheckBox
        work_Button               matlab.ui.control.Button
        work_EditField            matlab.ui.control.EditField
        Label                     matlab.ui.control.Label
        sub_TextArea              matlab.ui.control.TextArea
    end

    % Callbacks that handle component events
    methods (Access = private)

        % 控件开始状态
        function startupFcn(app)
            
            % 根据复选框的初始状态设置按钮组的 Enable 状态
            app.resp_ButtonGroup.Enable = 'off';
            app.maskedit_EditField.Enable = "off";
            app.wm_fa_EditField.Enable = "off";
            app.wmvoxel_EditField.Enable = 'off';
            app.gmvoxel_EditField.Enable = 'off';
            app.csfvoxel_EditField.Enable = 'off';
            app.maxFA_EditField.Enable = 'off';
            app.voxel_EditField.Enable = 'off';
            app.wmvoxel_ButtonGroup.Enable = 'off';
            app.FArange_EditField.Enable = 'off';
            app.fsr_EditField.Enable = 'off';
            app.intrate_change_EditField.Enable = 'off';
            app.intrate_num_EditField.Enable = 'off';
            app.fiber_num_EditField.Enable = 'off';
            app.next_fiber_num_EditField.Enable = 'off';
            app.fod_ButtonGroup.Enable = "off";

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
                startname = folderName;

                % 检查是否需要进行响应函数估计处理
                if app.resp_CheckBox.Value
                    if strcmp(app.resp_ButtonGroup.SelectedObject.Text, 'dhollander') 
                        
                        maskedit = app.maskedit_EditField.Value;
                        wm_fa = app.wm_fa_EditField.Value;
                        wmvoxel = app.wmvoxel_EditField.Value;
                        gmvoxel = app.gmvoxel_EditField.Value;
                        csfvoxel = app.csfvoxel_EditField.Value;

                        currentPath = dhollander(workPath, subFolder, currentPath,maskedit,wm_fa,wmvoxel,gmvoxel,csfvoxel); % 调用dhollander

                    elseif strcmp(app.resp_ButtonGroup.SelectedObject.Text, 'fa')
                        maskedit = app.maskedit_EditField.Value;
                        maxfa = app.maxFA_EditField.Value;
                        
                        currentPath = fa(workPath, subFolder, currentPath,maskedit,maxfa); % 调用fa

                    elseif strcmp(app.resp_ButtonGroup.SelectedObject.Text, 'msmt_5tt')
                        if strcmp(app.wmvoxel_ButtonGroup.SelectedObject.Text, 'tournier')
                            wm_fa = app.wm_fa_EditField.Value;
                            voxel = app.voxel_EditField.Value;

                            currentPath = msmt_5tt_tournier(workPath, subFolder, currentPath,wm_fa, voxel); % 调用msmt_5tt_tournier

                        elseif strcmp(app.wmvoxel_ButtonGroup.SelectedObject.Text, 'tax')
                            wm_fa = app.wm_fa_EditField.Value;
                            voxel = app.voxel_EditField.Value;

                            currentPath = msmt_5tt_tax(workPath, subFolder, currentPath,wm_fa, voxel); % 调用msmt_5tt_tax

                        elseif strcmp(app.wmvoxel_ButtonGroup.SelectedObject.Text, 'fa')
                            wm_fa = app.wm_fa_EditField.Value;
                            voxel = app.voxel_EditField.Value;
                            farange = app.FArange_EditField.Value;

                            currentPath = msmt_5tt_fa(workPath, subFolder, currentPath,wm_fa, voxel,farange); % 调用msmt_5tt_fa

                        end
                    elseif strcmp(app.resp_ButtonGroup.SelectedObject.Text, 'tax')
                        peak_ratio = app.fsr_EditField.Value;
                        max_iters = app.intrate_num_EditField.Value;
                        convergence = app.intrate_change_EditField.Value;

                        currentPath = tax(workPath, subFolder, currentPath,peak_ratio, max_iters,convergence); % 调用tax

                    elseif strcmp(app.resp_ButtonGroup.SelectedObject.Text, 'tournier')
                        max_iters = app.intrate_num_EditField.Value;
                        number = app.fiber_num_EditField.Value;
                        iter_voxel = app.next_fiber_num_EditField.Value;
                        
                        currentPath = tournier(workPath, subFolder, currentPath, number,iter_voxel,max_iters); % 调用tournier

                    end
                end
                
                % 检查是否需要进行纤维方向计算
                if app.fod_CheckBox.Value
                    if strcmp(app.fod_ButtonGroup.SelectedObject.Text, '单组织')
                        currentPath = csd(currentPath);
                    else 
                        strcmp(app.fod_ButtonGroup.SelectedObject.Text, '多组织')

                        currentPath = msmt(currentPath);
                    end
                end

                % 检测是否需要标准化
                if app.norm_CheckBox.Value
                    currentPath = normal(workPath, currentPath, subFolder);
                end

                % 检测是否需要配准
                if app.f2m_CheckBox.Value
                    fodtoMNI(workPath,subFolder,currentPath);
                end

            end
            
            % 结束计时
            elapsedTime = toc(startTime); % 获取处理总时间（秒）
            
            % 将处理时间转换为小时、分钟、秒
            hours = floor(elapsedTime / 3600);
            minutes = floor((elapsedTime - hours * 3600) / 60);
            seconds = mod(elapsedTime, 60);
            
            % 显示处理完成提示和处理时间
            uialert(app.UIFigure, ['处理完成' newline '共耗时：', num2str(hours), '小时 ', ...
                num2str(minutes), '分钟 ', num2str(seconds), '秒'], '完成提示');
        end

        % Value changed function: fod_CheckBox
        function fod_CheckBoxValueChanged(app, event)
            value = app.fod_CheckBox.Value;
            if value
                app.fod_ButtonGroup.Enable = 'on';
            else
                app.fod_ButtonGroup.Enable = 'off';
            end
            
        end

        % Value changed function: norm_CheckBox
        function norm_CheckBoxValueChanged(app, event)
            value = app.norm_CheckBox.Value;
            
        end

        % Value changed function: f2m_CheckBox
        function f2m_CheckBoxValueChanged(app, event)
            value = app.f2m_CheckBox.Value;
            
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

        % Value changed function: resp_CheckBox
        function resp_CheckBoxValueChanged(app, event)
            value = app.resp_CheckBox.Value;
            if value
                app.resp_ButtonGroup.Enable = 'on';
                app.maskedit_EditField.Enable = "on";
                app.wm_fa_EditField.Enable = "on";
                app.wmvoxel_EditField.Enable = 'on';
                app.gmvoxel_EditField.Enable = 'on';
                app.csfvoxel_EditField.Enable = 'on';
                app.maxFA_EditField.Enable = 'off';
                app.voxel_EditField.Enable = 'off';
                app.wmvoxel_ButtonGroup.Enable = 'off';
                app.FArange_EditField.Enable = 'off';
                app.fsr_EditField.Enable = 'off';
                app.intrate_change_EditField.Enable = 'off';
                app.intrate_num_EditField.Enable = 'off';
                app.fiber_num_EditField.Enable = 'off';
                app.next_fiber_num_EditField.Enable = 'off';
                
            else
                app.resp_ButtonGroup.Enable = 'off';
                app.maskedit_EditField.Enable = "off";
                app.wm_fa_EditField.Enable = "off";
                app.wmvoxel_EditField.Enable = 'off';
                app.gmvoxel_EditField.Enable = 'off';
                app.csfvoxel_EditField.Enable = 'off';
                app.maxFA_EditField.Enable = 'off';
                app.voxel_EditField.Enable = 'off';
                app.wmvoxel_ButtonGroup.Enable = 'off';
                app.FArange_EditField.Enable = 'off';
                app.fsr_EditField.Enable = 'off';
                app.intrate_change_EditField.Enable = 'off';
                app.intrate_num_EditField.Enable = 'off';
                app.fiber_num_EditField.Enable = 'off';
                app.next_fiber_num_EditField.Enable = 'off';
            end
            
        end

        % Selection changed function: resp_ButtonGroup
        function resp_ButtonGroupSelectionChanged(app, event)
            selectedButton = app.resp_ButtonGroup.SelectedObject;
            if strcmp(selectedButton.Text, 'dhollander')
                app.maskedit_EditField.Enable = 'on';
                app.wm_fa_EditField.Enable = "on";
                app.wmvoxel_EditField.Enable = 'on';
                app.gmvoxel_EditField.Enable = 'on';
                app.csfvoxel_EditField.Enable = 'on';
                app.maxFA_EditField.Enable = 'off';
                app.voxel_EditField.Enable = 'off';
                app.wmvoxel_ButtonGroup.Enable = 'off';
                app.FArange_EditField.Enable = 'off';
                app.fsr_EditField.Enable = 'off';
                app.intrate_change_EditField.Enable = 'off';
                app.intrate_num_EditField.Enable = 'off';
                app.fiber_num_EditField.Enable = 'off';
                app.next_fiber_num_EditField.Enable = 'off';
                
            elseif strcmp(selectedButton.Text, 'fa')
                app.maskedit_EditField.Enable = 'on';
                app.wm_fa_EditField.Enable = "off";
                app.wmvoxel_EditField.Enable = 'off';
                app.gmvoxel_EditField.Enable = 'off';
                app.csfvoxel_EditField.Enable = 'off';
                app.maxFA_EditField.Enable = 'on';
                app.voxel_EditField.Enable = 'off';
                app.wmvoxel_ButtonGroup.Enable = 'off';
                app.FArange_EditField.Enable = 'off';
                app.fsr_EditField.Enable = 'off';
                app.intrate_change_EditField.Enable = 'off';
                app.intrate_num_EditField.Enable = 'off';
                app.fiber_num_EditField.Enable = 'off';
                app.next_fiber_num_EditField.Enable = 'off';

            elseif strcmp(selectedButton.Text, 'msmt_5tt')
                app.maskedit_EditField.Enable = 'off';
                app.wm_fa_EditField.Enable = "on";
                app.wmvoxel_EditField.Enable = 'off';
                app.gmvoxel_EditField.Enable = 'off';
                app.csfvoxel_EditField.Enable = 'off';
                app.maxFA_EditField.Enable = 'off';
                app.voxel_EditField.Enable = 'on';
                app.wmvoxel_ButtonGroup.Enable = 'on';
                app.FArange_EditField.Enable = 'off';
                app.fsr_EditField.Enable = 'off';
                app.intrate_change_EditField.Enable = 'off';
                app.intrate_num_EditField.Enable = 'off';
                app.fiber_num_EditField.Enable = 'off';
                app.next_fiber_num_EditField.Enable = 'off';
            
            elseif strcmp(selectedButton.Text, 'tax')
                app.maskedit_EditField.Enable = 'off';
                app.wm_fa_EditField.Enable = "off";
                app.wmvoxel_EditField.Enable = 'off';
                app.gmvoxel_EditField.Enable = 'off';
                app.csfvoxel_EditField.Enable = 'off';
                app.maxFA_EditField.Enable = 'off';
                app.voxel_EditField.Enable = 'off';
                app.wmvoxel_ButtonGroup.Enable = 'off';
                app.FArange_EditField.Enable = 'off';
                app.fsr_EditField.Enable = 'on';
                app.intrate_change_EditField.Enable = 'on';
                app.intrate_num_EditField.Enable = 'on';
                app.fiber_num_EditField.Enable = 'off';
                app.next_fiber_num_EditField.Enable = 'off';

            elseif strcmp(selectedButton.Text, 'tournier')
                app.maskedit_EditField.Enable = 'off';
                app.wm_fa_EditField.Enable = "off";
                app.wmvoxel_EditField.Enable = 'off';
                app.gmvoxel_EditField.Enable = 'off';
                app.csfvoxel_EditField.Enable = 'off';
                app.maxFA_EditField.Enable = 'off';
                app.voxel_EditField.Enable = 'off';
                app.wmvoxel_ButtonGroup.Enable = 'off';
                app.FArange_EditField.Enable = 'off';
                app.fsr_EditField.Enable = 'off';
                app.intrate_change_EditField.Enable = 'off';
                app.intrate_num_EditField.Enable = 'on';
                app.fiber_num_EditField.Enable = 'on';
                app.next_fiber_num_EditField.Enable = 'on';
            end
            
        end

        % Value changed function: maskedit_EditField
        function maskedit_EditFieldValueChanged(app, event)
            value = app.maskedit_EditField.Value;
            
        end

        % Value changed function: wm_fa_EditField
        function wm_fa_EditFieldValueChanged(app, event)
            value = app.wm_fa_EditField.Value;
            
        end

        % Value changed function: wmvoxel_EditField
        function wmvoxel_EditFieldValueChanged(app, event)
            value = app.wmvoxel_EditField.Value;
            
        end

        % Value changed function: gmvoxel_EditField
        function gmvoxel_EditFieldValueChanged(app, event)
            value = app.gmvoxel_EditField.Value;
            
        end

        % Value changed function: csfvoxel_EditField
        function csfvoxel_EditFieldValueChanged(app, event)
            value = app.csfvoxel_EditField.Value;
            
        end

        % Value changed function: maxFA_EditField
        function maxFA_EditFieldValueChanged(app, event)
            value = app.maxFA_EditField.Value;
            
        end

        % Value changed function: voxel_EditField
        function voxel_EditFieldValueChanged(app, event)
            value = app.voxel_EditField.Value;
            
        end

        % Selection changed function: wmvoxel_ButtonGroup
        function wmvoxel_ButtonGroupSelectionChanged(app, event)
            selectedButton = app.wmvoxel_ButtonGroup.SelectedObject;
            if strcmp(selectedButton.Text, 'tournier')
                app.FArange_EditField.Enable = 'off';
            elseif strcmp(selectedButton.Text, 'tax')
                app.FArange_EditField.Enable = 'off';
            elseif strcmp(selectedButton.Text, 'fa');
                app.FArange_EditField.Enable = 'on';
            end
            
        end

        % Value changed function: FArange_EditField
        function FArange_EditFieldValueChanged(app, event)
            value = app.FArange_EditField.Value;
            
        end

        % Value changed function: fsr_EditField
        function fsr_EditFieldValueChanged(app, event)
            value = app.fsr_EditField.Value;
            
        end

        % Value changed function: intrate_num_EditField
        function intrate_num_EditFieldValueChanged(app, event)
            value = app.intrate_num_EditField.Value;
            
        end

        % Value changed function: intrate_change_EditField
        function intrate_change_EditFieldValueChanged(app, event)
            value = app.intrate_change_EditField.Value;
            
        end

        % Value changed function: fiber_num_EditField
        function fiber_num_EditFieldValueChanged(app, event)
            value = app.fiber_num_EditField.Value;
            
        end

        % Value changed function: next_fiber_num_EditField
        function next_fiber_num_EditFieldValueChanged(app, event)
            value = app.next_fiber_num_EditField.Value;
            
        end

        % Selection changed function: fod_ButtonGroup
        function fod_ButtonGroupSelectionChanged(app, event)
            selectedButton = app.fod_ButtonGroup.SelectedObject;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 573 372];
            app.UIFigure.Name = '反卷积函数估计';

            screenSize = get(0, 'ScreenSize');
            figureWidth = app.UIFigure.Position(3);
            figureHeight = app.UIFigure.Position(4);
            app.UIFigure.Position(1) = (screenSize(3) - figureWidth) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - figureHeight) / 2;

            % Create sub_TextArea
            app.sub_TextArea = uitextarea(app.UIFigure);
            app.sub_TextArea.Editable = 'off';
            app.sub_TextArea.Position = [34 217 304 65];

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [34 334 53 22];
            app.Label.Text = '工作路径';

            % Create work_EditField
            app.work_EditField = uieditfield(app.UIFigure, 'text');
            app.work_EditField.Editable = 'off';
            app.work_EditField.Position = [102 334 355 22];

            % Create work_Button
            app.work_Button = uibutton(app.UIFigure, 'push');
            app.work_Button.ButtonPushedFcn = createCallbackFcn(app, @work_ButtonPushed, true);
            app.work_Button.Position = [474 334 35 23];
            app.work_Button.Text = '...';

            % Create fod_CheckBox
            app.fod_CheckBox = uicheckbox(app.UIFigure);
            app.fod_CheckBox.ValueChangedFcn = createCallbackFcn(app, @fod_CheckBoxValueChanged, true);
            app.fod_CheckBox.Text = '纤维方向计算';
            app.fod_CheckBox.Position = [402 270 94 22];

            % Create norm_CheckBox
            app.norm_CheckBox = uicheckbox(app.UIFigure);
            app.norm_CheckBox.ValueChangedFcn = createCallbackFcn(app, @norm_CheckBoxValueChanged, true);
            app.norm_CheckBox.Text = '强度标准化';
            app.norm_CheckBox.Position = [402 245 82 22];

            % Create f2m_CheckBox
            app.f2m_CheckBox = uicheckbox(app.UIFigure);
            app.f2m_CheckBox.ValueChangedFcn = createCallbackFcn(app, @f2m_CheckBoxValueChanged, true);
            app.f2m_CheckBox.Text = 'fod_to_MNI';
            app.f2m_CheckBox.Position = [402 220 84 22];

            % Create start_Button
            app.start_Button = uibutton(app.UIFigure, 'push');
            app.start_Button.ButtonPushedFcn = createCallbackFcn(app, @start_ButtonPushed, true);
            app.start_Button.Position = [503 13 67 23];
            app.start_Button.Text = '开始处理';

            % Create find_Button
            app.find_Button = uibutton(app.UIFigure, 'push');
            app.find_Button.ButtonPushedFcn = createCallbackFcn(app, @find_ButtonPushed, true);
            app.find_Button.Position = [262 293 75 23];
            app.find_Button.Text = '检索';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [40 293 77 22];
            app.Label_2.Text = '被试文件夹名';

            % Create start_EditField
            app.start_EditField = uieditfield(app.UIFigure, 'text');
            app.start_EditField.Position = [132 293 100 22];

            % Create resp_ButtonGroup
            app.resp_ButtonGroup = uibuttongroup(app.UIFigure);
            app.resp_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @resp_ButtonGroupSelectionChanged, true);
            app.resp_ButtonGroup.Title = '响应函数计算算法';
            app.resp_ButtonGroup.Position = [22 71 121 134];

            % Create resp_dhollander_Button
            app.resp_dhollander_Button = uiradiobutton(app.resp_ButtonGroup);
            app.resp_dhollander_Button.Text = 'dhollander';
            app.resp_dhollander_Button.Position = [11 88 79 22];
            app.resp_dhollander_Button.Value = true;

            % Create resp_fa_Button
            app.resp_fa_Button = uiradiobutton(app.resp_ButtonGroup);
            app.resp_fa_Button.Text = 'fa';
            app.resp_fa_Button.Position = [11 67 32 22];

            % Create resp_msmt_5tt_Button
            app.resp_msmt_5tt_Button = uiradiobutton(app.resp_ButtonGroup);
            app.resp_msmt_5tt_Button.Text = 'msmt_5tt';
            app.resp_msmt_5tt_Button.Position = [11 45 72 22];

            % Create resp_tax_Button
            app.resp_tax_Button = uiradiobutton(app.resp_ButtonGroup);
            app.resp_tax_Button.Text = 'tax';
            app.resp_tax_Button.Position = [11 24 38 22];

            % Create resp_tournier_Button
            app.resp_tournier_Button = uiradiobutton(app.resp_ButtonGroup);
            app.resp_tournier_Button.Text = 'tournier';
            app.resp_tournier_Button.Position = [11 2 63 22];

            % Create maskEditFieldLabel
            app.maskEditFieldLabel = uilabel(app.UIFigure);
            app.maskEditFieldLabel.HorizontalAlignment = 'right';
            app.maskEditFieldLabel.Position = [157 183 82 22];
            app.maskEditFieldLabel.Text = 'mask腐蚀次数';

            % Create maskedit_EditField
            app.maskedit_EditField = uieditfield(app.UIFigure, 'numeric');
            app.maskedit_EditField.ValueChangedFcn = createCallbackFcn(app, @maskedit_EditFieldValueChanged, true);
            app.maskedit_EditField.Position = [243 183 16 22];
            app.maskedit_EditField.Value = 2;

            % Create faEditFieldLabel
            app.faEditFieldLabel = uilabel(app.UIFigure);
            app.faEditFieldLabel.HorizontalAlignment = 'right';
            app.faEditFieldLabel.Position = [266 183 99 22];
            app.faEditFieldLabel.Text = '区分灰白质fa阈值';

            % Create wm_fa_EditField
            app.wm_fa_EditField = uieditfield(app.UIFigure, 'numeric');
            app.wm_fa_EditField.ValueChangedFcn = createCallbackFcn(app, @wm_fa_EditFieldValueChanged, true);
            app.wm_fa_EditField.Position = [369 183 27 22];
            app.wm_fa_EditField.Value = 0.2;

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [403 183 125 22];
            app.Label_3.Text = '单纤维白质体素数量%';

            % Create wmvoxel_EditField
            app.wmvoxel_EditField = uieditfield(app.UIFigure, 'numeric');
            app.wmvoxel_EditField.ValueChangedFcn = createCallbackFcn(app, @wmvoxel_EditFieldValueChanged, true);
            app.wmvoxel_EditField.Position = [531 183 28 22];
            app.wmvoxel_EditField.Value = 0.5;

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.Position = [157 154 125 22];
            app.Label_4.Text = '选择的灰质体素数量%';

            % Create gmvoxel_EditField
            app.gmvoxel_EditField = uieditfield(app.UIFigure, 'numeric');
            app.gmvoxel_EditField.ValueChangedFcn = createCallbackFcn(app, @gmvoxel_EditFieldValueChanged, true);
            app.gmvoxel_EditField.Position = [285 154 32 22];
            app.gmvoxel_EditField.Value = 2;

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.Position = [324 154 137 22];
            app.Label_5.Text = '选择的脑脊液体素数量%';

            % Create csfvoxel_EditField
            app.csfvoxel_EditField = uieditfield(app.UIFigure, 'numeric');
            app.csfvoxel_EditField.ValueChangedFcn = createCallbackFcn(app, @csfvoxel_EditFieldValueChanged, true);
            app.csfvoxel_EditField.Position = [464 154 23 22];
            app.csfvoxel_EditField.Value = 10;

            % Create FAEditFieldLabel
            app.FAEditFieldLabel = uilabel(app.UIFigure);
            app.FAEditFieldLabel.HorizontalAlignment = 'right';
            app.FAEditFieldLabel.Position = [157 125 103 22];
            app.FAEditFieldLabel.Text = '使用最高FA的数量';

            % Create maxFA_EditField
            app.maxFA_EditField = uieditfield(app.UIFigure, 'numeric');
            app.maxFA_EditField.ValueChangedFcn = createCallbackFcn(app, @maxFA_EditFieldValueChanged, true);
            app.maxFA_EditField.Position = [264 125 42 22];
            app.maxFA_EditField.Value = 1000;

            % Create Label_6
            app.Label_6 = uilabel(app.UIFigure);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.Position = [313 125 185 22];
            app.Label_6.Text = '组织体素选择的部分体积分数阈值';

            % Create voxel_EditField
            app.voxel_EditField = uieditfield(app.UIFigure, 'numeric');
            app.voxel_EditField.ValueChangedFcn = createCallbackFcn(app, @voxel_EditFieldValueChanged, true);
            app.voxel_EditField.Position = [513 125 46 22];
            app.voxel_EditField.Value = 0.95;

            % Create wmvoxel_ButtonGroup
            app.wmvoxel_ButtonGroup = uibuttongroup(app.UIFigure);
            app.wmvoxel_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @wmvoxel_ButtonGroupSelectionChanged, true);
            app.wmvoxel_ButtonGroup.Title = '白质单纤维体素选择算法';
            app.wmvoxel_ButtonGroup.Position = [155 69 213 51];

            % Create wmvoxel_tournierButton
            app.wmvoxel_tournierButton = uiradiobutton(app.wmvoxel_ButtonGroup);
            app.wmvoxel_tournierButton.Text = 'tournier';
            app.wmvoxel_tournierButton.Position = [11 5 63 22];
            app.wmvoxel_tournierButton.Value = true;

            % Create wmvoxel_taxButton
            app.wmvoxel_taxButton = uiradiobutton(app.wmvoxel_ButtonGroup);
            app.wmvoxel_taxButton.Text = 'tax';
            app.wmvoxel_taxButton.Position = [86 5 38 22];

            % Create wmvoxel_faButton
            app.wmvoxel_faButton = uiradiobutton(app.wmvoxel_ButtonGroup);
            app.wmvoxel_faButton.Text = 'fa';
            app.wmvoxel_faButton.Position = [147 5 32 22];

            % Create FAEditField_2Label
            app.FAEditField_2Label = uilabel(app.UIFigure);
            app.FAEditField_2Label.HorizontalAlignment = 'right';
            app.FAEditField_2Label.Position = [372 96 48 22];
            app.FAEditField_2Label.Text = ' FA 阈值';

            % Create FArange_EditField
            app.FArange_EditField = uieditfield(app.UIFigure, 'numeric');
            app.FArange_EditField.ValueChangedFcn = createCallbackFcn(app, @FArange_EditFieldValueChanged, true);
            app.FArange_EditField.Position = [427 96 31 22];
            app.FArange_EditField.Value = 0.2;

            % Create Label_7
            app.Label_7 = uilabel(app.UIFigure);
            app.Label_7.HorizontalAlignment = 'right';
            app.Label_7.Position = [374 71 149 22];
            app.Label_7.Text = '第二峰与第一峰幅度比阈值';

            % Create fsr_EditField
            app.fsr_EditField = uieditfield(app.UIFigure, 'numeric');
            app.fsr_EditField.ValueChangedFcn = createCallbackFcn(app, @fsr_EditFieldValueChanged, true);
            app.fsr_EditField.Position = [530 71 30 22];
            app.fsr_EditField.Value = 0.2;

            % Create Label_8
            app.Label_8 = uilabel(app.UIFigure);
            app.Label_8.HorizontalAlignment = 'right';
            app.Label_8.Position = [26 42 77 22];
            app.Label_8.Text = '最大迭代次数';

            % Create intrate_num_EditField
            app.intrate_num_EditField = uieditfield(app.UIFigure, 'numeric');
            app.intrate_num_EditField.ValueChangedFcn = createCallbackFcn(app, @intrate_num_EditFieldValueChanged, true);
            app.intrate_num_EditField.Position = [106 42 36 22];
            app.intrate_num_EditField.Value = 100;

            % Create Label_9
            app.Label_9 = uilabel(app.UIFigure);
            app.Label_9.HorizontalAlignment = 'right';
            app.Label_9.Position = [149 42 113 22];
            app.Label_9.Text = '继续迭代所需变化%';

            % Create intrate_change_EditField
            app.intrate_change_EditField = uieditfield(app.UIFigure, 'numeric');
            app.intrate_change_EditField.ValueChangedFcn = createCallbackFcn(app, @intrate_change_EditFieldValueChanged, true);
            app.intrate_change_EditField.Position = [268 42 26 22];
            app.intrate_change_EditField.Value = 1;

            % Create Label_10
            app.Label_10 = uilabel(app.UIFigure);
            app.Label_10.HorizontalAlignment = 'right';
            app.Label_10.Position = [26 13 77 22];
            app.Label_10.Text = '纤维体素数量';

            % Create fiber_num_EditField
            app.fiber_num_EditField = uieditfield(app.UIFigure, 'numeric');
            app.fiber_num_EditField.ValueChangedFcn = createCallbackFcn(app, @fiber_num_EditFieldValueChanged, true);
            app.fiber_num_EditField.Position = [110 13 43 22];
            app.fiber_num_EditField.Value = 1000;

            % Create Label_11
            app.Label_11 = uilabel(app.UIFigure);
            app.Label_11.HorizontalAlignment = 'right';
            app.Label_11.Position = [160 13 125 22];
            app.Label_11.Text = '下次迭代选择纤维数量';

            % Create next_fiber_num_EditField
            app.next_fiber_num_EditField = uieditfield(app.UIFigure, 'numeric');
            app.next_fiber_num_EditField.ValueChangedFcn = createCallbackFcn(app, @next_fiber_num_EditFieldValueChanged, true);
            app.next_fiber_num_EditField.Position = [292 13 45 22];
            app.next_fiber_num_EditField.Value = 10000;

            % Create fod_ButtonGroup
            app.fod_ButtonGroup = uibuttongroup(app.UIFigure);
            app.fod_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @fod_ButtonGroupSelectionChanged, true);
            app.fod_ButtonGroup.Title = '纤维分布方向算法';
            app.fod_ButtonGroup.Position = [348 13 145 51];

            % Create smt_Button
            app.smt_Button = uiradiobutton(app.fod_ButtonGroup);
            app.smt_Button.Text = '单组织';
            app.smt_Button.Position = [11 5 58 22];
            app.smt_Button.Value = true;

            % Create msmt_Button
            app.msmt_Button = uiradiobutton(app.fod_ButtonGroup);
            app.msmt_Button.Text = '多组织';
            app.msmt_Button.Position = [81 4 58 22];

            % Create resp_CheckBox
            app.resp_CheckBox = uicheckbox(app.UIFigure);
            app.resp_CheckBox.ValueChangedFcn = createCallbackFcn(app, @resp_CheckBoxValueChanged, true);
            app.resp_CheckBox.Text = '响应函数估计';
            app.resp_CheckBox.Position = [402 295 94 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = fod

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