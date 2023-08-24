
# DIPm

一个使用MATLAB App Designer开发的简单数字图像处理APP

## 图像处理函数

### 自动调整

#### 降噪

[`wiener2`](https://ww2.mathworks.cn/help/images/ref/wiener2.html?s_tid=doc_ta):二维自适应去噪滤波
基于图像的局部统计特性来估计噪声方差，并根据噪声的特性进行滤波。这种滤波方法通常在存在噪声的图像中能够有效地减少噪声并保持图像的细节。

```matlab
function denoise(app, event)  % 去噪按钮按下时执行的函数
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
```

#### 伽马校正

[`lin2rgb`](https://ww2.mathworks.cn/help/images/ref/lin2rgb.html?s_tid=doc_ta):将线性 RGB 值应用伽马校正，使其转换为适合显示的 sRGB 色彩空间。对图像中的像素值进行非线性变换，使较暗区域的细节更加可见，同时保持较亮区域的细节不被过度压缩。这样可以增强图像的对比度，使其在显示时更加生动和自然。

```matlab
function gamma(app, event)  % gamma按钮按下时执行的函数
    if (app.im_class == 3)
        sRGB = lin2rgb(app.im); % 将线性RGB图像转换为sRGB图像
        updateimage(app,sRGB);
        
    end
end
```

#### 自动白平衡

当人们用眼晴观察自然世界时，在不同的光线下，对相同颜色的感觉基本是相同的，大脑已经对不同光线下的物体的彩色还原有了适应性。这种现象称为颜色恒常性。不幸的是，CMOS或CCD等感光器件没有这样的适应能力。
为了使得摄像机也具有颜色恒常性能力，需要使用白平衡技术。所谓白平衡(WiteBalance),简单地说就是去除环境光的影响，还原物体真实的颜色，把不同色温下的白颜色调整正确。从理论上说白颜色调整正确了，其他色彩就都准确了。即在红色灯光照射下，白色物体依然呈白色，在蓝色灯光照射下也呈现白色。
灰度世界算法以灰度世界假设为基础，该假设认为：对于一幅有着大量色彩变化的图像,其R,G,B 三个色彩分量的平均值趋于同一灰度值 K。 从物理意义上讲，灰色世界法假设自然界景物对于光线的平均反射的均值在总体上是个定值，这个定值近似地为“灰色”。 颜色平衡算法将这一假设强制应用于待处理图像，可以从图像中消除环境光的影响，获得原始场景图像。

```matlab
function AWB(app, event)   % 白平衡
    R = app.im(:,:,1);G = app.im(:,:,2);B = app.im(:,:,3);
    Rave = mean2(R);
    Gave = mean2(G);
    Bave = mean2(B);
    K = (Rave + Gave + Bave) / 3;
    
    R_new=(K/Rave)*R;G_new=(K/Gave)*G;B_new=(K/Bave)*B;
    J = (cat(3,R_new,G_new,B_new));
    updateimage(app,J);
end
```

#### 自动对比度增强

MATLAB中有三个函数适用于对比度增强：

- `imadjust`：将输入强度图像的值映射到新值，以对输入数据中强度最低和最高的 1%（默认值）数据进行饱和处理，从而提高图像的对比度。
- `histeq`：执行直方图均衡化。它变换强度图像中的值，以使输出图像的直方图近似匹配指定的直方图（默认情况下为均匀分布），从而增强图像的对比度。
- `adapthisteq` ：执行对比度受限的自适应直方图均衡化。与 histeq 不同，它对小数据区域（图块）而不是整个图像执行运算。它会增强每个图块的对比度，使得每个输出区域的直方图近似匹配指定的直方图（默认情况下为均匀分布）。可以限制对比度增强，以避免放大图像中可能存在的噪声。
通过对比以下各图，可以看出`adapthisteq`方法效果最好。
![duibidubijiao](<Pasted image 20230622152850.png>)
[`adapthisteq`](https://ww2.mathworks.cn/help/images/ref/adapthisteq.html?s_tid=doc_ta):对比度受限的自适应直方图均衡化 (CLAHE)
通过在LAB空间中对亮度通道进行处理，我们能够保持彩色图像的整体色彩平衡，因为在LAB空间中，色度通道（a和b通道）与亮度通道（L通道）是相互独立的。这种方法可以在增强对比度的同时保持图像的自然色彩。

```matlab
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
            J = adapthisteq(app.im);  % 灰度图像直方图均衡化增强对比度
            updateimage(app,J);
        end
end
```

### 图像几何变换

#### 裁剪

[`imcrop`](https://ww2.mathworks.cn/help/images/ref/imcrop.html?s_tid=doc_ta)：`imcrop` 创建与当前图窗中显示的灰度、真彩色或二值图像相关联的交互式裁剪图像工具。`imcrop` 返回裁剪的图像 `Icropped`。

```matlab
       function crop(app, event)   % 裁剪按钮按下时执行的函数
            J = imcrop(app.im);
            if ~isempty(J)       % 如果用户没有取消裁剪
                updateimage(app,J);
                close all
            end
        end
```

#### 旋转

[`imrotate`](https://ww2.mathworks.cn/help/images/ref/imrotate.html?s_tid=doc_ta):`J = imrotate(I,angle)`将图像 I 围绕其中心点逆时针方向旋转 angle 度。要顺时针旋转图像，请为 angle 指定负值。imrotate 使输出图像 J 足够大，可以包含整个旋转图像。默认情况下，imrotate 使用最近邻点插值，对于数值和逻辑图像，将 J 中位于旋转后的图像外的像素的值设置为 0；对于分类图像，设置为 missing。

```matlab
function rotation(app, event)  % 旋转按钮按下时执行的函数
    J = imrotate(app.im,-90,'bilinear','crop'); % 逆时针旋转90度
    updateimage(app,J);
end
```

#### 翻转

[`fliplr`](https://ww2.mathworks.cn/help/matlab/ref/fliplr.html?s_tid=doc_ta):围绕垂直轴按左右方向翻转其各列。对于多维数组，`fliplr` 作用于由第一个和第二个维度构成的平面。
[`flipud`](https://ww2.mathworks.cn/help/matlab/ref/flipud.html?s_tid=doc_ta):围绕水平轴按上下方向翻转其各行。

```matlab
function flip1(app, event)  % 水平翻转按钮按下时执行的函数
    J = fliplr(app.im);    
    updateimage(app,J);
end
    function flip2(app, event)   % 垂直翻转图像
    J = flipud(app.im);
    updateimage(app,J);
end
```

### 图像调节

#### 亮度、饱和度、色调调节

HSV模型的三个分量（色相、饱和度、亮度）是相互独立的，调节其中一个分量不会直接影响其他分量。
[`rgb2hsv`](https://ww2.mathworks.cn/help/matlab/ref/rgb2hsv.html?s_tid=doc_ta):将 RGB 图像的红色、绿色和蓝色值转换为 HSV 图像的色调、饱和度和明度 (HSV) 值。
[`hsv2rgb`](https://ww2.mathworks.cn/help/matlab/ref/hsv2rgb.html?s_tid=doc_ta):将 HSV 图像的色调、饱和度和明度值转换为 RGB 图像的红色、绿色和蓝色值。

```matlab
function chge(app, event)  % 滑动条改变时执行的函数
    if (app.im_class == 3)
        H = 0.002*app.Slider_3.Value+1; % 色调调节因子
        S = 0.01*app.Slider_2.Value+1;  % 饱和度调节因子
        V = 0.01*app.Slider_1.Value+1;  % 亮度调节因子
        hsv = app.im_hsv;
        hsv(:,:,1) = hsv(:,:,1)*H; % 色调
        hsv(:,:,2) = hsv(:,:,2)*S;% 饱和度
        hsv(:,:,3) = hsv(:,:,3)*V; % 亮度
        J = hsv2rgb(hsv);
        updateimage(app,J);
    else
        app.im = app.im_tab*(1+app.Slider_1.Value/100);
        % 灰度图像亮度调节
        updateimage(app,app.im);
    end
end
```

#### 对比度调节

[`imadjust`](https://ww2.mathworks.cn/help/images/ref/imadjust.html?s_tid=doc_ta):调整图像强度值或颜色图
`J = imadjust(I,[low_in high_in])`将 I 中的强度值映射到 J 中的新值，以使 low_in 和 high_in 之间的值映射到 0 到 1 之间的值。

```matlab
function adjust(app, event)  % 手动调节对比度
    value = app.Slider_5.Value;
    det = value/200;
    J = imadjust(app.im_tab,[det 0.99-det]);  
    updateimage(app,J);
end
```

#### 锐化

[`imsharpen`](https://ww2.mathworks.cn/help/images/ref/imsharpen.html?s_tid=doc_ta):使用非锐化掩蔽（unsharp masking）方法对灰度图像或真彩色（RGB）图像进行锐化处理。
该方法通过对原始图像与其高频成分之间的差异进行增强来实现图像的锐化。可以通过 `Name-Value` 形式进行设置具体参数：

- `Radius`：设置非锐化掩蔽过程中使用的滤波器半径。较大的半径将会增加图像的锐化程度。默认值为 0.5。
- `Amount`：设置非锐化掩蔽增强的强度。较大的值将导致更强烈的锐化效果。默认值为 1.0。
- `Threshold`：设置非锐化掩蔽过程中用于抑制低对比度细节的阈值。较大的阈值将减少锐化效果。默认值为 0.01。

```matlab
function sharpen(app, event)   % 锐化
    value= app.Slider_4.Value/50 ;   % 锐化因子
    sharpened_image = imsharpen(app.im_tab,'Amount',value); % 锐化
    updateimage(app,sharpened_image);  % 更新图像
end
```

### 参考资料

1. [Image Processing Toolbox Documentation - MathWorks 中国](https://ww2.mathworks.cn/help/images/?s_tid=srchbrcm)
2. [对比度增强方法 - MATLAB & Simulink - MathWorks 中国](https://ww2.mathworks.cn/help/images/contrast-enhancement-techniques.html)
3. 《计算摄影学基础》张茂军等 白平衡部分
4. [App 构建组件 - MATLAB & Simulink - MathWorks 中国](https://ww2.mathworks.cn/help/matlab/creating_guis/choose-components-for-your-app-designer-app.html)
5. [如何实现网页运行matlab程序？ - 知乎 (zhihu.com)](https://www.zhihu.com/question/266000152)

## APP设计

项目的任务是做一个拍照质量提高的项目，根据日常生活经验，拍照质量受到很多因素影响，比如拍摄时的环境，拍摄器材，拍摄时参数，后期处理等等，而我们注重的是图片的后期处理。至于图片的后期处理，现在有许多成熟的软件，比如Photoshop，美图秀秀，甚至还有许多网页版实现。但考虑到难度，时间等因素，我们参考了简单的手机图片编辑软件，对照着实现了部分功能。

### 框架设计

总体来说，APP主要实现以下几个部分。其中最关键的部分是处理图像部分,可以将其转化为各种基本处理函数的组合调用。

![Alt text](<Pasted image 20230623093941.png>)

界面设计，初步计划如下：

![Alt text](<Pasted image 20230623094413.png>)

本次开发APP使用的开发环境是MATLAB R2020b,这个版本APP Designer有了许多有用的更新，比如uitable也加入了列宽定义为可变宽度，按钮和面板组加入了Enable选项等实用的功能。

### 开发方法

APP Designer使用[面向对象语言编程](https://ww2.mathworks.cn/products/matlab/object-oriented-programming.html)，页面分为设计视图和代码视图界面，实现了前端和后端的分离，可以分别进行设计，最后组合在一起。
下图是设计视图，左侧是一些组件，这些组件本身有一些属性可以在右侧查看，如位置，字体颜色，交互性等。而每个组件的回调函数，可以让用户的行为触发相应的函数，响应用户操作。

![Alt text](<Pasted image 20230623101156.png>)

App程序采用面向对象设计模式，声明对象、定义函数、设置属性和共享数据都封装在一个类中，一个MLAPP文件就是一个类的定义。

**① 类的基本结构**
properties段：属性的定义，主要包含属性声明代码。
methods段：方法的定义，由若干函数组成。回调函数只有一个参数app，为界面句柄，存储了界面中各个成员的数据。

```matlab
classdef 类名 < matlab.apps.AppBase 
    properties (Access = public) 
    … 
    end 
    methods (Access = private) 
        function 函数1(app) 
        … 
        end 
        function 函数2(app) 
        … 
        end 
    end 
end 
```

存取数据和调用函数称为访问对象成员。

**② 访问权限**
public：可用于与App的其他类共享数据。
private：只允许在本类中访问。
以下属性和函数的默认访问权限为private。

- 属性的声明
- 界面的启动函数startupFcn
- 建立界面组件的函数createComponents
- 回调函数

下面是空白APP的代码，可以清晰的看清代码的结构。

```matlab
classdef app1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure  matlab.ui.Figure
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app1

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
```

本次项目代码的整体结构如下

![Alt text](<Pasted image 20230623153656.png>)

### 前端设计

首先可以使用网格布局，配置加权大小。并开启图窗的位置中的`Resize`属性，使其能根据窗口大小自动调整布局。

![Alt text](<Pasted image 20230623120828.png>)

接下来拖动相应的组件，并编辑。

![Alt text](<Pasted image 20230623121203.png>)

设置好相应的回调函数之后，打开APP，最终效果如下

![Alt text](<Pasted image 20230623115257.png>)

### 后端设计

#### 图像输入和输出

首先要进行图像输入和输出功能的设计，并为图像处理部分提供相应的接口。
图像输入分为软件预设图像和用户上传图像两部分
**预设图像选择部分**

```matlab
function DropDownValueChanged(app, event)
 
 % Update the image and histograms
 updateimage(app, app.DropDown.Value);
 app.im_init = app.im;
 reset(app,0);
end
```

这部分主要完成对下拉列表值得获取，初始并不处理图像，所以将值直接传递给图像输出函数。

**用户上传图像部分**

```matlab
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
```

这部分主要用到了`uigetfile`这个内置函数，该函数可以打开文件选择对话框，让用户选择相应文件，并返回文件的名称和路径，同样上传后不做处理直接输出。

**图像输出部分**
这部分比较简单，直接调用内置的`imsava`函数即可。

```matlab
function export(app, event)
 imsave(app.ImageAxes);
end
```

#### 图像处理部分

这部分是项目的关键，具体的图像处理算法，这里不详细介绍，主要介绍关于APP的设计问题。输入和输出的功能已经实现，图像处理作为一个整体，又可分解为一次次基本图像处理的组合。如下图所示，每次处理之后为了直观展现处理效果，方便调节，所以也要进行显示。而还原是和对比又为每次处理提供了更多的选择性。

![Alt text](<Pasted image 20230623112107.png>)

图像处理部分由于分解为按步处理，所以要定义属性，方便不同处理函数之间共享数据。且对比和还原功能也需要相应的属性。

```
properties (Access = public)
 im     % 当前显示的图像数据
 im_hsv  % 打开调节1选项卡时保存的HSV空间数据
 im_class  % 图像类别数据
 im_tab    % 选项卡图像数据
 im_init     % 初始图像数据
end
```

如果对当前图像进行某个处理，便可以将`im`的属性传递给该处理函数，处理之后，调用图像显示函数，更新`im`并显示图像。
将`im_init`传入图像更新函数，便可将`im`恢复到`im_init`，实现**图像复原**。
由于图像更新后`im`属性也会改变，**图像对比**要定义一个局部变量暂存现在的图像。

```matlab
function compare(app, event)
 if app.Button_8.Value == 1
  im_0 = app.im;
  updateimage(app,app.im_init);
  app.im = im_0;
 else
  updateimage(app,app.im);
 end
end
```

不同于图像处理部分需要根据处理方式设计不同的函数，图像显示可以设计为可复用函数的形式，将某图像和其直方图显示出来。
由于为输入图像传入或者为处理后图像传入，为了实现函数的复用，所以进行判断选择，而且加入错误提示。
**图像更新函数**`updateimage(app,imagefile)`分解如下：

```matlab
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
```

之后是图像的显示输出。这里根据图像类型为灰度还是真彩色，分别进行不同的显示。

```matlab
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
```

### 发布和共享

根据官方[共享 App 的方式](https://ww2.mathworks.cn/help/matlab/creating_guis/app-sharing.html)所列举的几种方式，其中直接共享m文件和打包成APP最为方便，但却要求用户安装有MATLAB，虽然可以使用MATLAB Online版本，但一般没有正版工具箱使用权限。而创建独立的桌面应用程序虽然不需要MATLAB本体，但仍需用户要下载用户必须在其系统上安装 MATLAB Runtime运行程序。所以我们选择了使用创建预部署 Web App，此方法允许创建网络内的用户可以在其 Web 浏览器上运行的 App。
从2018a开始Matlab提供了Web Apps功能，它能够将电脑设为服务器，把App程序发布到局域网，可以通过浏览器访问。使用步骤为

- 使用App Designer创建交互式的应用程序；
- 使用Web App Compiler打包；
- 基于MATLAB Web App Server托管。
具体步骤不再赘述，搭建好后，可以在主页中看到发布的APP，而且同一局域网内可以在浏览器输入`server ip address:port`进行访问。但由于限制和自身水平有限，现在只能体验部分功能。
![Alt text](<Pasted image 20230623154041.png>)

![Alt text](<Pasted image 20230623154326.png>)

## 总结

本次APP的设计，依赖MATLAB的APP Designer，很方便的制作出来。体验到了APP开发的基本流程，虽然最后开发的APP仍然有很多缺点，比如性能不够好，调节参数设置还不够合理，Web端功能部分失效，但鉴于开发时间较短，仅仅几天的时间做出来的需要完善的地方仍然有很多。
