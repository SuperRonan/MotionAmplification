pyr = true;
if pyr
    file = 'results/wrist_b=200_l=local_sigma=1_c=ycbcr_f=fft.mp4';
    outputname = 'Wrist_pyr';
else
    file = 'results/wrist_b=200_l=local_sigma=1_c=ycbcr_f=fftNOPYR.mp4';
    outputname = 'Wrist_nopyr';
end

reader = VideoReader(file);
fps = reader.FrameRate;
video = read(reader);
index = 175;
extracted = extract_slice(video,index,3);

prev = video(:,1:index,:,20);
prev = squeeze(prev);
next = video(:,index:end,:,20);
next = squeeze(next);

slice = [prev extracted next];

imshow(slice)
% imwrite(slice, 'results/cr/Wrist_nopyr.png')
% imwrite(slice, strcat('results/cr/', outputname, '.png'))