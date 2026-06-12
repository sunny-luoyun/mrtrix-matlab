classdef fba < matlab.apps.AppBase

    properties (Access = public)
        UIFigure        matlab.ui.Figure
        btn_organize    matlab.ui.control.Button
        btn_subject     matlab.ui.control.Button
        btn_template    matlab.ui.control.Button
        btn_fixel       matlab.ui.control.Button
        btn_stats       matlab.ui.control.Button
        Label           matlab.ui.control.Label
    end

    methods (Access = private)

        function btn_organizePushed(app, event)
            run('fba_organize.m')
        end

        function btn_subjectPushed(app, event)
            run('fba_subject.m')
        end

        function btn_templatePushed(app, event)
            run('fba_template.m')
        end

        function btn_fixelPushed(app, event)
            run('fba_fixel.m')
        end

        function btn_statsPushed(app, event)
            run('fba_stats.m')
        end
    end

    methods (Access = private)

        function createComponents(app)

            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);
            figure_width = 300;
            figure_height = 500;
            figure_x = (screen_width - figure_width) / 2;
            figure_y = (screen_height - figure_height) / 2;

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [figure_x figure_y figure_width figure_height];
            app.UIFigure.Name = 'FBA 纤维分析';

            app.Label = uilabel(app.UIFigure);
            app.Label.BackgroundColor = [0.902 0.902 0.902];
            app.Label.HorizontalAlignment = 'center';
            app.Label.FontName = 'PingFang SC';
            app.Label.FontSize = 20;
            app.Label.Position = [1 430 299 71];
            app.Label.Text = 'FBA 纤维分析';

            app.btn_organize = uibutton(app.UIFigure, 'push');
            app.btn_organize.ButtonPushedFcn = createCallbackFcn(app, @btn_organizePushed, true);
            app.btn_organize.FontSize = 13;
            app.btn_organize.Position = [60 345 180 45];
            app.btn_organize.Text = '0. 数据整理';

            app.btn_subject = uibutton(app.UIFigure, 'push');
            app.btn_subject.ButtonPushedFcn = createCallbackFcn(app, @btn_subjectPushed, true);
            app.btn_subject.FontSize = 13;
            app.btn_subject.Position = [60 275 180 45];
            app.btn_subject.Text = '1. 个体水平处理';

            app.btn_template = uibutton(app.UIFigure, 'push');
            app.btn_template.ButtonPushedFcn = createCallbackFcn(app, @btn_templatePushed, true);
            app.btn_template.FontSize = 13;
            app.btn_template.Position = [60 205 180 45];
            app.btn_template.Text = '2. 模板构建与配准';

            app.btn_fixel = uibutton(app.UIFigure, 'push');
            app.btn_fixel.ButtonPushedFcn = createCallbackFcn(app, @btn_fixelPushed, true);
            app.btn_fixel.FontSize = 13;
            app.btn_fixel.Position = [60 135 180 45];
            app.btn_fixel.Text = '3. Fixel 指标与追踪';

            app.btn_stats = uibutton(app.UIFigure, 'push');
            app.btn_stats.ButtonPushedFcn = createCallbackFcn(app, @btn_statsPushed, true);
            app.btn_stats.FontSize = 13;
            app.btn_stats.Position = [60 65 180 45];
            app.btn_stats.Text = '4. 统计分析';

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = fba
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
