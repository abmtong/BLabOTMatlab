function BurstSize__Main_GUI_ScreenCapture(FileName,Extension)
% FileName is the complete filename [Folder filesep File]
% Extension is either 'png' or 'jpg'
%
% USE: BurstSize__Main_GUI_ScreenCapture(FileName,Extension)
%
% Gheorghe Chistol, saurabh kumar, 25 Feb 2013

    robo = java.awt.Robot;
    t = java.awt.Toolkit.getDefaultToolkit();
    rectangle = java.awt.Rectangle(t.getScreenSize());
    image = robo.createScreenCapture(rectangle);
    filehandle = java.io.File([FileName '.' Extension]);
    javax.imageio.ImageIO.write(image,Extension,filehandle);
    %imageview('screencapture.png');
end