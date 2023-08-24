classdef PBL_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure     matlab.ui.Figure
        GridLayout   matlab.ui.container.GridLayout
        TabGroup     matlab.ui.container.TabGroup
        Tab_1        matlab.ui.container.Tab
        GridLayout4  matlab.ui.container.GridLayout
        Button_5     matlab.ui.control.Button
        Button_10    matlab.ui.control.Button
        Button_7     matlab.ui.control.Button
        Button_6     matlab.ui.control.Button
        Tab_2        matlab.ui.container.Tab
        GridLayout2  matlab.ui.container.GridLayout
        Button_2     matlab.ui.control.Button
        Button_3     matlab.ui.control.Button
        Button_12    matlab.ui.control.Button
        Button_4     matlab.ui.control.Button
        Tab_3        matlab.ui.container.Tab
        GridLayout3  matlab.ui.container.GridLayout
        Slider_1     matlab.ui.control.Slider
        Label_2      matlab.ui.control.Label
        Slider_2     matlab.ui.control.Slider
        Label_3      matlab.ui.control.Label
        Slider_3     matlab.ui.control.Slider
        Label_4      matlab.ui.control.Label
        Tab_4        matlab.ui.container.Tab
        GridLayout5  matlab.ui.container.GridLayout
        Slider_5     matlab.ui.control.Slider
        Label_5      matlab.ui.control.Label
        Slider_4     matlab.ui.control.Slider
        Label_6      matlab.ui.control.Label
        Label        matlab.ui.control.Label
        DropDown     matlab.ui.control.DropDown
        LoadButton   matlab.ui.control.Button
        Button_8     matlab.ui.control.StateButton
        Button_9     matlab.ui.control.Button
        Button_11    matlab.ui.control.Button
        RedAxes      matlab.ui.control.UIAxes
        BlueAxes     matlab.ui.control.UIAxes
        GreenAxes    matlab.ui.control.UIAxes
        ImageAxes    matlab.ui.control.UIAxes
    end

    properties (Access = public)
        im
        im_hsv
        im_class
        im_tab
        im_init
    end
    
    methods (Access = private)
        
        function updateimage(app,imagefile)
            
            try
                if (ischar(imagefile))
                    app.im = imread(imagefile);
                else
                    app.im = imagefile;
                end
                
            catch ME
                % If problem reading image, display error message
                uialert(app.UIFigure, ME.message, 'Image Error');
                return;
            end
            
            app.im_class = size(app.im,3);
            if isempty(app.im_tab)
                app.im_tab = app.im;
                app.im_init = app.im;
            end
            % Create histograms based on number of color channels
            switch app.im_class
                case 1
                    % Display the grayscale image
                    imagesc(app.ImageAxes,app.im);
                    
                    % Plot all histograms with the same data for grayscale
                    histr = histogram(app.RedAxes, app.im, 'FaceColor',[1 0 0],'EdgeColor', 'none');
                    histg = histogram(app.GreenAxes, app.im, 'FaceColor',[0 1 0],'EdgeColor', 'none');
                    histb = histogram(app.BlueAxes, app.im, 'FaceColor',[0 0 1],'EdgeColor', 'none');
                    
                    
                case 3
                    
                    % Display the truecolor image
                    imagesc(app.ImageAxes,app.im);
                    
                    % Plot the histograms
                    histr = histogram(app.RedAxes, im2uint8(app.im(:,:,1)), 'FaceColor', [1 0 0], 'EdgeColor', 'none');
                    histg = histogram(app.GreenAxes, im2uint8(app.im(:,:,2)), 'FaceColor', [0 1 0], 'EdgeColor', 'none');
                    histb = histogram(app.BlueAxes, im2uint8(app.im(:,:,3)), 'FaceColor', [0 0 1], 'EdgeColor', 'none');
                    
                otherwise
                    % Error when image is not grayscale or truecolor
                    uialert(app.UIFigure, 'Image must be grayscale or truecolor.', 'Image Error');
                    return;
            end
            % Get largest bin count
            maxr = max(histr.BinCounts);
            maxg = max(histg.BinCounts);
            maxb = max(histb.BinCounts);
            maxcount = max([maxr maxg maxb]);
            
            % Set y axes limits based on largest bin count
            app.RedAxes.YLim = [0 maxcount];
            app.RedAxes.YTick = round([0 maxcount/2 maxcount], 2, 'significant');
            app.GreenAxes.YLim = [0 maxcount];
            app.GreenAxes.YTick = round([0 maxcount/2 maxcount], 2, 'significant');
            app.BlueAxes.YLim = [0 maxcount];
            app.BlueAxes.YTick = round([0 maxcount/2 maxcount], 2, 'significant');
            
        end
        

        
        function reset(app,mode)
            if mode == 0
                app.TabGroup.SelectedTab = app.Tab_1;
                app.Slider_1.Value = 0;
                app.Slider_2.Value = 0;
                app.Slider_3.Value = 0;
                if(app.im_class == 3)
                    app.im_hsv = rgb2hsv(app.im);
                    app.Button_10.Enable = 'on';
                    app.Button_7.Enable = 'on';
                end
                if(app.im_class == 1)
                    app.Button_10.Enable = 'off';
                    app.Button_7.Enable = 'off';
                end
            end
            
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Configure image axes
            app.ImageAxes.Visible = 'off';
            app.ImageAxes.Colormap = gray(256);
            axis(app.ImageAxes, 'image');
            
            % Update the image and histograms
            updateimage(app, 'peppers.png');
        end

        % Value changed function: DropDown
        function DropDownValueChanged(app, event)
            
            % Update the image and histograms
            updateimage(app, app.DropDown.Value);
            app.im_init = app.im;
            reset(app,0);
        end

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            
            % Display uigetfile dialog
            filterspec = {'*.jpg;*.tif;*.png;*.gif','All Image Files'};
            [f, p] = uigetfile(filterspec);
            
            % Make sure user didn't cancel uigetfile dialog
            if (ischar(p))
                fname = [p f];
                updateimage(app, fname);
                app.im_init = app.im;
                reset(app,0)
            end
        end

        % Value changed function: Button_8
        function compare(app, event)
            
            if app.Button_8.Value == 1
                im_0 = app.im;
                updateimage(app,app.im_init);
                app.im = im_0;
            else
                
                updateimage(app,app.im);
                
            end
        end

        % Button pushed function: Button_9
        function recovery(app, event)
            updateimage(app,app.im_init);
            reset(app,0);
        end

        % Button pushed function: Button_11
        function export(app, event)
            imsave(app.ImageAxes);
        end

        % Selection change function: TabGroup
        function secTab(app, event)
            selectedTab = app.TabGroup.SelectedTab;
            app.im_tab = app.im;
            if (selectedTab == app.Tab_3)
                if (app.im_class == 3)
                    app.im_hsv = rgb2hsv(app.im);
                    app.Slider_2.Enable = 'on';
                    app.Slider_3.Enable = 'on';
                else
                    app.Slider_2.Value = 0;
                    app.Slider_2.Enable = 'off';
                    app.Slider_3.Value = 0;
                    app.Slider_3.Enable = 'off';
                    
                end
                
            end
            if (selectedTab == app.Tab_4)
                app.Slider_4.Value = 0;
                app.Slider_5.Value = 0;
                
            end
            
        end

        % Button pushed function: Button_5
        function denoise(app, event)
            if app.im_class == 3
                J(:,:,1) = wiener2(app.im(:,:,1),[3 3]);
                J(:,:,2) = wiener2(app.im(:,:,2),[3 3]);
                J(:,:,3) = wiener2(app.im(:,:,3),[3 3]);
                updateimage(app,J);
            else
                J = wiener2(app.im,[3 3]);
                updateimage(app,J);
            end
        end

        % Button pushed function: Button_6
        function CLAHE(app, event)
            if (app.im_class == 3)
                lab_image = rgb2lab(app.im);
                % 提取亮度通道,将值缩放到 adapthisteq 函数预期的范围 [0 1]。
                luminance = lab_image(:, :, 1)/100;
                % 对亮度通道进行自适应直方图均衡化,缩放结果，使其回到 L*a*b* 颜色空间使用的范围。
                enhanced_luminance = adapthisteq(luminance)*100;
                % 替换原来的亮度通道
                lab_image(:,:,1) = enhanced_luminance;
                % 将图像转换回RGB空间
                enhanced_image = lab2rgb(lab_image);
                updateimage(app,enhanced_image);
            else
                J = adapthisteq(app.im);
                updateimage(app,J);
            end
        end

        % Button pushed function: Button_7
        function gamma(app, event)
            if (app.im_class == 3)
                sRGB = lin2rgb(app.im);
                updateimage(app,sRGB);
                
            end
        end

        % Button pushed function: Button_10
        function AWB(app, event)
            R = app.im(:,:,1);G = app.im(:,:,2);B = app.im(:,:,3);
            Rave = mean2(R);
            Gave = mean2(G);
            Bave = mean2(B);
            K = (Rave + Gave + Bave) / 3;
            
            R_new=(K/Rave)*R;G_new=(K/Gave)*G;B_new=(K/Bave)*B;
            J = (cat(3,R_new,G_new,B_new));
            updateimage(app,J);
        end

        % Button pushed function: Button_2
        function crop(app, event)
            J = imcrop(app.im);
            if ~isempty(J)
                updateimage(app,J);
                close all
            end
            
        end

        % Button pushed function: Button_3
        function rotation(app, event)
            J = imrotate(app.im,-90,'bilinear','crop');
            updateimage(app,J);
        end

        % Button pushed function: Button_4
        function flip1(app, event)
            J = fliplr(app.im);
            updateimage(app,J);
        end

        % Button pushed function: Button_12
        function flip2(app, event)
            J = flipud(app.im);
            updateimage(app,J);
        end

        % Value changed function: Slider_1, Slider_2, Slider_3
        function chge(app, event)
            if (app.im_class == 3)
                H = 0.0005*app.Slider_3.Value+1;
                S = 0.01*app.Slider_2.Value+1;
                V = 0.01*app.Slider_1.Value+1;
                hsv = app.im_hsv;
                hsv(:,:,1) = hsv(:,:,1)*H; % 色调
                hsv(:,:,2) = hsv(:,:,2)*S;% 饱和度
                hsv(:,:,3) = hsv(:,:,3)*V; % 亮度
                J = hsv2rgb(hsv);
                updateimage(app,J);
            else
                app.im = app.im_tab*(1+app.Slider_1.Value/100);
                updateimage(app,app.im);
            end
        end

        % Value changed function: Slider_4
        function sharpen(app, event)
            value= app.Slider_4.Value/50 ;
            sharpened_image = imsharpen(app.im_tab,'Amount',value);
            updateimage(app,sharpened_image);
        end

        % Value changed function: Slider_5
        function adjust(app, event)
            value = app.Slider_5.Value;
            det = value/200;
            J = imadjust(app.im_tab,[det 0.99-det]);
            updateimage(app,J);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [1 1 1];
            app.UIFigure.Position = [100 100 702 528];
            app.UIFigure.Name = '图片编辑';
            app.UIFigure.Icon = 'appicon.png';
            app.UIFigure.WindowStyle = 'modal';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x', '1.47x', '1x', '1.29x', '1x'};
            app.GridLayout.RowHeight = {'3x', '3x', '3x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout.RowSpacing = 5.29989776611328;
            app.GridLayout.Padding = [10 5.29989776611328 10 5.29989776611328];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @secTab, true);
            app.TabGroup.Layout.Row = [5 10];
            app.TabGroup.Layout.Column = [4 6];

            % Create Tab_1
            app.Tab_1 = uitab(app.TabGroup);
            app.Tab_1.AutoResizeChildren = 'off';
            app.Tab_1.Title = '处理';
            app.Tab_1.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.Tab_1);
            app.GridLayout4.ColumnWidth = {'3x', 'fit', '3x'};
            app.GridLayout4.RowHeight = {'fit', '1x', '1x'};

            % Create Button_5
            app.Button_5 = uibutton(app.GridLayout4, 'push');
            app.Button_5.ButtonPushedFcn = createCallbackFcn(app, @denoise, true);
            app.Button_5.FontSize = 14;
            app.Button_5.Layout.Row = 2;
            app.Button_5.Layout.Column = 1;
            app.Button_5.Text = '降噪';

            % Create Button_10
            app.Button_10 = uibutton(app.GridLayout4, 'push');
            app.Button_10.ButtonPushedFcn = createCallbackFcn(app, @AWB, true);
            app.Button_10.FontSize = 14;
            app.Button_10.Layout.Row = 3;
            app.Button_10.Layout.Column = 3;
            app.Button_10.Text = '自动白平衡';

            % Create Button_7
            app.Button_7 = uibutton(app.GridLayout4, 'push');
            app.Button_7.ButtonPushedFcn = createCallbackFcn(app, @gamma, true);
            app.Button_7.FontSize = 14;
            app.Button_7.Layout.Row = 3;
            app.Button_7.Layout.Column = 1;
            app.Button_7.Text = '伽马校正';

            % Create Button_6
            app.Button_6 = uibutton(app.GridLayout4, 'push');
            app.Button_6.ButtonPushedFcn = createCallbackFcn(app, @CLAHE, true);
            app.Button_6.FontSize = 14;
            app.Button_6.Layout.Row = 2;
            app.Button_6.Layout.Column = 3;
            app.Button_6.Text = '自动对比度增强';

            % Create Tab_2
            app.Tab_2 = uitab(app.TabGroup);
            app.Tab_2.AutoResizeChildren = 'off';
            app.Tab_2.Title = '调整';
            app.Tab_2.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Tab_2);
            app.GridLayout2.RowHeight = {'fit', '1x', '1x', '1x'};

            % Create Button_2
            app.Button_2 = uibutton(app.GridLayout2, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @crop, true);
            app.Button_2.FontSize = 16;
            app.Button_2.Layout.Row = 2;
            app.Button_2.Layout.Column = [1 2];
            app.Button_2.Text = '裁剪';

            % Create Button_3
            app.Button_3 = uibutton(app.GridLayout2, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @rotation, true);
            app.Button_3.FontSize = 16;
            app.Button_3.Layout.Row = 3;
            app.Button_3.Layout.Column = [1 2];
            app.Button_3.Text = '旋转';

            % Create Button_12
            app.Button_12 = uibutton(app.GridLayout2, 'push');
            app.Button_12.ButtonPushedFcn = createCallbackFcn(app, @flip2, true);
            app.Button_12.FontSize = 14;
            app.Button_12.Layout.Row = 4;
            app.Button_12.Layout.Column = 2;
            app.Button_12.Text = '镜像(垂直)';

            % Create Button_4
            app.Button_4 = uibutton(app.GridLayout2, 'push');
            app.Button_4.ButtonPushedFcn = createCallbackFcn(app, @flip1, true);
            app.Button_4.FontSize = 14;
            app.Button_4.Layout.Row = 4;
            app.Button_4.Layout.Column = 1;
            app.Button_4.Text = '镜像(水平)';

            % Create Tab_3
            app.Tab_3 = uitab(app.TabGroup);
            app.Tab_3.AutoResizeChildren = 'off';
            app.Tab_3.Title = '调节1';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.Tab_3);
            app.GridLayout3.ColumnWidth = {41, '1x'};
            app.GridLayout3.RowHeight = {21.99, 16.01, 21.99, 16.01, 21.99, 16.01};
            app.GridLayout3.RowSpacing = 7.2853878566197;
            app.GridLayout3.Padding = [10 7.2853878566197 10 7.2853878566197];

            % Create Slider_1
            app.Slider_1 = uislider(app.GridLayout3);
            app.Slider_1.Limits = [-100 100];
            app.Slider_1.ValueChangedFcn = createCallbackFcn(app, @chge, true);
            app.Slider_1.Layout.Row = [1 2];
            app.Slider_1.Layout.Column = 2;

            % Create Label_2
            app.Label_2 = uilabel(app.GridLayout3);
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.Layout.Row = [1 2];
            app.Label_2.Layout.Column = 1;
            app.Label_2.Text = '亮度';

            % Create Slider_2
            app.Slider_2 = uislider(app.GridLayout3);
            app.Slider_2.Limits = [-100 100];
            app.Slider_2.ValueChangedFcn = createCallbackFcn(app, @chge, true);
            app.Slider_2.Layout.Row = [3 4];
            app.Slider_2.Layout.Column = 2;

            % Create Label_3
            app.Label_3 = uilabel(app.GridLayout3);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Layout.Row = [3 4];
            app.Label_3.Layout.Column = 1;
            app.Label_3.Text = '饱和度';

            % Create Slider_3
            app.Slider_3 = uislider(app.GridLayout3);
            app.Slider_3.Limits = [-100 100];
            app.Slider_3.ValueChangedFcn = createCallbackFcn(app, @chge, true);
            app.Slider_3.Layout.Row = [5 6];
            app.Slider_3.Layout.Column = 2;

            % Create Label_4
            app.Label_4 = uilabel(app.GridLayout3);
            app.Label_4.HorizontalAlignment = 'center';
            app.Label_4.Layout.Row = [5 6];
            app.Label_4.Layout.Column = 1;
            app.Label_4.Text = '色调';

            % Create Tab_4
            app.Tab_4 = uitab(app.TabGroup);
            app.Tab_4.AutoResizeChildren = 'off';
            app.Tab_4.Title = '调节2';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.Tab_4);
            app.GridLayout5.ColumnWidth = {47, '1x'};
            app.GridLayout5.RowHeight = {'fit', '1x', '1x'};

            % Create Slider_5
            app.Slider_5 = uislider(app.GridLayout5);
            app.Slider_5.ValueChangedFcn = createCallbackFcn(app, @adjust, true);
            app.Slider_5.FontSize = 14;
            app.Slider_5.Layout.Row = 3;
            app.Slider_5.Layout.Column = 2;

            % Create Label_5
            app.Label_5 = uilabel(app.GridLayout5);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.FontSize = 14;
            app.Label_5.Layout.Row = 3;
            app.Label_5.Layout.Column = 1;
            app.Label_5.Text = '对比度';

            % Create Slider_4
            app.Slider_4 = uislider(app.GridLayout5);
            app.Slider_4.ValueChangedFcn = createCallbackFcn(app, @sharpen, true);
            app.Slider_4.FontSize = 14;
            app.Slider_4.Layout.Row = 2;
            app.Slider_4.Layout.Column = 2;

            % Create Label_6
            app.Label_6 = uilabel(app.GridLayout5);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.FontSize = 14;
            app.Label_6.Layout.Row = 2;
            app.Label_6.Layout.Column = 1;
            app.Label_6.Text = '锐化';

            % Create Label
            app.Label = uilabel(app.GridLayout);
            app.Label.BackgroundColor = [0.8 0.8 0.8];
            app.Label.HorizontalAlignment = 'center';
            app.Label.FontName = '方正姚体';
            app.Label.FontSize = 14;
            app.Label.Layout.Row = 5;
            app.Label.Layout.Column = [2 3];
            app.Label.Text = '预设图像';

            % Create DropDown
            app.DropDown = uidropdown(app.GridLayout);
            app.DropDown.Items = {'Peppers', 'Cameraman', 'Saturn', 'Lowlight_1'};
            app.DropDown.ItemsData = {'peppers.png', 'cameraman.tif', 'saturn.png', 'lowlight_1.jpg'};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
            app.DropDown.FontName = '方正姚体';
            app.DropDown.FontSize = 14;
            app.DropDown.BackgroundColor = [0.9412 0.9412 0.9412];
            app.DropDown.Layout.Row = 6;
            app.DropDown.Layout.Column = [2 3];
            app.DropDown.Value = 'peppers.png';

            % Create LoadButton
            app.LoadButton = uibutton(app.GridLayout, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.LoadButton.FontName = '方正姚体';
            app.LoadButton.FontSize = 14;
            app.LoadButton.Layout.Row = 8;
            app.LoadButton.Layout.Column = [2 3];
            app.LoadButton.Text = '导入图像';

            % Create Button_8
            app.Button_8 = uibutton(app.GridLayout, 'state');
            app.Button_8.ValueChangedFcn = createCallbackFcn(app, @compare, true);
            app.Button_8.Text = '对比';
            app.Button_8.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Button_8.FontName = '方正姚体';
            app.Button_8.FontSize = 14;
            app.Button_8.Layout.Row = 9;
            app.Button_8.Layout.Column = 2;

            % Create Button_9
            app.Button_9 = uibutton(app.GridLayout, 'push');
            app.Button_9.ButtonPushedFcn = createCallbackFcn(app, @recovery, true);
            app.Button_9.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Button_9.FontName = '方正姚体';
            app.Button_9.FontSize = 14;
            app.Button_9.Layout.Row = 9;
            app.Button_9.Layout.Column = 3;
            app.Button_9.Text = '复原';

            % Create Button_11
            app.Button_11 = uibutton(app.GridLayout, 'push');
            app.Button_11.ButtonPushedFcn = createCallbackFcn(app, @export, true);
            app.Button_11.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Button_11.FontName = '方正姚体';
            app.Button_11.FontSize = 14;
            app.Button_11.Layout.Row = 10;
            app.Button_11.Layout.Column = [2 3];
            app.Button_11.Text = '导出图像';

            % Create RedAxes
            app.RedAxes = uiaxes(app.GridLayout);
            title(app.RedAxes, 'Red')
            xlabel(app.RedAxes, 'Intensity')
            ylabel(app.RedAxes, 'Pixels')
            app.RedAxes.XLim = [0 255];
            app.RedAxes.XTick = [0 128 255];
            app.RedAxes.Layout.Row = 1;
            app.RedAxes.Layout.Column = [5 6];

            % Create BlueAxes
            app.BlueAxes = uiaxes(app.GridLayout);
            title(app.BlueAxes, 'Blue')
            xlabel(app.BlueAxes, 'Intensity')
            ylabel(app.BlueAxes, 'Pixels')
            app.BlueAxes.XLim = [0 255];
            app.BlueAxes.XTick = [0 128 255];
            app.BlueAxes.Layout.Row = 3;
            app.BlueAxes.Layout.Column = [5 6];

            % Create GreenAxes
            app.GreenAxes = uiaxes(app.GridLayout);
            title(app.GreenAxes, 'Green')
            xlabel(app.GreenAxes, 'Intensity')
            ylabel(app.GreenAxes, 'Pixels')
            app.GreenAxes.XLim = [0 255];
            app.GreenAxes.XTick = [0 128 255];
            app.GreenAxes.Layout.Row = 2;
            app.GreenAxes.Layout.Column = [5 6];

            % Create ImageAxes
            app.ImageAxes = uiaxes(app.GridLayout);
            app.ImageAxes.XTick = [];
            app.ImageAxes.XTickLabel = {'[ ]'};
            app.ImageAxes.YTick = [];
            app.ImageAxes.Layout.Row = [1 3];
            app.ImageAxes.Layout.Column = [1 4];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PBL_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

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