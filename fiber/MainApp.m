classdef MainApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        DefROIButton       matlab.ui.control.Button
        TextDisplay        matlab.ui.control.TextArea
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: DefROIButton
        function defroi_ButtonPushed(app, event)
            Cfg = ROIListDialog();

            % 检查用户是否取消了操作
            if isempty(Cfg)
                app.TextDisplay.Value = 'User cancelled the operation.';
                return;
            end

            % 确保 Cfg.ROIDef 是一个单元格数组
            if isempty(Cfg.ROIDef)
                ROIDefStr = 'No ROI definitions';
            else
                % 将非字符串元素转换为字符串
                ROIDefStr = strjoin(cellfun(@num2str, Cfg.ROIDef, 'UniformOutput', false), ', ');
            end

            % 确保 Cfg.ROISelectedIndex 是一个单元格数组
            if isempty(Cfg.ROISelectedIndex)
                ROISelectedIndexStr = 'No ROI selected indices';
            else
                % 将非字符串元素转换为字符串
                ROISelectedIndexStr = strjoin(cellfun(@num2str, Cfg.ROISelectedIndex, 'UniformOutput', false), ', ');
            end

            % 将返回的配置信息显示在文本框中
            app.TextDisplay.Value = sprintf('ROIDef: %s\nROISelectedIndex: %s', ...
                ROIDefStr, ...
                ROISelectedIndexStr);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 400 300];
            app.UIFigure.Name = 'Main Application';

            % Create DefROIButton
            app.DefROIButton = uibutton(app.UIFigure, 'push');
            app.DefROIButton.ButtonPushedFcn = createCallbackFcn(app, @defroi_ButtonPushed, true);
            app.DefROIButton.Position = [100 200 200 30];
            app.DefROIButton.Text = 'Define ROI';

            % Create TextDisplay
            app.TextDisplay = uitextarea(app.UIFigure);
            app.TextDisplay.Position = [100 100 200 80];
            app.TextDisplay.Value = 'ROI Configuration will be displayed here.';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App initialization and construction
    methods (Access = public)

        % Construct app
        function app = MainApp

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end