clear all;
close all;

video = VideoReader('../data/face.mp4');

fps = video.FrameRate;
video_len = int32(fps * video.Duration);
frames = cell(video_len, 1);

i = 1;
while(hasFrame(video))
    frame = video.readFrame();
    frames{i} = double(frame) / 255;
    i = i + 1;
end
clear video;
frames = cell2mat(frames);
frames = single(frames);

'video read'
tic
fourier = single(fft(frames, [], 1));

freq = 0.3; % Hz
bandwidth = 0.0;
band = bandwidth * freq;

alpha = 50;

low = floor(fps * (freq - band)) + 1;
high = ceil(fps * (freq + band)) + 1;

low = max(1, low)
high = min(video_len, high)

for i = low:high
    fourier(i,:,:,:) = fourier(i,:,:,:) * alpha;
end



frames=real(ifft(fourier, [], 1));
toc
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