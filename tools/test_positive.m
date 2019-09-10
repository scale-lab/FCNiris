function distances = test_positive(full_map)
% Compute Hamming Distances for all positive pairs
radial=16;
res=512;
distances = [];
deg = -50:50;
for k = keys(full_map)
    val = full_map(k{1});
    templates = val(1:radial,:);
    masks = val(radial+1:end, :);
    num = size(templates, 2)/res;
    for i = 1:num
        t = templates(:, (res*(i-1) + 1):res*i);
        m = masks(:, (res*(i-1) + 1):res*i);
        
        % too few useful bits
        if sum(sum(m)) > 0.5*size(m,1)*size(m,2)
            continue;
        end
        
        for j = (i + 1):num
            t2 = templates(:, (res*(j-1) + 1):res*j);
            m2 = masks(:, (res*(j-1) + 1):res*j);
            
            % too few useful bits
            if sum(sum(m2)) > 0.5*size(m2,1)*size(m2,2)
                continue;
            end
            
            % rotate the encoding
            hd = zeros(size(deg));
            parfor x=1:length(deg)
                t2shift = circshift(t2,deg(x),2);
                m2shift = circshift(m2,deg(x),2);
                hd(x) = hamming(t,t2shift,m, m2shift);
            end

            distances = [distances, min(hd)];
        end
    end
end
figure, histogram(distances);
title(sprintf('Histogram of HD over %d positive samples, mean=%1.2f, std dev=%1.2f', length(distances), mean(distances), std(distances)));
end
