clear all; close all;

cam1 = ipcam('http://192.168.1.26:8080/video');
cam2 = ipcam('http://192.168.1.22:8080/video');

% preview(cam1);
% 
% preview(cam2);
pause(7);
for i=1:70

    image1 = snapshot(cam1);
    image2 = snapshot(cam2);
    imshow(image1);
    title(['Zdjecie nr', num2str(i)]);
    
    imwrite(image1, ['./cam1/image', num2str(i), '.png']);
    imwrite(image2, ['./cam2/image', num2str(i), '.png']);
    pause(2);
end
%19mmm
%stereoCameraCalibrator