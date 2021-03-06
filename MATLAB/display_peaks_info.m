function display_peaks_info(fps, kmax_value, kmax_loc, loc, prominence, start)
    for i = 1:length(kmax_loc)
        disp(i +"/" + length(kmax_loc));
        elem = kmax_loc(i);
        p = prominence(elem);
        disp("   prominence = " + p);
        frame = loc(elem)+ start -1;
        disp("   fourier frame = " +  frame);
        f =   (frame)/ fps;
        disp("   frequence = " + f + " Hz");
    end
end