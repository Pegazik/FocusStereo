clear all; close all;

load stereoParams;

showExtrinsics(stereoParams);

left = 'left.avi';
right = 'right.avi';

readerLeft = vision.VideoFileReader(left, 'VideoOutputDataType', 'uint8');
readerRight = vision.VideoFileReader(right, 'VideoOutputDataType', 'uint8');
player = vision.DeployableVideoPlayer('Location', [20 400]);

frameLeft = readerLeft.step();
frameRight = readerRight.step();

[frameLeftRect frameRightRect] = rectifyStereoImages(frameLeft, frameRight, stereoParams);

figure;
imshow(stereoAnaglyph(frameLeftRect, frameRightRect));
title('Rectified Video Frames');

frameLeftGray = rgb2gray(frameLeftRect);
frameRightGray = rgb2gray(frameRightRect);

disparityMap = disparity(frameLeftGray, frameRightGray);
figure;
imshow(disparityMap, [0 64]);
title('Disparity Map');
colormap jet;
colorbar;

points3D = reconstructScene(disparityMap, stereoParams);

points3D = points3D ./ 1000;
ptCloud = pointCloud(points3D, 'Color', frameLeftRect);

player3D = pcplayer([-3 3], [-3 3], [0 8], 'VerticalAxis', 'y', 'VerticalAxisDir', 'down');

view(player3D, ptCloud);

