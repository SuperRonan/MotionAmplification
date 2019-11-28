%profile on

fprintf( "loading video \n")

file = 'face';
reader = VideoReader(strcat('../data/', file  ,'.mp4'));

fprintf( "reading video \n")

tmp = read(reader);


[H, W, C, N] = size(tmp);

factor = 5 ;

fprintf( "resizing video psk peu de ram enft (factor = " + factor + ") \n")

H = round(H / factor);
W = round(W / factor);


video_rgb = single(zeros(H, W, C, N));
video_ycbcr = single(zeros(H, W, C, N));

for i = 1 : N
    video_rgb(:,:,1,i) = imresize(tmp(:,:,1,i), [H, W]);
    video_rgb(:,:,2,i) = imresize(tmp(:,:,2,i), [H, W]);
    video_rgb(:,:,3,i) = imresize(tmp(:,:,3,i), [H, W]);
    video_ycbcr(:,:,:,i) = rgb2ycbcr(video_rgb(:,:,:,i)/255);
end
 
video_rgb = video_rgb./255;

fprintf("computing fourier \n");
fprintf("rgb... \n");
F_rgb = dct(video_rgb, [], 4);
fprintf("ycbcr... \n");
F_ycbcr = dct(video_ycbcr, [], 4); 


% frequence filtering

gain = 100;

fprintf("boosting frequencies \n");

rgb_weights = [0.8, 0.8, 0.8];
ycbcr_weights = [0.1, 0.8, 0.8];
disp("rgb weights: " +  rgb_weights );
disp("ycbcr weigts : " +  ycbcr_weights);


start = 10;
x = start:N;

F_means_rgb_without_first = squeeze(max(mean(mean(real(abs(F_rgb(:,:,:,x)))))));
F_means_ycbcr_without_first = squeeze(max(mean(mean(real(abs(F_ycbcr(:,:,:,x)))))));
[v_rgb, l_rgb, w_rgb, p_rgb] = findpeaks(F_means_rgb_without_first);
[v_ycbcr, l_ycbcr, w_ycbcr, p_ycbcr] = findpeaks(F_means_ycbcr_without_first);

nb_peaks = 8;

[max_rgb, I_rgb] = maxk(p_rgb, nb_peaks);
[max_ycbcr, I_ycbcr] = maxk(p_ycbcr, nb_peaks);

disp("rgb peaks : ")
display_peaks_info(30, max_rgb, I_rgb, l_rgb, p_rgb, start)
disp("ycbcr peaks : ")
display_peaks_info(30, max_ycbcr, I_ycbcr, l_ycbcr, p_ycbcr, start)

for i = 1:length(I_rgb)
    elem = I_rgb(i);
    f = l_rgb(elem)+ start -1 ;
    for j = 1 : 3 
        F_rgb(:,:,j,f) = F_rgb(:,:,j,f) * rgb_weights(j) * gain; 
    end
end

for i = 1:length(I_ycbcr)
    elem = I_ycbcr(i);
    f = l_ycbcr(elem)+ start - 1;
    for j = 1 : 3 
        F_ycbcr(:,:,j ,f) = F_ycbcr(:,:,j,f) * ycbcr_weights(j) * gain; 
    end
end


fprintf("computing inverses fourier \n");
fprintf("rgb... \n");
iF_rgb = idct(F_rgb,[], 4);
fprintf("ycbcr... \n");
iF_ycbcr = idct(F_ycbcr,[], 4);

fprintf("ycbcr back to rgb \n");

for i = 1 : N
     iF_ycbcr(:,:,:,i) = ycbcr2rgb(iF_ycbcr(:,:,:,i));
end

fprintf("tone mapping and checks \n");


iF_rgb = iF_rgb / max(iF_rgb(:));
iF_ycbcr = iF_ycbcr / max(iF_ycbcr(:));

avg_source = mean(video_rgb(:));
avg_rgb = mean(iF_rgb(:));
avg_ycbcr = mean(iF_ycbcr(:));

loss_rgb = avg_rgb / avg_source;
loss_ycbcr = avg_ycbcr / avg_source;


iF_rgb =  iF_rgb ./loss_rgb;
iF_ycbcr =  iF_ycbcr ./loss_ycbcr;


video_rgb(video_rgb >1) = 1;
video_rgb(video_rgb <0) = 0;
iF_rgb(iF_rgb>1) = 1;
iF_rgb(iF_rgb<0) = 0;
iF_ycbcr(iF_ycbcr >1) = 1;
iF_ycbcr(iF_ycbcr <0) = 0;

implay(iF_rgb);
implay(iF_ycbcr);
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





