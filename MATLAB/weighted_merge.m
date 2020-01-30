function res = weighted_merge(pyramid, amplified_pyramid, alphas)
assert(size(alphas) == size(pyramid));
assert(size(pyramid) == size(amplified_pyramid));

N = size(pyramid, 2);
res = pyramid;
for i = 1:N
    alpha = alphas{i};
    res{i} = alpha .* amplified_pyramid{i} + (1 - alpha) .* pyramid{i};
end

end

