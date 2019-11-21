function [array] = cell2mat(cells)

N = size(cells, 1);

D = size(cells{1});
dim = size(D, 2);

array = zeros([N, D]);

for i = 1:N
    array(i, :, :, :) = cells{i};
end

end

