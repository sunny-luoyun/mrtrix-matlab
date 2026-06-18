classdef mrstats < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                    matlab.ui.Figure

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

        start_Button                matlab.ui.control.Button

        fileList        cell
        currentMaskPath char
        import_Button    matlab.ui.control.Button
    end

    methods (Access = private)

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

        function mrstats_scope_ButtonGroupSelectionChanged(app, ~)
            if app.mrstats_roi_Radio.Value
                app.mrstats_roi_Panel.Visible = 'on';
            else
                app.mrstats_roi_Panel.Visible = 'off';
                app.currentMaskPath = '';
            end
        end

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

        function mrstats_maskFile_ButtonPushed(app, ~)
            [f, p] = uigetfile({'*.nii;*.nii.gz;*.mif', '图像文件 (*.nii,*.nii.gz,*.mif)'});
            if isequal(f, 0), return; end
            figure(app.UIFigure);
            app.mrstats_maskFile_EditField.Value = fullfile(p, f);
            app.currentMaskPath = fullfile(p, f);
        end

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

            [X, Y, Z] = ndgrid(0:dataDims(1)-1, 0:dataDims(2)-1, 0:dataDims(3)-1);

            grid = [X(:)'; Y(:)'; Z(:)'; ones(1, numel(X))];
            mm = T * grid;
            dist = sqrt((mm(1,:)-cx).^2 + (mm(2,:)-cy).^2 + (mm(3,:)-cz).^2);
            mask = reshape(dist <= r, dataDims);
            mask = uint8(mask);

            app.writeNifti(mask, outFile, T);
            app.currentMaskPath = outFile;
            app.mrstats_sphere_status_Label.Text = ['球形mask已生成: ' outFile];
        end

        function mrstats_output_ButtonPushed(app, ~)
            p = uigetdir('选择输出文件夹');
            if p == 0, return; end
            figure(app.UIFigure);
            app.mrstats_output_EditField.Value = p;
        end

        function import_ButtonPushed(app, ~)
            [file, path] = uigetfile('*.mat', '选择参数文件');
            if isequal(file, 0), return; end
            data = load_params(fullfile(path, file));
            p = data.params;
            app.mrstats_folder_EditField.Value = p.inDir;
            app.mrstats_output_EditField.Value = p.outDir;
            app.mrstats_mean_CheckBox.Value = p.mean;
            app.mrstats_median_CheckBox.Value = p.median;
            app.mrstats_std_CheckBox.Value = p.std;
            app.mrstats_min_CheckBox.Value = p.min;
            app.mrstats_max_CheckBox.Value = p.max;
            app.mrstats_count_CheckBox.Value = p.count;
            app.mrstats_ignorezero_CheckBox.Value = p.ignorezero;
            app.mrstats_allvolumes_CheckBox.Value = p.allvolumes;
            app.mrstats_wholeBrain_Radio.Value = strcmp(p.scope, 'wholeBrain');
            app.mrstats_roi_Radio.Value = strcmp(p.scope, 'roi');
            app.mrstats_maskFile_Radio.Value = strcmp(p.roiType, 'maskFile');
            app.mrstats_sphere_Radio.Value = strcmp(p.roiType, 'sphere');
            app.mrstats_maskFile_EditField.Value = p.maskFile;
            app.mrstats_sphere_x_EditField.Value = p.sphere_x;
            app.mrstats_sphere_y_EditField.Value = p.sphere_y;
            app.mrstats_sphere_z_EditField.Value = p.sphere_z;
            app.mrstats_sphere_r_EditField.Value = p.sphere_r;
            app.mrstats_ref_EditField.Value = p.ref;
            if isfield(p, 'fileList')
                app.fileList = p.fileList;
            end
            if isfield(p, 'currentMaskPath')
                app.currentMaskPath = p.currentMaskPath;
            end
        end

        function start_ButtonPushed(app, ~)
            params = struct();
            params.inDir = app.mrstats_folder_EditField.Value;
            params.outDir = app.mrstats_output_EditField.Value;
            params.mean = app.mrstats_mean_CheckBox.Value;
            params.median = app.mrstats_median_CheckBox.Value;
            params.std = app.mrstats_std_CheckBox.Value;
            params.min = app.mrstats_min_CheckBox.Value;
            params.max = app.mrstats_max_CheckBox.Value;
            params.count = app.mrstats_count_CheckBox.Value;
            params.ignorezero = app.mrstats_ignorezero_CheckBox.Value;
            params.allvolumes = app.mrstats_allvolumes_CheckBox.Value;
            params.scope = 'wholeBrain';
            if app.mrstats_roi_Radio.Value, params.scope = 'roi'; end
            params.roiType = 'maskFile';
            if app.mrstats_sphere_Radio.Value, params.roiType = 'sphere'; end
            params.maskFile = app.mrstats_maskFile_EditField.Value;
            params.sphere_x = app.mrstats_sphere_x_EditField.Value;
            params.sphere_y = app.mrstats_sphere_y_EditField.Value;
            params.sphere_z = app.mrstats_sphere_z_EditField.Value;
            params.sphere_r = app.mrstats_sphere_r_EditField.Value;
            params.ref = app.mrstats_ref_EditField.Value;
            params.fileList = app.fileList;
            params.currentMaskPath = app.currentMaskPath;
            save_params('stats', 'mrstats', app.mrstats_output_EditField.Value, params);
            mrstats_run(app);
        end

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

            maskOpt = '';
            if app.mrstats_roi_Radio.Value
                if isempty(app.currentMaskPath) || ~isfile(app.currentMaskPath)
                    uialert(app.UIFigure, '请选择或生成有效的ROI mask', 'mask缺失');
                    return;
                end
                maskOpt = [' -mask "' app.currentMaskPath '"'];
            end

            opts = '';
            if app.mrstats_ignorezero_CheckBox.Value
                opts = [opts ' -ignorezero'];
            end
            if app.mrstats_allvolumes_CheckBox.Value
                opts = [opts ' -allvolumes'];
            end

            fieldOpt = '';
            for i = 1:length(fields)
                fieldOpt = [fieldOpt ' -output ' fields{i}];
            end

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
    end

    methods (Access = private, Static)

        function writeNifti(data, filepath, T)
            dims = size(data);
            fid = fopen(filepath, 'wb');
            hdr = zeros(1, 348, 'uint8');
            hdr(1:4) = typecast(int32(348), 'uint8');
            dims16 = [int16(3), int16(dims(1)), int16(dims(2)), int16(dims(3)), ones(1,4,'int16')];
            hdr(41:56) = typecast(dims16, 'uint8');
            hdr(57:60) = typecast(single(0), 'uint8');
            hdr(61:64) = typecast(single(0), 'uint8');
            hdr(65:68) = typecast(single(0), 'uint8');
            hdr(69:70) = typecast(int16(0), 'uint8');
            hdr(71:72) = typecast(int16(2), 'uint8');
            hdr(73:74) = typecast(int16(8), 'uint8');
            hdr(75:76) = typecast(int16(0), 'uint8');
            vx = sqrt(T(1,1)^2+T(2,1)^2+T(3,1)^2);
            vy = sqrt(T(1,2)^2+T(2,2)^2+T(3,2)^2);
            vz = sqrt(T(1,3)^2+T(2,3)^2+T(3,3)^2);
            pixdims = [single(1), single(vx), single(vy), single(vz), zeros(1,4,'single')];
            hdr(77:108) = typecast(pixdims, 'uint8');
            hdr(109:112) = typecast(single(352), 'uint8');
            hdr(113:116) = typecast(single(1), 'uint8');
            hdr(117:120) = typecast(single(0), 'uint8');
            hdr(121:122) = typecast(int16(0), 'uint8');
            hdr(124) = 2;
            hdr(253:254) = typecast(int16(1), 'uint8');
            hdr(255:256) = typecast(int16(1), 'uint8');
            hdr(281:296) = typecast(single(T(1,1:4)), 'uint8');
            hdr(297:312) = typecast(single(T(2,1:4)), 'uint8');
            hdr(313:328) = typecast(single(T(3,1:4)), 'uint8');
            hdr(345:348) = uint8([110, 43, 49, 0]);
            fwrite(fid, hdr, 'uint8');
            fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');
            fwrite(fid, data, 'uint8');
            fclose(fid);
        end
    end

    methods (Access = private)

        function createComponents(app)

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100, 100, 700, 660];
            app.UIFigure.Name = 'mrstats 数值提取';
            screenSize = get(0, 'ScreenSize');
            app.UIFigure.Position(1) = (screenSize(3) - 700) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - 660) / 2;

            titleLabel = uilabel(app.UIFigure);
            titleLabel.Position = [0, 620, 700, 36];
            titleLabel.HorizontalAlignment = 'center';
            titleLabel.FontSize = 20;
            titleLabel.FontWeight = 'bold';
            titleLabel.Text = 'mrstats 数值提取';

            app.mrstats_Panel = uipanel(app.UIFigure);
            app.mrstats_Panel.Position = [10, 30, 680, 545];
            app.mrstats_Panel.Title = '';

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

            uilabel(app.mrstats_Panel, 'Position', [15, 485, 80, 22], ...
                'HorizontalAlignment', 'right', 'Text', '文件列表');
            app.mrstats_fileList_TextArea = uitextarea(app.mrstats_Panel);
            app.mrstats_fileList_TextArea.Position = [15, 395, 650, 90];
            app.mrstats_fileList_TextArea.Editable = 'off';
            app.mrstats_fileList_TextArea.Value = '请选择文件夹后点击"检索文件"';

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

            app.mrstats_roi_Panel = uipanel(app.mrstats_Panel);
            app.mrstats_roi_Panel.Position = [15, 215, 650, 145];
            app.mrstats_roi_Panel.Title = '';
            app.mrstats_roi_Panel.Visible = 'off';

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

            uilabel(app.mrstats_roi_Panel, 'Position', [20, 82, 70, 22], ...
                'HorizontalAlignment', 'right', 'Text', 'mask文件');
            app.mrstats_maskFile_EditField = uieditfield(app.mrstats_roi_Panel, 'text');
            app.mrstats_maskFile_EditField.Position = [95, 82, 445, 22];
            app.mrstats_maskFile_EditField.Editable = 'off';
            app.mrstats_maskFile_Button = uibutton(app.mrstats_roi_Panel, 'push');
            app.mrstats_maskFile_Button.Position = [545, 82, 35, 22];
            app.mrstats_maskFile_Button.Text = '...';
            app.mrstats_maskFile_Button.ButtonPushedFcn = createCallbackFcn(app, @mrstats_maskFile_ButtonPushed);

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

            app.mrstats_sphere_status_Label = uilabel(app.mrstats_roi_Panel);
            app.mrstats_sphere_status_Label.Position = [20, 0, 400, 20];
            app.mrstats_sphere_status_Label.FontSize = 11;
            app.mrstats_sphere_status_Label.Text = '';

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

            app.mrstats_ignorezero_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_ignorezero_CheckBox.Position = [15, 160, 120, 22];
            app.mrstats_ignorezero_CheckBox.Text = '忽略零值';
            app.mrstats_allvolumes_CheckBox = uicheckbox(app.mrstats_Panel);
            app.mrstats_allvolumes_CheckBox.Position = [145, 160, 120, 22];
            app.mrstats_allvolumes_CheckBox.Text = '所有体素';

            uilabel(app.mrstats_Panel, 'Position', [15, 130, 80, 22], ...
                'HorizontalAlignment', 'right', 'Text', '输出文件夹');
            app.mrstats_output_EditField = uieditfield(app.mrstats_Panel, 'text');
            app.mrstats_output_EditField.Position = [100, 130, 470, 22];
            app.mrstats_output_EditField.Editable = 'off';
            app.mrstats_output_Button = uibutton(app.mrstats_Panel, 'push');
            app.mrstats_output_Button.Position = [575, 130, 35, 22];
            app.mrstats_output_Button.Text = '...';
            app.mrstats_output_Button.ButtonPushedFcn = createCallbackFcn(app, @mrstats_output_ButtonPushed);

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

        function app = mrstats
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
