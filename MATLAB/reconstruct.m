function [video] = reconstruct(laplacian, float_type)
N = size(laplacian, 2);
video = laplacian{N};
for i = N-1: -1 :1
    tmp = impyramid(video, 'expand');
    tmp = imresize(tmp, [size(laplacian{i},1), size(laplacian{i}, 2)]);
    video =  single(tmp) + laplacian{i};
end
video = video;
end

