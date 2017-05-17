function[mapa] = map(ptCloud, varargin)
%ptCloud - point cloud
%Name-value pairs:
%box - size of single map pixel in real life (in centimeters)
%default 1
%xlim - [x1, x2] - upper and lower limits of x axis(width) 
%default [-5000, 5000]
%zlim - [z1, z2] - upper and lower limits of z axis(depth)
%default [-5000, 5000]
%ylim - [y1, y2] - upper and lower limits of y axis(height)
%default [-2000, 4000]
%output: map of size (x2-x1, y2-y1)/10*box in RGB, where: 
%R represents medium height in milimeters mapped to 0-255
%G represents weight (confidence) of measurement, being no. of measurements
%mapped to 0-255
%B - not implemented yet. Will represent in 0-1 if terrain is traversible
%or traversibility of terrain defined by smallest or median directional
%derivative of height
p = inputParser;

defaultxlim = [-5000, 5000]; 
defaultzlim = [-5000, 5000];
defaultylim = [-2000, 4000];
defaultbox = 1;

classes = {'numeric'};
attributes = {'size',[1, 2]};
validFcn = @(f) validateattributes(f, classes, attributes);

addParamValue(p,'xlim',defaultxlim,validFcn);
addParamValue(p,'ylim',defaultylim,validFcn);
addParamValue(p,'zlim',defaultzlim,validFcn);
addParamValue(p, 'box', defaultbox, @isnumeric);
parse(p,varargin{:});

dxthresh= p.Results.xlim(1);
xthresh= p.Results.xlim(2);
dythresh = p.Results.ylim(1);
ythresh = p.Results.ylim(2);
dzthresh = p.Results.zlim(1);
zthresh = p.Results.zlim(2);
box = p.Results.box;

sx = abs(xthresh-dxthresh);
sy = abs(ythresh-dythresh);
sz = abs(zthresh-dzthresh);

points3D = ptCloud.Location;
color = ptCloud.Color;
k = 0;
for i = 1:size(points3D, 1)
    if(points3D(i, 1) > xthresh || points3D(i, 1) < dxthresh || points3D(i, 2) > ythresh ||...
           points3D(i, 2) < dythresh || points3D(i, 3) > zthresh || points3D(i, 3) < dzthresh)
        k = k+1;
        del(k) = i;
    end
end

points3D(del, :) = [];
color(del, :) = [];

mapa = zeros(abs(zthresh-dzthresh)/(10*box), abs(xthresh-dxthresh)/(10*box), 3);
mapa(:,:,3) = 1;
for i = 1:size(points3D, 1)
    x = points3D(i, 1);
    y = points3D(i, 2);
    z = points3D(i, 3);
    px = floor( (x - dxthresh)/(sx)*size(mapa, 1))+1;
    py = floor( (z - dzthresh)/(sz)*size(mapa, 2))+1;
    mapa(px, py, 1) = (((y - dythresh)/(sy)*255)/(mapa(px, py, 2)+1) + mapa(px, py, 1)*mapa(px, py, 2)/(mapa(px, py, 2)+1))/255;
    mapa(px, py, 2) = mapa(px, py, 2)+1/255;
end
mapa = permute(mapa, [2 1 3]);
