function [list] = gaussian_pyramid(img, N)
    if nargin == 1
        N = 10;
    end
    tmp = img;
    list = {img};
    index = 1;
    while min(size(tmp)) > 1 & index < N
        index = index + 1;
        tmp = impyramid(tmp, 'reduce');
        list{index} = tmp;
    end
end