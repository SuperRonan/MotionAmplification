%profile on
clear all;
ycbcr = false;
if ~ycbcr
    weights = [1.0, 1.0, 1.0];
else
    %weights = [1.0, 0.2, 0.2];
    weights = [0.1, 1.0, 1.0];
end

boost_frequence = 100;
start = 10;
nb_peaks = 1;

fprintf( "loading video \n")

file = 'glenn';
reader = VideoReader(strcat('../data/', file  ,'.mp4'));
fps = reader.FrameRate;
fprintf( "reading video \n")

tmp = read(reader);

[H, W, C, N] = size(tmp);

factor =  2;

fprintf( "resizing video psk peu de ram enft (factor = " + factor + ") \n")

H = round(H / factor);
W = round(W / factor);


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


x = start:N;

F_means = squeeze(max(mean(mean(real(abs(F(:,:,:,x)))))));
plot(x,F_means);
[v, l, w, prominence] = findpeaks(F_means);

[max_prominences, max_prominence_locs] = maxk(prominence, nb_peaks);

disp("peaks : ")
display_peaks_info(fps, max_prominences, max_prominence_locs, l, prominence, start)

for i = 1:length(max_prominence_locs)
    elem = max_prominence_locs(i);
    f = l(elem)+ start - 1;
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

% fprintf("video writing \n");
% fprintf("1/3...\n");  
% filename = strcat(file,'_no_mag_auto.mp4');
% v = VideoWriter(filename, 'MPEG-4');
% open(v)
% writeVideo(v, video_rgb);
% close(v);
% fprintf("2/3...\n");
% filename = strcat(file,'_mag_rgb_auto.mp4');
% v = VideoWriter(filename, 'MPEG-4');
% open(v)
% writeVideo(v, iF_rgb);
% close(v);
% fprintf("3/3...\n");
% filename = strcat(file,'_mag_ycrvb_auto.mp4');
% v = VideoWriter(filename, 'MPEG-4');
% open(v)
% writeVideo(v, iF_ycbcr);
% close(v);





