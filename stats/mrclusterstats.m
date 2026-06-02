classdef mrclusterstats < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                    matlab.ui.Figure

        mrcluster_Panel             matlab.ui.container.Panel
        mrcluster_design_ButtonGroup    matlab.ui.container.ButtonGroup
        mrcluster_independ_Radio    matlab.ui.control.RadioButton
        mrcluster_paired_Radio      matlab.ui.control.RadioButton
        mrcluster_anova1_Radio      matlab.ui.control.RadioButton
        mrcluster_anova2_Radio      matlab.ui.control.RadioButton

        mrcluster_twoGroup_Panel           matlab.ui.container.Panel
        mrcluster_g1_Label                 matlab.ui.control.Label
        mrcluster_g1_EditField             matlab.ui.control.EditField
        mrcluster_g1_Button                matlab.ui.control.Button
        mrcluster_g2_Label                 matlab.ui.control.Label
        mrcluster_g2_EditField             matlab.ui.control.EditField
        mrcluster_g2_Button                matlab.ui.control.Button

        mrcluster_anova1_Panel             matlab.ui.container.Panel
        mrcluster_anova1_num_Label         matlab.ui.control.Label
        mrcluster_anova1_num_EditField     matlab.ui.control.NumericEditField
        mrcluster_a1_Label                 matlab.ui.control.Label
        mrcluster_a1_EditField             matlab.ui.control.EditField
        mrcluster_a1_Button                matlab.ui.control.Button
        mrcluster_a2_Label                 matlab.ui.control.Label
        mrcluster_a2_EditField             matlab.ui.control.EditField
        mrcluster_a2_Button                matlab.ui.control.Button
        mrcluster_a3_Label                 matlab.ui.control.Label
        mrcluster_a3_EditField             matlab.ui.control.EditField
        mrcluster_a3_Button                matlab.ui.control.Button
        mrcluster_a4_Label                 matlab.ui.control.Label
        mrcluster_a4_EditField             matlab.ui.control.EditField
        mrcluster_a4_Button                matlab.ui.control.Button
        mrcluster_a5_Label                 matlab.ui.control.Label
        mrcluster_a5_EditField             matlab.ui.control.EditField
        mrcluster_a5_Button                matlab.ui.control.Button
        mrcluster_a6_Label                 matlab.ui.control.Label
        mrcluster_a6_EditField             matlab.ui.control.EditField
        mrcluster_a6_Button                matlab.ui.control.Button
        mrcluster_a7_Label                 matlab.ui.control.Label
        mrcluster_a7_EditField             matlab.ui.control.EditField
        mrcluster_a7_Button                matlab.ui.control.Button
        mrcluster_a8_Label                 matlab.ui.control.Label
        mrcluster_a8_EditField             matlab.ui.control.EditField
        mrcluster_a8_Button                matlab.ui.control.Button
        mrcluster_a9_Label                 matlab.ui.control.Label
        mrcluster_a9_EditField             matlab.ui.control.EditField
        mrcluster_a9_Button                matlab.ui.control.Button
        mrcluster_a10_Label                matlab.ui.control.Label
        mrcluster_a10_EditField            matlab.ui.control.EditField
        mrcluster_a10_Button               matlab.ui.control.Button

        mrcluster_anova2_Panel             matlab.ui.container.Panel
        mrcluster_anova2_fa_Label          matlab.ui.control.Label
        mrcluster_anova2_fa_EditField      matlab.ui.control.NumericEditField
        mrcluster_anova2_fb_Label          matlab.ui.control.Label
        mrcluster_anova2_fb_EditField      matlab.ui.control.NumericEditField
        anova2_cell_labels                 cell
        anova2_cell_editfields             cell
        anova2_cell_buttons                cell

        mrcluster_ext_EditField            matlab.ui.control.EditField
        mrcluster_design_TextArea          matlab.ui.control.TextArea
        mrcluster_contrast_TextArea        matlab.ui.control.TextArea
        mrcluster_update_Button            matlab.ui.control.Button
        mrcluster_mask_EditField           matlab.ui.control.EditField
        mrcluster_mask_Button              matlab.ui.control.Button
        mrcluster_prefix_EditField         matlab.ui.control.EditField
        mrcluster_nshuffles_EditField      matlab.ui.control.NumericEditField
        mrcluster_tfce_dh_EditField        matlab.ui.control.NumericEditField
        mrcluster_tfce_e_EditField         matlab.ui.control.NumericEditField
        mrcluster_tfce_h_EditField         matlab.ui.control.NumericEditField
        mrcluster_nonstationarity_CheckBox matlab.ui.control.CheckBox
        mrcluster_notest_CheckBox          matlab.ui.control.CheckBox
        mrcluster_cluster_CheckBox         matlab.ui.control.CheckBox
        mrcluster_threshold_EditField      matlab.ui.control.NumericEditField
        mrcluster_connect_ButtonGroup      matlab.ui.container.ButtonGroup
        mrcluster_connect6_Radio           matlab.ui.control.RadioButton
        mrcluster_connect26_Radio          matlab.ui.control.RadioButton
        mrcluster_output_EditField         matlab.ui.control.EditField
        mrcluster_output_Button            matlab.ui.control.Button

        start_Button                    matlab.ui.control.Button

        fileList        cell
    end

    methods (Access = private)

        function mrcluster_design_ButtonGroupSelectionChanged(app, ~)
            app.mrcluster_twoGroup_Panel.Visible = 'off';
            app.mrcluster_anova1_Panel.Visible = 'off';
            app.mrcluster_anova2_Panel.Visible = 'off';
            if app.mrcluster_independ_Radio.Value || app.mrcluster_paired_Radio.Value
                app.mrcluster_twoGroup_Panel.Visible = 'on';
                if app.mrcluster_independ_Radio.Value
                    app.mrcluster_g1_Label.Text = '组1 (对照)';
                    app.mrcluster_g2_Label.Text = '组2 (实验)';
                else
                    app.mrcluster_g1_Label.Text = '条件A';
                    app.mrcluster_g2_Label.Text = '条件B';
                end
            elseif app.mrcluster_anova1_Radio.Value
                app.mrcluster_anova1_Panel.Visible = 'on';
                mrcluster_anova1_num_EditFieldValueChanged(app);
            elseif app.mrcluster_anova2_Radio.Value
                app.mrcluster_anova2_Panel.Visible = 'on';
                mrcluster_anova2_update_grid(app);
            end
        end

        function mrcluster_g1_ButtonPushed(app, ~)
            p = uigetdir('选择组文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.mrcluster_g1_EditField.Value = p;
        end

        function mrcluster_g2_ButtonPushed(app, ~)
            p = uigetdir('选择组文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.mrcluster_g2_EditField.Value = p;
        end

        function mrcluster_anova1_num_EditFieldValueChanged(app, ~)
            n = round(app.mrcluster_anova1_num_EditField.Value);
            n = max(2, min(10, n));
            app.mrcluster_anova1_num_EditField.Value = n;
            rows = {app.mrcluster_a1_Label, app.mrcluster_a1_EditField, app.mrcluster_a1_Button;
                    app.mrcluster_a2_Label, app.mrcluster_a2_EditField, app.mrcluster_a2_Button;
                    app.mrcluster_a3_Label, app.mrcluster_a3_EditField, app.mrcluster_a3_Button;
                    app.mrcluster_a4_Label, app.mrcluster_a4_EditField, app.mrcluster_a4_Button;
                    app.mrcluster_a5_Label, app.mrcluster_a5_EditField, app.mrcluster_a5_Button;
                    app.mrcluster_a6_Label, app.mrcluster_a6_EditField, app.mrcluster_a6_Button;
                    app.mrcluster_a7_Label, app.mrcluster_a7_EditField, app.mrcluster_a7_Button;
                    app.mrcluster_a8_Label, app.mrcluster_a8_EditField, app.mrcluster_a8_Button;
                    app.mrcluster_a9_Label, app.mrcluster_a9_EditField, app.mrcluster_a9_Button;
                    app.mrcluster_a10_Label, app.mrcluster_a10_EditField, app.mrcluster_a10_Button};
            for i = 1:10
                on = i <= n;
                rows{i,1}.Visible = on; rows{i,2}.Visible = on; rows{i,3}.Visible = on;
            end
        end

        function mrcluster_a1_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a1_EditField.Value = p;
        end
        function mrcluster_a2_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a2_EditField.Value = p;
        end
        function mrcluster_a3_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a3_EditField.Value = p;
        end
        function mrcluster_a4_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a4_EditField.Value = p;
        end
        function mrcluster_a5_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a5_EditField.Value = p;
        end
        function mrcluster_a6_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a6_EditField.Value = p;
        end
        function mrcluster_a7_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a7_EditField.Value = p;
        end
        function mrcluster_a8_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a8_EditField.Value = p;
        end
        function mrcluster_a9_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a9_EditField.Value = p;
        end
        function mrcluster_a10_ButtonPushed(app, ~)
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure); app.mrcluster_a10_EditField.Value = p;
        end

        function mrcluster_anova2_update_grid(app)
            fa = round(app.mrcluster_anova2_fa_EditField.Value);
            fb = round(app.mrcluster_anova2_fb_EditField.Value);
            fa = max(2, min(4, fa));
            fb = max(2, min(4, fb));
            app.mrcluster_anova2_fa_EditField.Value = fa;
            app.mrcluster_anova2_fb_EditField.Value = fb;
            for ai = 1:4
                for bj = 1:4
                    on = ai <= fa && bj <= fb;
                    app.anova2_cell_labels{ai, bj}.Visible = on;
                    app.anova2_cell_editfields{ai, bj}.Visible = on;
                    app.anova2_cell_buttons{ai, bj}.Visible = on;
                end
            end
        end

        function mrcluster_anova2_fa_EditFieldValueChanged(app, ~)
            mrcluster_anova2_update_grid(app);
        end

        function mrcluster_anova2_fb_EditFieldValueChanged(app, ~)
            mrcluster_anova2_update_grid(app);
        end

        function anova2_cell_ButtonPushed(app, event)
            src = event.Source;
            pos = src.UserData;
            ai = pos(1); bj = pos(2);
            p = uigetdir; if p == 0, return; end
            figure(app.UIFigure);
            app.anova2_cell_editfields{ai, bj}.Value = p;
        end

        function mrcluster_mask_ButtonPushed(app, ~)
            [f, p] = uigetfile({'*.nii;*.nii.gz;*.mif', '图像文件'});
            if isequal(f, 0), return; end
            figure(app.UIFigure);
            app.mrcluster_mask_EditField.Value = fullfile(p, f);
        end

        function mrcluster_output_ButtonPushed(app, ~)
            p = uigetdir('选择输出文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.mrcluster_output_EditField.Value = p;
        end

        function mrcluster_notest_ValueChanged(app, ~)
            isDisabled = app.mrcluster_notest_CheckBox.Value;
            app.mrcluster_nshuffles_EditField.Enable = ~isDisabled;
            app.mrcluster_tfce_dh_EditField.Enable = ~isDisabled;
            app.mrcluster_tfce_e_EditField.Enable = ~isDisabled;
            app.mrcluster_tfce_h_EditField.Enable = ~isDisabled;
            app.mrcluster_connect6_Radio.Enable = ~isDisabled;
            app.mrcluster_connect26_Radio.Enable = ~isDisabled;
            app.mrcluster_nonstationarity_CheckBox.Enable = ~isDisabled;
            app.mrcluster_cluster_CheckBox.Enable = ~isDisabled;
            app.mrcluster_threshold_EditField.Enable = ~isDisabled && app.mrcluster_cluster_CheckBox.Value;
        end

        function mrcluster_cluster_ValueChanged(app, ~)
            isCluster = app.mrcluster_cluster_CheckBox.Value;
            app.mrcluster_tfce_dh_EditField.Enable = ~isCluster;
            app.mrcluster_tfce_e_EditField.Enable = ~isCluster;
            app.mrcluster_tfce_h_EditField.Enable = ~isCluster;
            app.mrcluster_nonstationarity_CheckBox.Enable = ~isCluster;
            app.mrcluster_threshold_EditField.Enable = isCluster && ~app.mrcluster_notest_CheckBox.Value;
        end

        function mrcluster_update_ButtonPushed(app, ~)
            ext = strtrim(app.mrcluster_ext_EditField.Value);
            if isempty(ext)
                ext = '.nii';
                app.mrcluster_ext_EditField.Value = ext;
            end
            if ~startsWith(ext, '.')
                ext = ['.' ext];
            end

            groupFolders = {};
            if app.mrcluster_independ_Radio.Value || app.mrcluster_paired_Radio.Value
                g1 = strtrim(app.mrcluster_g1_EditField.Value);
                g2 = strtrim(app.mrcluster_g2_EditField.Value);
                if ~isfolder(g1) || ~isfolder(g2)
                    uialert(app.UIFigure, '请选择有效的组文件夹', '路径错误');
                    return;
                end
                groupFolders = {g1, g2};
            elseif app.mrcluster_anova1_Radio.Value
                n = round(app.mrcluster_anova1_num_EditField.Value);
                editFields = {app.mrcluster_a1_EditField, app.mrcluster_a2_EditField, ...
                    app.mrcluster_a3_EditField, app.mrcluster_a4_EditField, ...
                    app.mrcluster_a5_EditField, app.mrcluster_a6_EditField, ...
                    app.mrcluster_a7_EditField, app.mrcluster_a8_EditField, ...
                    app.mrcluster_a9_EditField, app.mrcluster_a10_EditField};
                for i = 1:n
                    f = strtrim(editFields{i}.Value);
                    if ~isfolder(f)
                        uialert(app.UIFigure, sprintf('组%d 文件夹无效', i), '路径错误');
                        return;
                    end
                    groupFolders{end+1} = f;
                end
            elseif app.mrcluster_anova2_Radio.Value
                fa = round(app.mrcluster_anova2_fa_EditField.Value);
                fb = round(app.mrcluster_anova2_fb_EditField.Value);
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

            if app.mrcluster_independ_Radio.Value
                [D, C, ft] = app.stats_design_independent_t(groupSizes);
            elseif app.mrcluster_paired_Radio.Value
                if groupSizes(1) ~= groupSizes(2)
                    uialert(app.UIFigure, '配对T检验要求两组文件数量相同', '数量不匹配');
                    return;
                end
                [D, C, ft] = app.stats_design_paired_t(groupSizes(1));
            elseif app.mrcluster_anova1_Radio.Value
                [D, C, ft] = app.stats_design_anova1(groupSizes);
            elseif app.mrcluster_anova2_Radio.Value
                fa = round(app.mrcluster_anova2_fa_EditField.Value);
                fb = round(app.mrcluster_anova2_fb_EditField.Value);
                [D, C, ft] = app.stats_design_anova2(groupSizes, fa, fb);
            end

            Dstr = '';
            for i = 1:size(D, 1)
                for j = 1:size(D, 2)
                    Dstr = [Dstr sprintf('%g ', D(i, j))];
                end
                Dstr = [Dstr newline];
            end
            app.mrcluster_design_TextArea.Value = Dstr;

            if isempty(C)
                app.mrcluster_contrast_TextArea.Value = '(F-test 模式，无对比矩阵)';
            else
                Cstr = '';
                for i = 1:size(C, 1)
                    for j = 1:size(C, 2)
                        Cstr = [Cstr sprintf('%g ', C(i, j))];
                    end
                    Cstr = [Cstr newline];
                end
                app.mrcluster_contrast_TextArea.Value = Cstr;
            end

            app.fileList = allFiles;
            app.mrcluster_update_Button.Text = sprintf('已更新 (%d人)', length(allFiles));
        end

        function start_ButtonPushed(app, ~)
            mrcluster_run(app);
        end

        function mrcluster_run(app)
            outDir = strtrim(app.mrcluster_output_EditField.Value);
            if isempty(outDir) || ~isfolder(outDir)
                uialert(app.UIFigure, '请先选择输出文件夹', '输出文件夹缺失');
                return;
            end
            maskFile = strtrim(app.mrcluster_mask_EditField.Value);
            if ~isfile(maskFile)
                uialert(app.UIFigure, '请选择有效的mask文件', 'mask缺失');
                return;
            end
            prefix = strtrim(app.mrcluster_prefix_EditField.Value);
            if isempty(prefix)
                uialert(app.UIFigure, '请输入输出前缀', '前缀缺失');
                return;
            end
            if isempty(app.fileList)
                uialert(app.UIFigure, '请先更新文件列表和设计矩阵', '文件列表为空');
                return;
            end

            inputListFile = fullfile(outDir, [prefix '_inputlist.txt']);
            fid = fopen(inputListFile, 'w');
            for i = 1:length(app.fileList)
                rel = app.makeRelativePath(app.fileList{i}, outDir);
                fprintf(fid, '%s\n', rel);
            end
            fclose(fid);

            ext = strtrim(app.mrcluster_ext_EditField.Value);
            if isempty(ext), ext = '.nii'; end
            if ~startsWith(ext, '.'), ext = ['.' ext]; end

            groupFolders = {};
            if app.mrcluster_independ_Radio.Value || app.mrcluster_paired_Radio.Value
                groupFolders = {strtrim(app.mrcluster_g1_EditField.Value), ...
                                strtrim(app.mrcluster_g2_EditField.Value)};
            elseif app.mrcluster_anova1_Radio.Value
                n = round(app.mrcluster_anova1_num_EditField.Value);
                editFields = {app.mrcluster_a1_EditField, app.mrcluster_a2_EditField, ...
                    app.mrcluster_a3_EditField, app.mrcluster_a4_EditField, ...
                    app.mrcluster_a5_EditField, app.mrcluster_a6_EditField, ...
                    app.mrcluster_a7_EditField, app.mrcluster_a8_EditField, ...
                    app.mrcluster_a9_EditField, app.mrcluster_a10_EditField};
                for i = 1:n
                    groupFolders{end+1} = strtrim(editFields{i}.Value);
                end
            elseif app.mrcluster_anova2_Radio.Value
                fa = round(app.mrcluster_anova2_fa_EditField.Value);
                fb = round(app.mrcluster_anova2_fb_EditField.Value);
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

            if app.mrcluster_independ_Radio.Value
                [D, C, ft] = app.stats_design_independent_t(groupSizes);
            elseif app.mrcluster_paired_Radio.Value
                [D, C, ft] = app.stats_design_paired_t(groupSizes(1));
            elseif app.mrcluster_anova1_Radio.Value
                [D, C, ft] = app.stats_design_anova1(groupSizes);
            elseif app.mrcluster_anova2_Radio.Value
                fa = round(app.mrcluster_anova2_fa_EditField.Value);
                fb = round(app.mrcluster_anova2_fb_EditField.Value);
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

            nshuffles = round(app.mrcluster_nshuffles_EditField.Value);
            dh = app.mrcluster_tfce_dh_EditField.Value;
            e  = app.mrcluster_tfce_e_EditField.Value;
            h  = app.mrcluster_tfce_h_EditField.Value;
            threshold = app.mrcluster_threshold_EditField.Value;

            cmd = sprintf('mrclusterstats "%s" "%s"', inputListFile, designFile);
            if ~isempty(C)
                cmd = [cmd sprintf(' "%s"', contrastFile)];
            end
            cmd = [cmd sprintf(' "%s" "%s"', maskFile, fullfile(outDir, prefix))];
            if ~isempty(ft)
                cmd = [cmd sprintf(' -ftests "%s"', ftestFile)];
            end
            if app.mrcluster_notest_CheckBox.Value
                cmd = [cmd ' -notest'];
            elseif app.mrcluster_cluster_CheckBox.Value && threshold > 0
                cmd = [cmd sprintf(' -nshuffles %d', nshuffles)];
                cmd = [cmd sprintf(' -threshold %g', threshold)];
                if app.mrcluster_connect26_Radio.Value
                    cmd = [cmd ' -connectivity'];
                end
            else
                cmd = [cmd sprintf(' -nshuffles %d', nshuffles)];
                cmd = [cmd sprintf(' -tfce_dh %g -tfce_e %g -tfce_h %g', dh, e, h)];
                if app.mrcluster_nonstationarity_CheckBox.Value
                    cmd = [cmd ' -nonstationarity'];
                end
                if app.mrcluster_connect26_Radio.Value
                    cmd = [cmd ' -connectivity'];
                end
            end
            cmd = [cmd ' -force'];

            app.start_Button.Enable = 'off';
            startTime = tic;

            fprintf('\n========== mrclusterstats ==========\n');
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
                fprintf('\n========== mrclusterstats 完成! ==========\n');
                fprintf('输出文件前缀: %s\n', fullfile(outDir, prefix));
                fprintf('耗时: %.1f 秒\n', elapsed);
                uialert(app.UIFigure, sprintf('mrclusterstats 完成\n耗时: %.1f 秒\n输出: %s', ...
                    elapsed, fullfile(outDir, prefix)), '完成');
            else
                uialert(app.UIFigure, ['mrclusterstats 运行失败: ' result], '错误');
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
            app.UIFigure.Name = 'mrclusterstats 统计分析';
            screenSize = get(0, 'ScreenSize');
            app.UIFigure.Position(1) = (screenSize(3) - 700) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - 660) / 2;

            titleLabel = uilabel(app.UIFigure);
            titleLabel.Position = [0, 620, 700, 36];
            titleLabel.HorizontalAlignment = 'center';
            titleLabel.FontSize = 20;
            titleLabel.FontWeight = 'bold';
            titleLabel.Text = 'mrclusterstats 统计分析';

            app.mrcluster_Panel = uipanel(app.UIFigure);
            app.mrcluster_Panel.Position = [10, 30, 680, 545];
            app.mrcluster_Panel.Title = '';

            uilabel(app.mrcluster_Panel, 'Position', [15, 510, 60, 22], 'Text', '统计设计');
            app.mrcluster_design_ButtonGroup = uibuttongroup(app.mrcluster_Panel);
            app.mrcluster_design_ButtonGroup.Position = [80, 509, 500, 26];
            app.mrcluster_design_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @mrcluster_design_ButtonGroupSelectionChanged);
            app.mrcluster_independ_Radio = uiradiobutton(app.mrcluster_design_ButtonGroup);
            app.mrcluster_independ_Radio.Position = [10, 3, 110, 22];
            app.mrcluster_independ_Radio.Text = '独立T检验';
            app.mrcluster_independ_Radio.Value = true;
            app.mrcluster_paired_Radio = uiradiobutton(app.mrcluster_design_ButtonGroup);
            app.mrcluster_paired_Radio.Position = [125, 3, 90, 22];
            app.mrcluster_paired_Radio.Text = '配对T检验';
            app.mrcluster_anova1_Radio = uiradiobutton(app.mrcluster_design_ButtonGroup);
            app.mrcluster_anova1_Radio.Position = [220, 3, 120, 22];
            app.mrcluster_anova1_Radio.Text = '单因素方差分析';
            app.mrcluster_anova2_Radio = uiradiobutton(app.mrcluster_design_ButtonGroup);
            app.mrcluster_anova2_Radio.Position = [345, 3, 120, 22];
            app.mrcluster_anova2_Radio.Text = '双因素方差分析';

            app.mrcluster_twoGroup_Panel = uipanel(app.mrcluster_Panel);
            app.mrcluster_twoGroup_Panel.Position = [15, 375, 650, 130];
            app.mrcluster_twoGroup_Panel.Title = '';

            app.mrcluster_g1_Label = uilabel(app.mrcluster_twoGroup_Panel);
            app.mrcluster_g1_Label.Position = [15, 95, 80, 22];
            app.mrcluster_g1_Label.Text = '组1 (对照)';
            app.mrcluster_g1_EditField = uieditfield(app.mrcluster_twoGroup_Panel, 'text');
            app.mrcluster_g1_EditField.Position = [100, 95, 440, 22];
            app.mrcluster_g1_EditField.Editable = 'off';
            app.mrcluster_g1_Button = uibutton(app.mrcluster_twoGroup_Panel, 'push');
            app.mrcluster_g1_Button.Position = [545, 95, 35, 22];
            app.mrcluster_g1_Button.Text = '...';
            app.mrcluster_g1_Button.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_g1_ButtonPushed);

            app.mrcluster_g2_Label = uilabel(app.mrcluster_twoGroup_Panel);
            app.mrcluster_g2_Label.Position = [15, 65, 80, 22];
            app.mrcluster_g2_Label.Text = '组2 (实验)';
            app.mrcluster_g2_EditField = uieditfield(app.mrcluster_twoGroup_Panel, 'text');
            app.mrcluster_g2_EditField.Position = [100, 65, 440, 22];
            app.mrcluster_g2_EditField.Editable = 'off';
            app.mrcluster_g2_Button = uibutton(app.mrcluster_twoGroup_Panel, 'push');
            app.mrcluster_g2_Button.Position = [545, 65, 35, 22];
            app.mrcluster_g2_Button.Text = '...';
            app.mrcluster_g2_Button.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_g2_ButtonPushed);

            uilabel(app.mrcluster_twoGroup_Panel, 'Position', [15, 30, 300, 22], ...
                'Text', '每组文件夹内需包含被试的 .nii 图像文件', 'FontSize', 11);

            app.mrcluster_anova1_Panel = uipanel(app.mrcluster_Panel);
            app.mrcluster_anova1_Panel.Position = [15, 330, 650, 175];
            app.mrcluster_anova1_Panel.Title = '';
            app.mrcluster_anova1_Panel.Visible = 'off';
            app.mrcluster_anova1_Panel.Scrollable = 'on';

            app.mrcluster_anova1_num_Label = uilabel(app.mrcluster_anova1_Panel);
            app.mrcluster_anova1_num_Label.Position = [15, 295, 80, 22];
            app.mrcluster_anova1_num_Label.Text = '组数';
            app.mrcluster_anova1_num_EditField = uieditfield(app.mrcluster_anova1_Panel, 'numeric');
            app.mrcluster_anova1_num_EditField.Position = [100, 295, 50, 22];
            app.mrcluster_anova1_num_EditField.Value = 3;
            app.mrcluster_anova1_num_EditField.Limits = [2 10];
            app.mrcluster_anova1_num_EditField.ValueChangedFcn = createCallbackFcn(app, @mrcluster_anova1_num_EditFieldValueChanged);

            aY = @(i) 265 - (i-1)*28;
            for gi = 1:10
                lbl = uilabel(app.mrcluster_anova1_Panel);
                lbl.Position = [15, aY(gi), 40, 22]; lbl.Text = sprintf('组%d', gi);
                ef = uieditfield(app.mrcluster_anova1_Panel, 'text');
                ef.Position = [60, aY(gi), 480, 22]; ef.Editable = 'off';
                btn = uibutton(app.mrcluster_anova1_Panel, 'push');
                btn.Position = [545, aY(gi), 35, 22]; btn.Text = '...';
                switch gi
                    case 1, app.mrcluster_a1_Label = lbl; app.mrcluster_a1_EditField = ef; app.mrcluster_a1_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a1_ButtonPushed);
                    case 2, app.mrcluster_a2_Label = lbl; app.mrcluster_a2_EditField = ef; app.mrcluster_a2_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a2_ButtonPushed);
                    case 3, app.mrcluster_a3_Label = lbl; app.mrcluster_a3_EditField = ef; app.mrcluster_a3_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a3_ButtonPushed);
                    case 4, app.mrcluster_a4_Label = lbl; app.mrcluster_a4_EditField = ef; app.mrcluster_a4_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a4_ButtonPushed);
                    case 5, app.mrcluster_a5_Label = lbl; app.mrcluster_a5_EditField = ef; app.mrcluster_a5_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a5_ButtonPushed);
                    case 6, app.mrcluster_a6_Label = lbl; app.mrcluster_a6_EditField = ef; app.mrcluster_a6_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a6_ButtonPushed);
                    case 7, app.mrcluster_a7_Label = lbl; app.mrcluster_a7_EditField = ef; app.mrcluster_a7_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a7_ButtonPushed);
                    case 8, app.mrcluster_a8_Label = lbl; app.mrcluster_a8_EditField = ef; app.mrcluster_a8_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a8_ButtonPushed);
                    case 9, app.mrcluster_a9_Label = lbl; app.mrcluster_a9_EditField = ef; app.mrcluster_a9_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a9_ButtonPushed);
                    case 10, app.mrcluster_a10_Label = lbl; app.mrcluster_a10_EditField = ef; app.mrcluster_a10_Button = btn; btn.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_a10_ButtonPushed);
                end
            end

            for gi = 4:10
                rows = {app.mrcluster_a4_Label, app.mrcluster_a4_EditField, app.mrcluster_a4_Button;
                        app.mrcluster_a5_Label, app.mrcluster_a5_EditField, app.mrcluster_a5_Button;
                        app.mrcluster_a6_Label, app.mrcluster_a6_EditField, app.mrcluster_a6_Button;
                        app.mrcluster_a7_Label, app.mrcluster_a7_EditField, app.mrcluster_a7_Button;
                        app.mrcluster_a8_Label, app.mrcluster_a8_EditField, app.mrcluster_a8_Button;
                        app.mrcluster_a9_Label, app.mrcluster_a9_EditField, app.mrcluster_a9_Button;
                        app.mrcluster_a10_Label, app.mrcluster_a10_EditField, app.mrcluster_a10_Button};
                rows{gi-3,1}.Visible = 'off'; rows{gi-3,2}.Visible = 'off'; rows{gi-3,3}.Visible = 'off';
            end

            app.mrcluster_anova2_Panel = uipanel(app.mrcluster_Panel);
            app.mrcluster_anova2_Panel.Position = [15, 330, 650, 175];
            app.mrcluster_anova2_Panel.Title = '';
            app.mrcluster_anova2_Panel.Visible = 'off';
            app.mrcluster_anova2_Panel.Scrollable = 'on';

            app.mrcluster_anova2_fa_Label = uilabel(app.mrcluster_anova2_Panel);
            app.mrcluster_anova2_fa_Label.Position = [15, 500, 100, 22]; app.mrcluster_anova2_fa_Label.Text = '因素A水平数';
            app.mrcluster_anova2_fa_EditField = uieditfield(app.mrcluster_anova2_Panel, 'numeric');
            app.mrcluster_anova2_fa_EditField.Position = [120, 500, 50, 22]; app.mrcluster_anova2_fa_EditField.Value = 2;
            app.mrcluster_anova2_fa_EditField.Limits = [2 4];
            app.mrcluster_anova2_fa_EditField.ValueChangedFcn = createCallbackFcn(app, @mrcluster_anova2_fa_EditFieldValueChanged);
            app.mrcluster_anova2_fb_Label = uilabel(app.mrcluster_anova2_Panel);
            app.mrcluster_anova2_fb_Label.Position = [190, 500, 100, 22]; app.mrcluster_anova2_fb_Label.Text = '因素B水平数';
            app.mrcluster_anova2_fb_EditField = uieditfield(app.mrcluster_anova2_Panel, 'numeric');
            app.mrcluster_anova2_fb_EditField.Position = [295, 500, 50, 22]; app.mrcluster_anova2_fb_EditField.Value = 2;
            app.mrcluster_anova2_fb_EditField.Limits = [2 4];
            app.mrcluster_anova2_fb_EditField.ValueChangedFcn = createCallbackFcn(app, @mrcluster_anova2_fb_EditFieldValueChanged);

            app.anova2_cell_labels = cell(4, 4);
            app.anova2_cell_editfields = cell(4, 4);
            app.anova2_cell_buttons = cell(4, 4);
            for ai = 1:4
                for bj = 1:4
                    cy = 50 + (4-ai)*4*28 + (4-bj)*28;
                    lbl = uilabel(app.mrcluster_anova2_Panel);
                    lbl.Position = [15, cy, 40, 22];
                    lbl.Text = sprintf('A%dB%d', ai, bj);
                    ef = uieditfield(app.mrcluster_anova2_Panel, 'text');
                    ef.Position = [60, cy, 480, 22]; ef.Editable = 'off';
                    btn = uibutton(app.mrcluster_anova2_Panel, 'push');
                    btn.Position = [545, cy, 35, 22]; btn.Text = '...';
                    btn.UserData = [ai, bj];
                    btn.ButtonPushedFcn = createCallbackFcn(app, @anova2_cell_ButtonPushed);
                    app.anova2_cell_labels{ai, bj} = lbl;
                    app.anova2_cell_editfields{ai, bj} = ef;
                    app.anova2_cell_buttons{ai, bj} = btn;
                end
            end

            uilabel(app.mrcluster_Panel, 'Position', [15, 306, 80, 22], 'Text', '文件扩展名');
            app.mrcluster_ext_EditField = uieditfield(app.mrcluster_Panel, 'text');
            app.mrcluster_ext_EditField.Position = [100, 306, 60, 22];
            app.mrcluster_ext_EditField.Value = '.nii';

            uilabel(app.mrcluster_Panel, 'Position', [15, 282, 65, 22], ...
                'HorizontalAlignment', 'right', 'Text', '设计矩阵');
            app.mrcluster_design_TextArea = uitextarea(app.mrcluster_Panel);
            app.mrcluster_design_TextArea.Position = [15, 225, 320, 55];
            app.mrcluster_design_TextArea.Editable = 'off';
            app.mrcluster_design_TextArea.Value = '请点击"更新矩阵"';

            uilabel(app.mrcluster_Panel, 'Position', [345, 282, 65, 22], ...
                'HorizontalAlignment', 'right', 'Text', '对比矩阵');
            app.mrcluster_contrast_TextArea = uitextarea(app.mrcluster_Panel);
            app.mrcluster_contrast_TextArea.Position = [345, 225, 310, 55];
            app.mrcluster_contrast_TextArea.Editable = 'off';
            app.mrcluster_contrast_TextArea.Value = '请点击"更新矩阵"';

            app.mrcluster_update_Button = uibutton(app.mrcluster_Panel, 'push');
            app.mrcluster_update_Button.Position = [15, 195, 100, 22];
            app.mrcluster_update_Button.Text = '更新矩阵';
            app.mrcluster_update_Button.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_update_ButtonPushed);

            uilabel(app.mrcluster_Panel, 'Position', [125, 195, 70, 22], 'Text', 'mask文件');
            app.mrcluster_mask_EditField = uieditfield(app.mrcluster_Panel, 'text');
            app.mrcluster_mask_EditField.Position = [200, 195, 260, 22];
            app.mrcluster_mask_EditField.Editable = 'off';
            app.mrcluster_mask_Button = uibutton(app.mrcluster_Panel, 'push');
            app.mrcluster_mask_Button.Position = [465, 195, 35, 22];
            app.mrcluster_mask_Button.Text = '...';
            app.mrcluster_mask_Button.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_mask_ButtonPushed);

            uilabel(app.mrcluster_Panel, 'Position', [515, 195, 70, 22], 'Text', '输出前缀');
            app.mrcluster_prefix_EditField = uieditfield(app.mrcluster_Panel, 'text');
            app.mrcluster_prefix_EditField.Position = [585, 195, 80, 22];
            app.mrcluster_prefix_EditField.Value = 'result';

            uilabel(app.mrcluster_Panel, 'Position', [15, 172, 70, 22], 'Text', '置换次数');
            app.mrcluster_nshuffles_EditField = uieditfield(app.mrcluster_Panel, 'numeric');
            app.mrcluster_nshuffles_EditField.Position = [90, 172, 60, 22];
            app.mrcluster_nshuffles_EditField.Value = 5000;

            uilabel(app.mrcluster_Panel, 'Position', [165, 172, 70, 22], 'Text', '高度步长');
            app.mrcluster_tfce_dh_EditField = uieditfield(app.mrcluster_Panel, 'numeric');
            app.mrcluster_tfce_dh_EditField.Position = [240, 172, 55, 22];
            app.mrcluster_tfce_dh_EditField.Value = 0.1;
            uilabel(app.mrcluster_Panel, 'Position', [305, 172, 70, 22], 'Text', '范围指数');
            app.mrcluster_tfce_e_EditField = uieditfield(app.mrcluster_Panel, 'numeric');
            app.mrcluster_tfce_e_EditField.Position = [380, 172, 55, 22];
            app.mrcluster_tfce_e_EditField.Value = 0.5;
            uilabel(app.mrcluster_Panel, 'Position', [445, 172, 70, 22], 'Text', '高度指数');
            app.mrcluster_tfce_h_EditField = uieditfield(app.mrcluster_Panel, 'numeric');
            app.mrcluster_tfce_h_EditField.Position = [520, 172, 55, 22];
            app.mrcluster_tfce_h_EditField.Value = 2;

            app.mrcluster_nonstationarity_CheckBox = uicheckbox(app.mrcluster_Panel);
            app.mrcluster_nonstationarity_CheckBox.Position = [15, 142, 130, 22];
            app.mrcluster_nonstationarity_CheckBox.Text = '非平稳性校正';
            app.mrcluster_notest_CheckBox = uicheckbox(app.mrcluster_Panel);
            app.mrcluster_notest_CheckBox.Position = [155, 142, 100, 22];
            app.mrcluster_notest_CheckBox.Text = '不执行检验';
            app.mrcluster_notest_CheckBox.ValueChangedFcn = createCallbackFcn(app, @mrcluster_notest_ValueChanged);

            app.mrcluster_cluster_CheckBox = uicheckbox(app.mrcluster_Panel);
            app.mrcluster_cluster_CheckBox.Position = [265, 142, 100, 22];
            app.mrcluster_cluster_CheckBox.Text = '传统簇分析';
            app.mrcluster_cluster_CheckBox.ValueChangedFcn = createCallbackFcn(app, @mrcluster_cluster_ValueChanged);

            uilabel(app.mrcluster_Panel, 'Position', [585, 172, 35, 22], ...
                'HorizontalAlignment', 'right', 'Text', '阈值');
            app.mrcluster_threshold_EditField = uieditfield(app.mrcluster_Panel, 'numeric');
            app.mrcluster_threshold_EditField.Position = [625, 172, 50, 22];
            app.mrcluster_threshold_EditField.Value = 0;
            app.mrcluster_threshold_EditField.Enable = 'off';

            app.mrcluster_connect_ButtonGroup = uibuttongroup(app.mrcluster_Panel);
            app.mrcluster_connect_ButtonGroup.Position = [380, 141, 130, 26];
            app.mrcluster_connect_ButtonGroup.Title = '';
            app.mrcluster_connect6_Radio = uiradiobutton(app.mrcluster_connect_ButtonGroup);
            app.mrcluster_connect6_Radio.Position = [10, 3, 60, 22];
            app.mrcluster_connect6_Radio.Text = '6体素';
            app.mrcluster_connect6_Radio.Value = true;
            app.mrcluster_connect26_Radio = uiradiobutton(app.mrcluster_connect_ButtonGroup);
            app.mrcluster_connect26_Radio.Position = [75, 3, 60, 22];
            app.mrcluster_connect26_Radio.Text = '26体素';

            uilabel(app.mrcluster_Panel, 'Position', [15, 112, 80, 22], ...
                'HorizontalAlignment', 'right', 'Text', '输出文件夹');
            app.mrcluster_output_EditField = uieditfield(app.mrcluster_Panel, 'text');
            app.mrcluster_output_EditField.Position = [100, 112, 470, 22];
            app.mrcluster_output_EditField.Editable = 'off';
            app.mrcluster_output_Button = uibutton(app.mrcluster_Panel, 'push');
            app.mrcluster_output_Button.Position = [575, 112, 35, 22];
            app.mrcluster_output_Button.Text = '...';
            app.mrcluster_output_Button.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_output_ButtonPushed);

            app.start_Button = uibutton(app.UIFigure, 'push');
            app.start_Button.Position = [290, 10, 120, 30];
            app.start_Button.Text = '开始处理';
            app.start_Button.FontSize = 14;
            app.start_Button.FontWeight = 'bold';
            app.start_Button.ButtonPushedFcn = createCallbackFcn(app, @start_ButtonPushed);

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = mrclusterstats
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
