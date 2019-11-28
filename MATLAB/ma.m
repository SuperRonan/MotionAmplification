clear all;
close all;

file = 'face';

video = VideoReader(strcat('../data/', file, '.mp4'));

fps = video.FrameRate;
video_len = int32(fps * video.Duration);
width = video.Width;
height = video.Height;
frames = single(zeros(video_len, height, width, 3));

i = 1;
while(hasFrame(video))
    frame = video.readFrame();
    frames(i,:,:,:) = single(frame) / 255;
    i = i + 1;
end
clear video;
'video read'
tic
fourier = single(fft(frames, [], 1));

freq = 0.6; % Hz
bandwidth = 0.0;
band = bandwidth * freq;

alpha = 50;

low = floor(fps * (freq - band) / 2) + 1;
high = ceil(fps * (freq + band) / 2)  + 1;

low = max(1, low)
high = min(video_len, high)

for i = low:high
    fourier(i,:,:,:) = fourier(i,:,:,:) * alpha;
end



frames=single(real(ifft(fourier, [], 1)));

frames(frames <= 0) = 0;

toc

'saving video'
%vw = VideoWriter(strcat('result/',file, '.mp4'));


i = 1;
while(true)
    frame = squeeze(frames(i, :, :, :));
    imshow(frame);
    i = i + 1;
    if(i > video_len)
        i = 1;
    end
end

'done!'