classdef stats_fun < matlab.apps.AppBase

    properties (Access = public)
        UIFigure       matlab.ui.Figure
        conn_Button    matlab.ui.control.Button
        mrcluster_Button    matlab.ui.control.Button
        mrstats_Button    matlab.ui.control.Button
        Label          matlab.ui.control.Label
    end

    methods (Access = private)

        function mrstats_ButtonPushed(app, event)
            run('mrstats.m')
        end

        function mrcluster_ButtonPushed(app, event)
            run('mrclusterstats.m')
        end

        function conn_ButtonPushed(app, event)
            run('connectomestats.m')
        end
    end

    methods (Access = private)

        function createComponents(app)

            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);

            figure_width = 261;
            figure_height = 406;

            figure_x = (screen_width - figure_width) / 2;
            figure_y = (screen_height - figure_height) / 2;

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [figure_x figure_y figure_width figure_height];
            app.UIFigure.Name = 'MRtrix';

            app.Label = uilabel(app.UIFigure);
            app.Label.BackgroundColor = [0.902 0.902 0.902];
            app.Label.HorizontalAlignment = 'center';
            app.Label.FontName = 'PingFang SC';
            app.Label.FontSize = 24;
            app.Label.Position = [1 332 260 75];
            app.Label.Text = '统计分析';

            app.mrstats_Button = uibutton(app.UIFigure, 'push');
            app.mrstats_Button.ButtonPushedFcn = createCallbackFcn(app, @mrstats_ButtonPushed, true);
            app.mrstats_Button.Position = [52 275 158 37];
            app.mrstats_Button.Text = 'mrstats 数值提取';

            app.mrcluster_Button = uibutton(app.UIFigure, 'push');
            app.mrcluster_Button.ButtonPushedFcn = createCallbackFcn(app, @mrcluster_ButtonPushed, true);
            app.mrcluster_Button.Position = [52 186 158 37];
            app.mrcluster_Button.Text = 'mrclusterstats 统计分析';

            app.conn_Button = uibutton(app.UIFigure, 'push');
            app.conn_Button.ButtonPushedFcn = createCallbackFcn(app, @conn_ButtonPushed, true);
            app.conn_Button.Position = [52 100 158 37];
            app.conn_Button.Text = 'connectomestats 网络统计';

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = stats_fun
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
