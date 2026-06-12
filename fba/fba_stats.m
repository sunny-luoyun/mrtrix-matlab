classdef fba_stats < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        work_EditField          matlab.ui.control.EditField
        work_Button             matlab.ui.control.Button

        groupNum_DropDown       matlab.ui.control.DropDown
        statType_DropDown       matlab.ui.control.DropDown

        g1_key_EditField        matlab.ui.control.EditField
        g2_key_EditField        matlab.ui.control.EditField
        design_TextArea         matlab.ui.control.TextArea
        contrast_TextArea       matlab.ui.control.TextArea
        preview_TextArea        matlab.ui.control.TextArea
        btn_genDesign           matlab.ui.control.Button

        chk_fd                  matlab.ui.control.CheckBox
        chk_logfc               matlab.ui.control.CheckBox
        chk_fdc                 matlab.ui.control.CheckBox

        nshuffles_EditField     matlab.ui.control.NumericEditField
        cfe_h_EditField         matlab.ui.control.NumericEditField
        cfe_e_EditField         matlab.ui.control.NumericEditField
        cfe_c_EditField         matlab.ui.control.NumericEditField

        btn_stats               matlab.ui.control.Button
        btn_view                matlab.ui.control.Button
        progress_Label          matlab.ui.control.Label
        stats_import_Button     matlab.ui.control.Button
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

        function btn_genDesignPushed(app, event)
            subDir = fullfile(app.workPath, 'fba', 'subjects');
            if ~isfolder(subDir)
                uialert(app.UIFigure, '请先完成个体水平处理', '错误');
                return
            end
            d = dir(fullfile(subDir, 'Sub*'));
            if isempty(d)
                d = dir(fullfile(subDir, 'sub*'));
            end
            subs = {d.name};
            g1key = strtrim(app.g1_key_EditField.Value);
            g2key = strtrim(app.g2_key_EditField.Value);

            g1 = {}; g2 = {};
            for i = 1:length(subs)
                if contains(subs{i}, g1key)
                    g1{end+1} = subs{i};
                elseif contains(subs{i}, g2key)
                    g2{end+1} = subs{i};
                end
            end
            isG1 = ismember(subs, g1);
            isG2 = ismember(subs, g2);

            nGroups = app.groupNum_DropDown.Value;
            if strcmp(nGroups, '1')
                design = '';
                for i = 1:length(subs)
                    design = [design '1' newline];
                end
                contrast = '1';
            elseif strcmp(nGroups, '2')
                design = '';
                for i = 1:length(subs)
                    if isG1(i)
                        design = [design '1 0' newline];
                    elseif isG2(i)
                        design = [design '0 1' newline];
                    end
                end
                if strcmp(app.statType_DropDown.Value, 'T检验')
                    contrast = '1 -1';
                else
                    contrast = ['1 0' newline '0 1'];
                end
            else
                design = '';
                for i = 1:length(subs)
                    if isG1(i)
                        design = [design '1 0 0' newline];
                    elseif isG2(i)
                        design = [design '0 1 0' newline];
                    else
                        design = [design '0 0 1' newline];
                    end
                end
                contrast = ['1 0 0' newline '0 1 0' newline '0 0 1'];
            end

            app.design_TextArea.Value = design;
            app.contrast_TextArea.Value = contrast;

            preview = ['分组预览:' newline];
            for i = 1:length(g1)
                preview = [preview g1{i} ' → 组1' newline];
            end
            for i = 1:length(g2)
                preview = [preview g2{i} ' → 组2' newline];
            end
            app.preview_TextArea.Value = preview;
        end

        function stats_import_ButtonPushed(app, event)
            [file, path] = uigetfile('*.mat', '选择参数文件');
            if isequal(file, 0), return; end
            data = load_params(fullfile(path, file));
            p = data.params;
            app.groupNum_DropDown.Value = p.groupNum;
            app.statType_DropDown.Value = p.statType;
            app.g1_key_EditField.Value = p.g1key;
            app.g2_key_EditField.Value = p.g2key;
            app.chk_fd.Value = p.fd;
            app.chk_logfc.Value = p.logfc;
            app.chk_fdc.Value = p.fdc;
            app.nshuffles_EditField.Value = p.nshuffles;
            app.cfe_h_EditField.Value = p.cfe_h;
            app.cfe_e_EditField.Value = p.cfe_e;
            app.cfe_c_EditField.Value = p.cfe_c;
            app.design_TextArea.Value = p.designTxt;
            app.contrast_TextArea.Value = p.contrastTxt;
        end

        function btn_statsPushed(app, event)
            app.btn_stats.Enable = 'off';
            app.progress_Label.Text = '运行 CFE 统计分析...';
            drawnow;

            params = struct();
            params.groupNum = app.groupNum_DropDown.Value;
            params.statType = app.statType_DropDown.Value;
            params.g1key = app.g1_key_EditField.Value;
            params.g2key = app.g2_key_EditField.Value;
            params.fd = app.chk_fd.Value;
            params.logfc = app.chk_logfc.Value;
            params.fdc = app.chk_fdc.Value;
            params.nshuffles = app.nshuffles_EditField.Value;
            params.cfe_h = app.cfe_h_EditField.Value;
            params.cfe_e = app.cfe_e_EditField.Value;
            params.cfe_c = app.cfe_c_EditField.Value;
            params.designTxt = app.design_TextArea.Value;
            params.contrastTxt = app.contrast_TextArea.Value;
            save_params('fba', 'fba_stats', app.workPath, params);

            designTxt = app.design_TextArea.Value;
            contrastTxt = app.contrast_TextArea.Value;
            if isempty(designTxt) || isempty(contrastTxt)
                uialert(app.UIFigure, '请先生成设计矩阵', '提示');
                app.btn_stats.Enable = 'on';
                return
            end

            metrics = {};
            if app.chk_fd.Value, metrics{end+1} = 'fd'; end
            if app.chk_logfc.Value, metrics{end+1} = 'log_fc'; end
            if app.chk_fdc.Value, metrics{end+1} = 'fdc'; end
            if isempty(metrics)
                uialert(app.UIFigure, '请至少选择一个指标', '提示');
                app.btn_stats.Enable = 'on';
                return
            end

            nshuffles = app.nshuffles_EditField.Value;
            cfe_h = app.cfe_h_EditField.Value;
            cfe_e = app.cfe_e_EditField.Value;
            cfe_c = app.cfe_c_EditField.Value;

            try
                step20_stats(app.workPath, designTxt, contrastTxt, ...
                    nshuffles, cfe_h, cfe_e, cfe_c, metrics);
                app.progress_Label.Text = 'CFE 统计分析完成';
                msg = sprintf('CFE 统计分析完成！\n结果保存在 fba/template/stats_*');
                uialert(app.UIFigure, msg, '完成提示');
            catch ME
                uialert(app.UIFigure, ['统计出错: ' ME.message], '错误');
            end

            app.btn_stats.Enable = 'on';
        end

        function btn_viewPushed(app, event)
            try
                step21_view(app.workPath);
            catch ME
                uialert(app.UIFigure, ['mrview 启动失败: ' ME.message], '错误');
            end
        end
    end

    methods (Access = private)

        function createComponents(app)

            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);
            fw = 520; fh = 680;
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [(screen_width-fw)/2 (screen_height-fh)/2 fw fh];
            app.UIFigure.Name = 'FBA - CFE 统计分析';

            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 615 60 22], 'Text', '工作路径');
            app.work_EditField = uieditfield(app.UIFigure, 'text', ...
                'Editable', 'off', 'Position', [80 615 370 22]);
            app.work_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @work_ButtonPushed, true), ...
                'Position', [460 615 35 23], 'Text', '...');

            pDesign = uipanel(app.UIFigure, 'Title', '被试分组与设计矩阵', ...
                'Position', [10 380 490 220]);

            uilabel(pDesign, 'Position', [20 170 70 18], 'Text', '输入组数');
            app.groupNum_DropDown = uidropdown(pDesign, ...
                'Items', {'1', '2', '3'}, 'Position', [95 170 60 22]);

            uilabel(pDesign, 'Position', [170 170 70 18], 'Text', '统计类型');
            app.statType_DropDown = uidropdown(pDesign, ...
                'Items', {'T检验', 'F检验'}, 'Position', [245 170 80 22]);

            uilabel(pDesign, 'Position', [20 140 80 18], 'Text', '组1关键词');
            app.g1_key_EditField = uieditfield(pDesign, 'text', ...
                'Position', [105 140 80 22], 'Value', 'control');
            uilabel(pDesign, 'Position', [200 140 80 18], 'Text', '组2关键词');
            app.g2_key_EditField = uieditfield(pDesign, 'text', ...
                'Position', [285 140 80 22], 'Value', 'patient');

            app.btn_genDesign = uibutton(pDesign, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_genDesignPushed, true), ...
                'Position', [20 105 140 22], 'Text', '自动生成设计矩阵');

            uilabel(pDesign, 'Position', [20 75 60 18], 'Text', '设计矩阵');
            app.design_TextArea = uitextarea(pDesign, ...
                'Position', [85 55 140 50]);
            uilabel(pDesign, 'Position', [240 75 70 18], 'Text', '对比矩阵');
            app.contrast_TextArea = uitextarea(pDesign, ...
                'Position', [315 55 140 50]);
            uilabel(pDesign, 'Position', [20 28 120 18], 'Text', '分组预览');
            app.preview_TextArea = uitextarea(pDesign, ...
                'Editable', 'off', 'Position', [20 5 200 30]);

            pMetrics = uipanel(app.UIFigure, 'Title', '要检验的指标', ...
                'Position', [10 325 490 50]);
            app.chk_fd = uicheckbox(pMetrics, ...
                'Position', [30 5 60 22], 'Text', 'FD', 'Value', true);
            app.chk_logfc = uicheckbox(pMetrics, ...
                'Position', [120 5 80 22], 'Text', 'log(FC)', 'Value', true);
            app.chk_fdc = uicheckbox(pMetrics, ...
                'Position', [230 5 80 22], 'Text', 'FDC', 'Value', true);

            pCfe = uipanel(app.UIFigure, 'Title', 'CFE 参数', ...
                'Position', [10 175 490 120]);
            uilabel(pCfe, 'Position', [20 70 80 18], 'Text', '置换次数');
            app.nshuffles_EditField = uieditfield(pCfe, 'numeric', ...
                'Position', [105 70 60 22], 'Value', 5000);
            uilabel(pCfe, 'Position', [190 70 70 18], 'Text', '高度指数 h');
            app.cfe_h_EditField = uieditfield(pCfe, 'numeric', ...
                'Position', [265 70 50 22], 'Value', 2);
            uilabel(pCfe, 'Position', [330 70 70 18], 'Text', '范围指数 e');
            app.cfe_e_EditField = uieditfield(pCfe, 'numeric', ...
                'Position', [405 70 50 22], 'Value', 0.5);
            uilabel(pCfe, 'Position', [20 40 70 18], 'Text', '连接指数 c');
            app.cfe_c_EditField = uieditfield(pCfe, 'numeric', ...
                'Position', [95 40 50 22], 'Value', 0.5);

            app.btn_stats = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_statsPushed, true), ...
                'Position', [100 120 120 30], 'Text', '运行 CFE 统计', ...
                'FontSize', 13);

            app.stats_import_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @stats_import_ButtonPushed, true), ...
                'Position', [225 120 40 30], 'Text', '导入', ...
                'FontSize', 12);

            app.btn_view = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_viewPushed, true), ...
                'Position', [275 120 120 30], 'Text', '查看结果', ...
                'FontSize', 13);

            app.progress_Label = uilabel(app.UIFigure, ...
                'Position', [10 60 500 22], ...
                'HorizontalAlignment', 'center', 'Text', '');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = fba_stats
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
