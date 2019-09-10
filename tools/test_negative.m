function distances = test_negative(full_map)
% Compute Hamming Distances for all negative samples
radial=16;
res=512;
distances = [];
deg = -50:50;
allkey = keys(full_map);
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
            fprintf('here\n');
            continue;
        end
        
        sampled_keys = datasample(allkey, 20);

        for k2 = sampled_keys
            if strcmp(k,k2)
                continue;
            end
            
            val2 = full_map(k2{1});
            templates2 = val2(1:radial,:);
            masks2 = val2(radial+1:end, :);
            num2 = size(templates2, 2)/res;
            for j = 1:num2
                t2 = templates2(:, (res*(j-1) + 1):res*j);
                m2 = masks2(:, (res*(j-1) + 1):res*j);

                % again, if too few useful bits, skip:
                if sum(sum(m2)) > 0.5*size(m2,1)*size(m2,2)
                    continue;
                end

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
end

figure
histogram(distances)
title(sprintf('Histogram of HD over %d negative samples, mean=%1.2f, std dev=%1.2f', length(distances), mean(distances), std(distances)));
end
