
# YEPasswordRing ![App Icon](https://github.com/Eugenia-Ye/YEPasswordRing/blob/master/Resources/Images/Icon-App.png)
----------
# Demo
<img src="https://github.com/Eugenia-Ye/YEPasswordRing/blob/master/YEPasswordRingDemo.gif">

# IBInspectable
With IBInspectable, it’s possible to build a custom interface for configuring our custom controls and have them rendered in real-time while designing project.

IBInspectable properties provide new access to an old feature: user-defined runtime attributes. They provide a powerful mechanism for configuring any key-value coded property of an instance in a NIB, XIB, or storyboard:

![IBInspectable](https://github.com/Eugenia-Ye/YEPasswordRing/blob/master/IBInspectable.png)

While powerful, runtime attributes can be cumbersome to work with.  In YEPasswordRing, there are two IBInspectable properties in a YERingView with their values:

    @interface YERingView : UIView
        
    @property (nonatomic) IBInspectable CGFloat thickness;
       
    @property (nonatomic) IBInspectable int segments;

Marked with IBInspectable, they are easily editable in Interface Builder’s inspector panel. Now we have created a configurable annulus radius or thickness and segments.


