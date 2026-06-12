classdef fba_subject < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure

        work_EditField          matlab.ui.control.EditField
        work_Button             matlab.ui.control.Button
        find_Button             matlab.ui.control.Button
        sub_ListBox          matlab.ui.control.ListBox
        sub_ContextMenu      matlab.ui.container.ContextMenu
        sub_DeleteMenu       matlab.ui.container.Menu

        csd_ButtonGroup         matlab.ui.container.ButtonGroup
        csd_msmt_Radio          matlab.ui.control.RadioButton
        csd_st_Radio            matlab.ui.control.RadioButton

        alg_Panel               matlab.ui.container.Panel
        alg_erode_EditField     matlab.ui.control.NumericEditField
        alg_fa_EditField        matlab.ui.control.NumericEditField
        alg_sfwm_EditField      matlab.ui.control.NumericEditField
        alg_gm_EditField        matlab.ui.control.NumericEditField
        alg_csf_EditField       matlab.ui.control.NumericEditField
        alg_iters_EditField     matlab.ui.control.NumericEditField
        alg_nextfiber_EditField matlab.ui.control.NumericEditField
        alg_change_EditField    matlab.ui.control.NumericEditField
        alg_sfwm2_EditField     matlab.ui.control.NumericEditField
        alg_label1              matlab.ui.control.Label
        alg_label2              matlab.ui.control.Label
        alg_label3              matlab.ui.control.Label
        alg_label4              matlab.ui.control.Label
        alg_label5              matlab.ui.control.Label
        alg_label6              matlab.ui.control.Label
        alg_label7              matlab.ui.control.Label
        alg_label8              matlab.ui.control.Label
        alg_label9              matlab.ui.control.Label

        voxel_EditField         matlab.ui.control.NumericEditField

        chk_resp                matlab.ui.control.CheckBox
        chk_respmean            matlab.ui.control.CheckBox
        chk_upsample            matlab.ui.control.CheckBox
        chk_csd                 matlab.ui.control.CheckBox
        chk_norm                matlab.ui.control.CheckBox

        start_Button            matlab.ui.control.Button
        progress_Label          matlab.ui.control.Label
        import_Button           matlab.ui.control.Button
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

        function find_ButtonPushed(app, event)
            workPath = app.work_EditField.Value;
            if isempty(workPath)
                return
            end
            fbaSubPath = fullfile(workPath, 'fba', 'subjects');
            if ~isfolder(fbaSubPath)
                uialert(app.UIFigure, '未找到 fba/subjects/ 文件夹，请先运行数据整理', '提示');
                return
            end
            subFolders = dir(fullfile(fbaSubPath, 'Sub*'));
            if isempty(subFolders)
                subFolders = dir(fullfile(fbaSubPath, 'sub*'));
            end
            names = {};
            for i = 1:length(subFolders)
                if exist(fullfile(fbaSubPath, subFolders(i).name, 'dwi.mif'), 'file')
                    names{end+1} = subFolders(i).name;
                end
            end
            if isempty(names)
                uialert(app.UIFigure, '未找到包含 dwi.mif 的被试文件夹', '提示');
                return
            end
            app.sub_ListBox.Items = names;
            app.sub_ListBox.Value = {};
        end

        % Context menu selected function: sub_DeleteMenu
        function sub_DeleteMenuSelected(app, event)
            selectedItems = app.sub_ListBox.Value;
            if isempty(selectedItems)
                return
            end
            if ischar(selectedItems)
                selectedItems = {selectedItems};
            end
            currentItems = app.sub_ListBox.Items;
            keepIdx = ~ismember(currentItems, selectedItems);
            app.sub_ListBox.Items = currentItems(keepIdx);
            app.sub_ListBox.Value = {};
        end

        function csd_ButtonGroupSelectionChanged(app, event)
            showParams(app);
        end

        function showParams(app)
            visibleMT = strcmp(app.csd_ButtonGroup.SelectedObject.Text, '多组织');
            app.alg_label1.Visible = visibleMT;
            app.alg_erode_EditField.Visible = visibleMT;
            app.alg_label2.Visible = visibleMT;
            app.alg_fa_EditField.Visible = visibleMT;
            app.alg_label3.Visible = visibleMT;
            app.alg_sfwm_EditField.Visible = visibleMT;
            app.alg_label4.Visible = visibleMT;
            app.alg_gm_EditField.Visible = visibleMT;
            app.alg_label5.Visible = visibleMT;
            app.alg_csf_EditField.Visible = visibleMT;
            app.alg_label6.Visible = ~visibleMT;
            app.alg_iters_EditField.Visible = ~visibleMT;
            app.alg_label7.Visible = ~visibleMT;
            app.alg_sfwm2_EditField.Visible = ~visibleMT;
            app.alg_label8.Visible = ~visibleMT;
            app.alg_nextfiber_EditField.Visible = ~visibleMT;
            app.alg_label9.Visible = ~visibleMT;
            app.alg_change_EditField.Visible = ~visibleMT;
        end

        function import_ButtonPushed(app, event)
            [file, path] = uigetfile('*.mat', '选择参数文件');
            if isequal(file, 0), return; end
            data = load_params(fullfile(path, file));
            p = data.params;
            app.work_EditField.Value = p.workPath;
            app.sub_ListBox.Items = strsplit(p.subjects, ', ');
            app.csd_msmt_Radio.Value = strcmp(p.csd, 'msmt');
            app.csd_st_Radio.Value = strcmp(p.csd, 'st');
            app.alg_erode_EditField.Value = p.erode;
            app.alg_fa_EditField.Value = p.fa;
            app.alg_sfwm_EditField.Value = p.sfwm;
            app.alg_gm_EditField.Value = p.gm;
            app.alg_csf_EditField.Value = p.csf;
            app.alg_iters_EditField.Value = p.iters;
            app.alg_sfwm2_EditField.Value = p.sfwm2;
            app.alg_nextfiber_EditField.Value = p.nextfiber;
            app.alg_change_EditField.Value = p.change;
            app.voxel_EditField.Value = p.voxel;
            app.chk_resp.Value = p.chk_resp;
            app.chk_respmean.Value = p.chk_respmean;
            app.chk_upsample.Value = p.chk_upsample;
            app.chk_csd.Value = p.chk_csd;
            app.chk_norm.Value = p.chk_norm;
        end

        function start_ButtonPushed(app, event)
            app.start_Button.Enable = 'off';
            app.progress_Label.Text = '处理中...';
            drawnow;

            startTime = tic;

            workPath = app.work_EditField.Value;
            subList = app.sub_ListBox.Items;
            if isempty(workPath) || isempty(subList)
                uialert(app.UIFigure, '请先选择路径并检索被试', '错误');
                app.start_Button.Enable = 'on';
                return
            end

            isMT = strcmp(app.csd_ButtonGroup.SelectedObject.Text, '多组织');
            algorithm = 'dhollander';
            if ~isMT
                algorithm = 'tournier';
            end
            voxelSize = sprintf('%.2f,%.2f,%.2f', app.voxel_EditField.Value, app.voxel_EditField.Value, app.voxel_EditField.Value);

            params = struct();
            if isMT
                params.erode = app.alg_erode_EditField.Value;
                params.fa = app.alg_fa_EditField.Value;
                params.sfwm = app.alg_sfwm_EditField.Value;
                params.gm = app.alg_gm_EditField.Value;
                params.csf = app.alg_csf_EditField.Value;
            else
                params.max_iters = app.alg_iters_EditField.Value;
                params.sfwm = app.alg_sfwm2_EditField.Value;
                params.next_fiber = app.alg_nextfiber_EditField.Value;
                params.change = app.alg_change_EditField.Value;
            end

            params = struct();
            params.workPath = app.work_EditField.Value;
            params.subjects = strjoin(app.sub_ListBox.Items, ', ');
            params.csd = 'msmt';
            if app.csd_st_Radio.Value, params.csd = 'st'; end
            params.erode = app.alg_erode_EditField.Value;
            params.fa = app.alg_fa_EditField.Value;
            params.sfwm = app.alg_sfwm_EditField.Value;
            params.gm = app.alg_gm_EditField.Value;
            params.csf = app.alg_csf_EditField.Value;
            params.iters = app.alg_iters_EditField.Value;
            params.sfwm2 = app.alg_sfwm2_EditField.Value;
            params.nextfiber = app.alg_nextfiber_EditField.Value;
            params.change = app.alg_change_EditField.Value;
            params.voxel = app.voxel_EditField.Value;
            params.chk_resp = app.chk_resp.Value;
            params.chk_respmean = app.chk_respmean.Value;
            params.chk_upsample = app.chk_upsample.Value;
            params.chk_csd = app.chk_csd.Value;
            params.chk_norm = app.chk_norm.Value;
            save_params('fba', 'fba_subject', workPath, params);

            try
                if app.chk_resp.Value
                    app.progress_Label.Text = '步骤1/4: 计算响应函数...';
                    drawnow;
                    step1_resp(workPath, subList, algorithm, params);
                end

                if app.chk_respmean.Value
                    app.progress_Label.Text = '计算群体平均响应函数...';
                    drawnow;
                    step2_respmean(workPath, algorithm);
                end

                if app.chk_upsample.Value
                    app.progress_Label.Text = '步骤2/4: 上采样 DWI...';
                    drawnow;
                    step3_upsample(workPath, subList, voxelSize);
                    app.progress_Label.Text = '计算上采样后 mask...';
                    drawnow;
                    step4_mask(workPath, subList);
                end

                if app.chk_csd.Value
                    app.progress_Label.Text = '步骤3/4: CSD 计算...';
                    drawnow;
                    csdAlgo = 'msmt_csd';
                    if ~isMT
                        csdAlgo = 'csd';
                    end
                    step5_csd(workPath, subList, csdAlgo);
                end

                if app.chk_norm.Value
                    app.progress_Label.Text = '步骤4/4: 归一化...';
                    drawnow;
                    csdAlgo = 'msmt_csd';
                    if ~isMT
                        csdAlgo = 'csd';
                    end
                    step6_normalise(workPath, subList, csdAlgo);
                end

                app.progress_Label.Text = '个体处理完成';

                elapsedTime = toc(startTime);
                hours = floor(elapsedTime / 3600);
                minutes = floor((elapsedTime - hours * 3600) / 60);
                seconds = mod(elapsedTime, 60);
                msg = sprintf('个体水平处理完成！\n结果保存在 fba/subjects/ 目录\n共耗时：%d小时 %d分钟 %.0f秒', hours, minutes, seconds);
                uialert(app.UIFigure, msg, '完成提示');
            catch ME
                uialert(app.UIFigure, ['处理出错: ' ME.message], '错误');
            end

            app.start_Button.Enable = 'on';
        end

        function chk_respValueChanged(app, event)
            if app.chk_resp.Value
                app.chk_respmean.Enable = 'on';
            else
                app.chk_respmean.Value = false;
                app.chk_respmean.Enable = 'off';
            end
        end
    end

    methods (Access = private)

        function createComponents(app)

            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);
            fw = 520; fh = 620;
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [(screen_width-fw)/2 (screen_height-fh)/2 fw fh];
            app.UIFigure.Name = 'FBA - 个体水平处理';

            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 595 60 22], 'Text', '工作路径');
            app.work_EditField = uieditfield(app.UIFigure, 'text', ...
                'Editable', 'off', 'Position', [80 595 370 22]);
            app.work_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @work_ButtonPushed, true), ...
                'Position', [460 595 35 23], 'Text', '...');

            app.find_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @find_ButtonPushed, true), ...
                'Position', [90 558 70 23], 'Text', '检索');
            % Create sub_ContextMenu
            app.sub_ContextMenu = uicontextmenu(app.UIFigure);
            app.sub_DeleteMenu = uimenu(app.sub_ContextMenu, ...
                'Text', '删除选中文件夹', ...
                'MenuSelectedFcn', createCallbackFcn(app, @sub_DeleteMenuSelected, true));

            % Create sub_ListBox
            app.sub_ListBox = uilistbox(app.UIFigure, ...
                'Position', [175 535 315 55]);
            app.sub_ListBox.ContextMenu = app.sub_ContextMenu;

            uilabel(app.UIFigure, 'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold', 'Position', [10 510 100 22], 'Text', 'CSD 算法');
            app.csd_ButtonGroup = uibuttongroup(app.UIFigure, ...
                'SelectionChangedFcn', createCallbackFcn(app, @csd_ButtonGroupSelectionChanged, true), ...
                'Position', [10 455 160 50]);
            app.csd_msmt_Radio = uiradiobutton(app.csd_ButtonGroup, ...
                'Text', '多组织', 'Position', [10 5 60 22], 'Value', true);
            app.csd_st_Radio = uiradiobutton(app.csd_ButtonGroup, ...
                'Text', '单组织', 'Position', [80 5 60 22]);

            app.alg_Panel = uipanel(app.UIFigure, ...
                'Title', '响应函数参数', 'Position', [180 335 320 110]);
            yy = 60;
            app.alg_label1 = uilabel(app.alg_Panel, 'Position', [5 yy 85 18], 'Text', 'mask腐蚀次数');
            app.alg_erode_EditField = uieditfield(app.alg_Panel, 'numeric', ...
                'Position', [90 yy 35 22], 'Value', 2);
            app.alg_label2 = uilabel(app.alg_Panel, 'Position', [130 yy 80 18], 'Text', 'FA阈值');
            app.alg_fa_EditField = uieditfield(app.alg_Panel, 'numeric', ...
                'Position', [210 yy 40 22], 'Value', 0.2);
            app.alg_label3 = uilabel(app.alg_Panel, 'Position', [5 yy-30 95 18], 'Text', '单纤维WM体素%');
            app.alg_sfwm_EditField = uieditfield(app.alg_Panel, 'numeric', ...
                'Position', [100 yy-30 40 22], 'Value', 0.5);
            app.alg_label4 = uilabel(app.alg_Panel, 'Position', [150 yy-30 80 18], 'Text', 'GM体素%');
            app.alg_gm_EditField = uieditfield(app.alg_Panel, 'numeric', ...
                'Position', [230 yy-30 35 22], 'Value', 2);
            app.alg_label5 = uilabel(app.alg_Panel, 'Position', [5 yy-60 80 18], 'Text', 'CSF体素%');
            app.alg_csf_EditField = uieditfield(app.alg_Panel, 'numeric', ...
                'Position', [85 yy-60 35 22], 'Value', 10);

            app.alg_label6 = uilabel(app.alg_Panel, 'Position', [5 yy 75 18], 'Text', '最大迭代次数');
            app.alg_iters_EditField = uieditfield(app.alg_Panel, 'numeric', ...
                'Position', [85 yy 40 22], 'Value', 100);
            app.alg_label7 = uilabel(app.alg_Panel, 'Position', [5 yy-30 80 18], 'Text', '纤维体素数量');
            app.alg_sfwm2_EditField = uieditfield(app.alg_Panel, 'numeric', ...
                'Position', [90 yy-30 50 22], 'Value', 1000);
            app.alg_label8 = uilabel(app.alg_Panel, 'Position', [5 yy-60 80 18], 'Text', '下次迭代选择');
            app.alg_nextfiber_EditField = uieditfield(app.alg_Panel, 'numeric', ...
                'Position', [90 yy-60 50 22], 'Value', 10000);
            app.alg_label9 = uilabel(app.alg_Panel, 'Position', [150 yy-60 90 18], 'Text', '继续迭代变化%');
            app.alg_change_EditField = uieditfield(app.alg_Panel, 'numeric', ...
                'Position', [245 yy-60 35 22], 'Value', 1);

            set([app.alg_label6 app.alg_iters_EditField app.alg_label7 ...
                 app.alg_sfwm2_EditField app.alg_label8 app.alg_nextfiber_EditField ...
                 app.alg_label9 app.alg_change_EditField], 'Visible', 'off');

            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 290 100 22], 'Text', '目标体素大小');
            app.voxel_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [115 290 50 22], 'Value', 1.25);
            uilabel(app.UIFigure, 'Position', [168 290 110 22], 'Text', 'mm（各向同性）');

            app.chk_resp = uicheckbox(app.UIFigure, ...
                'ValueChangedFcn', createCallbackFcn(app, @chk_respValueChanged, true), ...
                'Position', [10 255 200 22], 'Text', '步骤1: 响应函数 (dwi2response)');
            app.chk_respmean = uicheckbox(app.UIFigure, ...
                'Position', [30 228 250 22], 'Text', '自动计算群体平均 (responsemean)', ...
                'Value', true, 'Enable', 'off');
            app.chk_upsample = uicheckbox(app.UIFigure, ...
                'Position', [10 201 200 22], 'Text', '步骤2: 上采样 (mrgrid regrid)', ...
                'Value', true);
            app.chk_csd = uicheckbox(app.UIFigure, ...
                'Position', [10 174 200 22], 'Text', '步骤3: FOD 计算 (dwi2fod)', ...
                'Value', true);
            app.chk_norm = uicheckbox(app.UIFigure, ...
                'Position', [10 147 220 22], 'Text', '步骤4: 归一化 (mtnormalise)', ...
                'Value', true);

            app.start_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @start_ButtonPushed, true), ...
                'Position', [200 100 100 30], 'Text', '开始处理', ...
                'FontSize', 13);

            app.import_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @import_ButtonPushed, true), ...
                'Position', [305 100 40 30], 'Text', '导入', ...
                'FontSize', 12);
            app.progress_Label = uilabel(app.UIFigure, ...
                'Position', [10 50 480 22], ...
                'HorizontalAlignment', 'center', 'Text', '');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = fba_subject
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
