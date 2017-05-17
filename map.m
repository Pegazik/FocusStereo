function[mapa] = map(ptCloud, varargin)
%ptCloud - point cloud, filtered
%arg 2: box - size of single map pixel in real life (in centimeters)
%arg 3: [x1, x2] - upper and lower limits of x axis(width)
%arg 4: [z1, z2] - upper and lower limits of z axis(depth)
%arg 5: [y1, y2] - upper and lower limits of y axis(height)
%output: map of size (x2-x1, y2-y1)/10*box in RGB, where: 
%R represents medium height in milimeters mapped to 0-255
%G represents weight (confidence) of measurement, being no. of measurements
%mapped to 0-255
%B - not implemented yet. Will represent in 0-1 if terrain is traversible
%or traversibility of terrain defined by smallest or median directional
%derivative of height
if(nargin<5)
    ythresh = 4000;
    dythresh = -2000;
else
    ythresh = varargin{4}(1);
    dythresh = varargin{4}(2);
end;
if(nargin<4)
    zthresh = 5000;
    dzthresh = -5000;
else
    zthresh = varargin{3}(1);
    dzthresh = varargin{3}(2);
end;
if(nargin<3)
    xthresh = 5000;
    dxthresh = -5000;
else
    xthresh = varargin{2}(1);
    dxthresh = varargin{2}(2);
end;
if(nargin<2)
    box = 1;
else
    box = varargin{1};
end
sx = abs(xthresh-dxThresh);
sy = abs(ythresh-dyThresh);
sz = abs(zthresh-dzThresh);

mapa = zeros(abs(zthresh-dzThresh)/(10*box), abs(xthresh-dxThresh)/(10*box), 3);
mapa(:,:,3) = 1;
for i = 1:size(points3D, 1)
    x = points3D(i, 1);
    y = points3D(i, 2);
    z = points3D(i, 3);
    px = floor( (x - dxThresh)/(sx)*size(mapa, 1))+1;
    py = floor( (z - dzThresh)/(sz)*size(mapa, 2))+1;
    mapa(px, py, 1) = (((y - dyThresh)/(sy)*255)/(mapa(px, py, 2)+1) + mapa(px, py, 1)*mapa(px, py, 2)/(mapa(px, py, 2)+1))/255;
    mapa(px, py, 2) = mapa(px, py, 2)+1/255;
end
mapa = permute(mapa, [2 1 3]);
