%profile on
clear all; close all; clf;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMS SECTION
file = 'wrist';

is_ycbcr = true; % better for luminance / chrominance separation
is_fft = false; % seems noisier with fft
is_local = false; % better for local changes (ex : wrist.mp4)
if ~is_ycbcr
    weights = [1.0, 1.0, 1.0];
    color_mode = 'rgb';
else
    weights = [1.0, 0.2, 0.2];
    %weights = [0.8, 1.0, 1.0];
    color_mode = 'ycbcr';
end
if is_fft fourier_mode = 'fft', else fourier_mode = 'dct', end;
if is_local locality = 'local', else locality = 'global', end;

boost_frequence = 60;
min_frame = 30;
max_frame = 80;
nb_peaks_global = 5;
decimation_factor =  5;
prominence_treshold = 0.0125;
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

if decimation_factor == 1
    video = single(tmp);
else 
    video = single(zeros(H, W, C, N));
end





for i = 1 : N
    if decimation_factor ~= 1
        video(:,:,:,i) = imresize(tmp(:,:,:,i), [H, W]);
    end
    if is_ycbcr
        video(:,:,:,i) = rgb2ycbcr(video(:,:,:,i)/255);
    end
end

clear tmp;

if ~is_ycbcr
    video = video ./ 255;
    avg_source = mean(video(:));
end

fprintf("computing fourier \n");
if is_fft
    F = fft(video, [], 4); 
else
    F = dct(video, [], 4);
end

clear video;

% frequence filtering

fprintf("boosting frequencies \n");
disp("pixel coefficient weigts : " +  weights);

 x = min_frame:max_frame;
 
 

if ~is_local
    F_means = squeeze(max(mean(mean(abs(F(:,:,:,x))))));
    plot(x,F_means);

    [v, l, w, prominence] = findpeaks(F_means);
    
    [max_prominence, max_prominence_locs] = maxk(prominence, nb_peaks_global);
    disp("peaks : ")
    display_peaks_info(fps, max_prominence, max_prominence_locs, l, prominence, min_frame)

    for i = 1:length(max_prominence_locs)
        elem = max_prominence_locs(i);
        f = l(elem)+ min_frame - 1;
        for j = 1 : 3 
            F(:,:,j ,f) = F(:,:,j,f) * weights(j) * boost_frequence; 
        end
    end
else
    for col = 1 : H
         fprintf('%d/%d\n', col, H);
        for lin =1 : W


            F_means = squeeze(max(abs(F(col,lin,:,x))));
            
            [v, l, w, prominence] = findpeaks(F_means);
             
            [max_prominence, max_prominence_loc] = max(prominence);
            if max_prominence > prominence_treshold
                f = l(max_prominence_loc)+ min_frame - 1;
                for j = 1 : 3 
                    F(col,lin,j ,f) = F(col,lin,j,f) * weights(j) * boost_frequence; 
                end
            end
        end
    end
end



fprintf("computing inverses fourier \n");

if is_fft
    iF = real(ifft(F,[], 4));
else
    iF = idct(F,[], 4);
end

clear F;

if is_ycbcr
    fprintf("ycbcr back to rgb \n");
    for i = 1 : N
         iF(:,:,:,i) = ycbcr2rgb(iF(:,:,:,i));
    end
end

fprintf("tone mapping and checks \n");

iF = iF / max(iF(:));

avg = mean(iF(:));

if ~is_ycbcr
    loss = avg / avg_source;
    iF =  iF ./loss;
end

iF(iF >1) = 1;
iF(iF <0) = 0;

implay(iF);

fprintf("video writing \n");

filename = strcat('results/', file, '_b=',int2str(boost_frequence), '_l=', locality,'_c=',color_mode, '_f=', fourier_mode , '.mp4');
v = VideoWriter(filename, 'MPEG-4');
open(v)
writeVideo(v, iF);
close(v);






