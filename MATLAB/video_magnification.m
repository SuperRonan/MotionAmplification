%profile on
clear all; close all; clf;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMS SECTION
file = 'mael_stab';
    
is_ycbcr = true; % better for luminance / chrominance separation
is_fft = true; % seems noisier with fft but conserves phase information
is_local = false; % better for local changes (ex : wrist.mp4)
if ~is_ycbcr
    weights = [1.0, 1.0, 1.0];
    color_mode = 'rgb';
else
    %weights = [1.0, 0.2, 0.2];
    weights = [0.8, 1.0, 1.0];
    color_mode = 'ycbcr';
end

boost_frequence = 300;
min_frame = 8;
max_frame = 10;
nb_peaks_global = 1;
nb_peaks_local = 1;
decimation_factor =  2;
prominence_treshold = 0.025;
sigma = 10/decimation_factor;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if is_fft fourier_mode = 'fft', else fourier_mode = 'dct', end;
if is_local locality = 'local', else locality = 'global', end;


fprintf( "loading video \n")


reader = VideoReader(strcat('../data/', file  ,'.mp4'));
fps = reader.FrameRate;
fprintf( "reading video \n")

tmp = read(reader);

[H, W, C, N] = size(tmp);

max_frame = min(N, max_frame);


fprintf( "resizing video for memory saving(factor = " + decimation_factor + ") \n")

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
 
decay = (1 - exp(-10*(x - min_frame)/(max_frame-min_frame))).^2;
decay= decay(:);

plot(x, decay);

if ~is_local
    F_means = squeeze(max(mean(mean(abs(F(:,:,:,x))))));
    %F_means = F_means .* decay;
    %f = fit(x(:),F_means(:),'exp2');
    %model = f(x);
    %F_means = F_means - model;
    %fit = fminsearch(@(b) norm(F_means - f(b,x)), x, options);
   
    %plot(x, f,'-', x, F_means, '*' )
    figure, plot(x,F_means);

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
    F_blur = F;
    for n = 1:N
        F_blur(:,:,1,n) = imgaussfilt(abs(F_blur(:,:,1,n)), sigma) * weights(1);
        F_blur(:,:,2,n) = imgaussfilt(abs(F_blur(:,:,2,n)), sigma) * weights(2);
        F_blur(:,:,3,n) = imgaussfilt(abs(F_blur(:,:,3,n)), sigma) * weights(3);
    end
    
    for col = 1 : H
        fprintf("%s\n", strcat(num2str(round(100 * col/single(H))) ," %"));
        for lin =1 : W

            F_means = squeeze(max(abs(F_blur(col,lin,:,x))));
            F_means = F_means .* decay;
            %f = fit(x(:),double(F_means(:)),'exp2');
            %model = f(x);
            %F_means = F_means - model;
            [v, l, w, prominence] = findpeaks(F_means);
            
             
            [max_prominences, max_prominence_locs] = maxk(prominence, nb_peaks_local);
            
            for i = 1:length(max_prominence_locs)
                max_prominence_loc = max_prominence_locs(i);
                max_prominence = max_prominences(i);
                if max_prominence > prominence_treshold
                    f = l(max_prominence_loc)+ min_frame - 1;
                    for j = 1 : 3 
                        F(col,lin,j ,f) = F(col,lin,j,f) * weights(j) * boost_frequence; 
                    end
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
if is_local
    filename = strcat('results/', file, '_b=',int2str(boost_frequence), '_l=local_sigma=',num2str(sigma),'_c=',color_mode, '_f=', fourier_mode , '.mp4');
else
    filename = strcat('results/', file, '_b=',int2str(boost_frequence), '_l=global_nbpeaks=',int2str(nb_peaks_global),'_c=',color_mode, '_f=', fourier_mode , '.mp4');
end
v = VideoWriter(filename, 'MPEG-4');
open(v)
writeVideo(v, iF);
close(v);






