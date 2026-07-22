classdef tckstats < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                       matlab.ui.Figure

        tckstats_Panel                 matlab.ui.container.Panel
        tckstats_folder_EditField      matlab.ui.control.EditField
        tckstats_folder_Button         matlab.ui.control.Button
        tckstats_scan_Button           matlab.ui.control.Button
        tckstats_fileList_TextArea     matlab.ui.control.TextArea

        tckstats_mean_CheckBox         matlab.ui.control.CheckBox
        tckstats_median_CheckBox       matlab.ui.control.CheckBox
        tckstats_std_CheckBox          matlab.ui.control.CheckBox
        tckstats_min_CheckBox          matlab.ui.control.CheckBox
        tckstats_max_CheckBox          matlab.ui.control.CheckBox
        tckstats_count_CheckBox        matlab.ui.control.CheckBox

        tckstats_histogram_CheckBox    matlab.ui.control.CheckBox
        tckstats_histogram_EditField   matlab.ui.control.EditField
        tckstats_histogram_Button      matlab.ui.control.Button
        tckstats_dump_CheckBox         matlab.ui.control.CheckBox
        tckstats_dump_EditField        matlab.ui.control.EditField
        tckstats_dump_Button           matlab.ui.control.Button
        tckstats_weight_CheckBox       matlab.ui.control.CheckBox

        tckstats_output_EditField      matlab.ui.control.EditField
        tckstats_output_Button         matlab.ui.control.Button

        start_Button                   matlab.ui.control.Button
        tckstats_status_Label          matlab.ui.control.Label
        tckstats_result_TextArea       matlab.ui.control.TextArea

        fileList             cell
        fileFullPaths        cell
        import_Button        matlab.ui.control.Button

        tckstats_scope_ButtonGroup       matlab.ui.container.ButtonGroup
        tckstats_wholeBrain_Radio        matlab.ui.control.RadioButton
        tckstats_roi_Radio               matlab.ui.control.RadioButton

        tckstats_roi_Panel               matlab.ui.container.Panel
        tckstats_roi_list_ListBox        matlab.ui.control.ListBox
        tckstats_roi_add_Button          matlab.ui.control.Button
        tckstats_roi_del_Button          matlab.ui.control.Button
        tckstats_ends_only_CheckBox      matlab.ui.control.CheckBox
        tckstats_ordered_CheckBox        matlab.ui.control.CheckBox

        roiMasks             cell
    end

    methods (Access = private)

        function tckstats_folder_ButtonPushed(app, ~)
            p = uigetdir('选择纤维文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.tckstats_folder_EditField.Value = p;
        end

        function tckstats_scan_ButtonPushed(app, ~)
            folder = strtrim(app.tckstats_folder_EditField.Value);
            if ~isfolder(folder)
                uialert(app.UIFigure, '请先选择有效的纤维文件夹', '路径错误');
                return;
            end
            d = dir(fullfile(folder, '**', '*.tck'));
            files = {};
            fullPaths = {};
            for i = 1:length(d)
                if d(i).isdir, continue; end
                fullPath = fullfile(d(i).folder, d(i).name);
                relPath = strrep(fullPath, [folder filesep], '');
                files{end+1} = relPath;
                fullPaths{end+1} = fullPath;
            end
            app.fileList = files;
            app.fileFullPaths = fullPaths;
            if isempty(files)
                app.tckstats_fileList_TextArea.Value = '未找到 .tck 文件';
            else
                app.tckstats_fileList_TextArea.Value = strjoin(files, newline);
            end
        end

        function tckstats_histogram_CheckBoxValueChanged(app, ~)
            if app.tckstats_histogram_CheckBox.Value
                app.tckstats_histogram_EditField.Enable = 'on';
                app.tckstats_histogram_Button.Enable = 'on';
            else
                app.tckstats_histogram_EditField.Enable = 'off';
                app.tckstats_histogram_Button.Enable = 'off';
            end
        end

        function tckstats_histogram_ButtonPushed(app, ~)
            p = uigetdir('选择直方图保存路径');
            if p == 0, return; end
            figure(app.UIFigure);
            app.tckstats_histogram_EditField.Value = p;
        end

        function tckstats_dump_CheckBoxValueChanged(app, ~)
            if app.tckstats_dump_CheckBox.Value
                app.tckstats_dump_EditField.Enable = 'on';
                app.tckstats_dump_Button.Enable = 'on';
            else
                app.tckstats_dump_EditField.Enable = 'off';
                app.tckstats_dump_Button.Enable = 'off';
            end
        end

        function tckstats_dump_ButtonPushed(app, ~)
            p = uigetdir('选择长度导出路径');
            if p == 0, return; end
            figure(app.UIFigure);
            app.tckstats_dump_EditField.Value = p;
        end

        function tckstats_output_ButtonPushed(app, ~)
            p = uigetdir('选择输出文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.tckstats_output_EditField.Value = p;
        end

        function scope_ButtonGroupSelectionChanged(app, ~)
            if app.tckstats_roi_Radio.Value
                app.tckstats_roi_Panel.Visible = 'on';
                app.tckstats_weight_CheckBox.Enable = 'off';
                app.tckstats_weight_CheckBox.Value = false;
            else
                app.tckstats_roi_Panel.Visible = 'off';
                app.tckstats_weight_CheckBox.Enable = 'on';
            end
        end

        function roi_add_ButtonPushed(app, ~)
            [f, p] = uigetfile({'*.nii;*.nii.gz;*.mif', 'ROI mask 文件 (*.nii,*.nii.gz,*.mif)'});
            if isequal(f, 0), return; end
            figure(app.UIFigure);
            app.roiMasks{end+1} = fullfile(p, f);
            app.refreshROIList();
        end

        function roi_del_ButtonPushed(app, ~)
            idx = app.tckstats_roi_list_ListBox.Value;
            if isempty(idx), return; end
            if isequal(idx, 1) && length(app.roiMasks) == 0
                return;
            end
            app.roiMasks(idx) = [];
            app.refreshROIList();
        end

        function refreshROIList(app)
            if isempty(app.roiMasks)
                app.tckstats_roi_list_ListBox.Items = {'(无 mask，请添加)'};
                app.tckstats_roi_list_ListBox.Value = 1;
                app.tckstats_roi_list_ListBox.ItemsData = 1;
            else
                n = length(app.roiMasks);
                items = cell(1, n);
                for k = 1:n
                    [~, name, ext] = fileparts(app.roiMasks{k});
                    items{k} = sprintf('%d: %s%s', k, name, ext);
                end
                app.tckstats_roi_list_ListBox.Items = items;
                app.tckstats_roi_list_ListBox.ItemsData = 1:n;
                app.tckstats_roi_list_ListBox.Value = [];
            end
        end

        function import_ButtonPushed(app, ~)
            [file, path] = uigetfile('*.mat', '选择参数文件');
            if isequal(file, 0), return; end
            data = load_params(fullfile(path, file));
            p = data.params;
            app.tckstats_folder_EditField.Value = p.inDir;
            app.tckstats_output_EditField.Value = p.outDir;
            app.tckstats_mean_CheckBox.Value = p.mean;
            app.tckstats_median_CheckBox.Value = p.median;
            app.tckstats_std_CheckBox.Value = p.std;
            app.tckstats_min_CheckBox.Value = p.min;
            app.tckstats_max_CheckBox.Value = p.max;
            app.tckstats_count_CheckBox.Value = p.count;
            app.tckstats_histogram_CheckBox.Value = p.histogram;
            app.tckstats_histogram_EditField.Value = p.histDir;
            app.tckstats_dump_CheckBox.Value = p.dump;
            app.tckstats_dump_EditField.Value = p.dumpDir;
            app.tckstats_weight_CheckBox.Value = p.weight;
            if isfield(p, 'scope')
                app.tckstats_wholeBrain_Radio.Value = strcmp(p.scope, 'wholeBrain');
                app.tckstats_roi_Radio.Value = strcmp(p.scope, 'roi');
            end
            if isfield(p, 'roiMasks'),  app.roiMasks = p.roiMasks;  end
            if isfield(p, 'endsOnly'),  app.tckstats_ends_only_CheckBox.Value = p.endsOnly; end
            if isfield(p, 'ordered'),   app.tckstats_ordered_CheckBox.Value = p.ordered; end
            app.scope_ButtonGroupSelectionChanged();
            app.refreshROIList();
        end

        function start_ButtonPushed(app, ~)
            params = struct();
            params.inDir = app.tckstats_folder_EditField.Value;
            params.outDir = app.tckstats_output_EditField.Value;
            params.mean = app.tckstats_mean_CheckBox.Value;
            params.median = app.tckstats_median_CheckBox.Value;
            params.std = app.tckstats_std_CheckBox.Value;
            params.min = app.tckstats_min_CheckBox.Value;
            params.max = app.tckstats_max_CheckBox.Value;
            params.count = app.tckstats_count_CheckBox.Value;
            params.histogram = app.tckstats_histogram_CheckBox.Value;
            params.histDir = app.tckstats_histogram_EditField.Value;
            params.dump = app.tckstats_dump_CheckBox.Value;
            params.dumpDir = app.tckstats_dump_EditField.Value;
            params.weight = app.tckstats_weight_CheckBox.Value;
            params.scope = 'wholeBrain';
            if app.tckstats_roi_Radio.Value, params.scope = 'roi'; end
            params.roiMasks = app.roiMasks;
            params.endsOnly = app.tckstats_ends_only_CheckBox.Value;
            params.ordered = app.tckstats_ordered_CheckBox.Value;
            save_params('stats', 'tckstats', app.tckstats_output_EditField.Value, params);
            tckstats_run(app);
        end

        function tckstats_run(app)
            outDir = strtrim(app.tckstats_output_EditField.Value);
            if isempty(outDir) || ~isfolder(outDir)
                uialert(app.UIFigure, '请先选择输出文件夹', '输出文件夹缺失');
                return;
            end
            inDir = strtrim(app.tckstats_folder_EditField.Value);
            if isempty(app.fileList) || ~isfolder(inDir)
                uialert(app.UIFigure, '请先检索纤维文件夹', '输入缺失');
                return;
            end

            useROI = app.tckstats_roi_Radio.Value && ~isempty(app.roiMasks);

            fields = {};
            if app.tckstats_mean_CheckBox.Value,   fields{end+1} = 'mean';   end
            if app.tckstats_median_CheckBox.Value, fields{end+1} = 'median'; end
            if app.tckstats_std_CheckBox.Value,    fields{end+1} = 'std';    end
            if app.tckstats_min_CheckBox.Value,    fields{end+1} = 'min';    end
            if app.tckstats_max_CheckBox.Value,    fields{end+1} = 'max';    end
            if app.tckstats_count_CheckBox.Value,  fields{end+1} = 'count';  end
            if isempty(fields)
                uialert(app.UIFigure, '请至少选择一个输出指标', '指标缺失');
                return;
            end

            useHist = app.tckstats_histogram_CheckBox.Value;
            histDir = strtrim(app.tckstats_histogram_EditField.Value);
            if useHist && (isempty(histDir) || ~isfolder(histDir))
                uialert(app.UIFigure, '直方图保存路径无效', '路径错误');
                return;
            end

            useDump = app.tckstats_dump_CheckBox.Value;
            dumpDir = strtrim(app.tckstats_dump_EditField.Value);
            if useDump && (isempty(dumpDir) || ~isfolder(dumpDir))
                uialert(app.UIFigure, '长度导出路径无效', '路径错误');
                return;
            end

            useWeight = app.tckstats_weight_CheckBox.Value;

            fieldOpt = '';
            for i = 1:length(fields)
                fieldOpt = [fieldOpt ' -output ' fields{i}];
            end

            csvFile = fullfile(outDir, ['tckstats_' datestr(now, 'yyyymmdd_HHMMSS') '.csv']);
            fid = fopen(csvFile, 'w');
            fprintf(fid, 'File,%s\n', strjoin(fields, ','));
            fclose(fid);

            resultLines = {};
            resultLines{end+1} = '=== 处理结果 ===';

            app.start_Button.Enable = 'off';
            startTime = tic;

            for i = 1:length(app.fileList)
                relPath = app.fileList{i};
                fullPath = app.fileFullPaths{i};
                [tckDir, ~, ~] = fileparts(fullPath);
                baseName = strrep(relPath, filesep, '_');
                baseName = strrep(baseName, '.tck', '');

                app.tckstats_status_Label.Text = sprintf('处理中: %s (%d/%d)', relPath, i, length(app.fileList));
                drawnow;

                % === ROI 筛选 ===
                if useROI
                    [fiberDir, subjectName] = fileparts(tckDir);
                    workPath = fileparts(fiberDir);

                    refImage = fullfile(workPath, 'pred_b0', subjectName, 'mean_b0.nii.gz');
                    if ~isfile(refImage)
                        uialert(app.UIFigure, ...
                            sprintf('自动查找参考图像失败：\n%s\n\n请确保已执行 DWI 预处理（pred_b0 步骤）', refImage), ...
                            '参考图像缺失');
                        app.start_Button.Enable = 'on';
                        return;
                    end

                    transformPath = fullfile(workPath, 'dwi_coreg', subjectName, 'dwi_to_MNI_mrtrix.txt');

                    subjectTag = strrep(relPath, filesep, '_');
                    subjectTag = strrep(subjectTag, '.tck', '');
                    warpedMasks = {};
                    warpOk = true;
                    for m = 1:length(app.roiMasks)
                        [warped, ok, errMsg] = app.warpMask(app.roiMasks{m}, refImage, transformPath, subjectTag, outDir);
                        if ~ok
                            fprintf(2, '\n=== 配准错误 ===\n%s\n', errMsg);
                            uialert(app.UIFigure, 'mask 配准失败，详情请查看 MATLAB 命令行窗口', '配准错误');
                            warpOk = false;
                            break;
                        end
                        warpedMasks{m} = warped;
                    end
                    if ~warpOk
                        app.start_Button.Enable = 'on';
                        return;
                    end

                    filteredName = ['filtered_' subjectTag '.tck'];
                    filteredPath = fullfile(outDir, filteredName);

                    incOpt = '';
                    for m = 1:length(warpedMasks)
                        incOpt = [incOpt ' -include "' warpedMasks{m} '"'];
                    end
                    if app.tckstats_ordered_CheckBox.Value
                        incOpt = strrep(incOpt, '-include', '-include_ordered');
                    end
                    endsOpt = '';
                    if app.tckstats_ends_only_CheckBox.Value
                        endsOpt = ' -ends_only';
                    end

                    tckeditCmd = sprintf('tckedit "%s" "%s"%s%s -force', fullPath, filteredPath, incOpt, endsOpt);
                    app.tckstats_status_Label.Text = sprintf('筛选纤维: %s', relPath);
                    drawnow;
                    [status, ~] = system(tckeditCmd);
                    if status ~= 0
                        uialert(app.UIFigure, sprintf('tckedit 筛选失败: %s', relPath), '筛选错误');
                        app.start_Button.Enable = 'on';
                        return;
                    end
                    targetPath = filteredPath;
                    resultLines{end+1} = sprintf('[%d/%d] %s (ROI 筛选)', i, length(app.fileList), relPath);
                else
                    targetPath = fullPath;
                end

                weightOpt = '';
                if ~useROI && useWeight
                    weightPath = fullfile(tckDir, 'sift_weight.txt');
                    if exist(weightPath, 'file')
                        weightOpt = [' -tck_weights_in "' weightPath '"'];
                    end
                end

                cmd = sprintf('tckstats "%s"%s%s', targetPath, fieldOpt, weightOpt);
                [~, result] = system(cmd);
                result = strtrim(result);

                if useHist
                    histFile = fullfile(histDir, [baseName '_hist.txt']);
                    histCmd = sprintf('tckstats "%s"%s -histogram "%s"', targetPath, weightOpt, histFile);
                    system(histCmd);
                end

                if useDump
                    dumpFile = fullfile(dumpDir, [baseName '_lengths.txt']);
                    dumpCmd = sprintf('tckstats "%s"%s -dump "%s"', targetPath, weightOpt, dumpFile);
                    system(dumpCmd);
                end

                vals = {};
                clean = regexprep(result, '\x1b\[[0-9;]*[a-zA-Z]', '');
                rawLines = strsplit(strtrim(clean), '\n');
                for li = 1:length(rawLines)
                    line = strtrim(rawLines{li});
                    if isempty(line) || contains(line, '***') || contains(line, 'tckstats:')
                        continue;
                    end
                    nums = regexp(line, '([\+\-]?\d+\.?\d*(?:[eE][\+\-]?\d+)?)', 'tokens');
                    for ni = 1:length(nums)
                        vals{end+1} = nums{ni}{1};
                    end
                end
                vals = vals(1:min(length(vals), length(fields)));

                fid = fopen(csvFile, 'a');
                fprintf(fid, '%s', relPath);
                for j = 1:length(vals)
                    fprintf(fid, ',%s', vals{j});
                end
                fprintf(fid, '\n');
                fclose(fid);

                if ~useROI
                    lineStr = sprintf('[%d/%d] %s', i, length(app.fileList), relPath);
                    for j = 1:min(length(vals), length(fields))
                        lineStr = [lineStr sprintf(' | %s: %s', fields{j}, vals{j})];
                    end
                    resultLines{end+1} = lineStr;
                else
                    for j = 1:min(length(vals), length(fields))
                        resultLines{end} = [resultLines{end} sprintf(' | %s: %s', fields{j}, vals{j})];
                    end
                end
                app.tckstats_result_TextArea.Value = strjoin(resultLines, newline);
            end

            elapsed = toc(startTime);

            resultLines{end+1} = '';
            resultLines{end+1} = sprintf('完成! 共处理 %d 个文件, 耗时: %.1f 秒', length(app.fileList), elapsed);
            resultLines{end+1} = sprintf('结果已保存: %s', csvFile);
            app.tckstats_result_TextArea.Value = strjoin(resultLines, newline);

            app.tckstats_status_Label.Text = '处理完成';
            app.start_Button.Enable = 'on';

            uialert(app.UIFigure, ...
                sprintf('tckstats 完成\n共处理 %d 个文件\n结果: %s\n耗时: %.1f 秒', ...
                length(app.fileList), csvFile, elapsed), '完成');
        end
    end

    methods (Access = private, Static)

        function [warpedMask, ok, errMsg] = warpMask(maskPath, refPath, transformPath, subjectTag, outDir)
            warpedMask = maskPath;
            ok = true;
            errMsg = '';
            [~, r1] = system(sprintf('mrinfo -size "%s"', maskPath));
            [~, r2] = system(sprintf('mrinfo -size "%s"', refPath));
            if strcmp(strtrim(r1), strtrim(r2))
                return;
            end
            if ~isfile(transformPath)
                errMsg = sprintf('Mask 配准失败，未找到变换文件：\n%s\n\n请确保已执行 dwi_coreg，或使用与 DWI 同空间的 mask。', transformPath);
                ok = false;
                return;
            end
            [~, fname, fext] = fileparts(maskPath);
            if strcmp(fext, '.gz')
                [~, fname] = fileparts(fname);
                fext = '.nii.gz';
            end
            warpedMask = fullfile(outDir, [fname '_' subjectTag fext]);
            cmd = sprintf('mrtransform "%s" -linear "%s" -inverse -template "%s" "%s" -interp nearest -datatype int32 -force', ...
                maskPath, transformPath, refPath, warpedMask);
            [status, result] = system(cmd);
            if status ~= 0
                errMsg = sprintf('Mask 配准失败：mrtransform 返回错误 (exit=%d)\n%s\n命令:\n%s', status, strtrim(result), cmd);
                ok = false;
                return;
            end
            fprintf('Mask 已配准到 %s: %s\n', subjectTag, warpedMask);
        end
    end

    methods (Access = private)

        function createComponents(app)

            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);

            fw = 580;
            fh = 750;
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [(screen_width-fw)/2 (screen_height-fh)/2 fw fh];
            app.UIFigure.Name = '纤维指标数值提取';

            app.tckstats_Panel = uipanel(app.UIFigure, ...
                'Title', '', 'Position', [10 10 560 730]);

            % --- 文件夹区域 ---
            y = 625;
            uilabel(app.tckstats_Panel, ...
                'Position', [10 y 100 22], 'Text', '纤维文件夹');
            app.tckstats_folder_EditField = uieditfield(app.tckstats_Panel, 'text', ...
                'Editable', 'off', 'Position', [110 y 350 22]);
            app.tckstats_folder_Button = uibutton(app.tckstats_Panel, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @tckstats_folder_ButtonPushed, true), ...
                'Position', [465 y 35 23], 'Text', '...');

            y = 596;
            app.tckstats_scan_Button = uibutton(app.tckstats_Panel, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @tckstats_scan_ButtonPushed, true), ...
                'Position', [110 y 100 22], 'Text', '检索');

            y = 570;
            uilabel(app.tckstats_Panel, ...
                'Position', [10 y 100 22], 'Text', '文件列表');
            app.tckstats_fileList_TextArea = uitextarea(app.tckstats_Panel, ...
                'Position', [10 390 540 175], 'Editable', 'off');

            % --- Scope 切换 ---
            app.tckstats_scope_ButtonGroup = uibuttongroup(app.tckstats_Panel, ...
                'Position', [10 362 300 24], ...
                'SelectionChangedFcn', createCallbackFcn(app, @scope_ButtonGroupSelectionChanged, true));
            app.tckstats_wholeBrain_Radio = uiradiobutton(app.tckstats_scope_ButtonGroup, ...
                'Position', [10 2 85 22], 'Text', '全脑分析', 'Value', true);
            app.tckstats_roi_Radio = uiradiobutton(app.tckstats_scope_ButtonGroup, ...
                'Position', [100 2 95 22], 'Text', 'ROI纤维筛选');

            % --- ROI 参数面板 ---
            app.tckstats_roi_Panel = uipanel(app.tckstats_Panel, ...
                'Position', [10 264 540 90], 'Visible', 'off', 'Title', '');

            uilabel(app.tckstats_roi_Panel, ...
                'Position', [5 68 65 22], 'Text', 'mask列表');
            app.tckstats_roi_list_ListBox = uilistbox(app.tckstats_roi_Panel, ...
                'Position', [5 22 310 44], 'Items', {'(无 mask，请添加)'}, ...
                'Value', 1, 'ItemsData', 1, 'multiselect', 'on');

            app.tckstats_roi_add_Button = uibutton(app.tckstats_roi_Panel, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @roi_add_ButtonPushed, true), ...
                'Position', [320 68 55 22], 'Text', '添加');
            app.tckstats_roi_del_Button = uibutton(app.tckstats_roi_Panel, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @roi_del_ButtonPushed, true), ...
                'Position', [378 68 55 22], 'Text', '删除');

            app.tckstats_ends_only_CheckBox = uicheckbox(app.tckstats_roi_Panel, ...
                'Position', [5 0 145 22], 'Text', '以ROI为端点 (-ends_only)');
            app.tckstats_ordered_CheckBox = uicheckbox(app.tckstats_roi_Panel, ...
                'Position', [155 0 150 22], 'Text', '按顺序通过 (-include_ordered)');

            % --- 统计量 ---
            y = 226;
            uilabel(app.tckstats_Panel, ...
                'Position', [10 y 80 18], 'Text', '统计量', 'FontWeight', 'bold');
            y = 202;
            app.tckstats_mean_CheckBox = uicheckbox(app.tckstats_Panel, ...
                'Position', [15 y 60 22], 'Text', 'mean', 'Value', true);
            app.tckstats_median_CheckBox = uicheckbox(app.tckstats_Panel, ...
                'Position', [90 y 70 22], 'Text', 'median', 'Value', true);
            app.tckstats_std_CheckBox = uicheckbox(app.tckstats_Panel, ...
                'Position', [175 y 55 22], 'Text', 'std');
            app.tckstats_min_CheckBox = uicheckbox(app.tckstats_Panel, ...
                'Position', [245 y 55 22], 'Text', 'min');
            app.tckstats_max_CheckBox = uicheckbox(app.tckstats_Panel, ...
                'Position', [315 y 55 22], 'Text', 'max');
            app.tckstats_count_CheckBox = uicheckbox(app.tckstats_Panel, ...
                'Position', [385 y 70 22], 'Text', 'count', 'Value', true);

            % --- 高级选项 ---
            y = 176;
            uilabel(app.tckstats_Panel, ...
                'Position', [10 y 80 18], 'Text', '高级选项', 'FontWeight', 'bold');

            y = 152;
            app.tckstats_histogram_CheckBox = uicheckbox(app.tckstats_Panel, ...
                'Position', [15 y 100 22], 'Text', '输出直方图', ...
                'ValueChangedFcn', createCallbackFcn(app, @tckstats_histogram_CheckBoxValueChanged, true));
            app.tckstats_histogram_EditField = uieditfield(app.tckstats_Panel, 'text', ...
                'Position', [115 y 330 22], 'Enable', 'off');
            app.tckstats_histogram_Button = uibutton(app.tckstats_Panel, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @tckstats_histogram_ButtonPushed, true), ...
                'Position', [450 y 35 23], 'Text', '...', 'Enable', 'off');

            y = 126;
            app.tckstats_dump_CheckBox = uicheckbox(app.tckstats_Panel, ...
                'Position', [15 y 100 22], 'Text', '导出长度', ...
                'ValueChangedFcn', createCallbackFcn(app, @tckstats_dump_CheckBoxValueChanged, true));
            app.tckstats_dump_EditField = uieditfield(app.tckstats_Panel, 'text', ...
                'Position', [115 y 330 22], 'Enable', 'off');
            app.tckstats_dump_Button = uibutton(app.tckstats_Panel, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @tckstats_dump_ButtonPushed, true), ...
                'Position', [450 y 35 23], 'Text', '...', 'Enable', 'off');

            y = 102;
            app.tckstats_weight_CheckBox = uicheckbox(app.tckstats_Panel, ...
                'Position', [15 y 260 22], 'Text', '使用 SIFT2 权重 (自动匹配 sift_weight.txt)', 'Value', true);

            % --- 输出文件夹 ---
            y = 76;
            uilabel(app.tckstats_Panel, ...
                'Position', [10 y 100 22], 'Text', '输出文件夹');
            app.tckstats_output_EditField = uieditfield(app.tckstats_Panel, 'text', ...
                'Position', [110 y 350 22], 'Editable', 'off');
            app.tckstats_output_Button = uibutton(app.tckstats_Panel, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @tckstats_output_ButtonPushed, true), ...
                'Position', [465 y 35 23], 'Text', '...');

            % --- 按钮 ---
            y = 44;
            app.start_Button = uibutton(app.tckstats_Panel, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @start_ButtonPushed, true), ...
                'Position', [(fw-200)/2-10 y 200 30], 'Text', '开始处理', 'FontSize', 13);

            app.import_Button = uibutton(app.tckstats_Panel, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @import_ButtonPushed, true), ...
                'Position', [(fw-200)/2+200 y 40 30], 'Text', '导入', 'FontSize', 12);

            % --- 结果区域 ---
            app.tckstats_result_TextArea = uitextarea(app.tckstats_Panel, ...
                'Position', [10 2 540 18], 'Editable', 'off');

            app.tckstats_status_Label = uilabel(app.tckstats_Panel, ...
                'Position', [10 24 540 18], ...
                'HorizontalAlignment', 'center', 'Text', '就绪');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = tckstats
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
