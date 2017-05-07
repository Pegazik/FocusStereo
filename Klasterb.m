close all;
clear all;

load points;

xthresh = 2000;
dxThresh = -1000;
ythresh = 9000;
dyThresh = -2000;
zthresh = -1000;
dzThresh = -5000;
prox = 70;
step = 10;
k = 1;

for i = 1:size(points3D, 1)
    for j = 1:size(points3D, 2)
        if(points3D(i, 1) > xthresh || points3D(i, 1) < dxThresh || points3D(i, 2) > ythresh ||...
                points3D(i, 2) < dyThresh || points3D(i, 3) > zthresh || points3D(i, 3) < dzThresh)
            del(k) = i;
            k = k+1;
        end
    end
end

k = k-1;
points3D(del, :) = [];
color(del, :) = [];

ptCloud = pointCloud(points3D, 'Color', color);

clust = zeros(size(points3D, 1));   %tablica do sprawdzania które punkty s¹ ju¿ przypisane
k = 1;                              %numer klastra
n = 2;                              %numer punktu w klastrze
groups(1, 1) = 1;                   %tablica (k, n) zawieraj¹ca klastry i ich punkty
clust(1) = 1;                       %pierwszy punkt chmury to punkt startowy
cp = 1;                             %obecnie sprawdzany punkt (indeks kolumny w macierzy groups) 
mincl = 15;                         %minimalna iloœæ punktów aby klaster by³ zachowany
while nnz(clust)<size(clust, 1)
    [indices,dists] = findNearestNeighbors(ptCloud,...
        [points3D(groups(k, cp), 1) points3D(groups(k, cp), 2) points3D(groups(k, cp), 3)],step);
    for i = 1:step
        if(dists(i)<prox && clust(indices(i)) == 0)
           clust(indices(i)) = k;
           groups(k, n) = indices(i);
           n = n+1;
        end
    end
    if (cp<n-1)
        cp = cp+1;
    else
        cp = 1;
        k = k+1;
        n = 1;
        groups(k, cp) = find(clust==0, 1, 'first');
    end
end
% % Czyszczenie klastrów po wielkoœci
if(size(groups, 2)>mincl)   %sprawdzanie czy którykolwiek klaster ma rozs¹dn¹ wielkoœæ,
                            %je¿eli nie - nie obcinamy i nie wyœwietlamy
k = 1;
i =1;
while i<=size(groups, 1);
    while(k<mincl)
        if(groups(i, k) == 0)
            groups(i,:) = [];
            i = i-1;
            break;
        end
        k = k+1;
    end
    i = i+1;
    k = 1;
end
% % Wyœwietlanie klastrów
for j = 1:size(groups, 1);
    figure(j+1);
    vec = groups(j, :);
    vec = nonzeros(vec);    %tworzenie wektora indeksów
    ptClust = pointCloud(points3D(vec, :), 'Color', color(vec, :));
    pcshow(ptClust, 'VerticalAxis','y','VerticalAxisDir','down',...
    'MarkerSize',45);
end
end
%Wyœwietlanie ca³ej chmury
figure(1);
pcshow(ptCloud, 'VerticalAxis','y','VerticalAxisDir','down',...
    'MarkerSize',45);
camorbit(0, -30);
camzoom(1.5);