classdef sortimg < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        NIFTIoutput_EditField  matlab.ui.control.EditField
        Label_6                matlab.ui.control.Label
        NIFTIoutput_Button     matlab.ui.control.Button
        NIFTIstart_Button      matlab.ui.control.Button
        dwi_EditField          matlab.ui.control.EditField
        Label_5                matlab.ui.control.Label
        dwi_Button             matlab.ui.control.Button
        T1_EditField           matlab.ui.control.EditField
        Label_4                matlab.ui.control.Label
        T1_Button              matlab.ui.control.Button
        IMALabel_2             matlab.ui.control.Label
        IMALabel               matlab.ui.control.Label
        IMAoutput_EditField    matlab.ui.control.EditField
        Label_3                matlab.ui.control.Label
        IMAoutput_Button       matlab.ui.control.Button
        IMAfile_EditField      matlab.ui.control.EditField
        IMAEditFieldLabel      matlab.ui.control.Label
        subfile_EditField      matlab.ui.control.EditField
        Label_2                matlab.ui.control.Label
        work_EditField         matlab.ui.control.EditField
        Label                  matlab.ui.control.Label
        IMAstart_Button        matlab.ui.control.Button
        work_Button            matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Callback function
        function work_ButtonPushed(app, event)
            
        end

        % Callback function
        function IMAstart_ButtonPushed(app, event)
            
        end

        % Button pushed function: work_Button
        function work_ButtonPushed2(app, event)
            path = uigetdir('选择工作路径');
            figure(app.UIFigure)
            if isempty(path) % 如果用户取消选择
                figure(app.UIFigure)
                return;
            end
            app.work_EditField.Value = path;
        end

        % Button pushed function: IMAoutput_Button
        function IMAoutput_ButtonPushed(app, event)
            path = uigetdir('选择工作路径');
            figure(app.UIFigure)
            if isempty(path) % 如果用户取消选择
                figure(app.UIFigure)
                return;
            end
            app.IMAoutput_EditField.Value = path;
        end

        % Button pushed function: IMAstart_Button
        function IMAstart_ButtonPushed2(app, event)
            A = app.work_EditField.Value;
            letter = app.subfile_EditField.Value;
            B = app.IMAfile_EditField.Value;
            C = app.IMAoutput_EditField.Value;
            
            IMAsort(A, letter, B, C);
        end

        % Button pushed function: T1_Button
        function T1_ButtonPushed(app, event)
            path = uigetdir('选择工作路径');
            figure(app.UIFigure)
            if isempty(path) % 如果用户取消选择
                figure(app.UIFigure)
                return;
            end
            app.T1_EditField.Value = path;
        end

        % Button pushed function: dwi_Button
        function dwi_ButtonPushed(app, event)
            path = uigetdir('选择工作路径');
            figure(app.UIFigure)
            if isempty(path) % 如果用户取消选择
                figure(app.UIFigure)
                return;
            end
            app.dwi_EditField.Value = path;
        end

        % Button pushed function: NIFTIoutput_Button
        function NIFTIoutput_ButtonPushed(app, event)
            path = uigetdir('选择工作路径');
            figure(app.UIFigure)
            if isempty(path) % 如果用户取消选择
                figure(app.UIFigure)
                return;
            end
            app.NIFTIoutput_EditField.Value = path;
        end

        % Button pushed function: NIFTIstart_Button
        function NIFTIstart_ButtonPushed(app, event)
            T1file = app.T1_EditField.Value;
            dwifile = app.dwi_EditField.Value;
            outputpath = app.NIFTIoutput_EditField.Value;
            
            NIFTIsort(T1file, dwifile, outputpath);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 373 434];
            app.UIFigure.Name = '原始数据整理';

            % 设置窗口居中
            screenSize = get(0, 'ScreenSize');
            figureWidth = app.UIFigure.Position(3);
            figureHeight = app.UIFigure.Position(4);
            app.UIFigure.Position(1) = (screenSize(3) - figureWidth) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - figureHeight) / 2;

            % Create work_Button
            app.work_Button = uibutton(app.UIFigure, 'push');
            app.work_Button.ButtonPushedFcn = createCallbackFcn(app, @work_ButtonPushed2, true);
            app.work_Button.Position = [333 366 35 23];
            app.work_Button.Text = '...';

            % Create IMAstart_Button
            app.IMAstart_Button = uibutton(app.UIFigure, 'push');
            app.IMAstart_Button.ButtonPushedFcn = createCallbackFcn(app, @IMAstart_ButtonPushed2, true);
            app.IMAstart_Button.Position = [240 211 128 23];
            app.IMAstart_Button.Text = '开始提取';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [10 366 53 22];
            app.Label.Text = '工作路径';

            % Create work_EditField
            app.work_EditField = uieditfield(app.UIFigure, 'text');
            app.work_EditField.Editable = 'off';
            app.work_EditField.Position = [78 366 245 22];

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [10 327 207 22];
            app.Label_2.Text = '被试文件夹名称后缀 (如001T1则填T1)';

            % Create subfile_EditField
            app.subfile_EditField = uieditfield(app.UIFigure, 'text');
            app.subfile_EditField.Position = [232 327 91 22];

            % Create IMAEditFieldLabel
            app.IMAEditFieldLabel = uilabel(app.UIFigure);
            app.IMAEditFieldLabel.HorizontalAlignment = 'right';
            app.IMAEditFieldLabel.Position = [10 286 195 22];
            app.IMAEditFieldLabel.Text = '需要提取的IMA图像所在文件夹名称';

            % Create IMAfile_EditField
            app.IMAfile_EditField = uieditfield(app.UIFigure, 'text');
            app.IMAfile_EditField.Position = [220 286 103 22];

            % Create IMAoutput_Button
            app.IMAoutput_Button = uibutton(app.UIFigure, 'push');
            app.IMAoutput_Button.ButtonPushedFcn = createCallbackFcn(app, @IMAoutput_ButtonPushed, true);
            app.IMAoutput_Button.Position = [333 252 35 23];
            app.IMAoutput_Button.Text = '...';

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [10 252 53 22];
            app.Label_3.Text = '输出路径';

            % Create IMAoutput_EditField
            app.IMAoutput_EditField = uieditfield(app.UIFigure, 'text');
            app.IMAoutput_EditField.Editable = 'off';
            app.IMAoutput_EditField.Position = [78 252 245 22];

            % Create IMALabel
            app.IMALabel = uilabel(app.UIFigure);
            app.IMALabel.HorizontalAlignment = 'center';
            app.IMALabel.FontSize = 14;
            app.IMALabel.Position = [104 401 170 22];
            app.IMALabel.Text = '从原始文件中提取IMA图像';

            % Create IMALabel_2
            app.IMALabel_2 = uilabel(app.UIFigure);
            app.IMALabel_2.HorizontalAlignment = 'center';
            app.IMALabel_2.FontSize = 14;
            app.IMALabel_2.Position = [83 178 213 22];
            app.IMALabel_2.Text = '将IMA图像整理成预处理可用格式';

            % Create T1_Button
            app.T1_Button = uibutton(app.UIFigure, 'push');
            app.T1_Button.ButtonPushedFcn = createCallbackFcn(app, @T1_ButtonPushed, true);
            app.T1_Button.Position = [334 138 35 23];
            app.T1_Button.Text = '...';

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.Position = [11 138 65 22];
            app.Label_4.Text = '结构像路径';

            % Create T1_EditField
            app.T1_EditField = uieditfield(app.UIFigure, 'text');
            app.T1_EditField.Editable = 'off';
            app.T1_EditField.Position = [91 138 232 22];

            % Create dwi_Button
            app.dwi_Button = uibutton(app.UIFigure, 'push');
            app.dwi_Button.ButtonPushedFcn = createCallbackFcn(app, @dwi_ButtonPushed, true);
            app.dwi_Button.Position = [334 105 35 23];
            app.dwi_Button.Text = '...';

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.Position = [12 105 65 22];
            app.Label_5.Text = '弥散像路径';

            % Create dwi_EditField
            app.dwi_EditField = uieditfield(app.UIFigure, 'text');
            app.dwi_EditField.Editable = 'off';
            app.dwi_EditField.Position = [91 105 232 22];

            % Create NIFTIstart_Button
            app.NIFTIstart_Button = uibutton(app.UIFigure, 'push');
            app.NIFTIstart_Button.ButtonPushedFcn = createCallbackFcn(app, @NIFTIstart_ButtonPushed, true);
            app.NIFTIstart_Button.Position = [242 27 128 23];
            app.NIFTIstart_Button.Text = '开始整理';

            % Create NIFTIoutput_Button
            app.NIFTIoutput_Button = uibutton(app.UIFigure, 'push');
            app.NIFTIoutput_Button.ButtonPushedFcn = createCallbackFcn(app, @NIFTIoutput_ButtonPushed, true);
            app.NIFTIoutput_Button.Position = [334 69 35 23];
            app.NIFTIoutput_Button.Text = '...';

            % Create Label_6
            app.Label_6 = uilabel(app.UIFigure);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.Position = [13 69 53 22];
            app.Label_6.Text = '输出路径';

            % Create NIFTIoutput_EditField
            app.NIFTIoutput_EditField = uieditfield(app.UIFigure, 'text');
            app.NIFTIoutput_EditField.Editable = 'off';
            app.NIFTIoutput_EditField.Position = [91 69 232 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = sortimg

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