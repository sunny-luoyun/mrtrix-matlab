classdef fba_fixel < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        work_EditField          matlab.ui.control.EditField
        work_Button             matlab.ui.control.Button

        fmls_EditField          matlab.ui.control.NumericEditField
        cutoff_EditField        matlab.ui.control.NumericEditField

        btn_fixel_mask          matlab.ui.control.Button
        btn_fd_fc               matlab.ui.control.Button

        tck_algo_DropDown       matlab.ui.control.DropDown
        tck_angle_EditField     matlab.ui.control.NumericEditField
        tck_maxlen_EditField    matlab.ui.control.NumericEditField
        tck_minlen_EditField    matlab.ui.control.NumericEditField
        tck_power_EditField     matlab.ui.control.NumericEditField
        tck_select_EditField    matlab.ui.control.NumericEditField
        tck_cutoff_EditField    matlab.ui.control.NumericEditField
        tck_sift_EditField      matlab.ui.control.NumericEditField

        btn_tck                 matlab.ui.control.Button
        btn_smooth              matlab.ui.control.Button

        chk_fd                  matlab.ui.control.CheckBox
        chk_logfc               matlab.ui.control.CheckBox
        chk_fdc                 matlab.ui.control.CheckBox

        progress_Label              matlab.ui.control.Label
        fixel_mask_import_Button    matlab.ui.control.Button
        fd_fc_import_Button         matlab.ui.control.Button
        tck_import_Button           matlab.ui.control.Button
        smooth_import_Button        matlab.ui.control.Button
    end

    properties (Access = private)
        workPath char
    end

    methods (Access = private)

        function work_ButtonPushed(app, event)
            path = uigetdir('选择工作路径');
            figure(app.UIFigure)
            if isempty(path)
                return
            end
            app.work_EditField.Value = path;
            app.workPath = path;
        end

        function subList = getSubList(app)
            subDir = fullfile(app.workPath, 'fba', 'subjects');
            d = dir(fullfile(subDir, 'Sub*'));
            if isempty(d)
                d = dir(fullfile(subDir, 'sub*'));
            end
            names = {};
            for i = 1:length(d)
                names{end+1} = d(i).name;
            end
            subList = names;
        end

        function fixel_mask_import_ButtonPushed(app, event)
            [file, path] = uigetfile('*.mat', '选择参数文件');
            if isequal(file, 0), return; end
            data = load_params(fullfile(path, file));
            p = data.params;
            app.fmls_EditField.Value = p.fmls;
            app.tck_cutoff_EditField.Value = p.tck_cutoff;
        end

        function fd_fc_import_ButtonPushed(app, event)
            [file, path] = uigetfile('*.mat', '选择参数文件');
            if isequal(file, 0), return; end
            data = load_params(fullfile(path, file));
            p = data.params;
            app.fmls_EditField.Value = p.fmls;
        end

        function tck_import_ButtonPushed(app, event)
            [file, path] = uigetfile('*.mat', '选择参数文件');
            if isequal(file, 0), return; end
            data = load_params(fullfile(path, file));
            p = data.params;
            app.tck_algo_DropDown.Value = p.algo;
            app.tck_angle_EditField.Value = p.angle;
            app.tck_maxlen_EditField.Value = p.maxlen;
            app.tck_minlen_EditField.Value = p.minlen;
            app.tck_power_EditField.Value = p.power;
            app.tck_select_EditField.Value = p.select;
            app.tck_cutoff_EditField.Value = p.cutoff;
            app.tck_sift_EditField.Value = p.sift;
        end

        function smooth_import_ButtonPushed(app, event)
            [file, path] = uigetfile('*.mat', '选择参数文件');
            if isequal(file, 0), return; end
            data = load_params(fullfile(path, file));
            p = data.params;
            app.chk_fd.Value = p.fd;
            app.chk_logfc.Value = p.logfc;
            app.chk_fdc.Value = p.fdc;
        end

        function btn_fixel_maskPushed(app, event)
            app.btn_fixel_mask.Enable = 'off';
            app.progress_Label.Text = '生成 fixel mask...';
            drawnow;
            startTime = tic;
            params = struct();
            params.fmls = app.fmls_EditField.Value;
            params.tck_cutoff = app.tck_cutoff_EditField.Value;
            save_params('fba', 'fba_fixel_mask', app.workPath, params);
            try
                step10_fixel_mask(app.workPath, app.fmls_EditField.Value);
                app.progress_Label.Text = 'fixel mask 生成完成';

                elapsedTime = toc(startTime);
                hours = floor(elapsedTime / 3600);
                minutes = floor((elapsedTime - hours * 3600) / 60);
                seconds = mod(elapsedTime, 60);
                uialert(app.UIFigure, sprintf('fixel mask 生成完成！\n共耗时：%d小时 %d分钟 %.0f秒', hours, minutes, seconds), '完成提示');
            catch ME
                uialert(app.UIFigure, ['fixel mask 出错: ' ME.message], '错误');
            end
            app.btn_fixel_mask.Enable = 'on';
        end

        function btn_fd_fcPushed(app, event)
            app.btn_fd_fc.Enable = 'off';
            app.progress_Label.Text = '计算 FD/FC/FDC...';
            drawnow;
            startTime = tic;
            params = struct();
            params.fmls = app.fmls_EditField.Value;
            save_params('fba', 'fba_fixel_fdfc', app.workPath, params);
            subList = getSubList(app);
            try
                step11_warp_fod(app.workPath, subList);
                app.progress_Label.Text = 'warp FOD 完成，计算 FD...';
                drawnow;
                step12_fd(app.workPath, subList, app.fmls_EditField.Value);
                app.progress_Label.Text = 'FD 完成，重定向 fixel...';
                drawnow;
                step13_reorient(app.workPath, subList);
                app.progress_Label.Text = '重定向完成，建立对应...';
                drawnow;
                step14_corresp(app.workPath, subList);
                app.progress_Label.Text = '对应完成，计算 FC...';
                drawnow;
                step15_fc(app.workPath, subList);
                app.progress_Label.Text = 'FC 完成，计算 log(FC) 和 FDC...';
                drawnow;
                step16_log_fdc(app.workPath, subList);
                app.progress_Label.Text = 'FD/FC/FDC 计算完成';

                elapsedTime = toc(startTime);
                hours = floor(elapsedTime / 3600);
                minutes = floor((elapsedTime - hours * 3600) / 60);
                seconds = mod(elapsedTime, 60);
                uialert(app.UIFigure, sprintf('FD/FC/FDC 指标计算完成！\n共耗时：%d小时 %d分钟 %.0f秒', hours, minutes, seconds), '完成提示');
            catch ME
                uialert(app.UIFigure, ['指标计算出错: ' ME.message], '错误');
            end
            app.btn_fd_fc.Enable = 'on';
        end

        function btn_tckPushed(app, event)
            app.btn_tck.Enable = 'off';
            app.progress_Label.Text = '模板全脑追踪...';
            drawnow;
            startTime = tic;
            params = struct();
            params.algo = app.tck_algo_DropDown.Value;
            params.angle = app.tck_angle_EditField.Value;
            params.maxlen = app.tck_maxlen_EditField.Value;
            params.minlen = app.tck_minlen_EditField.Value;
            params.power = app.tck_power_EditField.Value;
            params.select = app.tck_select_EditField.Value;
            params.cutoff = app.tck_cutoff_EditField.Value;
            params.sift = app.tck_sift_EditField.Value;
            save_params('fba', 'fba_fixel_tck', app.workPath, params);
            tckParams = struct();
            tckParams.algorithm = app.tck_algo_DropDown.Value;
            tckParams.angle = app.tck_angle_EditField.Value;
            tckParams.maxlen = app.tck_maxlen_EditField.Value;
            tckParams.minlen = app.tck_minlen_EditField.Value;
            tckParams.power = app.tck_power_EditField.Value;
            tckParams.select = app.tck_select_EditField.Value;
            tckParams.cutoff = app.tck_cutoff_EditField.Value;
            tckParams.siftNum = app.tck_sift_EditField.Value;
            try
                step17_tckgen(app.workPath, tckParams);
                app.progress_Label.Text = '追踪+SIFT完成，生成连接矩阵...';
                drawnow;
                step18_connect(app.workPath, tckParams);
                app.progress_Label.Text = '追踪、SIFT、连接矩阵完成';

                elapsedTime = toc(startTime);
                hours = floor(elapsedTime / 3600);
                minutes = floor((elapsedTime - hours * 3600) / 60);
                seconds = mod(elapsedTime, 60);
                uialert(app.UIFigure, sprintf('全脑追踪、SIFT、fixel-fixel 连接矩阵完成！\n共耗时：%d小时 %d分钟 %.0f秒', hours, minutes, seconds), '完成提示');
            catch ME
                uialert(app.UIFigure, ['追踪出错: ' ME.message], '错误');
            end
            app.btn_tck.Enable = 'on';
        end

        function btn_smoothPushed(app, event)
            app.btn_smooth.Enable = 'off';
            app.progress_Label.Text = '平滑指标...';
            drawnow;
            startTime = tic;
            params = struct();
            params.fd = app.chk_fd.Value;
            params.logfc = app.chk_logfc.Value;
            params.fdc = app.chk_fdc.Value;
            save_params('fba', 'fba_fixel_smooth', app.workPath, params);
            metrics = {};
            if app.chk_fd.Value
                metrics{end+1} = 'fd';
            end
            if app.chk_logfc.Value
                metrics{end+1} = 'log_fc';
            end
            if app.chk_fdc.Value
                metrics{end+1} = 'fdc';
            end
            if isempty(metrics)
                uialert(app.UIFigure, '请至少选择一个指标', '提示');
                app.btn_smooth.Enable = 'on';
                return
            end
            try
                step19_smooth(app.workPath, metrics);
                app.progress_Label.Text = '平滑完成';

                elapsedTime = toc(startTime);
                hours = floor(elapsedTime / 3600);
                minutes = floor((elapsedTime - hours * 3600) / 60);
                seconds = mod(elapsedTime, 60);
                uialert(app.UIFigure, sprintf('平滑完成！\n共耗时：%d小时 %d分钟 %.0f秒', hours, minutes, seconds), '完成提示');
            catch ME
                uialert(app.UIFigure, ['平滑出错: ' ME.message], '错误');
            end
            app.btn_smooth.Enable = 'on';
        end
    end

    methods (Access = private)

        function createComponents(app)

            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);
            fw = 500; fh = 620;
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [(screen_width-fw)/2 (screen_height-fh)/2 fw fh];
            app.UIFigure.Name = 'FBA - Fixel 指标与追踪';

            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 595 60 22], 'Text', '工作路径');
            app.work_EditField = uieditfield(app.UIFigure, 'text', ...
                'Editable', 'off', 'Position', [80 595 350 22]);
            app.work_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @work_ButtonPushed, true), ...
                'Position', [440 595 35 23], 'Text', '...');

            uipanel(app.UIFigure, 'Title', 'Fixel Mask 参数', ...
                'Position', [10 523 460 72]);
            uilabel(app.UIFigure, 'Position', [20 551 100 18], 'Text', 'FMLS 峰值阈值');
            app.fmls_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [125 551 50 22], 'Value', 0.06);
            uilabel(app.UIFigure, 'Position', [20 526 100 18], 'Text', '追踪 FOD 截止值');
            app.tck_cutoff_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [125 526 50 22], 'Value', 0.06);

            app.btn_fixel_mask = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_fixel_maskPushed, true), ...
                'Position', [10 492 140 28], 'Text', '生成 fixel mask', ...
                'FontSize', 12);
            app.fixel_mask_import_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @fixel_mask_import_ButtonPushed, true), ...
                'Position', [155 492 30 28], 'Text', '导入', ...
                'FontSize', 11);
            app.btn_fd_fc = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_fd_fcPushed, true), ...
                'Position', [195 492 160 28], 'Text', 'FD → FC → FDC', ...
                'FontSize', 12);
            app.fd_fc_import_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @fd_fc_import_ButtonPushed, true), ...
                'Position', [360 492 30 28], 'Text', '导入', ...
                'FontSize', 11);

            uipanel(app.UIFigure, 'Title', '模板追踪参数', ...
                'Position', [10 295 460 170]);
            uilabel(app.UIFigure, 'Position', [20 420 50 18], 'Text', '算法');
            app.tck_algo_DropDown = uidropdown(app.UIFigure, ...
                'Items', {'iFOD2', 'SD_STREAM', 'TENSOR_DET', 'TENSOR_PROB', 'FACT'}, ...
                'Position', [75 420 100 22]);
            uilabel(app.UIFigure, 'Position', [200 420 40 18], 'Text', '角度');
            app.tck_angle_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [240 420 50 22], 'Value', 22.5);
            uilabel(app.UIFigure, 'Position', [310 420 50 18], 'Text', '轨迹系数');
            app.tck_power_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [365 420 50 22], 'Value', 1.0);

            uilabel(app.UIFigure, 'Position', [20 395 60 18], 'Text', '最大长度');
            app.tck_maxlen_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [85 395 50 22], 'Value', 250);
            uilabel(app.UIFigure, 'Position', [150 395 60 18], 'Text', '最小长度');
            app.tck_minlen_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [215 395 50 22], 'Value', 10);

            uilabel(app.UIFigure, 'Position', [20 370 60 18], 'Text', '追踪条数');
            app.tck_select_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [85 370 70 22], 'Value', 20000000);
            uilabel(app.UIFigure, 'Position', [170 370 90 18], 'Text', 'SIFT 后条数');
            app.tck_sift_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [265 370 70 22], 'Value', 2000000);

            app.btn_tck = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_tckPushed, true), ...
                'Position', [10 258 180 28], 'Text', '全脑追踪 + SIFT + 连接矩阵', ...
                'FontSize', 12);

            app.tck_import_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @tck_import_ButtonPushed, true), ...
                'Position', [195 258 30 28], 'Text', '导入', ...
                'FontSize', 11);

            uipanel(app.UIFigure, 'Title', '平滑指标', ...
                'Position', [10 183 460 50]);
            app.chk_fd = uicheckbox(app.UIFigure, ...
                'Position', [30 188 60 22], 'Text', 'FD', 'Value', true);
            app.chk_logfc = uicheckbox(app.UIFigure, ...
                'Position', [120 188 80 22], 'Text', 'log(FC)', 'Value', true);
            app.chk_fdc = uicheckbox(app.UIFigure, ...
                'Position', [230 188 80 22], 'Text', 'FDC', 'Value', true);

            app.btn_smooth = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_smoothPushed, true), ...
                'Position', [10 145 80 28], 'Text', '平滑', ...
                'FontSize', 12);

            app.smooth_import_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @smooth_import_ButtonPushed, true), ...
                'Position', [95 145 30 28], 'Text', '导入', ...
                'FontSize', 11);

            app.progress_Label = uilabel(app.UIFigure, ...
                'Position', [10 80 480 22], ...
                'HorizontalAlignment', 'center', 'Text', '');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = fba_fixel
            createComponents(app)
            registerApp(app, app.UIFigure)
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
