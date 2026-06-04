classdef fun < matlab.apps.AppBase

    properties (Access = public)
        MRtrixUIFigure  matlab.ui.Figure
        net_Button      matlab.ui.control.Button
        fba_Button      matlab.ui.control.Button
        fiber_Button    matlab.ui.control.Button
        fod_Button      matlab.ui.control.Button
        dti_Button      matlab.ui.control.Button
        pre_Button      matlab.ui.control.Button
        Label           matlab.ui.control.Label
    end

    methods (Access = private)

        function pre_ButtonPushed(app, event)
            addpath('pre')
            run('prepro.m')
        end

        function dti_ButtonPushed(app, event)
            addpath('dti')
            run('dti.m')
        end

        function fod_ButtonPushed(app, event)
            addpath('fod')
            run('fod.m')
        end

        function fiber_ButtonPushed(app, event)
            addpath('fiber')
            run('fiber.m')
        end

        function fba_ButtonPushed(app, event)
            addpath('fba')
            run('fba.m')
        end

        function net_ButtonPushed(app, event)
            addpath('map')
            run('build_map.m')
        end
    end

    methods (Access = private)

        function createComponents(app)

            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);
            figure_width = 261;
            figure_height = 460;
            figure_x = (screen_width - figure_width) / 2;
            figure_y = (screen_height - figure_height) / 2;

            app.MRtrixUIFigure = uifigure('Visible', 'off');
            app.MRtrixUIFigure.Position = [figure_x figure_y figure_width figure_height];
            app.MRtrixUIFigure.Name = 'MRtrix';

            app.Label = uilabel(app.MRtrixUIFigure);
            app.Label.BackgroundColor = [0.902 0.902 0.902];
            app.Label.HorizontalAlignment = 'center';
            app.Label.FontName = 'PingFang SC';
            app.Label.FontSize = 24;
            app.Label.Position = [1 380 260 81];
            app.Label.Text = '弥散像处理';

            app.pre_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.pre_Button.ButtonPushedFcn = createCallbackFcn(app, @pre_ButtonPushed, true);
            app.pre_Button.Position = [52 312 158 37];
            app.pre_Button.Text = '预处理';

            app.dti_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.dti_Button.ButtonPushedFcn = createCallbackFcn(app, @dti_ButtonPushed, true);
            app.dti_Button.Position = [52 254 158 37];
            app.dti_Button.Text = '弥散指标计算';

            app.fod_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.fod_Button.ButtonPushedFcn = createCallbackFcn(app, @fod_ButtonPushed, true);
            app.fod_Button.Position = [52 196 158 37];
            app.fod_Button.Text = '反卷积响应函数计算';

            app.fiber_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.fiber_Button.ButtonPushedFcn = createCallbackFcn(app, @fiber_ButtonPushed, true);
            app.fiber_Button.Position = [52 138 158 37];
            app.fiber_Button.Text = '纤维重建';

            app.fba_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.fba_Button.ButtonPushedFcn = createCallbackFcn(app, @fba_ButtonPushed, true);
            app.fba_Button.Position = [52 80 158 37];
            app.fba_Button.Text = 'FBA 纤维分析';

            app.net_Button = uibutton(app.MRtrixUIFigure, 'push');
            app.net_Button.ButtonPushedFcn = createCallbackFcn(app, @net_ButtonPushed, true);
            app.net_Button.Position = [52 22 158 37];
            app.net_Button.Text = '纤维网络矩阵构建';

            app.MRtrixUIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = fun
            createComponents(app)
            registerApp(app, app.MRtrixUIFigure)
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.MRtrixUIFigure)
        end
    end
end