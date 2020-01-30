function img = view_pyramid(pyramid)
% TODO add mode to switch between horizontal and vertical
if(size(pyramid, 2) == 1)
    img = pyramid;
else
    N = size(pyramid, 2);
    height = size(pyramid{1}, 1);
    width =size(pyramid{1}, 2) + size(pyramid{2}, 2);
    new_size = size(pyramid{1});
    new_size(1) = height;
    new_size(2) = width;
    img = ones(new_size);
    if(isa(pyramid{1}, 'uint8'))
        img = uint8(255 * img);
    end
    img(1:size(pyramid{1}, 1), 1:size(pyramid{1},2), :, :) = pyramid{1};
    left = size(pyramid{1}, 2);
    up = 0;
    for i = 2 : N 
        img(up+1:up+size(pyramid{i}, 1) , (left+1):(left+size(pyramid{i}, 2)), :, :) = pyramid{i};
        up = up + size(pyramid{i}, 1);
    end
end
end

