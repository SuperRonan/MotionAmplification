pyr = true; % use pyramid or not
wrist2 = true;
if pyr
    file = 'results/wrist_b=200_l=local_sigma=1_c=ycbcr_f=fft.mp4';
    outputname = 'Wrist_pyr';
else
    file = 'results/wrist_b=200_l=local_sigma=1_c=ycbcr_f=fftNOPYR.mp4';
    outputname = 'Wrist_nopyr';
end
if wrist2 && pyr
    file = 'results/wrist2_b=300_l=local_sigma=1_c=ycbcr_f=fft.mp4';
    outputname = 'Wrist2_pyr';
else
    file = 'results/wrist2_b=300_l=local_sigma=1_c=ycbcr_f=fftNOPYR.mp4';
    outputname = 'Wrist2_nopyr';
end

% file = 'results/CR/wrist_cropped.mp4'; outputname = 'Wrist'
% file = 'results/CR/wrist2_cropped.mp4'; outputname = 'Wrist2'

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

% imshow(slice)
imwrite(slice, strcat('results/cr/', outputname, '.png'))