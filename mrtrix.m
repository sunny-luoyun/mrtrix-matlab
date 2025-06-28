classdef mrtrix < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure       matlab.ui.Figure
        Button_4       matlab.ui.control.Button
        Button_3       matlab.ui.control.Button
        Button_2       matlab.ui.control.Button
        Button         matlab.ui.control.Button
        MRtrix30Label  matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: 整理
        function ButtonPushed(app, event)
            run('sortimg.m')
        end

        % Button pushed function: 处理
        function Button_2Pushed(app, event)
            run('fun.m')
        end

        % Button pushed function: 相关
        function Button_3Pushed(app, event)
  
            
        end

        % Button pushed function: 图形
        function Button_4Pushed(app, event)
            system("mrview");
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 267 414]; % 初始位置，稍后会调整
            app.UIFigure.Name = 'MRtrix';

            % Center the UIFigure on the screen
            centerFigure(app); % 调用方法时传入 app 对象

            % Create MRtrix30Label
            app.MRtrix30Label = uilabel(app.UIFigure);
            app.MRtrix30Label.BackgroundColor = [0.902 0.902 0.902];
            app.MRtrix30Label.HorizontalAlignment = 'center';
            app.MRtrix30Label.FontName = 'PingFang SC';
            app.MRtrix30Label.FontSize = 24;
            app.MRtrix30Label.FontWeight = 'bold';
            app.MRtrix30Label.Position = [2 352 266 63];
            app.MRtrix30Label.Text = 'MRtrix 3.0';

            % Create Button
            app.Button = uibutton(app.UIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.FontSize = 14;
            app.Button.Position = [51 279 170 52];
            app.Button.Text = '原始数据整理';

            % Create Button_2
            app.Button_2 = uibutton(app.UIFigure, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @Button_2Pushed, true);
            app.Button_2.FontSize = 14;
            app.Button_2.Position = [51 194 170 52];
            app.Button_2.Text = '弥散像处理';

            % Create Button_3
            app.Button_3 = uibutton(app.UIFigure, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @Button_3Pushed, true);
            app.Button_3.FontSize = 14;
            app.Button_3.Position = [51 111 170 52];
            app.Button_3.Text = '结构功能矩阵相关分析';

            % Create Button_4
            app.Button_4 = uibutton(app.UIFigure, 'push');
            app.Button_4.ButtonPushedFcn = createCallbackFcn(app, @Button_4Pushed, true);
            app.Button_4.FontSize = 14;
            app.Button_4.Position = [52 26 170 52];
            app.Button_4.Text = '图形化查看';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end

        % Center the UIFigure on the screen
        function centerFigure(app)
            % Get screen size
            screen_size = get(0, 'ScreenSize');
            screen_width = screen_size(3);
            screen_height = screen_size(4);

            % Get figure size
            fig_width = app.UIFigure.Position(3);
            fig_height = app.UIFigure.Position(4);

            % Calculate new position to center the figure
            new_x = (screen_width - fig_width) / 2;
            new_y = (screen_height - fig_height) / 2;

            % Update figure position
            app.UIFigure.Position = [new_x, new_y, fig_width, fig_height];
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mrtrix

            % 调用 env.m 文件
            run('env.m');  % 确保 env.m 文件的路径是正确的

            % Create UIFigure and components
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