%profile on
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMS SECTION
ycbcr = false;
if ~ycbcr
    weights = [1.0, 1.0, 1.0];
    mode = 'rgb';
else
    weights = [1.0, 0.2, 0.2];
    %weights = [0.1, 1.0, 1.0];
    mode = 'ycbcr';

end

boost_frequence = 100;
min_frame = 15;
max_frame = 300;
nb_peaks = 1;
decimation_factor =  2;
file = 'camera';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf( "loading video \n")


reader = VideoReader(strcat('../data/', file  ,'.mp4'));
fps = reader.FrameRate;
fprintf( "reading video \n")

tmp = read(reader);

[H, W, C, N] = size(tmp);

max_frame = min(N, max_frame);


fprintf( "resizing video psk peu de ram enft (factor = " + decimation_factor + ") \n")

H = round(H / decimation_factor);
W = round(W / decimation_factor);


video = single(zeros(H, W, C, N));



for i = 1 : N
    video(:,:,1,i) = imresize(tmp(:,:,1,i), [H, W]);
    video(:,:,2,i) = imresize(tmp(:,:,2,i), [H, W]);
    video(:,:,3,i) = imresize(tmp(:,:,3,i), [H, W]);
    if ycbcr
        video(:,:,:,i) = rgb2ycbcr(video(:,:,:,i)/255);
    end
end

clear tmp;

if ~ycbcr
    video = video ./ 255;
    avg_source = mean(video(:))
end

fprintf("computing fourier \n");
F = dct(video, [], 4); 


% frequence filtering

fprintf("boosting frequencies \n");
disp("pixel coefficient weigts : " +  weights);


x = min_frame:max_frame;

F_means = squeeze(mean(mean(mean(real(abs(F(:,:,:,x)))))));



plot(x,F_means);
[v, l, w, prominence] = findpeaks(F_means);

[max_prominences, max_prominence_locs] = maxk(prominence, nb_peaks);

disp("peaks : ")
display_peaks_info(fps, max_prominences, max_prominence_locs, l, prominence, min_frame)

for i = 1:length(max_prominence_locs)
    elem = max_prominence_locs(i);
    f = l(elem)+ min_frame - 1;
    for j = 1 : 3 
        F(:,:,j ,f) = F(:,:,j,f) * weights(j) * boost_frequence; 
    end
end


fprintf("computing inverses fourier \n");
iF = idct(F,[], 4);


if ycbcr
    fprintf("ycbcr back to rgb \n");
    for i = 1 : N
         iF(:,:,:,i) = ycbcr2rgb(iF(:,:,:,i));
    end
end

fprintf("tone mapping and checks \n");

iF = iF / max(iF(:));

avg = mean(iF(:));

if ~ycbcr
    loss = avg / avg_source;
    iF =  iF ./loss;
end

iF(iF >1) = 1;
iF(iF <0) = 0;

implay(iF);
%implay(video_source);

%implay(iF);

fprintf("video writing \n");

filename = strcat('results/', file, '_',mode, '_', nb_peaks, '.mp4');
v = VideoWriter(filename, 'MPEG-4');
open(v)
writeVideo(v, iF_rgb);
close(v);






