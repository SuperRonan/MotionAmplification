clear all;
close all;

file = 'chess';
format = 'MOV';

video = VideoReader(strcat('../data/', file, '.', format));
disp('Reading video...');
frames = read(video);

scale = 0.5;
disp(strcat('Resizing the video at the scale ', num2str(scale), '...'));
frames = imresize(frames, scale);

writter = VideoWriter(strcat('../data/', file, '.mp4'), 'MPEG-4');
disp('Writting the video...');
open(writter);
writeVideo(writter, frames);
close(writter);

fprintf('done');