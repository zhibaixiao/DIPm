
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

- `'Radius'`：设置非锐化掩蔽过程中使用的滤波器半径。较大的半径将会增加图像的锐化程度。默认值为 0.5。
- `'Amount'`：设置非锐化掩蔽增强的强度。较大的值将导致更强烈的锐化效果。默认值为 1.0。
- `'Threshold'`：设置非锐化掩蔽过程中用于抑制低对比度细节的阈值。较大的阈值将减少锐化效果。默认值为 0.01。

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
