classdef fba_template < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        work_EditField          matlab.ui.control.EditField
        work_Button             matlab.ui.control.Button

        mode_ButtonGroup        matlab.ui.container.ButtonGroup
        mode_all_Radio          matlab.ui.control.RadioButton
        mode_subset_Radio       matlab.ui.control.RadioButton

        sub_listbox             matlab.ui.control.ListBox
        selectAll_Button        matlab.ui.control.Button
        deselectAll_Button      matlab.ui.control.Button

        voxel_EditField         matlab.ui.control.NumericEditField

        btn_template            matlab.ui.control.Button
        reg_scale_EditField     matlab.ui.control.EditField
        reg_niter_EditField     matlab.ui.control.EditField
        btn_register            matlab.ui.control.Button
        progress_Label          matlab.ui.control.Label
    end

    properties (Access = private)
        workPath char
        allSubs cell
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
            loadSubjects(app);
        end

        function loadSubjects(app)
            subDir = fullfile(app.workPath, 'fba', 'subjects');
            if ~isfolder(subDir)
                return
            end
            d = dir(fullfile(subDir, 'Sub*'));
            if isempty(d)
                d = dir(fullfile(subDir, 'sub*'));
            end
            names = {d.name};
            for i = length(names):-1:1
                if ~exist(fullfile(subDir, names{i}, 'wmfod_norm.mif'), 'file')
                    names(i) = [];
                end
            end
            app.allSubs = names;
            app.sub_listbox.Items = names;
            app.sub_listbox.Value = {};
        end

        function mode_ButtonGroupSelectionChanged(app, event)
            if strcmp(app.mode_ButtonGroup.SelectedObject.Text, '全部被试')
                app.sub_listbox.Enable = 'off';
                app.selectAll_Button.Enable = 'off';
                app.deselectAll_Button.Enable = 'off';
            else
                app.sub_listbox.Enable = 'on';
                app.selectAll_Button.Enable = 'on';
                app.deselectAll_Button.Enable = 'on';
            end
        end

        function selectAll_ButtonPushed(app, event)
            app.sub_listbox.Value = app.sub_listbox.Items;
        end

        function deselectAll_ButtonPushed(app, event)
            app.sub_listbox.Value = {};
        end

        function btn_templatePushed(app, event)
            app.btn_template.Enable = 'off';
            app.progress_Label.Text = '构建群体模板 (耗时较长)...';
            drawnow;

            voxelSize = sprintf('%.2f', app.voxel_EditField.Value);

            if strcmp(app.mode_ButtonGroup.SelectedObject.Text, '全部被试')
                subList = app.allSubs;
            else
                subList = app.sub_listbox.Value;
                if isempty(subList)
                    uialert(app.UIFigure, '请选择用于构建模板的被试', '提示');
                    app.btn_template.Enable = 'on';
                    return
                end
            end

            if isempty(subList)
                uialert(app.UIFigure, '没有找到已完成个体处理的被试', '错误');
                app.btn_template.Enable = 'on';
                return
            end

            try
                step7_template(app.workPath, subList, voxelSize);
                app.progress_Label.Text = '模板构建完成';
                uialert(app.UIFigure, '群体模板构建完成！' + newline + ...
                    '结果保存在 fba/template/', '完成提示');
            catch ME
                uialert(app.UIFigure, ['模板构建出错: ' ME.message], '错误');
            end

            app.btn_template.Enable = 'on';
        end

        function btn_registerPushed(app, event)
            app.btn_register.Enable = 'off';
            app.progress_Label.Text = '配准到模板...';
            drawnow;

            subList = app.allSubs;
            if isempty(subList)
                subDir = fullfile(app.workPath, 'fba', 'subjects');
                d = dir(fullfile(subDir, 'Sub*'));
                if isempty(d)
                    d = dir(fullfile(subDir, 'sub*'));
                end
                subList = {d.name};
            end

            nlScale = app.reg_scale_EditField.Value;
            nlNiter = app.reg_niter_EditField.Value;

            try
                step8_register(app.workPath, subList, nlScale, nlNiter);
                app.progress_Label.Text = '配准完成，计算 mask 交集...';
                drawnow;
                step9_mask_inter(app.workPath, subList);
                app.progress_Label.Text = '配准与 mask 完成';
                uialert(app.UIFigure, '配准与 mask 交集完成！', '完成提示');
            catch ME
                uialert(app.UIFigure, ['配准出错: ' ME.message], '错误');
            end

            app.btn_register.Enable = 'on';
        end
    end

    methods (Access = private)

        function createComponents(app)

            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);
            fw = 480; fh = 530;
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [(screen_width-fw)/2 (screen_height-fh)/2 fw fh];
            app.UIFigure.Name = 'FBA - 模板构建与配准';

            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 500 60 22], 'Text', '工作路径');
            app.work_EditField = uieditfield(app.UIFigure, 'text', ...
                'Editable', 'off', 'Position', [80 500 330 22]);
            app.work_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @work_ButtonPushed, true), ...
                'Position', [420 500 35 23], 'Text', '...');

            uilabel(app.UIFigure, 'FontWeight', 'bold', ...
                'Position', [10 475 180 22], 'Text', '选择构建模板的被试');
            app.mode_ButtonGroup = uibuttongroup(app.UIFigure, ...
                'SelectionChangedFcn', createCallbackFcn(app, @mode_ButtonGroupSelectionChanged, true), ...
                'Position', [10 425 180 45]);
            app.mode_all_Radio = uiradiobutton(app.mode_ButtonGroup, ...
                'Text', '全部被试', 'Position', [10 5 70 22], 'Value', true);
            app.mode_subset_Radio = uiradiobutton(app.mode_ButtonGroup, ...
                'Text', '手动指定子集', 'Position', [90 5 80 22]);

            app.sub_listbox = uilistbox(app.UIFigure, ...
                'Position', [10 335 180 85], ...
                'Enable', 'off', 'Max', 100, 'Min', 0);
            app.selectAll_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @selectAll_ButtonPushed, true), ...
                'Position', [10 310 80 22], 'Text', '全选', 'Enable', 'off');
            app.deselectAll_Button = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @deselectAll_ButtonPushed, true), ...
                'Position', [100 310 80 22], 'Text', '取消全选', 'Enable', 'off');

            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 272 90 22], 'Text', '模板体素大小');
            app.voxel_EditField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [105 272 50 22], 'Value', 1.25);
            uilabel(app.UIFigure, 'Position', [158 272 30 22], 'Text', 'mm');

            app.btn_template = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_templatePushed, true), ...
                'Position', [10 232 160 30], 'Text', '构建群体模板', ...
                'FontSize', 13);

            uilabel(app.UIFigure, 'FontWeight', 'bold', ...
                'Position', [10 192 120 22], 'Text', '非线性配准参数');
            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 170 80 18], 'Text', '多级尺度');
            app.reg_scale_EditField = uieditfield(app.UIFigure, 'text', ...
                'Position', [95 170 150 22], 'Value', '0.5,0.75,1.0');
            uilabel(app.UIFigure, 'HorizontalAlignment', 'right', ...
                'Position', [10 145 80 18], 'Text', '每级迭代数');
            app.reg_niter_EditField = uieditfield(app.UIFigure, 'text', ...
                'Position', [95 145 150 22], 'Value', '5,5,15');

            app.btn_register = uibutton(app.UIFigure, 'push', ...
                'ButtonPushedFcn', createCallbackFcn(app, @btn_registerPushed, true), ...
                'Position', [10 105 160 30], 'Text', '配准到模板', ...
                'FontSize', 13);

            app.progress_Label = uilabel(app.UIFigure, ...
                'Position', [10 50 460 22], ...
                'HorizontalAlignment', 'center', 'Text', '');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = fba_template
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
