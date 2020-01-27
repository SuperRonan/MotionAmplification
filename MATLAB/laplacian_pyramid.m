function [list] = laplacian_pyramid(gaussian_pyramid)
    N = size(gaussian_pyramid, 2);
    list = gaussian_pyramid;
    for i = 1 : N-1
        list{i} = single(gaussian_pyramid{i}) - single(imresize(impyramid(gaussian_pyramid{i+1}, 'expand'), [size(gaussian_pyramid{i}, 1), size(gaussian_pyramid{i}, 2)]));
    end
    list{N} = gaussian_pyramid{N};
end

