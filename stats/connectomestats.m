classdef connectomestats < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                    matlab.ui.Figure

        conn_algo_ButtonGroup       matlab.ui.container.ButtonGroup
        conn_algo_nbs_Radio         matlab.ui.control.RadioButton
        conn_algo_tfnbs_Radio       matlab.ui.control.RadioButton
        conn_algo_none_Radio        matlab.ui.control.RadioButton

        conn_Panel                  matlab.ui.container.Panel
        conn_design_ButtonGroup     matlab.ui.container.ButtonGroup
        conn_independ_Radio         matlab.ui.control.RadioButton
        conn_paired_Radio           matlab.ui.control.RadioButton
        conn_anova1_Radio           matlab.ui.control.RadioButton
        conn_anova2_Radio           matlab.ui.control.RadioButton

        conn_twoGroup_Panel         matlab.ui.container.Panel
        conn_g1_Label               matlab.ui.control.Label
        conn_g1_EditField           matlab.ui.control.EditField
        conn_g1_Button              matlab.ui.control.Button
        conn_g2_Label               matlab.ui.control.Label
        conn_g2_EditField           matlab.ui.control.EditField
        conn_g2_Button              matlab.ui.control.Button

        conn_anova1_Panel           matlab.ui.container.Panel
        conn_anova1_num_Label       matlab.ui.control.Label
        conn_anova1_num_EditField   matlab.ui.control.NumericEditField
        conn_a1_Label               matlab.ui.control.Label
        conn_a1_EditField           matlab.ui.control.EditField
        conn_a1_Button              matlab.ui.control.Button
        conn_a2_Label               matlab.ui.control.Label
        conn_a2_EditField           matlab.ui.control.EditField
        conn_a2_Button              matlab.ui.control.Button
        conn_a3_Label               matlab.ui.control.Label
        conn_a3_EditField           matlab.ui.control.EditField
        conn_a3_Button              matlab.ui.control.Button
        conn_a4_Label               matlab.ui.control.Label
        conn_a4_EditField           matlab.ui.control.EditField
        conn_a4_Button              matlab.ui.control.Button
        conn_a5_Label               matlab.ui.control.Label
        conn_a5_EditField           matlab.ui.control.EditField
        conn_a5_Button              matlab.ui.control.Button
        conn_a6_Label               matlab.ui.control.Label
        conn_a6_EditField           matlab.ui.control.EditField
        conn_a6_Button              matlab.ui.control.Button
        conn_a7_Label               matlab.ui.control.Label
        conn_a7_EditField           matlab.ui.control.EditField
        conn_a7_Button              matlab.ui.control.Button
        conn_a8_Label               matlab.ui.control.Label
        conn_a8_EditField           matlab.ui.control.EditField
        conn_a8_Button              matlab.ui.control.Button
        conn_a9_Label               matlab.ui.control.Label
        conn_a9_EditField           matlab.ui.control.EditField
        conn_a9_Button              matlab.ui.control.Button
        conn_a10_Label              matlab.ui.control.Label
        conn_a10_EditField          matlab.ui.control.EditField
        conn_a10_Button             matlab.ui.control.Button

        conn_anova2_Panel           matlab.ui.container.Panel
        conn_anova2_fa_Label        matlab.ui.control.Label
        conn_anova2_fa_EditField    matlab.ui.control.NumericEditField
        conn_anova2_fb_Label        matlab.ui.control.Label
        conn_anova2_fb_EditField    matlab.ui.control.NumericEditField
        anova2_cell_labels          cell
        anova2_cell_editfields      cell
        anova2_cell_buttons         cell

        conn_ext_EditField          matlab.ui.control.EditField
        conn_design_TextArea        matlab.ui.control.TextArea
        conn_contrast_TextArea      matlab.ui.control.TextArea
        conn_update_Button          matlab.ui.control.Button
        conn_prefix_EditField       matlab.ui.control.EditField
        conn_nshuffles_EditField    matlab.ui.control.NumericEditField
        conn_tfce_dh_EditField      matlab.ui.control.NumericEditField
        conn_tfce_e_EditField       matlab.ui.control.NumericEditField
        conn_tfce_h_EditField       matlab.ui.control.NumericEditField
        conn_nonstationarity_CheckBox matlab.ui.control.CheckBox
        conn_notest_CheckBox        matlab.ui.control.CheckBox
        conn_threshold_EditField    matlab.ui.control.NumericEditField
        conn_output_EditField       matlab.ui.control.EditField
        conn_output_Button          matlab.ui.control.Button

        start_Button                matlab.ui.control.Button

        fileList        cell
        import_Button    matlab.ui.control.Button
    end

    methods (Access = private)

        function conn_design_ButtonGroupSelectionChanged(app, ~)
            app.conn_twoGroup_Panel.Visible = 'off';
            app.conn_anova1_Panel.Visible = 'off';
            app.conn_anova2_Panel.Visible = 'off';
            if app.conn_independ_Radio.Value || app.conn_paired_Radio.Value
                app.conn_twoGroup_Panel.Visible = 'on';
                if app.conn_independ_Radio.Value
                    app.conn_g1_Label.Text = '组1 (对照)';
                    app.conn_g2_Label.Text = '组2 (实验)';
                else
                    app.conn_g1_Label.Text = '条件A';
                    app.conn_g2_Label.Text = '条件B';
                end
            elseif app.conn_anova1_Radio.Value
                app.conn_anova1_Panel.Visible = 'on';
                conn_anova1_num_EditFieldValueChanged(app);
            elseif app.conn_anova2_Radio.Value
                app.conn_anova2_Panel.Visible = 'on';
                conn_anova2_update_grid(app);
            end
        end

        function conn_g1_ButtonPushed(app, ~)
            p = uigetdir('选择组文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.conn_g1_EditField.Value = p;
        end

        function conn_g2_ButtonPushed(app, ~)
            p = uigetdir('选择组文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.conn_g2_EditField.Value = p;
        end

        function conn_anova1_num_EditFieldValueChanged(app, ~)
            n = round(app.conn_anova1_num_EditField.Value);
            n = max(2, min(10, n));
            app.conn_anova1_num_EditField.Value = n;
            rows = {app.conn_a1_Label, app.conn_a1_EditField, app.conn_a1_Button;
                    app.conn_a2_Label, app.conn_a2_EditField, app.conn_a2_Button;
                    app.conn_a3_Label, app.conn_a3_EditField, app.conn_a3_Button;
                    app.conn_a4_Label, app.conn_a4_EditField, app.conn_a4_Button;
                    app.conn_a5_Label, app.conn_a5_EditField, app.conn_a5_Button;
                    app.conn_a6_Label, app.conn_a6_EditField, app.conn_a6_Button;
                    app.conn_a7_Label, app.conn_a7_EditField, app.conn_a7_Button;
                    app.conn_a8_Label, app.conn_a8_EditField, app.conn_a8_Button;
                    app.conn_a9_Label, app.conn_a9_EditField, app.conn_a9_Button;
                    app.conn_a10_Label, app.conn_a10_EditField, app.conn_a10_Button};
            for i = 1:10
                on = i <= n;
                rows{i,1}.Visible = on; rows{i,2}.Visible = on; rows{i,3}.Visible = on;
            end
        end

        function conn_a1_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a1_EditField.Value = p;
        end
        function conn_a2_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a2_EditField.Value = p;
        end
        function conn_a3_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a3_EditField.Value = p;
        end
        function conn_a4_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a4_EditField.Value = p;
        end
        function conn_a5_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a5_EditField.Value = p;
        end
        function conn_a6_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a6_EditField.Value = p;
        end
        function conn_a7_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a7_EditField.Value = p;
        end
        function conn_a8_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a8_EditField.Value = p;
        end
        function conn_a9_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a9_EditField.Value = p;
        end
        function conn_a10_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.conn_a10_EditField.Value = p;
        end

        function conn_anova2_update_grid(app)
            fa = round(app.conn_anova2_fa_EditField.Value);
            fb = round(app.conn_anova2_fb_EditField.Value);
            fa = max(2, min(4, fa));
            fb = max(2, min(4, fb));
            app.conn_anova2_fa_EditField.Value = fa;
            app.conn_anova2_fb_EditField.Value = fb;
            for ai = 1:4
                for bj = 1:4
                    on = ai <= fa && bj <= fb;
                    app.anova2_cell_labels{ai, bj}.Visible = on;
                    app.anova2_cell_editfields{ai, bj}.Visible = on;
                    app.anova2_cell_buttons{ai, bj}.Visible = on;
                end
            end
        end

        function conn_anova2_fa_EditFieldValueChanged(app, ~)
            conn_anova2_update_grid(app);
        end

        function conn_anova2_fb_EditFieldValueChanged(app, ~)
            conn_anova2_update_grid(app);
        end

        function anova2_cell_ButtonPushed(app, event)
            src = event.Source;
            pos = src.UserData;
            ai = pos(1); bj = pos(2);
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure);
            app.anova2_cell_editfields{ai, bj}.Value = p;
        end

        function conn_output_ButtonPushed(app, ~)
            p = uigetdir('选择输出文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.conn_output_EditField.Value = p;
        end

        function conn_notest_ValueChanged(app, ~)
            isDisabled = app.conn_notest_CheckBox.Value;
            app.conn_nshuffles_EditField.Enable = ~isDisabled;
            app.conn_tfce_dh_EditField.Enable = ~isDisabled;
            app.conn_tfce_e_EditField.Enable = ~isDisabled;
            app.conn_tfce_h_EditField.Enable = ~isDisabled;
            app.conn_nonstationarity_CheckBox.Enable = ~isDisabled;
            app.conn_threshold_EditField.Enable = ~isDisabled;
        end

        function conn_update_ButtonPushed(app, ~)
            ext = strtrim(app.conn_ext_EditField.Value);
            if isempty(ext)
                ext = '.csv';
                app.conn_ext_EditField.Value = ext;
            end
            if ~startsWith(ext, '.')
                ext = ['.' ext];
            end

            groupFolders = {};
            if app.conn_independ_Radio.Value || app.conn_paired_Radio.Value
                g1 = strtrim(app.conn_g1_EditField.Value);
                g2 = strtrim(app.conn_g2_EditField.Value);
                if ~isfolder(g1) || ~isfolder(g2)
                    uialert(app.UIFigure, '请选择有效的组文件夹', '路径错误');
                    return;
                end
                groupFolders = {g1, g2};
            elseif app.conn_anova1_Radio.Value
                n = round(app.conn_anova1_num_EditField.Value);
                editFields = {app.conn_a1_EditField, app.conn_a2_EditField, ...
                    app.conn_a3_EditField, app.conn_a4_EditField, ...
                    app.conn_a5_EditField, app.conn_a6_EditField, ...
                    app.conn_a7_EditField, app.conn_a8_EditField, ...
                    app.conn_a9_EditField, app.conn_a10_EditField};
                for i = 1:n
                    f = strtrim(editFields{i}.Value);
                    if ~isfolder(f)
                        uialert(app.UIFigure, sprintf('组%d 文件夹无效', i), '路径错误');
                        return;
                    end
                    groupFolders{end+1} = f;
                end
            elseif app.conn_anova2_Radio.Value
                fa = round(app.conn_anova2_fa_EditField.Value);
                fb = round(app.conn_anova2_fb_EditField.Value);
                for ai = 1:fa
                    for bj = 1:fb
                        f = strtrim(app.anova2_cell_editfields{ai, bj}.Value);
                        if ~isfolder(f)
                            uialert(app.UIFigure, sprintf('A%dB%d 文件夹无效', ai, bj), '路径错误');
                            return;
                        end
                        groupFolders{end+1} = f;
                    end
                end
            end

            allFiles = {};
            groupSizes = [];
            for i = 1:length(groupFolders)
                d = dir(fullfile(groupFolders{i}, ['*' ext]));
                files = {};
                for j = 1:length(d)
                    files{end+1} = fullfile(groupFolders{i}, d(j).name);
                end
                if isempty(files)
                    uialert(app.UIFigure, sprintf('组%d 文件夹中未找到 *%s 文件', i, ext), '文件缺失');
                    return;
                end
                allFiles = [allFiles; files(:)];
                groupSizes(i) = length(files);
            end

            if app.conn_independ_Radio.Value
                [D, C, ft] = app.stats_design_independent_t(groupSizes);
            elseif app.conn_paired_Radio.Value
                if groupSizes(1) ~= groupSizes(2)
                    uialert(app.UIFigure, '配对T检验要求两组文件数量相同', '数量不匹配');
                    return;
                end
                [D, C, ft] = app.stats_design_paired_t(groupSizes(1));
            elseif app.conn_anova1_Radio.Value
                [D, C, ft] = app.stats_design_anova1(groupSizes);
            elseif app.conn_anova2_Radio.Value
                fa = round(app.conn_anova2_fa_EditField.Value);
                fb = round(app.conn_anova2_fb_EditField.Value);
                [D, C, ft] = app.stats_design_anova2(groupSizes, fa, fb);
            end

            Dstr = '';
            for i = 1:size(D, 1)
                for j = 1:size(D, 2)
                    Dstr = [Dstr sprintf('%g ', D(i, j))];
                end
                Dstr = [Dstr newline];
            end
            app.conn_design_TextArea.Value = Dstr;

            if isempty(C)
                app.conn_contrast_TextArea.Value = '(F-test 模式，无对比矩阵)';
            else
                Cstr = '';
                for i = 1:size(C, 1)
                    for j = 1:size(C, 2)
                        Cstr = [Cstr sprintf('%g ', C(i, j))];
                    end
                    Cstr = [Cstr newline];
                end
                app.conn_contrast_TextArea.Value = Cstr;
            end

            app.fileList = allFiles;
            app.conn_update_Button.Text = sprintf('已更新 (%d人)', length(allFiles));
        end

        function import_ButtonPushed(app, ~)
            [file, path] = uigetfile('*.mat', '选择参数文件');
            if isequal(file, 0), return; end
            data = load_params(fullfile(path, file));
            p = data.params;
            app.conn_design_TextArea.Value = p.designTxt;
            app.conn_contrast_TextArea.Value = p.contrastTxt;
            app.conn_g1_EditField.Value = p.g1;
            app.conn_g2_EditField.Value = p.g2;
            app.conn_ext_EditField.Value = p.ext;
            app.conn_prefix_EditField.Value = p.prefix;
            app.conn_nshuffles_EditField.Value = p.nshuffles;
            app.conn_tfce_dh_EditField.Value = p.tfce_dh;
            app.conn_tfce_e_EditField.Value = p.tfce_e;
            app.conn_tfce_h_EditField.Value = p.tfce_h;
            app.conn_nonstationarity_CheckBox.Value = p.nonstationarity;
            app.conn_notest_CheckBox.Value = p.notest;
            app.conn_threshold_EditField.Value = p.threshold;
            app.conn_output_EditField.Value = p.outDir;
            app.conn_independ_Radio.Value = strcmp(p.design, 'independ');
            app.conn_paired_Radio.Value = strcmp(p.design, 'paired');
            app.conn_anova1_Radio.Value = strcmp(p.design, 'anova1');
            app.conn_anova2_Radio.Value = strcmp(p.design, 'anova2');
            app.conn_algo_nbs_Radio.Value = strcmp(p.algo, 'nbs');
            app.conn_algo_tfnbs_Radio.Value = strcmp(p.algo, 'tfnbs');
            app.conn_algo_none_Radio.Value = strcmp(p.algo, 'none');
            if isfield(p, 'fileList')
                app.fileList = p.fileList;
            end
            if isfield(p, 'conn_anova1_num')
                app.conn_anova1_num_EditField.Value = p.conn_anova1_num;
                conn_anova1_num_EditFieldValueChanged(app);
                for ci = 1:p.conn_anova1_num
                    fld = sprintf('conn_a%d', ci);
                    if isfield(p, fld)
                        ef = sprintf('conn_a%d_EditField', ci);
                        app.(ef).Value = p.(fld);
                    end
                end
            end
            if isfield(p, 'conn_anova2_fa')
                app.conn_anova2_fa_EditField.Value = p.conn_anova2_fa;
                app.conn_anova2_fb_EditField.Value = p.conn_anova2_fb;
                conn_anova2_update_grid(app);
                if isfield(p, 'anova2_cell_values') && ~isempty(p.anova2_cell_values)
                    for ai = 1:size(p.anova2_cell_values, 1)
                        for bj = 1:size(p.anova2_cell_values, 2)
                            if ~isempty(p.anova2_cell_values{ai, bj})
                                app.anova2_cell_editfields{ai, bj}.Value = p.anova2_cell_values{ai, bj};
                            end
                        end
                    end
                end
            end
        end

        function start_ButtonPushed(app, ~)
            params = struct();
            params.designTxt = app.conn_design_TextArea.Value;
            params.contrastTxt = app.conn_contrast_TextArea.Value;
            params.g1 = app.conn_g1_EditField.Value;
            params.g2 = app.conn_g2_EditField.Value;
            params.ext = app.conn_ext_EditField.Value;
            params.prefix = app.conn_prefix_EditField.Value;
            params.nshuffles = app.conn_nshuffles_EditField.Value;
            params.tfce_dh = app.conn_tfce_dh_EditField.Value;
            params.tfce_e = app.conn_tfce_e_EditField.Value;
            params.tfce_h = app.conn_tfce_h_EditField.Value;
            params.nonstationarity = app.conn_nonstationarity_CheckBox.Value;
            params.notest = app.conn_notest_CheckBox.Value;
            params.threshold = app.conn_threshold_EditField.Value;
            params.outDir = app.conn_output_EditField.Value;
            params.design = 'independ';
            if app.conn_paired_Radio.Value, params.design = 'paired'; end
            if app.conn_anova1_Radio.Value, params.design = 'anova1'; end
            if app.conn_anova2_Radio.Value, params.design = 'anova2'; end
            params.algo = 'tfnbs';
            if app.conn_algo_nbs_Radio.Value, params.algo = 'nbs'; end
            if app.conn_algo_none_Radio.Value, params.algo = 'none'; end
            params.fileList = app.fileList;
            params.conn_anova1_num = app.conn_anova1_num_EditField.Value;
            for ci = 1:10
                fld = sprintf('conn_a%d', ci);
                ef  = sprintf('conn_a%d_EditField', ci);
                params.(fld) = app.(ef).Value;
            end
            params.conn_anova2_fa = app.conn_anova2_fa_EditField.Value;
            params.conn_anova2_fb = app.conn_anova2_fb_EditField.Value;
            if ~isempty(app.anova2_cell_editfields)
                [nr, nc] = size(app.anova2_cell_editfields);
                params.anova2_cell_values = cell(nr, nc);
                for ai = 1:nr
                    for bj = 1:nc
                        params.anova2_cell_values{ai, bj} = app.anova2_cell_editfields{ai, bj}.Value;
                    end
                end
            end
            save_params('stats', 'connectomestats', app.conn_output_EditField.Value, params);
            conn_run(app);
        end

        function conn_run(app)
            outDir = strtrim(app.conn_output_EditField.Value);
            if isempty(outDir) || ~isfolder(outDir)
                uialert(app.UIFigure, '请先选择输出文件夹', '输出文件夹缺失');
                return;
            end
            prefix = strtrim(app.conn_prefix_EditField.Value);
            if isempty(prefix)
                uialert(app.UIFigure, '请输入输出前缀', '前缀缺失');
                return;
            end
            if isempty(app.fileList)
                uialert(app.UIFigure, '请先更新文件列表和设计矩阵', '文件列表为空');
                return;
            end

            algorithm = '';
            if app.conn_algo_nbs_Radio.Value
                algorithm = 'nbs';
            elseif app.conn_algo_tfnbs_Radio.Value
                algorithm = 'tfnbs';
            else
                algorithm = 'none';
            end

            inputListFile = fullfile(outDir, [prefix '_inputlist.txt']);
            fid = fopen(inputListFile, 'w');
            for i = 1:length(app.fileList)
                rel = app.makeRelativePath(app.fileList{i}, outDir);
                fprintf(fid, '%s\n', rel);
            end
            fclose(fid);

            ext = strtrim(app.conn_ext_EditField.Value);
            if isempty(ext), ext = '.csv'; end
            if ~startsWith(ext, '.'), ext = ['.' ext]; end

            groupFolders = {};
            if app.conn_independ_Radio.Value || app.conn_paired_Radio.Value
                groupFolders = {strtrim(app.conn_g1_EditField.Value), ...
                                strtrim(app.conn_g2_EditField.Value)};
            elseif app.conn_anova1_Radio.Value
                n = round(app.conn_anova1_num_EditField.Value);
                editFields = {app.conn_a1_EditField, app.conn_a2_EditField, ...
                    app.conn_a3_EditField, app.conn_a4_EditField, ...
                    app.conn_a5_EditField, app.conn_a6_EditField, ...
                    app.conn_a7_EditField, app.conn_a8_EditField, ...
                    app.conn_a9_EditField, app.conn_a10_EditField};
                for i = 1:n
                    groupFolders{end+1} = strtrim(editFields{i}.Value);
                end
            elseif app.conn_anova2_Radio.Value
                fa = round(app.conn_anova2_fa_EditField.Value);
                fb = round(app.conn_anova2_fb_EditField.Value);
                for ai = 1:fa
                    for bj = 1:fb
                        groupFolders{end+1} = strtrim(app.anova2_cell_editfields{ai, bj}.Value);
                    end
                end
            end

            groupSizes = [];
            for g = 1:length(groupFolders)
                d = dir(fullfile(groupFolders{g}, ['*' ext]));
                groupSizes(g) = length(d);
            end

            if app.conn_independ_Radio.Value
                [D, C, ft] = app.stats_design_independent_t(groupSizes);
            elseif app.conn_paired_Radio.Value
                [D, C, ft] = app.stats_design_paired_t(groupSizes(1));
            elseif app.conn_anova1_Radio.Value
                [D, C, ft] = app.stats_design_anova1(groupSizes);
            elseif app.conn_anova2_Radio.Value
                fa = round(app.conn_anova2_fa_EditField.Value);
                fb = round(app.conn_anova2_fb_EditField.Value);
                [D, C, ft] = app.stats_design_anova2(groupSizes, fa, fb);
            end

            designFile = fullfile(outDir, [prefix '_design.txt']);
            fid = fopen(designFile, 'w');
            for i = 1:size(D, 1)
                fprintf(fid, '%g', D(i, 1));
                for j = 2:size(D, 2)
                    fprintf(fid, ' %g', D(i, j));
                end
                fprintf(fid, '\n');
            end
            fclose(fid);

            if ~isempty(C)
                contrastFile = fullfile(outDir, [prefix '_contrast.txt']);
                fid = fopen(contrastFile, 'w');
                for i = 1:size(C, 1)
                    fprintf(fid, '%g', C(i, 1));
                    for j = 2:size(C, 2)
                        fprintf(fid, ' %g', C(i, j));
                    end
                    fprintf(fid, '\n');
                end
                fclose(fid);
            end

            if ~isempty(ft)
                ftestFile = fullfile(outDir, [prefix '_ftests.txt']);
                fid = fopen(ftestFile, 'w');
                for i = 1:size(ft, 1)
                    fprintf(fid, '%d', ft(i, 1));
                    for j = 2:size(ft, 2)
                        fprintf(fid, ' %d', ft(i, j));
                    end
                    fprintf(fid, '\n');
                end
                fclose(fid);
            end

            nshuffles = round(app.conn_nshuffles_EditField.Value);
            dh = app.conn_tfce_dh_EditField.Value;
            e  = app.conn_tfce_e_EditField.Value;
            h  = app.conn_tfce_h_EditField.Value;
            threshold = app.conn_threshold_EditField.Value;

            cmd = sprintf('connectomestats "%s" %s "%s"', inputListFile, algorithm, designFile);
            if ~isempty(C)
                cmd = [cmd sprintf(' "%s"', contrastFile)];
            end
            cmd = [cmd sprintf(' "%s"', fullfile(outDir, prefix))];
            if ~isempty(ft)
                cmd = [cmd sprintf(' -ftests "%s"', ftestFile)];
            end
            if app.conn_notest_CheckBox.Value
                cmd = [cmd ' -notest'];
            else
                cmd = [cmd sprintf(' -nshuffles %d', nshuffles)];
                if strcmp(algorithm, 'nbs') || strcmp(algorithm, 'none')
                    if threshold > 0
                        cmd = [cmd sprintf(' -threshold %g', threshold)];
                    end
                else
                    cmd = [cmd sprintf(' -tfce_dh %g -tfce_e %g -tfce_h %g', dh, e, h)];
                    if app.conn_nonstationarity_CheckBox.Value
                        cmd = [cmd ' -nonstationarity'];
                    end
                end
            end
            cmd = [cmd ' -force'];

            app.start_Button.Enable = 'off';
            startTime = tic;

            fprintf('\n========== connectomestats ==========\n');
            fprintf('算法: %s\n', algorithm);
            fprintf('设计: %s ', designFile);
            if ~isempty(C), fprintf('对比: %s ', contrastFile); end
            if ~isempty(ft), fprintf('F-test: %s ', ftestFile); end
            fprintf('\n');
            fprintf('命令: %s\n', cmd);
            fprintf('=====================================\n\n');

            [status, result] = system(cmd);
            fprintf('%s\n', result);

            elapsed = toc(startTime);
            app.start_Button.Enable = 'on';

            if status == 0
                fprintf('\n========== connectomestats 完成! ==========\n');
                fprintf('输出文件前缀: %s\n', fullfile(outDir, prefix));
                fprintf('耗时: %.1f 秒\n', elapsed);
                uialert(app.UIFigure, sprintf('connectomestats 完成\n耗时: %.1f 秒\n输出: %s', ...
                    elapsed, fullfile(outDir, prefix)), '完成');
            else
                uialert(app.UIFigure, ['connectomestats 运行失败: ' result], '错误');
            end
        end
    end

    methods (Access = private, Static)
        function [D, C, ft] = stats_design_independent_t(groupSizes)
            n1 = groupSizes(1); n2 = groupSizes(2);
            N = n1 + n2;
            D = zeros(N, 2);
            D(1:n1, 1) = 1;
            D(n1+1:end, 2) = 1;
            C = [1, -1];
            ft = [];
        end

        function [D, C, ft] = stats_design_paired_t(n)
            N = 2 * n;
            ncols = n + 1;
            D = zeros(N, ncols);
            D(1:n, 1) = 1;
            D(n+1:end, 1) = -1;
            for i = 1:n
                D(i, 1+i) = 1;
                D(n+i, 1+i) = 1;
            end
            C = zeros(1, ncols);
            C(1) = 1;
            ft = [];
        end

        function [D, C, ft] = stats_design_anova1(groupSizes)
            k = length(groupSizes);
            N = sum(groupSizes);
            D = zeros(N, k);
            idx = 1;
            for g = 1:k
                for i = 1:groupSizes(g)
                    D(idx, g) = 1;
                    idx = idx + 1;
                end
            end
            C = zeros(k-1, k);
            for i = 1:k-1
                C(i, i) = 1;
                C(i, i+1) = -1;
            end
            ft = ones(1, k-1);
        end

        function [D, C, ft] = stats_design_anova2(groupSizes, a, b)
            nCells = a * b;
            N = sum(groupSizes(1:nCells));
            D = zeros(N, nCells);
            idx = 1;
            for c = 1:nCells
                for i = 1:groupSizes(c)
                    D(idx, c) = 1;
                    idx = idx + 1;
                end
            end
            nContrasts = (a-1) + (b-1) + (a-1)*(b-1);
            C = zeros(nContrasts, nCells);
            row = 0;
            for ai = 1:a-1
                row = row + 1;
                for bj = 1:b
                    cellIdx = (ai-1)*b + bj;
                    C(row, cellIdx) = 1;
                    cellIdx2 = (a-1)*b + bj;
                    C(row, cellIdx2) = -1;
                end
            end
            for bj = 1:b-1
                row = row + 1;
                for ai = 1:a
                    cellIdx = (ai-1)*b + bj;
                    C(row, cellIdx) = 1;
                    cellIdx2 = (ai-1)*b + b;
                    C(row, cellIdx2) = -1;
                end
            end
            for ai = 1:a-1
                for bj = 1:b-1
                    row = row + 1;
                    c1 = (ai-1)*b + bj;
                    c2 = (ai-1)*b + b;
                    c3 = (a-1)*b + bj;
                    c4 = a*b;
                    C(row, c1) = 1;
                    C(row, c2) = -1;
                    C(row, c3) = -1;
                    C(row, c4) = 1;
                end
            end
            nA = a - 1;
            nB = b - 1;
            nAB = nA * nB;
            ft = [ones(1, nA), zeros(1, nB), zeros(1, nAB);
                  zeros(1, nA), ones(1, nB), zeros(1, nAB);
                   zeros(1, nA), zeros(1, nB), ones(1, nAB)];
        end

        function relPath = makeRelativePath(absPath, refDir)
            absParts = strsplit(absPath, filesep);
            refParts = strsplit(refDir, filesep);
            commonLen = 0;
            for i = 1:min(length(absParts), length(refParts))
                if strcmp(absParts{i}, refParts{i})
                    commonLen = i;
                else
                    break;
                end
            end
            up = repmat({'..'}, 1, length(refParts) - commonLen);
            down = absParts(commonLen+1:end);
            relPath = strjoin([up, down], filesep);
        end
    end

    methods (Access = private)

        function createComponents(app)

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100, 100, 700, 660];
            app.UIFigure.Name = 'connectomestats 网络统计';
            screenSize = get(0, 'ScreenSize');
            app.UIFigure.Position(1) = (screenSize(3) - 700) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - 660) / 2;

            titleLabel = uilabel(app.UIFigure);
            titleLabel.Position = [0, 620, 700, 36];
            titleLabel.HorizontalAlignment = 'center';
            titleLabel.FontSize = 20;
            titleLabel.FontWeight = 'bold';
            titleLabel.Text = 'connectomestats 网络统计';

            app.conn_Panel = uipanel(app.UIFigure);
            app.conn_Panel.Position = [10, 30, 680, 545];
            app.conn_Panel.Title = '';

            % 算法选择
            uilabel(app.conn_Panel, 'Position', [15, 510, 60, 22], 'Text', '算法');
            app.conn_algo_ButtonGroup = uibuttongroup(app.conn_Panel);
            app.conn_algo_ButtonGroup.Position = [80, 509, 500, 26];
            app.conn_algo_nbs_Radio = uiradiobutton(app.conn_algo_ButtonGroup);
            app.conn_algo_nbs_Radio.Position = [10, 3, 80, 22];
            app.conn_algo_nbs_Radio.Text = 'NBS';
            app.conn_algo_tfnbs_Radio = uiradiobutton(app.conn_algo_ButtonGroup);
            app.conn_algo_tfnbs_Radio.Position = [100, 3, 100, 22];
            app.conn_algo_tfnbs_Radio.Text = 'TFNBS';
            app.conn_algo_tfnbs_Radio.Value = true;
            app.conn_algo_none_Radio = uiradiobutton(app.conn_algo_ButtonGroup);
            app.conn_algo_none_Radio.Position = [210, 3, 100, 22];
            app.conn_algo_none_Radio.Text = '无增强';

            % 统计设计
            uilabel(app.conn_Panel, 'Position', [15, 482, 60, 22], 'Text', '统计设计');
            app.conn_design_ButtonGroup = uibuttongroup(app.conn_Panel);
            app.conn_design_ButtonGroup.Position = [80, 481, 500, 26];
            app.conn_design_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @conn_design_ButtonGroupSelectionChanged);
            app.conn_independ_Radio = uiradiobutton(app.conn_design_ButtonGroup);
            app.conn_independ_Radio.Position = [10, 3, 110, 22];
            app.conn_independ_Radio.Text = '独立T检验';
            app.conn_independ_Radio.Value = true;
            app.conn_paired_Radio = uiradiobutton(app.conn_design_ButtonGroup);
            app.conn_paired_Radio.Position = [125, 3, 90, 22];
            app.conn_paired_Radio.Text = '配对T检验';
            app.conn_anova1_Radio = uiradiobutton(app.conn_design_ButtonGroup);
            app.conn_anova1_Radio.Position = [220, 3, 120, 22];
            app.conn_anova1_Radio.Text = '单因素方差分析';
            app.conn_anova2_Radio = uiradiobutton(app.conn_design_ButtonGroup);
            app.conn_anova2_Radio.Position = [345, 3, 120, 22];
            app.conn_anova2_Radio.Text = '双因素方差分析';

            % Two-group panel
            app.conn_twoGroup_Panel = uipanel(app.conn_Panel);
            app.conn_twoGroup_Panel.Position = [15, 347, 650, 130];
            app.conn_twoGroup_Panel.Title = '';

            app.conn_g1_Label = uilabel(app.conn_twoGroup_Panel);
            app.conn_g1_Label.Position = [15, 95, 80, 22];
            app.conn_g1_Label.Text = '组1 (对照)';
            app.conn_g1_EditField = uieditfield(app.conn_twoGroup_Panel, 'text');
            app.conn_g1_EditField.Position = [100, 95, 440, 22];
            app.conn_g1_EditField.Editable = 'off';
            app.conn_g1_Button = uibutton(app.conn_twoGroup_Panel, 'push');
            app.conn_g1_Button.Position = [545, 95, 35, 22];
            app.conn_g1_Button.Text = '...';
            app.conn_g1_Button.ButtonPushedFcn = createCallbackFcn(app, @conn_g1_ButtonPushed);

            app.conn_g2_Label = uilabel(app.conn_twoGroup_Panel);
            app.conn_g2_Label.Position = [15, 65, 80, 22];
            app.conn_g2_Label.Text = '组2 (实验)';
            app.conn_g2_EditField = uieditfield(app.conn_twoGroup_Panel, 'text');
            app.conn_g2_EditField.Position = [100, 65, 440, 22];
            app.conn_g2_EditField.Editable = 'off';
            app.conn_g2_Button = uibutton(app.conn_twoGroup_Panel, 'push');
            app.conn_g2_Button.Position = [545, 65, 35, 22];
            app.conn_g2_Button.Text = '...';
            app.conn_g2_Button.ButtonPushedFcn = createCallbackFcn(app, @conn_g2_ButtonPushed);

            uilabel(app.conn_twoGroup_Panel, 'Position', [15, 30, 360, 22], ...
                'Text', '每组文件夹内需包含被试的 connectome .csv 矩阵文件', 'FontSize', 11);

            % One-way ANOVA panel
            app.conn_anova1_Panel = uipanel(app.conn_Panel);
            app.conn_anova1_Panel.Position = [15, 302, 650, 175];
            app.conn_anova1_Panel.Title = '';
            app.conn_anova1_Panel.Visible = 'off';
            app.conn_anova1_Panel.Scrollable = 'on';

            app.conn_anova1_num_Label = uilabel(app.conn_anova1_Panel);
            app.conn_anova1_num_Label.Position = [15, 295, 80, 22];
            app.conn_anova1_num_Label.Text = '组数';
            app.conn_anova1_num_EditField = uieditfield(app.conn_anova1_Panel, 'numeric');
            app.conn_anova1_num_EditField.Position = [100, 295, 50, 22];
            app.conn_anova1_num_EditField.Value = 3;
            app.conn_anova1_num_EditField.Limits = [2 10];
            app.conn_anova1_num_EditField.ValueChangedFcn = createCallbackFcn(app, @conn_anova1_num_EditFieldValueChanged);

            aY = @(i) 265 - (i-1)*28;
            for gi = 1:10
                lbl = uilabel(app.conn_anova1_Panel);
                lbl.Position = [15, aY(gi), 40, 22]; lbl.Text = sprintf('组%d', gi);
                ef = uieditfield(app.conn_anova1_Panel, 'text');
                ef.Position = [60, aY(gi), 480, 22]; ef.Editable = 'off';
                btn = uibutton(app.conn_anova1_Panel, 'push');
                btn.Position = [545, aY(gi), 35, 22]; btn.Text = '...';
                switch gi
                    case 1, app.conn_a1_Label = lbl; app.conn_a1_EditField = ef; app.conn_a1_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a1_ButtonPushed);
                    case 2, app.conn_a2_Label = lbl; app.conn_a2_EditField = ef; app.conn_a2_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a2_ButtonPushed);
                    case 3, app.conn_a3_Label = lbl; app.conn_a3_EditField = ef; app.conn_a3_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a3_ButtonPushed);
                    case 4, app.conn_a4_Label = lbl; app.conn_a4_EditField = ef; app.conn_a4_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a4_ButtonPushed);
                    case 5, app.conn_a5_Label = lbl; app.conn_a5_EditField = ef; app.conn_a5_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a5_ButtonPushed);
                    case 6, app.conn_a6_Label = lbl; app.conn_a6_EditField = ef; app.conn_a6_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a6_ButtonPushed);
                    case 7, app.conn_a7_Label = lbl; app.conn_a7_EditField = ef; app.conn_a7_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a7_ButtonPushed);
                    case 8, app.conn_a8_Label = lbl; app.conn_a8_EditField = ef; app.conn_a8_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a8_ButtonPushed);
                    case 9, app.conn_a9_Label = lbl; app.conn_a9_EditField = ef; app.conn_a9_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a9_ButtonPushed);
                    case 10, app.conn_a10_Label = lbl; app.conn_a10_EditField = ef; app.conn_a10_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @conn_a10_ButtonPushed);
                end
            end

            for gi = 4:10
                rows = {app.conn_a4_Label, app.conn_a4_EditField, app.conn_a4_Button;
                        app.conn_a5_Label, app.conn_a5_EditField, app.conn_a5_Button;
                        app.conn_a6_Label, app.conn_a6_EditField, app.conn_a6_Button;
                        app.conn_a7_Label, app.conn_a7_EditField, app.conn_a7_Button;
                        app.conn_a8_Label, app.conn_a8_EditField, app.conn_a8_Button;
                        app.conn_a9_Label, app.conn_a9_EditField, app.conn_a9_Button;
                        app.conn_a10_Label, app.conn_a10_EditField, app.conn_a10_Button};
                rows{gi-3,1}.Visible = 'off'; rows{gi-3,2}.Visible = 'off'; rows{gi-3,3}.Visible = 'off';
            end

            % Two-way ANOVA panel
            app.conn_anova2_Panel = uipanel(app.conn_Panel);
            app.conn_anova2_Panel.Position = [15, 302, 650, 175];
            app.conn_anova2_Panel.Title = '';
            app.conn_anova2_Panel.Visible = 'off';
            app.conn_anova2_Panel.Scrollable = 'on';

            app.conn_anova2_fa_Label = uilabel(app.conn_anova2_Panel);
            app.conn_anova2_fa_Label.Position = [15, 500, 100, 22]; app.conn_anova2_fa_Label.Text = '因素A水平数';
            app.conn_anova2_fa_EditField = uieditfield(app.conn_anova2_Panel, 'numeric');
            app.conn_anova2_fa_EditField.Position = [120, 500, 50, 22]; app.conn_anova2_fa_EditField.Value = 2;
            app.conn_anova2_fa_EditField.Limits = [2 4];
            app.conn_anova2_fa_EditField.ValueChangedFcn = createCallbackFcn(app, @conn_anova2_fa_EditFieldValueChanged);
            app.conn_anova2_fb_Label = uilabel(app.conn_anova2_Panel);
            app.conn_anova2_fb_Label.Position = [190, 500, 100, 22]; app.conn_anova2_fb_Label.Text = '因素B水平数';
            app.conn_anova2_fb_EditField = uieditfield(app.conn_anova2_Panel, 'numeric');
            app.conn_anova2_fb_EditField.Position = [295, 500, 50, 22]; app.conn_anova2_fb_EditField.Value = 2;
            app.conn_anova2_fb_EditField.Limits = [2 4];
            app.conn_anova2_fb_EditField.ValueChangedFcn = createCallbackFcn(app, @conn_anova2_fb_EditFieldValueChanged);

            app.anova2_cell_labels = cell(4, 4);
            app.anova2_cell_editfields = cell(4, 4);
            app.anova2_cell_buttons = cell(4, 4);
            for ai = 1:4
                for bj = 1:4
                    cy = 50 + (4-ai)*4*28 + (4-bj)*28;
                    lbl = uilabel(app.conn_anova2_Panel);
                    lbl.Position = [15, cy, 40, 22];
                    lbl.Text = sprintf('A%dB%d', ai, bj);
                    ef = uieditfield(app.conn_anova2_Panel, 'text');
                    ef.Position = [60, cy, 480, 22]; ef.Editable = 'off';
                    btn = uibutton(app.conn_anova2_Panel, 'push');
                    btn.Position = [545, cy, 35, 22]; btn.Text = '...';
                    btn.UserData = [ai, bj];
                    btn.ButtonPushedFcn = createCallbackFcn(app, @anova2_cell_ButtonPushed);
                    app.anova2_cell_labels{ai, bj} = lbl;
                    app.anova2_cell_editfields{ai, bj} = ef;
                    app.anova2_cell_buttons{ai, bj} = btn;
                end
            end

            % 文件扩展名
            uilabel(app.conn_Panel, 'Position', [15, 278, 80, 22], 'Text', '文件扩展名');
            app.conn_ext_EditField = uieditfield(app.conn_Panel, 'text');
            app.conn_ext_EditField.Position = [100, 278, 60, 22];
            app.conn_ext_EditField.Value = '.csv';

            % 设计矩阵 / 对比矩阵
            uilabel(app.conn_Panel, 'Position', [15, 254, 65, 22], ...
                'HorizontalAlignment', 'right', 'Text', '设计矩阵');
            app.conn_design_TextArea = uitextarea(app.conn_Panel);
            app.conn_design_TextArea.Position = [15, 197, 320, 55];
            app.conn_design_TextArea.Editable = 'off';
            app.conn_design_TextArea.Value = '请点击"更新矩阵"';

            uilabel(app.conn_Panel, 'Position', [345, 254, 65, 22], ...
                'HorizontalAlignment', 'right', 'Text', '对比矩阵');
            app.conn_contrast_TextArea = uitextarea(app.conn_Panel);
            app.conn_contrast_TextArea.Position = [345, 197, 310, 55];
            app.conn_contrast_TextArea.Editable = 'off';
            app.conn_contrast_TextArea.Value = '请点击"更新矩阵"';

            app.conn_update_Button = uibutton(app.conn_Panel, 'push');
            app.conn_update_Button.Position = [15, 167, 100, 22];
            app.conn_update_Button.Text = '更新矩阵';
            app.conn_update_Button.ButtonPushedFcn = createCallbackFcn(app, @conn_update_ButtonPushed);

            % 输出前缀
            uilabel(app.conn_Panel, 'Position', [125, 167, 70, 22], 'Text', '输出前缀');
            app.conn_prefix_EditField = uieditfield(app.conn_Panel, 'text');
            app.conn_prefix_EditField.Position = [195, 167, 80, 22];
            app.conn_prefix_EditField.Value = 'result';

            % 参数
            uilabel(app.conn_Panel, 'Position', [15, 144, 70, 22], 'Text', '置换次数');
            app.conn_nshuffles_EditField = uieditfield(app.conn_Panel, 'numeric');
            app.conn_nshuffles_EditField.Position = [90, 144, 60, 22];
            app.conn_nshuffles_EditField.Value = 5000;

            uilabel(app.conn_Panel, 'Position', [165, 144, 70, 22], 'Text', '高度步长');
            app.conn_tfce_dh_EditField = uieditfield(app.conn_Panel, 'numeric');
            app.conn_tfce_dh_EditField.Position = [240, 144, 55, 22];
            app.conn_tfce_dh_EditField.Value = 0.1;
            uilabel(app.conn_Panel, 'Position', [305, 144, 70, 22], 'Text', '范围指数');
            app.conn_tfce_e_EditField = uieditfield(app.conn_Panel, 'numeric');
            app.conn_tfce_e_EditField.Position = [380, 144, 55, 22];
            app.conn_tfce_e_EditField.Value = 0.4;
            uilabel(app.conn_Panel, 'Position', [445, 144, 70, 22], 'Text', '高度指数');
            app.conn_tfce_h_EditField = uieditfield(app.conn_Panel, 'numeric');
            app.conn_tfce_h_EditField.Position = [520, 144, 55, 22];
            app.conn_tfce_h_EditField.Value = 3;

            app.conn_nonstationarity_CheckBox = uicheckbox(app.conn_Panel);
            app.conn_nonstationarity_CheckBox.Position = [15, 114, 130, 22];
            app.conn_nonstationarity_CheckBox.Text = '非平稳性校正';
            app.conn_notest_CheckBox = uicheckbox(app.conn_Panel);
            app.conn_notest_CheckBox.Position = [155, 114, 100, 22];
            app.conn_notest_CheckBox.Text = '不执行检验';
            app.conn_notest_CheckBox.ValueChangedFcn = createCallbackFcn(app, @conn_notest_ValueChanged);

            uilabel(app.conn_Panel, 'Position', [580, 144, 55, 22], ...
                'HorizontalAlignment', 'right', 'Text', 'NBS阈值');
            app.conn_threshold_EditField = uieditfield(app.conn_Panel, 'numeric');
            app.conn_threshold_EditField.Position = [640, 144, 35, 22];
            app.conn_threshold_EditField.Value = 3;

            % 输出文件夹
            uilabel(app.conn_Panel, 'Position', [15, 84, 80, 22], ...
                'HorizontalAlignment', 'right', 'Text', '输出文件夹');
            app.conn_output_EditField = uieditfield(app.conn_Panel, 'text');
            app.conn_output_EditField.Position = [100, 84, 470, 22];
            app.conn_output_EditField.Editable = 'off';
            app.conn_output_Button = uibutton(app.conn_Panel, 'push');
            app.conn_output_Button.Position = [575, 84, 35, 22];
            app.conn_output_Button.Text = '...';
            app.conn_output_Button.ButtonPushedFcn = createCallbackFcn(app, @conn_output_ButtonPushed);

            app.start_Button = uibutton(app.UIFigure, 'push');
            app.start_Button.Position = [290, 10, 120, 30];
            app.start_Button.Text = '开始处理';
            app.start_Button.FontSize = 14;
            app.start_Button.FontWeight = 'bold';
            app.start_Button.ButtonPushedFcn = createCallbackFcn(app, @start_ButtonPushed);

            app.import_Button = uibutton(app.UIFigure, 'push');
            app.import_Button.Position = [415, 10, 50, 30];
            app.import_Button.Text = '导入';
            app.import_Button.FontSize = 12;
            app.import_Button.ButtonPushedFcn = createCallbackFcn(app, @import_ButtonPushed);

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = connectomestats
            createComponents(app);
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure);
        end
    end
end
