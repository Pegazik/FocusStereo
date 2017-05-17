function mapa = mapCombine(map1, map2)
exp = 2;
if map2>map1
    [map1 map2] = deal(map2, map1);
end
mapa = map1;
w1 = map1(:, :, 2).^exp;
w2 = map2(:, :, 2).^exp;
for i = 1:size(map1, 1)
    for j = 1:size(map1, 2)
      if i<size(map2, 1) && j<size(map2, 2)
            mapa(i, j, 1) = (map1(i, j, 1)*w1(i, j) + map2(i, j, 1)*w2(i, j))/(w1(i, j)+w2(i, j));
            mapa(i, j, 2) = map1(i, j, 2) + map2(i, j, 2);
      end
    end
end