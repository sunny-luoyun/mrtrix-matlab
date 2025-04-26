classdef dti < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        rk_CheckBox     matlab.ui.control.CheckBox
        ak_CheckBox     matlab.ui.control.CheckBox
        mk_CheckBox     matlab.ui.control.CheckBox
        Label_4         matlab.ui.control.Label
        Label_3         matlab.ui.control.Label
        dkt_CheckBox    matlab.ui.control.CheckBox
        EditField       matlab.ui.control.EditField
        Label_2         matlab.ui.control.Label
        find_Button     matlab.ui.control.Button
        start_Button    matlab.ui.control.Button
        cp_CheckBox     matlab.ui.control.CheckBox
        cs_CheckBox     matlab.ui.control.CheckBox
        cl_CheckBox     matlab.ui.control.CheckBox
        adc_CheckBox    matlab.ui.control.CheckBox
        rd_CheckBox     matlab.ui.control.CheckBox
        ad_CheckBox     matlab.ui.control.CheckBox
        fa_CheckBox     matlab.ui.control.CheckBox
        dt_CheckBox     matlab.ui.control.CheckBox
        work_Button     matlab.ui.control.Button
        work_EditField  matlab.ui.control.EditField
        Label           matlab.ui.control.Label
        sub_TextArea    matlab.ui.control.TextArea
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
            folderName = app.EditField.Value;    % 获取文件夹名称（起始文件夹）
            
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

                % 检查是否需要进行 dt 处理
                if app.dt_CheckBox.Value
                    dt(subFolder, workPath, startname); % 调用dt函数
                end

                % 检查是否需要进行 dkt 处理
                if app.dkt_CheckBox.Value
                    dkt(subFolder, workPath, startname); % 调用dkt函数
                end

                % 检查是否需要进行 fa 处理
                if app.fa_CheckBox.Value
                    fa(subFolder, workPath); % 调用fa函数
                end

                % 检查是否需要进行 ad 处理
                if app.ad_CheckBox.Value
                    ad(subFolder, workPath); % 调用ad函数
                end

                % 检查是否需要进行 rd 处理
                if app.rd_CheckBox.Value
                    rd(subFolder, workPath); % 调用rd函数
                end

                % 检查是否需要进行 adc 处理
                if app.adc_CheckBox.Value
                    adc(subFolder, workPath); % 调用adc函数
                end

                % 检查是否需要进行 cl 处理
                if app.cl_CheckBox.Value
                    cl(subFolder, workPath); % 调用cl函数
                end

                % 检查是否需要进行 cp 处理
                if app.cp_CheckBox.Value
                    cp(subFolder, workPath); % 调用cp函数
                end

                % 检查是否需要进行 cs 处理
                if app.cs_CheckBox.Value
                    cs(subFolder, workPath); % 调用cs函数
                end

                % 检查是否需要进行 mk 处理
                if app.mk_CheckBox.Value
                    mk(subFolder, workPath); % 调用mk函数
                end

                % 检查是否需要进行 ak 处理
                if app.ak_CheckBox.Value
                    ak(subFolder, workPath); % 调用ak函数
                end

                % 检查是否需要进行 rk 处理
                if app.rk_CheckBox.Value
                    rk(subFolder, workPath); % 调用rk函数
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

        % Value changed function: dt_CheckBox
        function dt_CheckBoxValueChanged(app, event)
            value = app.dt_CheckBox.Value;
            
        end

        % Value changed function: fa_CheckBox
        function fa_CheckBoxValueChanged(app, event)
            value = app.fa_CheckBox.Value;
            
        end

        % Value changed function: ad_CheckBox
        function ad_CheckBoxValueChanged(app, event)
            value = app.ad_CheckBox.Value;
            
        end

        % Value changed function: rd_CheckBox
        function rd_CheckBoxValueChanged(app, event)
            value = app.rd_CheckBox.Value;
            
        end

        % Value changed function: adc_CheckBox
        function adc_CheckBoxValueChanged(app, event)
            value = app.adc_CheckBox.Value;
            
        end

        % Value changed function: cl_CheckBox
        function cl_CheckBoxValueChanged(app, event)
            value = app.cl_CheckBox.Value;
            
        end

        % Value changed function: cp_CheckBox
        function cp_CheckBoxValueChanged(app, event)
            value = app.cp_CheckBox.Value;
            
        end

        % Value changed function: cs_CheckBox
        function cs_CheckBoxValueChanged(app, event)
            value = app.cs_CheckBox.Value;
            
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

        % Value changed function: dkt_CheckBox
        function dkt_CheckBoxValueChanged(app, event)
            value = app.dkt_CheckBox.Value;
            
        end

        % Value changed function: mk_CheckBox
        function mk_CheckBoxValueChanged(app, event)
            value = app.mk_CheckBox.Value;
            
        end

        % Value changed function: ak_CheckBox
        function ak_CheckBoxValueChanged(app, event)
            value = app.ak_CheckBox.Value;
            
        end

        % Value changed function: rk_CheckBox
        function rk_CheckBoxValueChanged(app, event)
            value = app.rk_CheckBox.Value;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 466 404];
            app.UIFigure.Name = '弥散指标计算';

            screenSize = get(0, 'ScreenSize');
            figureWidth = app.UIFigure.Position(3);
            figureHeight = app.UIFigure.Position(4);
            app.UIFigure.Position(1) = (screenSize(3) - figureWidth) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - figureHeight) / 2;

            % Create sub_TextArea
            app.sub_TextArea = uitextarea(app.UIFigure);
            app.sub_TextArea.Editable = 'off';
            app.sub_TextArea.Position = [55 244 364 65];

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [58 366 53 22];
            app.Label.Text = '工作路径';

            % Create work_EditField
            app.work_EditField = uieditfield(app.UIFigure, 'text');
            app.work_EditField.Editable = 'off';
            app.work_EditField.Position = [126 366 245 22];

            % Create work_Button
            app.work_Button = uibutton(app.UIFigure, 'push');
            app.work_Button.ButtonPushedFcn = createCallbackFcn(app, @work_ButtonPushed, true);
            app.work_Button.Position = [381 366 35 23];
            app.work_Button.Text = '...';

            % Create dt_CheckBox
            app.dt_CheckBox = uicheckbox(app.UIFigure);
            app.dt_CheckBox.ValueChangedFcn = createCallbackFcn(app, @dt_CheckBoxValueChanged, true);
            app.dt_CheckBox.Text = '生成弥散张量图';
            app.dt_CheckBox.Position = [30 211 106 22];
            app.dt_CheckBox.Value = true;

            % Create fa_CheckBox
            app.fa_CheckBox = uicheckbox(app.UIFigure);
            app.fa_CheckBox.ValueChangedFcn = createCallbackFcn(app, @fa_CheckBoxValueChanged, true);
            app.fa_CheckBox.Text = 'FA 计算弥散张量的分数各向异性';
            app.fa_CheckBox.Position = [30 161 196 22];

            % Create ad_CheckBox
            app.ad_CheckBox = uicheckbox(app.UIFigure);
            app.ad_CheckBox.ValueChangedFcn = createCallbackFcn(app, @ad_CheckBoxValueChanged, true);
            app.ad_CheckBox.Text = 'AD 计算弥散张量的轴向扩散率';
            app.ad_CheckBox.Position = [30 136 186 22];

            % Create rd_CheckBox
            app.rd_CheckBox = uicheckbox(app.UIFigure);
            app.rd_CheckBox.ValueChangedFcn = createCallbackFcn(app, @rd_CheckBoxValueChanged, true);
            app.rd_CheckBox.Text = 'RD 计算弥散张量的径向扩散率';
            app.rd_CheckBox.Position = [30 111 186 22];

            % Create adc_CheckBox
            app.adc_CheckBox = uicheckbox(app.UIFigure);
            app.adc_CheckBox.ValueChangedFcn = createCallbackFcn(app, @adc_CheckBoxValueChanged, true);
            app.adc_CheckBox.Text = 'ADC 计算弥散张量的平均表观扩散系数';
            app.adc_CheckBox.Position = [30 86 232 22];

            % Create cl_CheckBox
            app.cl_CheckBox = uicheckbox(app.UIFigure);
            app.cl_CheckBox.ValueChangedFcn = createCallbackFcn(app, @cl_CheckBoxValueChanged, true);
            app.cl_CheckBox.Text = 'cl 计算弥散张量的线性度量';
            app.cl_CheckBox.Position = [30 61 166 22];

            % Create cs_CheckBox
            app.cs_CheckBox = uicheckbox(app.UIFigure);
            app.cs_CheckBox.ValueChangedFcn = createCallbackFcn(app, @cs_CheckBoxValueChanged, true);
            app.cs_CheckBox.Text = 'cs 计算弥散张量的球形度量';
            app.cs_CheckBox.Position = [30 11 170 22];

            % Create cp_CheckBox
            app.cp_CheckBox = uicheckbox(app.UIFigure);
            app.cp_CheckBox.ValueChangedFcn = createCallbackFcn(app, @cp_CheckBoxValueChanged, true);
            app.cp_CheckBox.Text = 'cp 计算弥散张量的平面度度量';
            app.cp_CheckBox.Position = [30 36 183 22];

            % Create start_Button
            app.start_Button = uibutton(app.UIFigure, 'push');
            app.start_Button.ButtonPushedFcn = createCallbackFcn(app, @start_ButtonPushed, true);
            app.start_Button.Position = [304 11 128 23];
            app.start_Button.Text = '开始处理';

            % Create find_Button
            app.find_Button = uibutton(app.UIFigure, 'push');
            app.find_Button.ButtonPushedFcn = createCallbackFcn(app, @find_ButtonPushed, true);
            app.find_Button.Position = [297 327 75 23];
            app.find_Button.Text = '检索';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [88 327 77 22];
            app.Label_2.Text = '被试文件夹名';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'text');
            app.EditField.Position = [180 327 100 22];

            % Create dkt_CheckBox
            app.dkt_CheckBox = uicheckbox(app.UIFigure);
            app.dkt_CheckBox.ValueChangedFcn = createCallbackFcn(app, @dkt_CheckBoxValueChanged, true);
            app.dkt_CheckBox.Text = '生成弥散峰度图';
            app.dkt_CheckBox.Position = [290 211 106 22];

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.HorizontalAlignment = 'center';
            app.Label_3.FontWeight = 'bold';
            app.Label_3.FontAngle = 'italic';
            app.Label_3.Position = [84 186 77 22];
            app.Label_3.Text = '弥散张量指标';

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.HorizontalAlignment = 'center';
            app.Label_4.FontWeight = 'bold';
            app.Label_4.FontAngle = 'italic';
            app.Label_4.Position = [317 186 77 22];
            app.Label_4.Text = '弥散峰度指标';

            % Create mk_CheckBox
            app.mk_CheckBox = uicheckbox(app.UIFigure);
            app.mk_CheckBox.ValueChangedFcn = createCallbackFcn(app, @mk_CheckBoxValueChanged, true);
            app.mk_CheckBox.Text = 'MK 计算峰度张量的平均弯率';
            app.mk_CheckBox.Position = [280 161 176 22];

            % Create ak_CheckBox
            app.ak_CheckBox = uicheckbox(app.UIFigure);
            app.ak_CheckBox.ValueChangedFcn = createCallbackFcn(app, @ak_CheckBoxValueChanged, true);
            app.ak_CheckBox.Text = 'AK 计算峰度张量的轴向弯率';
            app.ak_CheckBox.Position = [280 136 173 22];

            % Create rk_CheckBox
            app.rk_CheckBox = uicheckbox(app.UIFigure);
            app.rk_CheckBox.ValueChangedFcn = createCallbackFcn(app, @rk_CheckBoxValueChanged, true);
            app.rk_CheckBox.Text = 'RK 计算弯率张量的径向弯率';
            app.rk_CheckBox.Position = [280 111 174 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dti

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