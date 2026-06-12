classdef fba_stats < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        work_EditField          matlab.ui.control.EditField
        work_Button             matlab.ui.control.Button

        designType_DropDown     matlab.ui.control.DropDown

        % Mode 1: Independent groups
        groupNum_DropDown       matlab.ui.control.DropDown
        statType_DropDown       matlab.ui.control.DropDown
        g1_key_EditField        matlab.ui.control.EditField
        g2_key_EditField        matlab.ui.control.EditField
        mode1_Panel             matlab.ui.container.Panel

        % Mode 2: Paired comparison
        condA_key_EditField     matlab.ui.control.EditField
        condB_key_EditField     matlab.ui.control.EditField
        tp_DropDown             matlab.ui.control.DropDown
        mode2_Panel             matlab.ui.container.Panel

        % Mode 3: Repeated measures ANOVA
        chk_cond                matlab.ui.control.CheckBox
        chk_time                matlab.ui.control.CheckBox
        chk_interact            matlab.ui.control.CheckBox
        mode3_Panel             matlab.ui.container.Panel

        % Shared controls
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
        anovaData struct
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

        function designType_ValueChanged(app, event)
            val = app.designType_DropDown.Value;
            showModePanels(app, val);
            updateTimepoints(app);
        end

        function showModePanels(app, mode)
            isM1 = strcmp(mode, '独立组间比较');
            isM2 = strcmp(mode, '配对比较');
            isM3 = strcmp(mode, '重复测量ANOVA');
            app.mode1_Panel.Visible = isM1;
            app.mode2_Panel.Visible = isM2;
            app.mode3_Panel.Visible = isM3;
        end

        function updateTimepoints(app)
            if isempty(app.workPath)
                return
            end
            tps = detectTimepoints(app.workPath);
            if isempty(tps)
                app.tp_DropDown.Items = {'未检测到时间点'};
            else
                app.tp_DropDown.Items = tps;
                app.tp_DropDown.Value = tps{1};
            end
        end

        function btn_genDesignPushed(app, event)
            mode = app.designType_DropDown.Value;
            if strcmp(mode, '独立组间比较')
                genIndependentDesign(app);
            elseif strcmp(mode, '配对比较')
                genPairedDesign(app);
            elseif strcmp(mode, '重复测量ANOVA')
                genANOVADesign(app);
            end
        end

        function genIndependentDesign(app)
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

        function genPairedDesign(app)
            condA = strtrim(app.condA_key_EditField.Value);
            condB = strtrim(app.condB_key_EditField.Value);
            tp = app.tp_DropDown.Value;
            if isempty(condA) || isempty(condB)
                uialert(app.UIFigure, '请填写条件A和条件B的关键词', '提示');
                return
            end
            if strcmp(tp, '未检测到时间点')
                uialert(app.UIFigure, '未检测到有效时间点', '提示');
                return
            end

            subDir = fullfile(app.workPath, 'fba', 'subjects');
            d = dir(fullfile(subDir, 'Sub*'));
            if isempty(d)
                d = dir(fullfile(subDir, 'sub*'));
            end

            paired = {};
            for i = 1:length(d)
                name = d(i).name;
                if endsWith(name, [condA '_' tp])
                    idA = name(1:end-length([condA '_' tp])-1);
                    matchB = [idA '_' condB '_' tp];
                    if exist(fullfile(subDir, matchB), 'dir')
                        paired{end+1, 1} = name;
                        paired{end, 2} = matchB;
                        paired{end, 3} = idA;
                    end
                end
            end

            if isempty(paired)
                uialert(app.UIFigure, '未找到配对的被试', '提示');
                return
            end

            subList = {};
            for k = 1:size(paired, 1)
                subList{end+1} = paired{k, 1};
                subList{end+1} = paired{k, 2};
            end

            design = '';
            for k = 1:size(paired, 1)
                design = [design '1 0' newline]; % A condition
                design = [design '1 1' newline]; % B condition
            end
            contrast = '0 1';

            app.design_TextArea.Value = design;
            app.contrast_TextArea.Value = contrast;

            preview = ['配对比较: ' tp newline];
            for k = 1:size(paired, 1)
                preview = [preview paired{k, 1} ' ↔ ' paired{k, 2} newline];
            end
            app.preview_TextArea.Value = preview;
        end

        function genANOVADesign(app)
            subDir = fullfile(app.workPath, 'fba', 'subjects');
            d = dir(fullfile(subDir, 'Sub*'));
            if isempty(d)
                d = dir(fullfile(subDir, 'sub*'));
            end

            parsed = {};
            for i = 1:length(d)
                p = parseSubjectName(d(i).name);
                if ~isempty(p)
                    parsed{end+1} = p;
                end
            end

            if isempty(parsed)
                uialert(app.UIFigure, '无法从文件夹名解析条件/时间点，请确认命名格式为 SubXXX_{条件}_{时间点}', '提示');
                return
            end

            conds = unique(cellfun(@(x) x{2}, parsed, 'UniformOutput', false));
            tps   = unique(cellfun(@(x) x{3}, parsed, 'UniformOutput', false));
            ids   = unique(cellfun(@(x) x{1}, parsed, 'UniformOutput', false));

            if length(conds) < 2
                uialert(app.UIFigure, '检测到的条件数不足2个，无法做ANOVA', '提示');
                return
            end
            if length(tps) < 2
                uialert(app.UIFigure, '检测到的时间点数不足2个，无法做ANOVA', '提示');
                return
            end

            conds = sort(conds);
            tps = sort(tps);
            nCond = length(conds);
            nTp = length(tps);
            nCol = nCond * nTp;

            cellLabels = {};
            for ci = 1:nCond
                for ti = 1:nTp
                    cellLabels{end+1} = [conds{ci} '_' tps{ti}];
                end
            end

            subList = {};
            design = '';
            exchange = {};
            for si = 1:length(ids)
                for ci = 1:nCond
                    for ti = 1:nTp
                        targetName = [ids{si} '_' conds{ci} '_' tps{ti}];
                        if any(cellfun(@(x) strcmp(x{1}, ids{si}) && strcmp(x{2}, conds{ci}) && strcmp(x{3}, tps{ti}), parsed))
                            subList{end+1} = targetName;
                            row = zeros(1, nCol);
                            colIdx = (ci-1)*nTp + ti;
                            row(colIdx) = 1;
                            design = [design sprintf('%d', row(1))];
                            for c = 2:nCol
                                design = [design sprintf(' %d', row(c))];
                            end
                            design = [design newline];
                            exchange{end+1} = num2str(si);
                        end
                    end
                end
            end

            % Contrast for condition main effect
            condContrast = zeros(1, nCol);
            for ci = 1:nCond
                for ti = 1:nTp
                    colIdx = (ci-1)*nTp + ti;
                    condContrast(colIdx) = 1/nTp;
                end
            end
            for ci = 2:nCond
                for ti = 1:nTp
                    colIdx = (ci-1)*nTp + ti;
                    condContrast(colIdx) = -1/nTp;
                end
            end
            condContrast = condContrast / sqrt(sum(condContrast.^2));

            % Contrast for time main effect (F-test)
            timeContrast = {};
            for ti = 2:nTp
                row = zeros(1, nCol);
                for ci = 1:nCond
                    col1 = (ci-1)*nTp + 1;
                    colT = (ci-1)*nTp + ti;
                    row(col1) = 1/nCond;
                    row(colT) = -1/nCond;
                end
                timeContrast{end+1} = row;
            end

            % Contrast for interaction (F-test)
            interactContrast = {};
            for ti = 2:nTp
                row = zeros(1, nCol);
                colA_1 = 1; colA_T = ti;
                colB_1 = nTp + 1; colB_T = nTp + ti;
                row(colA_1) = 1; row(colA_T) = -1;
                row(colB_1) = -1; row(colB_T) = 1;
                interactContrast{end+1} = row;
            end

            app.design_TextArea.Value = design;

            preview = sprintf('条件: %s\n时间: %s\n被试: %d\n', ...
                strjoin(conds, ', '), strjoin(tps, ', '), length(ids));
            preview = [preview sprintf('每位被试 %d 次扫描\n', nCond*nTp)];
            preview = [preview sprintf('总共 %d 行\n', length(subList))];
            app.preview_TextArea.Value = preview;

            % Store parsed info for stat run
            app.anovaData = struct();
            app.anovaData.subList = subList;
            app.anovaData.conds = conds;
            app.anovaData.tps = tps;
            app.anovaData.cellLabels = {cellLabels};
            app.anovaData.condContrast = condContrast;
            app.anovaData.timeContrast = {timeContrast};
            app.anovaData.interactContrast = {interactContrast};
            app.anovaData.exchange = exchange;
            app.anovaData.parsed = {parsed};
            app.anovaData.nCol = nCol;

            % Show the contrast for the first checked effect or cond by default
            if app.chk_cond.Value
                contrastStr = sprintf('%.6f', condContrast(1));
                for c = 2:nCol
                    contrastStr = [contrastStr sprintf(' %.6f', condContrast(c))];
                end
                app.contrast_TextArea.Value = contrastStr;
            elseif app.chk_time.Value
                contrastStr = '';
                for ri = 1:length(timeContrast)
                    row = timeContrast{ri};
                    contrastStr = [contrastStr sprintf('%.6f', row(1))];
                    for c = 2:nCol
                        contrastStr = [contrastStr sprintf(' %.6f', row(c))];
                    end
                    contrastStr = [contrastStr newline];
                end
                app.contrast_TextArea.Value = contrastStr;
            elseif app.chk_interact.Value
                contrastStr = '';
                for ri = 1:length(interactContrast)
                    row = interactContrast{ri};
                    contrastStr = [contrastStr sprintf('%.6f', row(1))];
                    for c = 2:nCol
                        contrastStr = [contrastStr sprintf(' %.6f', row(c))];
                    end
                    contrastStr = [contrastStr newline];
                end
                app.contrast_TextArea.Value = contrastStr;
            end
        end

        function result = parseSubjectName(app, name)
            result = {};
            parts = strsplit(name, '_');
            if length(parts) < 3
                return
            end
            tp = parts{end};
            cond = parts{end-1};
            id = strjoin(parts(1:end-2), '_');
            result = {id, cond, tp};
        end

        function tps = detectTimepoints(workPath)
            tps = {};
            subDir = fullfile(workPath, 'fba', 'subjects');
            if ~isfolder(subDir)
                return
            end
            d = dir(fullfile(subDir, 'Sub*'));
            if isempty(d)
                d = dir(fullfile(subDir, 'sub*'));
            end
            for i = 1:length(d)
                parts = strsplit(d(i).name, '_');
                if length(parts) >= 3
                    tps{end+1} = parts{end};
                end
            end
            tps = unique(tps);
        end

        function writeExchangeFile(app, exchangeList, exchangeFile)
            fid = fopen(exchangeFile, 'w');
            for i = 1:length(exchangeList)
                fprintf(fid, '%s\n', exchangeList{i});
            end
            fclose(fid);
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

            startTime = tic;

            mode = app.designType_DropDown.Value;

            params = struct();
            params.designType = mode;
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
                if strcmp(mode, '独立组间比较')
                    app.progress_Label.Text = '运行独立组间比较...';
                    drawnow;
                    step20_stats(app.workPath, designTxt, contrastTxt, ...
                        nshuffles, cfe_h, cfe_e, cfe_c, metrics);

                elseif strcmp(mode, '配对比较')
                    condA = strtrim(app.condA_key_EditField.Value);
                    condB = strtrim(app.condB_key_EditField.Value);
                    tp = app.tp_DropDown.Value;
                    subDir = fullfile(app.workPath, 'fba', 'subjects');
                    d = dir(fullfile(subDir, 'Sub*'));
                    if isempty(d), d = dir(fullfile(subDir, 'sub*')); end

                    subList = {};
                    exchanges = {};
                    block = 0;
                    for i = 1:length(d)
                        name = d(i).name;
                        if endsWith(name, [condA '_' tp])
                            idA = name(1:end-length([condA '_' tp])-1);
                            matchB = [idA '_' condB '_' tp];
                            if exist(fullfile(subDir, matchB), 'dir')
                                block = block + 1;
                                subList{end+1} = name;
                                subList{end+1} = matchB;
                                exchanges{end+1} = num2str(block);
                                exchanges{end+1} = num2str(block);
                            end
                        end
                    end

                    if isempty(subList)
                        uialert(app.UIFigure, '未找到配对被试', '提示');
                        app.btn_stats.Enable = 'on';
                        return
                    end

                    exchangeFile = fullfile(app.workPath, 'fba', 'template', 'exchangeability.txt');
                    writeExchangeFile(app, exchanges, exchangeFile);
                    app.progress_Label.Text = sprintf('运行配对比较 (%s)...', tp);
                    drawnow;
                    step20_stats(app.workPath, designTxt, contrastTxt, ...
                        nshuffles, cfe_h, cfe_e, cfe_c, metrics, subList, exchangeFile);

                elseif strcmp(mode, '重复测量ANOVA')
                    if isempty(app.anovaData) || ~isfield(app.anovaData, 'subList')
                        uialert(app.UIFigure, '请先生成ANOVA设计矩阵', '提示');
                        app.btn_stats.Enable = 'on';
                        return
                    end
                    ud = app.anovaData;
                    subList = ud.subList;
                    nCol = ud.nCol;

                    exchangeFile = fullfile(app.workPath, 'fba', 'template', 'exchangeability.txt');
                    writeExchangeFile(app, ud.exchange, exchangeFile);

                    effects = {};
                    if app.chk_cond.Value
                        cstr = sprintf('%.6f', ud.condContrast(1));
                        for c = 2:nCol
                            cstr = [cstr sprintf(' %.6f', ud.condContrast(c))];
                        end
                        effects{end+1} = struct('suffix', '_cond', ...
                            'contrast', cstr, ...
                            'label', '条件主效应');
                    end
                    if app.chk_time.Value
                        cstr = '';
                        for ri = 1:length(ud.timeContrast)
                            row = ud.timeContrast{ri};
                            cstr = [cstr sprintf('%.6f', row(1))];
                            for c = 2:nCol
                                cstr = [cstr sprintf(' %.6f', row(c))];
                            end
                            cstr = [cstr newline];
                        end
                        effects{end+1} = struct('suffix', '_time', ...
                            'contrast', cstr, ...
                            'label', '时间主效应');
                    end
                    if app.chk_interact.Value
                        cstr = '';
                        for ri = 1:length(ud.interactContrast)
                            row = ud.interactContrast{ri};
                            cstr = [cstr sprintf('%.6f', row(1))];
                            for c = 2:nCol
                                cstr = [cstr sprintf(' %.6f', row(c))];
                            end
                            cstr = [cstr newline];
                        end
                        effects{end+1} = struct('suffix', '_interact', ...
                            'contrast', cstr, ...
                            'label', '交互效应');
                    end

                    if isempty(effects)
                        uialert(app.UIFigure, '请至少勾选一个要检验的效应', '提示');
                        app.btn_stats.Enable = 'on';
                        return
                    end

                    for ei = 1:length(effects)
                        app.progress_Label.Text = sprintf('运行 %s...', effects{ei}.label);
                        drawnow;
                        step20_stats(app.workPath, designTxt, effects{ei}.contrast, ...
                            nshuffles, cfe_h, cfe_e, cfe_c, metrics, subList, exchangeFile, effects{ei}.suffix);
                    end
                end

                app.progress_Label.Text = 'CFE 统计分析完成';
                elapsedTime = toc(startTime);
                hours = floor(elapsedTime / 3600);
                minutes = floor((elapsedTime - hours * 3600) / 60);
                seconds = mod(elapsedTime, 60);
                msg = sprintf('CFE 统计分析完成！\n结果保存在 fba/template/stats_*\n共耗时：%d小时 %d分钟 %.0f秒', hours, minutes, seconds);
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
            fw = 540; fh = 780;
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [(screen_width-fw)/2 (screen_height-fh)/2 fw fh];
            app.UIFigure.Name = 'FBA - CFE 统计分析';

            % Work path
            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 735 60 22], 'Text', '工作路径');
            app.work_EditField = uieditfield(app.UIFigure, 'text', ...
                'Editable', 'off', 'Position', [80 735 390 22]);
            app.work_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @work_ButtonPushed, true), ...
                'Position', [480 735 35 23], 'Text', '...');

            % Design type
            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 705 60 22], 'Text', '设计类型');
            app.designType_DropDown = uidropdown(app.UIFigure, ...
                'Items', {'独立组间比较', '配对比较', '重复测量ANOVA'}, ...
                'ValueChangedFcn', createCallbackFcn(app, @designType_ValueChanged, true), ...
                'Position', [80 705 150 22]);

            % Main config panel
            pDesign = uipanel(app.UIFigure, 'Title', '设计矩阵与分组', ...
                'Position', [10 380 510 310]);

            % ---- Mode 1: Independent groups ----
            app.mode1_Panel = uipanel(pDesign, 'Title', '', ...
                'BorderType', 'none', 'Position', [0 250 510 60]);
            uilabel(app.mode1_Panel, 'Position', [15 40 70 18], 'Text', '输入组数');
            app.groupNum_DropDown = uidropdown(app.mode1_Panel, ...
                'Items', {'1', '2', '3'}, 'Position', [90 40 60 22]);
            uilabel(app.mode1_Panel, 'Position', [165 40 70 18], 'Text', '统计类型');
            app.statType_DropDown = uidropdown(app.mode1_Panel, ...
                'Items', {'T检验', 'F检验'}, 'Position', [240 40 80 22]);
            uilabel(app.mode1_Panel, 'Position', [15 10 80 18], 'Text', '组1关键词');
            app.g1_key_EditField = uieditfield(app.mode1_Panel, 'text', ...
                'Position', [100 10 80 22], 'Value', 'control');
            uilabel(app.mode1_Panel, 'Position', [195 10 80 18], 'Text', '组2关键词');
            app.g2_key_EditField = uieditfield(app.mode1_Panel, 'text', ...
                'Position', [280 10 80 22], 'Value', 'patient');

            % ---- Mode 2: Paired comparison ----
            app.mode2_Panel = uipanel(pDesign, 'Title', '', ...
                'BorderType', 'none', 'Position', [0 250 510 60], 'Visible', 'off');
            uilabel(app.mode2_Panel, 'Position', [15 40 80 18], 'Text', '条件A关键词');
            app.condA_key_EditField = uieditfield(app.mode2_Panel, 'text', ...
                'Position', [100 40 60 22], 'Value', 'A');
            uilabel(app.mode2_Panel, 'Position', [175 40 80 18], 'Text', '条件B关键词');
            app.condB_key_EditField = uieditfield(app.mode2_Panel, 'text', ...
                'Position', [260 40 60 22], 'Value', 'B');
            uilabel(app.mode2_Panel, 'Position', [15 10 60 18], 'Text', '时间点');
            app.tp_DropDown = uidropdown(app.mode2_Panel, ...
                'Items', {'未检测到时间点'}, 'Position', [80 10 100 22]);

            % ---- Mode 3: Repeated measures ANOVA ----
            app.mode3_Panel = uipanel(pDesign, 'Title', '', ...
                'BorderType', 'none', 'Position', [0 250 510 60], 'Visible', 'off');
            app.chk_cond = uicheckbox(app.mode3_Panel, ...
                'Position', [15 25 100 22], 'Text', '条件主效应', 'Value', true);
            app.chk_time = uicheckbox(app.mode3_Panel, ...
                'Position', [140 25 100 22], 'Text', '时间主效应', 'Value', true);
            app.chk_interact = uicheckbox(app.mode3_Panel, ...
                'Position', [265 25 100 22], 'Text', '交互效应', 'Value', true);
            uilabel(app.mode3_Panel, 'Position', [15 5 380 18], ...
                'Text', '勾选要检验的效应（每个效应分别运行）');

            % Generate button
            app.btn_genDesign = uibutton(pDesign, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_genDesignPushed, true), ...
                'Position', [15 220 150 25], 'Text', '自动生成设计矩阵');

            % Design / Contrast textareas
            uilabel(pDesign, 'Position', [15 200 80 18], 'Text', '设计矩阵');
            app.design_TextArea = uitextarea(pDesign, ...
                'Position', [15 80 230 115]);
            uilabel(pDesign, 'Position', [265 200 80 18], 'Text', '对比矩阵');
            app.contrast_TextArea = uitextarea(pDesign, ...
                'Position', [265 80 230 115]);

            % Preview
            app.preview_TextArea = uitextarea(pDesign, ...
                'Editable', 'off', ...
                'Position', [15 5 480 70]);

            % Metrics panel
            pMetrics = uipanel(app.UIFigure, 'Title', '要检验的指标', ...
                'Position', [10 325 510 50]);
            app.chk_fd = uicheckbox(pMetrics, ...
                'Position', [30 5 60 22], 'Text', 'FD', 'Value', true);
            app.chk_logfc = uicheckbox(pMetrics, ...
                'Position', [120 5 80 22], 'Text', 'log(FC)', 'Value', true);
            app.chk_fdc = uicheckbox(pMetrics, ...
                'Position', [230 5 80 22], 'Text', 'FDC', 'Value', true);

            % CFE parameters panel
            pCfe = uipanel(app.UIFigure, 'Title', 'CFE 参数', ...
                'Position', [10 160 510 120]);
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

            % Action buttons
            app.btn_stats = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_statsPushed, true), ...
                'Position', [160 105 120 30], 'Text', '运行 CFE 统计', ...
                'FontSize', 13);
            app.stats_import_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @stats_import_ButtonPushed, true), ...
                'Position', [285 105 40 30], 'Text', '导入', ...
                'FontSize', 12);
            app.btn_view = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_viewPushed, true), ...
                'Position', [330 105 100 30], 'Text', '查看结果', ...
                'FontSize', 13);
            app.progress_Label = uilabel(app.UIFigure, ...
                'Position', [10 60 510 22], ...
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
