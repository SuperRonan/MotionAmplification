clear all;
close all;

file = 'keyboard';
format = 'MOV';

video = VideoReader(strcat('../data/', file, '.', format));
frames = read(video);

factor = 3;

[H, W, C, N] = size(frames);
new_size = [ceil(H / factor), ceil(W / factor), C, N]
new_frames = zeros(new_size);
for i=1:N
    for c=1:C
        new_frames(:,:,c,i) = double(imresize(frames(:,:,c,i), new_size(1:2))) / 255;
    end
end

v = VideoWriter(strcat('../data/', file, '.mp4'), 'MPEG-4');

open(v);
writeVideo(v, new_frames);
close(v);

fprintf('done');