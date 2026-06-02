classdef stats < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                    matlab.ui.Figure

        % ---- Mode selection ----
        mode_ButtonGroup            matlab.ui.container.ButtonGroup
        mrstats_Radio               matlab.ui.control.RadioButton
        mrcluster_Radio             matlab.ui.control.RadioButton

        % ===== mrstats mode =====
        mrstats_Panel               matlab.ui.container.Panel
        mrstats_folder_EditField    matlab.ui.control.EditField
        mrstats_folder_Button       matlab.ui.control.Button
        mrstats_scan_Button         matlab.ui.control.Button
        mrstats_fileList_TextArea   matlab.ui.control.TextArea
        mrstats_scope_ButtonGroup   matlab.ui.container.ButtonGroup
        mrstats_wholeBrain_Radio    matlab.ui.control.RadioButton
        mrstats_roi_Radio           matlab.ui.control.RadioButton
        mrstats_roi_Panel           matlab.ui.container.Panel
        mrstats_roi_type_ButtonGroup matlab.ui.container.ButtonGroup
        mrstats_maskFile_Radio      matlab.ui.control.RadioButton
        mrstats_sphere_Radio        matlab.ui.control.RadioButton
        mrstats_maskFile_EditField  matlab.ui.control.EditField
        mrstats_maskFile_Button     matlab.ui.control.Button
        mrstats_sphere_x_EditField  matlab.ui.control.EditField
        mrstats_sphere_y_EditField  matlab.ui.control.EditField
        mrstats_sphere_z_EditField  matlab.ui.control.EditField
        mrstats_sphere_r_EditField  matlab.ui.control.EditField
        mrstats_ref_EditField       matlab.ui.control.EditField
        mrstats_ref_Button          matlab.ui.control.Button
        mrstats_createSphere_Button matlab.ui.control.Button
        mrstats_sphere_status_Label matlab.ui.control.Label
        mrstats_mean_CheckBox       matlab.ui.control.CheckBox
        mrstats_median_CheckBox     matlab.ui.control.CheckBox
        mrstats_std_CheckBox        matlab.ui.control.CheckBox
        mrstats_min_CheckBox        matlab.ui.control.CheckBox
        mrstats_max_CheckBox        matlab.ui.control.CheckBox
        mrstats_count_CheckBox      matlab.ui.control.CheckBox
        mrstats_ignorezero_CheckBox matlab.ui.control.CheckBox
        mrstats_allvolumes_CheckBox matlab.ui.control.CheckBox
        mrstats_output_EditField    matlab.ui.control.EditField
        mrstats_output_Button       matlab.ui.control.Button

        % ===== mrclusterstats mode =====
        mrcluster_Panel             matlab.ui.container.Panel
        mrcluster_design_ButtonGroup    matlab.ui.container.ButtonGroup
        mrcluster_independ_Radio    matlab.ui.control.RadioButton
        mrcluster_paired_Radio      matlab.ui.control.RadioButton
        mrcluster_anova1_Radio      matlab.ui.control.RadioButton
        mrcluster_anova2_Radio      matlab.ui.control.RadioButton

        % Two-group panel (独立T / 配对T)
        mrcluster_twoGroup_Panel           matlab.ui.container.Panel
        mrcluster_g1_Label                 matlab.ui.control.Label
        mrcluster_g1_EditField             matlab.ui.control.EditField
        mrcluster_g1_Button                matlab.ui.control.Button
        mrcluster_g2_Label                 matlab.ui.control.Label
        mrcluster_g2_EditField             matlab.ui.control.EditField
        mrcluster_g2_Button                matlab.ui.control.Button

        % One-way ANOVA panel
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

        % Two-way ANOVA panel
        mrcluster_anova2_Panel             matlab.ui.container.Panel
        mrcluster_anova2_fa_Label          matlab.ui.control.Label
        mrcluster_anova2_fa_EditField      matlab.ui.control.NumericEditField
        mrcluster_anova2_fb_Label          matlab.ui.control.Label
        mrcluster_anova2_fb_EditField      matlab.ui.control.NumericEditField
        anova2_cell_labels                 cell
        anova2_cell_editfields             cell
        anova2_cell_buttons                cell

        % Common mrcluster controls
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

        % ---- Common ----
        start_Button                    matlab.ui.control.Button

        % ---- Internal state ----
        fileList        cell
        currentMaskPath char
    end

    % ===================================================================
    % Callbacks
    % ===================================================================
    methods (Access = private)

        % ---- Mode switch ----
        function mode_ButtonGroupSelectionChanged(app, event)
            if app.mrstats_Radio.Value
                app.mrstats_Panel.Visible = 'on';
                app.mrcluster_Panel.Visible = 'off';
            else
                app.mrstats_Panel.Visible = 'off';
                app.mrcluster_Panel.Visible = 'on';
            end
        end

        % ---- mrstats folder ----
        function mrstats_folder_ButtonPushed(app, ~)
            p = uigetdir('选择指标文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.mrstats_folder_EditField.Value = p;
        end
        function mrstats_scan_ButtonPushed(app, ~)
            folder = strtrim(app.mrstats_folder_EditField.Value);
            if ~isfolder(folder)
                uialert(app.UIFigure, '请先选择有效的指标文件夹', '路径错误');
                return;
            end
            d1 = dir(fullfile(folder, '*.nii'));
            d2 = dir(fullfile(folder, '*.nii.gz'));
            files = {};
            for i = 1:length(d1), files{end+1} = d1(i).name; end
            for i = 1:length(d2), files{end+1} = d2(i).name; end
            app.fileList = files;
            if isempty(files)
                app.mrstats_fileList_TextArea.Value = '未找到 .nii / .nii.gz 文件';
            else
                app.mrstats_fileList_TextArea.Value = strjoin(files, newline);
            end
        end

        % ---- mrstats scope ----
        function mrstats_scope_ButtonGroupSelectionChanged(app, ~)
            if app.mrstats_roi_Radio.Value
                app.mrstats_roi_Panel.Visible = 'on';
            else
                app.mrstats_roi_Panel.Visible = 'off';
                app.currentMaskPath = '';
            end
        end

        % ---- mrstats ROI type ----
        function mrstats_roi_type_ButtonGroupSelectionChanged(app, ~)
            if app.mrstats_maskFile_Radio.Value
                app.mrstats_maskFile_EditField.Enable = 'on';
                app.mrstats_maskFile_Button.Enable = 'on';
                app.mrstats_sphere_x_EditField.Enable = 'off';
                app.mrstats_sphere_y_EditField.Enable = 'off';
                app.mrstats_sphere_z_EditField.Enable = 'off';
                app.mrstats_sphere_r_EditField.Enable = 'off';
                app.mrstats_ref_EditField.Enable = 'off';
                app.mrstats_ref_Button.Enable = 'off';
                app.mrstats_createSphere_Button.Enable = 'off';
            else
                app.mrstats_maskFile_EditField.Enable = 'off';
                app.mrstats_maskFile_Button.Enable = 'off';
                app.mrstats_sphere_x_EditField.Enable = 'on';
                app.mrstats_sphere_y_EditField.Enable = 'on';
                app.mrstats_sphere_z_EditField.Enable = 'on';
                app.mrstats_sphere_r_EditField.Enable = 'on';
                app.mrstats_ref_EditField.Enable = 'on';
                app.mrstats_ref_Button.Enable = 'on';
                app.mrstats_createSphere_Button.Enable = 'on';
            end
        end

        % ---- mrstats mask file ----
        function mrstats_maskFile_ButtonPushed(app, ~)
            [f, p] = uigetfile({'*.nii;*.nii.gz;*.mif', '图像文件 (*.nii,*.nii.gz,*.mif)'});
            if isequal(f, 0), return; end
            figure(app.UIFigure);
            app.mrstats_maskFile_EditField.Value = fullfile(p, f);
            app.currentMaskPath = fullfile(p, f);
        end

        % ---- mrstats sphere ----
        function mrstats_ref_ButtonPushed(app, ~)
            [f, p] = uigetfile({'*.nii;*.nii.gz;*.mif', '参考图像'});
            if isequal(f, 0), return; end
            figure(app.UIFigure);
            app.mrstats_ref_EditField.Value = fullfile(p, f);
        end
        function mrstats_createSphere_ButtonPushed(app, ~)
            cx = str2double(app.mrstats_sphere_x_EditField.Value);
            cy = str2double(app.mrstats_sphere_y_EditField.Value);
            cz = str2double(app.mrstats_sphere_z_EditField.Value);
            r  = str2double(app.mrstats_sphere_r_EditField.Value);
            if any(isnan([cx cy cz r])) || r <= 0
                uialert(app.UIFigure, '请正确输入球心坐标 (X Y Z) 和半径 (>0)', '输入错误');
                return;
            end
            ref = strtrim(app.mrstats_ref_EditField.Value);
            if ~isfile(ref)
                uialert(app.UIFigure, '请选择有效的参考图像', '参考图像缺失');
                return;
            end
            outDir = strtrim(app.mrstats_output_EditField.Value);
            if isempty(outDir) || ~isfolder(outDir)
                outDir = tempdir;
            end
            outFile = fullfile(outDir, 'sphere_mask.nii');

            % Read reference image geometry via mrinfo
            [~, r1] = system(sprintf('mrinfo -size "%s"', ref));
            [~, r3] = system(sprintf('mrinfo -transform "%s"', ref));
            dataDims = sscanf(r1, '%d')';
            if length(dataDims) < 3
                uialert(app.UIFigure, '无法读取参考图像信息', '错误');
                return;
            end
            dataDims = dataDims(1:3);
            lines = strsplit(strtrim(string(r3)), '\n');
            T = zeros(4, 4);
            for i = 1:4
                T(i, :) = sscanf(char(lines(i)), '%f')';
            end

            % Voxel meshgrid
            [X, Y, Z] = ndgrid(0:dataDims(1)-1, 0:dataDims(2)-1, 0:dataDims(3)-1);

            % Convert grid to mm and compute distances
            grid = [X(:)'; Y(:)'; Z(:)'; ones(1, numel(X))];
            mm = T * grid;
            dist = sqrt((mm(1,:)-cx).^2 + (mm(2,:)-cy).^2 + (mm(3,:)-cz).^2);
            mask = reshape(dist <= r, dataDims);
            mask = uint8(mask);

            % Write NIfTI file
            app.writeNifti(mask, outFile, T);
            app.currentMaskPath = outFile;
            app.mrstats_sphere_status_Label.Text = ['球形mask已生成: ' outFile];
        end

        % ---- mrstats output ----
        function mrstats_output_ButtonPushed(app, ~)
            p = uigetdir('选择输出文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.mrstats_output_EditField.Value = p;
        end

        % ---- mrcluster design type ----
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

        % ---- mrcluster group buttons ----
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

        % ---- mrcluster ANOVA1 num groups ----
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

        % ---- mrcluster ANOVA2 ----
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

        % ---- mrcluster mask / output ----
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

        % ---- mrcluster notest toggle ----
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

        % ---- mrcluster cluster toggle ----
        function mrcluster_cluster_ValueChanged(app, ~)
            isCluster = app.mrcluster_cluster_CheckBox.Value;
            app.mrcluster_tfce_dh_EditField.Enable = ~isCluster;
            app.mrcluster_tfce_e_EditField.Enable = ~isCluster;
            app.mrcluster_tfce_h_EditField.Enable = ~isCluster;
            app.mrcluster_nonstationarity_CheckBox.Enable = ~isCluster;
            app.mrcluster_threshold_EditField.Enable = isCluster && ~app.mrcluster_notest_CheckBox.Value;
        end

        % ---- mrcluster update matrix ----
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

            % Scan each folder
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

            % Generate design/contrast matrices
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

            % Display
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

            % Store for later use
            app.fileList = allFiles;
            app.mrcluster_update_Button.Text = sprintf('已更新 (%d人)', length(allFiles));
        end

        % ---- Start button ----
        function start_ButtonPushed(app, ~)
            if app.mrstats_Radio.Value
                mrstats_run(app);
            else
                mrcluster_run(app);
            end
        end

        % ---- mrstats execution ----
        function mrstats_run(app)
            outDir = strtrim(app.mrstats_output_EditField.Value);
            if isempty(outDir) || ~isfolder(outDir)
                uialert(app.UIFigure, '请先选择输出文件夹', '输出文件夹缺失');
                return;
            end
            inDir = strtrim(app.mrstats_folder_EditField.Value);
            if isempty(app.fileList) || ~isfolder(inDir)
                uialert(app.UIFigure, '请先检索指标文件夹', '输入缺失');
                return;
            end

            % Build output fields
            fields = {};
            if app.mrstats_mean_CheckBox.Value,  fields{end+1} = 'mean';  end
            if app.mrstats_median_CheckBox.Value,fields{end+1} = 'median';end
            if app.mrstats_std_CheckBox.Value,   fields{end+1} = 'std';   end
            if app.mrstats_min_CheckBox.Value,   fields{end+1} = 'min';   end
            if app.mrstats_max_CheckBox.Value,   fields{end+1} = 'max';   end
            if app.mrstats_count_CheckBox.Value, fields{end+1} = 'count'; end
            if isempty(fields)
                uialert(app.UIFigure, '请至少选择一个输出指标', '指标缺失');
                return;
            end

            % Build mask option
            maskOpt = '';
            if app.mrstats_roi_Radio.Value
                if isempty(app.currentMaskPath) || ~isfile(app.currentMaskPath)
                    uialert(app.UIFigure, '请选择或生成有效的ROI mask', 'mask缺失');
                    return;
                end
                maskOpt = [' -mask "' app.currentMaskPath '"'];
            end

            % Other options
            opts = '';
            if app.mrstats_ignorezero_CheckBox.Value
                opts = [opts ' -ignorezero'];
            end
            if app.mrstats_allvolumes_CheckBox.Value
                opts = [opts ' -allvolumes'];
            end

            % Build field options
            fieldOpt = '';
            for i = 1:length(fields)
                fieldOpt = [fieldOpt ' -output ' fields{i}];
            end

            % CSV header
            csvFile = fullfile(outDir, ['mrstats_results_' datestr(now, 'yyyymmdd_HHMMSS') '.csv']);
            fid = fopen(csvFile, 'w');
            fprintf(fid, 'File,%s\n', strjoin(fields, ','));
            fclose(fid);

            app.start_Button.Enable = 'off';
            startTime = tic;

            for i = 1:length(app.fileList)
                inFile = fullfile(inDir, app.fileList{i});
                cmd = sprintf('mrstats "%s"%s%s%s', inFile, fieldOpt, maskOpt, opts);
                fprintf('\n========== [%d/%d] %s ==========\n', i, length(app.fileList), app.fileList{i});
                [~, result] = system(cmd);
                result = strtrim(result);
                fprintf('%s\n', result);

                % Parse result to CSV (skip warnings, extract numbers from data line)
                clean = regexprep(result, '\x1b\[[0-9;]*[a-zA-Z]', '');
                vals = {};
                lines = strsplit(strtrim(clean), '\n');
                for li = 1:length(lines)
                    line = strtrim(lines{li});
                    if isempty(line) || startsWith(line, 'mrstats')
                        continue;
                    end
                    nums = regexp(line, '(?:[:=])\s*([\+\-]?\d+\.?\d*(?:[eE][\+\-]?\d+)?)', 'tokens');
                    if ~isempty(nums)
                        for ni = 1:length(nums)
                            vals{end+1} = nums{ni}{1};
                        end
                    else
                        nums = regexp(line, '[\+\-]?\d+\.?\d*(?:[eE][\+\-]?\d+)?', 'match');
                        for ni = 1:length(nums)
                            vals{end+1} = nums{ni};
                        end
                    end
                end
                fid = fopen(csvFile, 'a');
                fprintf(fid, '%s', app.fileList{i});
                for j = 1:length(vals)
                    fprintf(fid, ',%s', vals{j});
                end
                fprintf(fid, '\n');
                fclose(fid);
            end

            elapsed = toc(startTime);
            app.start_Button.Enable = 'on';
            fprintf('\n========== mrstats 完成! ==========\n');
            fprintf('结果已保存至: %s\n', csvFile);
            fprintf('共处理 %d 个文件, 耗时: %.1f 秒\n', length(app.fileList), elapsed);
            uialert(app.UIFigure, ...
                sprintf('mrstats 完成\n共处理 %d 个文件\n结果: %s\n耗时: %.1f 秒', ...
                length(app.fileList), csvFile, elapsed), '完成');
        end

        % ---- mrclusterstats execution ----
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

            % Write input file list (relative paths from outDir)
            inputListFile = fullfile(outDir, [prefix '_inputlist.txt']);
            fid = fopen(inputListFile, 'w');
            for i = 1:length(app.fileList)
                rel = app.makeRelativePath(app.fileList{i}, outDir);
                fprintf(fid, '%s\n', rel);
            end
            fclose(fid);

            % Determine design type and generate matrices
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

            % Scan for group sizes (reuse fileList order)
            groupSizes = [];
            idx = 1;
            for g = 1:length(groupFolders)
                d = dir(fullfile(groupFolders{g}, ['*' ext]));
                groupSizes(g) = length(d);
            end

            % Generate design/contrast
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

            % Write design matrix
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

            % Write contrast matrix
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

            % Write F-tests (one row per F-test, space-separated)
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

            % Build mrclusterstats command
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

    % ===================================================================
    % Design matrix generators
    % ===================================================================
    methods (Access = private, Static)
        function [D, C, ft] = stats_design_independent_t(groupSizes)
            n1 = groupSizes(1); n2 = groupSizes(2);
            N = n1 + n2;
            D = zeros(N, 3);
            D(1:n1, 1) = 1;
            D(n1+1:end, 2) = 1;
            D(:, 3) = 1;
            C = [1, -1, 0];
            ft = [];
        end

        function [D, C, ft] = stats_design_paired_t(n)
            N = 2 * n;
            ncols = n + 2;
            D = zeros(N, ncols);
            % Condition column: A=1, B=-1
            D(1:n, 1) = 1;
            D(n+1:end, 1) = -1;
            % Subject dummies
            for i = 1:n
                D(i, 1+i) = 1;
                D(n+i, 1+i) = 1;
            end
            D(:, n+2) = 1;
            C = zeros(1, ncols);
            C(1) = 1;
            ft = [];
        end

        function [D, C, ft] = stats_design_anova1(groupSizes)
            k = length(groupSizes);
            N = sum(groupSizes);
            D = zeros(N, k+1);
            idx = 1;
            for g = 1:k
                for i = 1:groupSizes(g)
                    D(idx, g) = 1;
                    D(idx, k+1) = 1;
                    idx = idx + 1;
                end
            end
            % Contrast: adjacent group comparisons
            C = zeros(k-1, k+1);
            for i = 1:k-1
                C(i, i) = 1;
                C(i, i+1) = -1;
            end
            ft = ones(1, k-1);
        end

        function [D, C, ft] = stats_design_anova2(groupSizes, a, b)
            nCells = a * b;
            N = sum(groupSizes(1:nCells));
            D = zeros(N, nCells + 1);
            idx = 1;
            for c = 1:nCells
                for i = 1:groupSizes(c)
                    D(idx, c) = 1;
                    D(idx, nCells+1) = 1;
                    idx = idx + 1;
                end
            end
            % Build contrasts for main effects and interaction
            nContrasts = (a-1) + (b-1) + (a-1)*(b-1);
            C = zeros(nContrasts, nCells+1);
            row = 0;
            % Factor A main effect
            for ai = 1:a-1
                row = row + 1;
                for bj = 1:b
                    cellIdx = (ai-1)*b + bj;
                    C(row, cellIdx) = 1;
                    cellIdx2 = (a-1)*b + bj;
                    C(row, cellIdx2) = -1;
                end
            end
            % Factor B main effect
            for bj = 1:b-1
                row = row + 1;
                for ai = 1:a
                    cellIdx = (ai-1)*b + bj;
                    C(row, cellIdx) = 1;
                    cellIdx2 = (ai-1)*b + b;
                    C(row, cellIdx2) = -1;
                end
            end
            % Interaction
            for ai = 1:a-1
                for bj = 1:b-1
                    row = row + 1;
                    c1 = (ai-1)*b + bj;       % A_i, B_j
                    c2 = (ai-1)*b + b;        % A_i, B_last
                    c3 = (a-1)*b + bj;        % A_last, B_j
                    c4 = a*b;                 % A_last, B_last
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

        function writeNifti(data, filepath, T)
            dims = size(data);
            fid = fopen(filepath, 'wb');
            hdr = zeros(1, 348, 'uint8');
            % [0] sizeof_hdr = 348
            hdr(1:4) = typecast(int32(348), 'uint8');
            % [39] dim_info (0, already zero)
            % [40-55] dim[0..7]
            dims16 = [int16(3), int16(dims(1)), int16(dims(2)), int16(dims(3)), ones(1,4,'int16')];
            hdr(41:56) = typecast(dims16, 'uint8');
            % [56-67] intent_p1, intent_p2, intent_p3, intent_code
            hdr(57:60) = typecast(single(0), 'uint8');
            hdr(61:64) = typecast(single(0), 'uint8');
            hdr(65:68) = typecast(single(0), 'uint8');
            hdr(69:70) = typecast(int16(0), 'uint8');
            % [70-71] datatype = 2 (uint8)
            hdr(71:72) = typecast(int16(2), 'uint8');
            % [72-73] bitpix = 8
            hdr(73:74) = typecast(int16(8), 'uint8');
            % [74-75] slice_start = 0
            hdr(75:76) = typecast(int16(0), 'uint8');
            % [76-107] pixdim[0..7]
            vx = sqrt(T(1,1)^2+T(2,1)^2+T(3,1)^2);
            vy = sqrt(T(1,2)^2+T(2,2)^2+T(3,2)^2);
            vz = sqrt(T(1,3)^2+T(2,3)^2+T(3,3)^2);
            pixdims = [single(1), single(vx), single(vy), single(vz), zeros(1,4,'single')];
            hdr(77:108) = typecast(pixdims, 'uint8');
            % [108-111] vox_offset = 352
            hdr(109:112) = typecast(single(352), 'uint8');
            % [112-115] scl_slope = 1
            hdr(113:116) = typecast(single(1), 'uint8');
            % [116-119] scl_inter = 0
            hdr(117:120) = typecast(single(0), 'uint8');
            % [120-121] slice_end = 0
            hdr(121:122) = typecast(int16(0), 'uint8');
            % [122] slice_code = 0, [123] xyzt_units = 2 (mm)
            hdr(124) = 2;
            % [124-251] (cal_max..aux_file) already zero
            % [252-253] qform_code = 1 (ScannerAnat)
            hdr(253:254) = typecast(int16(1), 'uint8');
            % [254-255] sform_code = 1 (ScannerAnat)
            hdr(255:256) = typecast(int16(1), 'uint8');
            % [256-279] quatern fields (already zero)
            % [280-295] srow_x
            hdr(281:296) = typecast(single(T(1,1:4)), 'uint8');
            % [296-311] srow_y
            hdr(297:312) = typecast(single(T(2,1:4)), 'uint8');
            % [312-327] srow_z
            hdr(313:328) = typecast(single(T(3,1:4)), 'uint8');
            % [328-343] intent_name (already zero)
            % [344-347] magic = "n+1\0"
            hdr(345:348) = uint8([110, 43, 49, 0]);
            % Write header
            fwrite(fid, hdr, 'uint8');
            % Extension flag (4 bytes, 0 = no extension)
            fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');
            % Image data
            fwrite(fid, data, 'uint8');
            fclose(fid);
        end
    end

    % ===================================================================
    % Component creation
    % ===================================================================
    methods (Access = private)

        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100, 100, 700, 660];
            app.UIFigure.Name = '统计分析';
            screenSize = get(0, 'ScreenSize');
            app.UIFigure.Position(1) = (screenSize(3) - 700) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - 660) / 2;

            % ==================== Title ====================
            titleLabel = uilabel(app.UIFigure);
            titleLabel.Position = [0, 620, 700, 36];
            titleLabel.HorizontalAlignment = 'center';
            titleLabel.FontSize = 20;
            titleLabel.FontWeight = 'bold';
            titleLabel.Text = '统计分析';

            % ==================== Mode Selection ====================
            app.mode_ButtonGroup = uibuttongroup(app.UIFigure);
            app.mode_ButtonGroup.Position = [10, 580, 680, 35];
            app.mode_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @mode_ButtonGroupSelectionChanged);

            app.mrstats_Radio = uiradiobutton(app.mode_ButtonGroup);
            app.mrstats_Radio.Position = [15, 7, 150, 22];
            app.mrstats_Radio.Text = 'mrstats 数值提取';
            app.mrstats_Radio.Value = true;

            app.mrcluster_Radio = uiradiobutton(app.mode_ButtonGroup);
            app.mrcluster_Radio.Position = [180, 7, 180, 22];
            app.mrcluster_Radio.Text = 'mrclusterstats 统计分析';

            % ==================== mrstats Panel ====================
            app.mrstats_Panel = uipanel(app.UIFigure);
            app.mrstats_Panel.Position = [10, 30, 680, 545];
            app.mrstats_Panel.Title = '';

            % 指标文件夹
            uilabel(app.mrstats_Panel, 'Position', [15, 510, 80, 22], ...
                'HorizontalAlignment', 'right', 'Text', '指标文件夹');
            app.mrstats_folder_EditField = uieditfield(app.mrstats_Panel, 'text');
            app.mrstats_folder_EditField.Position = [100, 510, 435, 22];
            app.mrstats_folder_EditField.Editable = 'off';
            app.mrstats_folder_Button = uibutton(app.mrstats_Panel, 'push');
            app.mrstats_folder_Button.Position = [540, 510, 35, 22];
            app.mrstats_folder_Button.Text = '...';
            app.mrstats_folder_Button.ButtonPushedFcn = createCallbackFcn(app, @mrstats_folder_ButtonPushed);
            app.mrstats_scan_Button = uibutton(app.mrstats_Panel, 'push');
            app.mrstats_scan_Button.Position = [580, 510, 85, 22];
            app.mrstats_scan_Button.Text = '检索文件';
            app.mrstats_scan_Button.ButtonPushedFcn = createCallbackFcn(app, @mrstats_scan_ButtonPushed);

            % 文件列表
            uilabel(app.mrstats_Panel, 'Position', [15, 485, 80, 22], ...
                'HorizontalAlignment', 'right', 'Text', '文件列表');
            app.mrstats_fileList_TextArea = uitextarea(app.mrstats_Panel);
            app.mrstats_fileList_TextArea.Position = [15, 395, 650, 90];
            app.mrstats_fileList_TextArea.Editable = 'off';
            app.mrstats_fileList_TextArea.Value = '请选择文件夹后点击"检索文件"';

            % 分析范围
            app.mrstats_scope_ButtonGroup = uibuttongroup(app.mrstats_Panel);
            app.mrstats_scope_ButtonGroup.Position = [15, 365, 200, 26];
            app.mrstats_scope_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @mrstats_scope_ButtonGroupSelectionChanged);
            app.mrstats_wholeBrain_Radio = uiradiobutton(app.mrstats_scope_ButtonGroup);
            app.mrstats_wholeBrain_Radio.Position = [10, 3, 80, 22];
            app.mrstats_wholeBrain_Radio.Text = '全脑分析';
            app.mrstats_wholeBrain_Radio.Value = true;
            app.mrstats_roi_Radio = uiradiobutton(app.mrstats_scope_ButtonGroup);
            app.mrstats_roi_Radio.Position = [105, 3, 95, 22];
            app.mrstats_roi_Radio.Text = '感兴趣区分析';

            % ROI子面板
            app.mrstats_roi_Panel = uipanel(app.mrstats_Panel);
            app.mrstats_roi_Panel.Position = [15, 215, 650, 145];
            app.mrstats_roi_Panel.Title = '';
            app.mrstats_roi_Panel.Visible = 'off';

            % ROI type
            app.mrstats_roi_type_ButtonGroup = uibuttongroup(app.mrstats_roi_Panel);
            app.mrstats_roi_type_ButtonGroup.Position = [10, 114, 220, 26];
            app.mrstats_roi_type_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @mrstats_roi_type_ButtonGroupSelectionChanged);
            app.mrstats_maskFile_Radio = uiradiobutton(app.mrstats_roi_type_ButtonGroup);
            app.mrstats_maskFile_Radio.Position = [10, 3, 100, 22];
            app.mrstats_maskFile_Radio.Text = '已有mask文件';
            app.mrstats_maskFile_Radio.Value = true;
            app.mrstats_sphere_Radio = uiradiobutton(app.mrstats_roi_type_ButtonGroup);
            app.mrstats_sphere_Radio.Position = [115, 3, 100, 22];
            app.mrstats_sphere_Radio.Text = '新建球形ROI';

            % Mask file row
            uilabel(app.mrstats_roi_Panel, 'Position', [20, 82, 70, 22], ...
                'HorizontalAlignment', 'right', 'Text', 'mask文件');
            app.mrstats_maskFile_EditField = uieditfield(app.mrstats_roi_Panel, 'text');
            app.mrstats_maskFile_EditField.Position = [95, 82, 445, 22];
            app.mrstats_maskFile_EditField.Editable = 'off';
            app.mrstats_maskFile_Button = uibutton(app.mrstats_roi_Panel, 'push');
            app.mrstats_maskFile_Button.Position = [545, 82, 35, 22];
            app.mrstats_maskFile_Button.Text = '...';
            app.mrstats_maskFile_Button.ButtonPushedFcn = createCallbackFcn(app, @mrstats_maskFile_ButtonPushed);

            % Sphere row
            uilabel(app.mrstats_roi_Panel, 'Position', [20, 52, 40, 22], ...
                'HorizontalAlignment', 'right', 'Text', '球心X');
            app.mrstats_sphere_x_EditField = uieditfield(app.mrstats_roi_Panel, 'text');
            app.mrstats_sphere_x_EditField.Position = [65, 52, 50, 22];
            app.mrstats_sphere_x_EditField.Enable = 'off';
            uilabel(app.mrstats_roi_Panel, 'Position', [120, 52, 20, 22], 'Text', 'Y');
            app.mrstats_sphere_y_EditField = uieditfield(app.mrstats_roi_Panel, 'text');
            app.mrstats_sphere_y_EditField.Position = [140, 52, 50, 22];
            app.mrstats_sphere_y_EditField.Enable = 'off';
            uilabel(app.mrstats_roi_Panel, 'Position', [195, 52, 20, 22], 'Text', 'Z');
            app.mrstats_sphere_z_EditField = uieditfield(app.mrstats_roi_Panel, 'text');
            app.mrstats_sphere_z_EditField.Position = [215, 52, 50, 22];
            app.mrstats_sphere_z_EditField.Enable = 'off';
            uilabel(app.mrstats_roi_Panel, 'Position', [270, 52, 65, 22], 'Text', '半径(mm)');
            app.mrstats_sphere_r_EditField = uieditfield(app.mrstats_roi_Panel, 'text');
            app.mrstats_sphere_r_EditField.Position = [340, 52, 50, 22];
            app.mrstats_sphere_r_EditField.Enable = 'off';

            % Reference image row
            uilabel(app.mrstats_roi_Panel, 'Position', [20, 22, 70, 22], ...
                'HorizontalAlignment', 'right', 'Text', '参考图像');
            app.mrstats_ref_EditField = uieditfield(app.mrstats_roi_Panel, 'text');
            app.mrstats_ref_EditField.Position = [95, 22, 445, 22];
            app.mrstats_ref_EditField.Enable = 'off';
            app.mrstats_ref_Button = uibutton(app.mrstats_roi_Panel, 'push');
            app.mrstats_ref_Button.Position = [545, 22, 35, 22];
            app.mrstats_ref_Button.Text = '...';
            app.mrstats_ref_Button.Enable = 'off';
            app.mrstats_ref_Button.ButtonPushedFcn = createCallbackFcn(app, @mrstats_ref_ButtonPushed);
            app.mrstats_createSphere_Button = uibutton(app.mrstats_roi_Panel, 'push');
            app.mrstats_createSphere_Button.Position = [585, 22, 55, 22];
            app.mrstats_createSphere_Button.Text = '生成';
            app.mrstats_createSphere_Button.Enable = 'off';
            app.mrstats_createSphere_Button.ButtonPushedFcn = createCallbackFcn(app, @mrstats_createSphere_ButtonPushed);

            % Sphere status
            app.mrstats_sphere_status_Label = uilabel(app.mrstats_roi_Panel);
            app.mrstats_sphere_status_Label.Position = [20, 0, 400, 20];
            app.mrstats_sphere_status_Label.FontSize = 11;
            app.mrstats_sphere_status_Label.Text = '';

            % 输出指标
            uilabel(app.mrstats_Panel, 'Position', [15, 190, 70, 22], ...
                'HorizontalAlignment', 'right', 'Text', '输出指标');
            app.mrstats_mean_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_mean_CheckBox.Position = [90, 190, 60, 22];
            app.mrstats_mean_CheckBox.Text = '均值';
            app.mrstats_mean_CheckBox.Value = true;
            app.mrstats_median_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_median_CheckBox.Position = [155, 190, 70, 22];
            app.mrstats_median_CheckBox.Text = '中位数';
            app.mrstats_std_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_std_CheckBox.Position = [235, 190, 60, 22];
            app.mrstats_std_CheckBox.Text = '标准差';
            app.mrstats_min_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_min_CheckBox.Position = [300, 190, 60, 22];
            app.mrstats_min_CheckBox.Text = '最小值';
            app.mrstats_max_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_max_CheckBox.Position = [365, 190, 60, 22];
            app.mrstats_max_CheckBox.Text = '最大值';
            app.mrstats_count_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_count_CheckBox.Position = [430, 190, 60, 22];
            app.mrstats_count_CheckBox.Text = '体素数';

            % 选项
            app.mrstats_ignorezero_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_ignorezero_CheckBox.Position = [15, 160, 120, 22];
            app.mrstats_ignorezero_CheckBox.Text = '忽略零值';
            app.mrstats_allvolumes_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_allvolumes_CheckBox.Position = [145, 160, 120, 22];
            app.mrstats_allvolumes_CheckBox.Text = '所有体素';

            % 输出文件夹
            uilabel(app.mrstats_Panel, 'Position', [15, 130, 80, 22], ...
                'HorizontalAlignment', 'right', 'Text', '输出文件夹');
            app.mrstats_output_EditField = uieditfield(app.mrstats_Panel, 'text');
            app.mrstats_output_EditField.Position = [100, 130, 470, 22];
            app.mrstats_output_EditField.Editable = 'off';
            app.mrstats_output_Button = uibutton(app.mrstats_Panel, 'push');
            app.mrstats_output_Button.Position = [575, 130, 35, 22];
            app.mrstats_output_Button.Text = '...';
            app.mrstats_output_Button.ButtonPushedFcn = createCallbackFcn(app, @mrstats_output_ButtonPushed);

            % ==================== mrclusterstats Panel ====================
            app.mrcluster_Panel = uipanel(app.UIFigure);
            app.mrcluster_Panel.Position = [10, 30, 680, 545];
            app.mrcluster_Panel.Title = '';
            app.mrcluster_Panel.Visible = 'off';

            % 统计设计
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

            % ---- Two-group panel ----
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

            % ---- One-way ANOVA panel (scrollable) ----
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

            % Group rows a1-a10, spaced 28px apart
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

            % Default: show groups 1-3, hide 4-10
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

            % ---- Two-way ANOVA panel (scrollable, up to 4x4) ----
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

            % 4x4 cell grid at positive y (A4B4 near bottom, A1B1 above visible area)
            % This ensures the scrollable content extent > panel height
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

            % ---- Common mrcluster controls ----
            % 文件扩展名
            uilabel(app.mrcluster_Panel, 'Position', [15, 306, 80, 22], 'Text', '文件扩展名');
            app.mrcluster_ext_EditField = uieditfield(app.mrcluster_Panel, 'text');
            app.mrcluster_ext_EditField.Position = [100, 306, 60, 22];
            app.mrcluster_ext_EditField.Value = '.nii';

            % 设计矩阵 / 对比矩阵
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

            % Mask (same row as update button, to the right)
            uilabel(app.mrcluster_Panel, 'Position', [125, 195, 70, 22], 'Text', 'mask文件');
            app.mrcluster_mask_EditField = uieditfield(app.mrcluster_Panel, 'text');
            app.mrcluster_mask_EditField.Position = [200, 195, 260, 22];
            app.mrcluster_mask_EditField.Editable = 'off';
            app.mrcluster_mask_Button = uibutton(app.mrcluster_Panel, 'push');
            app.mrcluster_mask_Button.Position = [465, 195, 35, 22];
            app.mrcluster_mask_Button.Text = '...';
            app.mrcluster_mask_Button.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_mask_ButtonPushed);

            % 输出前缀
            uilabel(app.mrcluster_Panel, 'Position', [515, 195, 70, 22], 'Text', '输出前缀');
            app.mrcluster_prefix_EditField = uieditfield(app.mrcluster_Panel, 'text');
            app.mrcluster_prefix_EditField.Position = [585, 195, 80, 22];
            app.mrcluster_prefix_EditField.Value = 'result';

            % 参数
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

            % 输出文件夹
            uilabel(app.mrcluster_Panel, 'Position', [15, 112, 80, 22], ...
                'HorizontalAlignment', 'right', 'Text', '输出文件夹');
            app.mrcluster_output_EditField = uieditfield(app.mrcluster_Panel, 'text');
            app.mrcluster_output_EditField.Position = [100, 112, 470, 22];
            app.mrcluster_output_EditField.Editable = 'off';
            app.mrcluster_output_Button = uibutton(app.mrcluster_Panel, 'push');
            app.mrcluster_output_Button.Position = [575, 112, 35, 22];
            app.mrcluster_output_Button.Text = '...';
            app.mrcluster_output_Button.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_output_ButtonPushed);

            % ==================== Start Button (shared) ====================
            app.start_Button = uibutton(app.UIFigure, 'push');
            app.start_Button.Position = [290, 10, 120, 30];
            app.start_Button.Text = '开始处理';
            app.start_Button.FontSize = 14;
            app.start_Button.FontWeight = 'bold';
            app.start_Button.ButtonPushedFcn = createCallbackFcn(app, @start_ButtonPushed);

            % Show figure
            app.UIFigure.Visible = 'on';
        end
    end

    % ===================================================================
    % App lifecycle
    % ===================================================================
    methods (Access = public)

        function app = stats()
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
