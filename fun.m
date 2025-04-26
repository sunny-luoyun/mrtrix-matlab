classdef fun < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MRtrixUIFigure  matlab.ui.Figure
        net_Button      matlab.ui.control.Button
        fiber_Button    matlab.ui.control.Button
        fod_Button      matlab.ui.control.Button
        dti_Button      matlab.ui.control.Button
        pre_Button      matlab.ui.control.Button
        Label           matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: pre_Button
        function pre_ButtonPushed(app, event)
            addpath('pre'); % 添加包含 prepro.m 的文件夹到路径中
            run('prepro.m'); % 运行脚本
        end
        % Button pushed function: dti_Button
        function dti_ButtonPushed(app, event)
            addpath('dti')
            run('dti.m')
            
        end

        % Button pushed function: fod_Button
        function fod_ButtonPushed(app, event)
            addpath('fod')
            run('fod.m')
        end

        % Button pushed function: fiber_Button
        function fiber_ButtonPushed(app, event)
            addpath('fiber')
            run('fiber.m')
        end

        % Button pushed function: net_Button
        function net_ButtonPushed(app, event)
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get screen size
            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);
        
            % Define figure size
            figure_width = 261;
            figure_height = 406;
        
            % Calculate figure position to center it on the screen
            figure_x = (screen_width - figure_width) / 2;
            figure_y = (screen_height - figure_height) / 2;

            % Create MRtrixUIFigure and hide until all components are created
            app.MRtrixUIFigure = uifigure('Visible', 'off');
            app.MRtrixUIFigure.Position = [figure_x figure_y figure_width figure_height];
            app.MRtrixUIFigure.Name = 'MRtrix';

            % Create Label
            app.Label = uilabel(app.MRtrixUIFigure);
            app.Label.BackgroundColor = [0.902 0.902 0.902];
            app.Label.HorizontalAlignment = 'center';
            app.Label.FontName = 'Apple Braille';
            app.Label.FontSize = 24;
            app.Label.Position = [1 332 260 75];
            app.Label.Text = '弥散像处理';

            % Create pre_Button
            app.pre_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.pre_Button.ButtonPushedFcn = createCallbackFcn(app, @pre_ButtonPushed, true);
            app.pre_Button.Position = [52 275 158 37];
            app.pre_Button.Text = '预处理';

            % Create dti_Button
            app.dti_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.dti_Button.ButtonPushedFcn = createCallbackFcn(app, @dti_ButtonPushed, true);
            app.dti_Button.Position = [52 217 158 37];
            app.dti_Button.Text = '弥散指标计算';

            % Create fod_Button
            app.fod_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.fod_Button.ButtonPushedFcn = createCallbackFcn(app, @fod_ButtonPushed, true);
            app.fod_Button.Position = [52 161 158 37];
            app.fod_Button.Text = '反卷积响应函数计算';

            % Create fiber_Button
            app.fiber_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.fiber_Button.ButtonPushedFcn = createCallbackFcn(app, @fiber_ButtonPushed, true);
            app.fiber_Button.Position = [52 100 158 37];
            app.fiber_Button.Text = '纤维重建';

            % Create net_Button
            app.net_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.net_Button.ButtonPushedFcn = createCallbackFcn(app, @net_ButtonPushed, true);
            app.net_Button.Position = [52 37 158 37];
            app.net_Button.Text = '纤维脑网络构建';

            % Show the figure after all components are created
            app.MRtrixUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = fun

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MRtrixUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MRtrixUIFigure)
        end
    end
end