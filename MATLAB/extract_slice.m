function slice = extract_slice(video, index, dimension)
    if dimension == 1
        slice = video(index, :, :, :);
    else
        slice = video(:, index, :, :);
    end
    slice = squeeze(slice);
    slice = permute(slice, [1 3 2]);
end

