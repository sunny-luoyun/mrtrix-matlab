classdef fba_organize < matlab.apps.AppBase

    properties (Access = public)
        UIFigure          matlab.ui.Figure
        work_EditField    matlab.ui.control.EditField
        work_Button       matlab.ui.control.Button
        sourceTable       matlab.ui.control.Table
        btn_addRow        matlab.ui.control.Button
        btn_deleteRow     matlab.ui.control.Button
        btn_browsePath    matlab.ui.control.Button
        separator_EditField matlab.ui.control.EditField
        mode_ButtonGroup    matlab.ui.container.ButtonGroup
        mode_copy_Radio     matlab.ui.control.RadioButton
        mode_link_Radio     matlab.ui.control.RadioButton
        preview_TextArea    matlab.ui.control.TextArea
        btn_preview         matlab.ui.control.Button
        btn_execute         matlab.ui.control.Button
        progress_Label      matlab.ui.control.Label
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

        function btn_addRowPushed(app, event)
            data = app.sourceTable.Data;
            if isempty(data)
                data = cell(1, 3);
            else
                data(end+1, :) = {'' '' ''};
            end
            app.sourceTable.Data = data;
        end

        function btn_deleteRowPushed(app, event)
            data = app.sourceTable.Data;
            if isempty(data)
                return
            end
            selected = app.sourceTable.Selection;
            if isempty(selected)
                return
            end
            data(selected(1), :) = [];
            app.sourceTable.Data = data;
        end

        function btn_browsePathPushed(app, event)
            data = app.sourceTable.Data;
            if isempty(data)
                return
            end
            selected = app.sourceTable.Selection;
            if isempty(selected)
                uialert(app.UIFigure, '请先选中一行', '提示');
                return
            end
            path = uigetdir('选择上一步的预处理文件夹路径（包含 Sub* 文件夹的那个）');
            figure(app.UIFigure)
            if isempty(path)
                return
            end
            data{selected(1), 3} = path;
            app.sourceTable.Data = data;
        end

        function btn_previewPushed(app, event)
            if isempty(app.workPath)
                uialert(app.UIFigure, '请先选择工作路径', '提示');
                return
            end
            data = app.sourceTable.Data;
            if isempty(data) || all(cellfun(@isempty, data(:, 1)))
                uialert(app.UIFigure, '请添加源数据配置', '提示');
                return
            end
            sep = app.separator_EditField.Value;
            lines = {};
            for i = 1:size(data, 1)
                cond = strtrim(data{i, 1});
                tp   = strtrim(data{i, 2});
                srcPath = strtrim(data{i, 3});
                if isempty(cond) || isempty(tp) || isempty(srcPath)
                    continue
                end
                subs = getSubDirs(srcPath);
                if isempty(subs)
                    lines{end+1} = sprintf('[%s/%s] 未找到 Sub* 文件夹', cond, tp);
                else
                    for j = 1:length(subs)
                        targetName = sprintf('Sub%s%s%s%s%s', subs{j}, sep, cond, sep, tp);
                        lines{end+1} = sprintf('%s  ←  %s/%s/dwi.mif', targetName, srcPath, subs{j});
                    end
                end
            end
            if isempty(lines)
                app.preview_TextArea.Value = '未找到任何有效的源数据';
            else
                app.preview_TextArea.Value = strjoin(lines, newline);
            end
        end

        function btn_executePushed(app, event)
            if isempty(app.workPath)
                uialert(app.UIFigure, '请先选择工作路径', '提示');
                return
            end
            data = app.sourceTable.Data;
            if isempty(data) || all(cellfun(@isempty, data(:, 1)))
                uialert(app.UIFigure, '请添加源数据配置', '提示');
                return
            end
            sep = app.separator_EditField.Value;
            useCopy = app.mode_copy_Radio.Value;
            subjectsDir = fullfile(app.workPath, 'fba', 'subjects');
            mkdir(subjectsDir);

            total = 0; done = 0;
            rows = {};
            for i = 1:size(data, 1)
                cond = strtrim(data{i, 1});
                tp   = strtrim(data{i, 2});
                srcPath = strtrim(data{i, 3});
                if isempty(cond) || isempty(tp) || isempty(srcPath)
                    continue
                end
                subs = getSubDirs(srcPath);
                for j = 1:length(subs)
                    total = total + 1;
                    rows{end+1} = {cond, tp, srcPath, subs{j}};
                end
            end

            app.btn_execute.Enable = 'off';
            app.progress_Label.Text = sprintf('处理中... 0/%d', total);
            drawnow;

            for k = 1:length(rows)
                r = rows{k};
                targetName = sprintf('Sub%s%s%s%s%s', r{4}, sep, r{1}, sep, r{2});
                targetDir = fullfile(subjectsDir, targetName);
                mkdir(targetDir);
                srcFile = fullfile(r{3}, r{4}, 'dwi.mif');
                dstFile = fullfile(targetDir, 'dwi.mif');
                if ~exist(srcFile, 'file')
                    app.progress_Label.Text = sprintf('跳过 %s (dwi.mif 不存在)', targetName);
                    drawnow;
                elseif exist(dstFile, 'file')
                    done = done + 1;
                elseif useCopy
                    copyfile(srcFile, dstFile);
                    done = done + 1;
                else
                    cmd = sprintf('ln -s %s %s', srcFile, dstFile);
                    system(cmd);
                    done = done + 1;
                end
                app.progress_Label.Text = sprintf('处理中... %d/%d', done, total);
                drawnow;
            end

            app.progress_Label.Text = sprintf('完成！共处理 %d 个扫描', done);
            uialert(app.UIFigure, sprintf('数据整理完成！\n共创建 %d 个被试目录\n保存在 %s', done, subjectsDir), '完成');
            app.btn_execute.Enable = 'on';
        end

    end

    methods (Access = private)

        function createComponents(app)

            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);
            fw = 580; fh = 540;
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [(screen_width-fw)/2 (screen_height-fh)/2 fw fh];
            app.UIFigure.Name = 'FBA - 数据整理';

            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 510 60 22], 'Text', '工作路径');
            app.work_EditField = uieditfield(app.UIFigure, 'text', ...
                'Editable', 'off', 'Position', [80 510 420 22]);
            app.work_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @work_ButtonPushed, true), ...
                'Position', [510 510 35 23], 'Text', '...');

            % Source config panel
            pSrc = uipanel(app.UIFigure, 'Title', '源数据配置', ...
                'Position', [10 290 540 200]);
            uilabel(pSrc, 'Position', [15 155 200 18], ...
                'Text', '条件      时间点    源路径');
            app.sourceTable = uitable(pSrc, ...
                'Position', [15 40 510 115], ...
                'ColumnName', {'条件', '时间点', '源路径'}, ...
                'ColumnWidth', {70, 70, 350}, ...
                'ColumnEditable', [true, true, true], ...
                'Data', cell(0, 3));

            app.btn_addRow = uibutton(pSrc, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_addRowPushed, true), ...
                'Position', [15 10 70 25], 'Text', '+ 添加行');
            app.btn_deleteRow = uibutton(pSrc, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_deleteRowPushed, true), ...
                'Position', [95 10 70 25], 'Text', '- 删除行');
            app.btn_browsePath = uibutton(pSrc, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_browsePathPushed, true), ...
                'Position', [175 10 90 25], 'Text', '选择路径');

            % Output settings panel
            pOpt = uipanel(app.UIFigure, 'Title', '输出设置', ...
                'Position', [10 210 540 70]);
            uilabel(pOpt, 'Position', [15 25 50 18], 'Text', '分隔符');
            app.separator_EditField = uieditfield(pOpt, 'text', ...
                'Position', [65 25 30 22], 'Value', '_');
            uilabel(pOpt, 'Position', [120 25 40 18], 'Text', '操作方式');
            app.mode_ButtonGroup = uibuttongroup(pOpt, ...
                'Position', [165 5 160 40]);
            app.mode_copy_Radio = uiradiobutton(app.mode_ButtonGroup, ...
                'Text', '复制', 'Position', [10 5 50 22], 'Value', true);
            app.mode_link_Radio = uiradiobutton(app.mode_ButtonGroup, ...
                'Text', '软链接', 'Position', [80 5 70 22]);

            % Preview panel
            pPrev = uipanel(app.UIFigure, 'Title', '预览', ...
                'Position', [10 55 540 140]);
            app.preview_TextArea = uitextarea(pPrev, ...
                'Editable', 'off', ...
                'Position', [10 10 520 105]);

            % Action buttons
            app.btn_preview = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_previewPushed, true), ...
                'Position', [160 16 80 28], 'Text', '预览', 'FontSize', 12);
            app.btn_execute = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_executePushed, true), ...
                'Position', [260 16 100 28], 'Text', '执  行', 'FontSize', 13);

            app.progress_Label = uilabel(app.UIFigure, ...
                'Position', [10 5 560 22], ...
                'HorizontalAlignment', 'center', 'Text', '');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = fba_organize
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

function subDirs = getSubDirs(rootPath)
    d = dir(fullfile(rootPath, 'Sub*'));
    if isempty(d)
        d = dir(fullfile(rootPath, 'sub*'));
    end
    subDirs = {d.name};
end
