close all;
clear all;


load ptCloud2;
ptCloud2 = ptCloud;

load ptCloud3;

figure(1)
pcshow(ptCloud, 'VerticalAxis','y','VerticalAxisDir','down',...
    'MarkerSize',45);
figure(2)
pcshow(ptCloud2, 'VerticalAxis','y','VerticalAxisDir','down',...
    'MarkerSize',45);
mapa = map(ptCloud);
mapa2 = map(ptCloud2);
figure(3)
subplot(2, 3, 1);
imshow(mapa(:, :, 1), []);
subplot(2, 3, 2);
imshow(mapa(:, :, 2), []);
subplot(2, 3, 3);
imshow(mapa(:, :, 3), []);

subplot(2, 3, 4);
imshow(mapa2(:, :, 1), []);
subplot(2, 3, 5);
imshow(mapa2(:, :, 2), []);
subplot(2, 3, 6);
imshow(mapa2(:, :, 3), []);
figure(4)
imshow(mapa);
figure(5)
imshow(mapa2);

mapa3 = mapCombine(mapa, mapa2);

figure(6)
imshow(mapa3);
figure(7)
subplot(1, 3, 1);
imshow(mapa3(:, :, 1), []);
subplot(1, 3, 2);
imshow(mapa3(:, :, 2), []);
subplot(1, 3, 3);
imshow(mapa3(:, :, 3), []);