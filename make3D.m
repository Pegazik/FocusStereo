%% STRUCTURE FROM MOTION FROM TWO VIEWS
clear all; close all;
cam1 = ipcam('http://192.168.1.26:8080/video');
cam2 = ipcam('http://192.168.1.22:8080/video');
right = snapshot(cam2);
left = snapshot(cam1);
right = imadjust(right, []);
keft = imadjust(left, []);
load stereoparams;
% % Reading a pair of images
%left = imread('left1.png');
%right = imread('right1.png');
f1 = figure;
set(f1,'name','Original Images');
imshowpair(left,right,'montage');

% % Loading precomputed camera parameters
%load upToScaleReconstructionCameraParameters.mat 

% % Removing Lens Distortion
left = undistortImage(left, stereoParams.CameraParameters1);
right = undistortImage(right, stereoParams.CameraParameters2);
f2 = figure;
set(f2,'name','Undistorted Images');
imshowpair(left,right,'montage');

% % Finding point correspondences between the images
% Detecting feature points
imagePointsLeft = detectMinEigenFeatures(rgb2gray(left),'MinQuality',0.1);

% Visualizing detected points
f3 = figure;
set(f3,'name','Strongest Corners from the First Image');
imshow(left,'InitialMagnification',50);
hold on;
plot(selectStrongest(imagePointsLeft, 120000));

% Creating the point tracker
tracker = vision.PointTracker('MaxBidirectionalError',1,'NumPyramidLevels',5);

% Initializing the point tracker
imagePointsLeft = imagePointsLeft.Location;
initialize(tracker, imagePointsLeft, left);

% Tracking the points
[imagePointsRight validIdx] = step(tracker, right);
matchedPointsLeft = imagePointsLeft(validIdx,:);
matchedPointsRight = imagePointsRight(validIdx,:);

% Visualizing correspondence
f4 = figure;
set(f4,'name','Tracked Features');
showMatchedFeatures(left,right,matchedPointsLeft,matchedPointsRight);

% % Estimating the essential matrix
% Estimating the fundamental matrix
[E epipolarInliers] = estimateEssentialMatrix(...
    matchedPointsLeft,matchedPointsRight,stereoParams.CameraParameters1,stereoParams.CameraParameters2,'Confidence',99.99);

% Finding epipolar inliers
inlierPointsLeft = matchedPointsLeft(epipolarInliers, :);
inlierPointsRight = matchedPointsRight(epipolarInliers, :);

% Displaying inlier matches
f5 = figure;
set(f5,'name','Epipolar Inliers');
showMatchedFeatures(left, right, inlierPointsLeft, inlierPointsRight);

% % Computing the camera pose
% [orient loc] = relativeCameraPose(...
%     E, cameraParams, inlierPointsLeft, inlierPointsRight);

% % Reconstructing the 3D Locations of Matched Points
% Detecting dense feature points. Using an ROI (Region-Of-Interest)
% to exclude points close to the image edges.
roi = [30, 30, size(left, 2) - 30, size(left, 1) - 30];
imagePointsLeft = detectMinEigenFeatures(rgb2gray(left),'ROI',roi,...
    'MinQuality',0.001);

% Creating the point tracker
tracker = vision.PointTracker('MaxBidirectionalError',1,'NumPyramidLevels',5);

% Initializing the point tracker
imagePointsLeft = imagePointsLeft.Location;
initialize(tracker, imagePointsLeft, left);

% Tracking the points
[imagePointsRight validIdx] = step(tracker, right);
matchedPointsLeft = imagePointsLeft(validIdx,:);
matchedPointsRight = imagePointsRight(validIdx,:);

% Computing the camera matrices for each position of the camera
% The first camera is at the origin looking along the Z-axis. Thus, 
% its rotation matrix is identity and its translation vector is 0.
% camMatrix1 = cameraMatrix(cameraParams, eye(3), [0 0 0]);

% Computing extrinsics of the second camera
% [R t] = cameraPoseToExtrinsics(orient, loc);
% camMatrix2 = cameraMatrix(cameraParams, R, t);

% Computing the 3D points
points3D = triangulate(matchedPointsLeft, matchedPointsRight,stereoParams);

% Getting the color of each reconstructed point
numPixels = size(left, 1) * size(left, 2);
allColors = reshape(left, [numPixels 3]);
colorIdx = sub2ind([size(left,1) size(left,2)],...
    round(matchedPointsLeft(:,2)), round(matchedPointsLeft(:,1)));
color = allColors(colorIdx,:);

% Creating the point cloud
ptCloud = pointCloud(points3D, 'Color', color);

% % Displaying the 3D Point Cloud
% Visualising the camera locations and orientations
cameraSize = 0.3;
f6 = figure;
set(f6,'name','Up to Scale Reconstruction of the Scene');
plotCamera('Size',cameraSize,'Color','r','Label','1','Opacity',0);
hold on;
grid on;
% plotCamera('Location',loc,'Orientation',orient,'Size',cameraSize,...
%     'Color','b','Label','2','Opacity',0);

% Visualising the point cloud
pcshow(ptCloud, 'VerticalAxis','y','VerticalAxisDir','down',...
    'MarkerSize',45);

% Rotating and zooming the plot
camorbit(0, -30);
camzoom(1.5);

% Labelling the axes
xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis');



% % Fitting a Cubic Figure to the Point Cloud to Find the Searched Object

% % Metric Reconstruction of the Scene