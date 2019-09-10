function [success, ci,ri, cp, rp] = get_circles1(mask)
%GET_CIRCLES returns radius and center of iris and pupil or outer and inner
%   success: whether an iris & pupil were found
%   co, ro: center & radius of outer circle (iris)
%   ci, ri: center & radius of inner circle (pupil

    ci = [0 0];
    cp = [0 0];
    ri = 0;
    rp = 0;
    ci1 = [0 0];
    ri1 = 0;
    success=true;
    sizes = size(mask);
    
    %if max(max(mask)) > 1
    mask1 = imbinarize(mask);
    %end
    % use region props to get iris radius and center
    iris_props = regionprops(mask1, 'Area', 'Centroid',...
       'MajorAxisLength','MinorAxisLength');
    max_iris = 0;
    for i =1:length(iris_props)
        area = iris_props(i).Area;
        if area > max_iris && area > 2000
            max_iris = area;
            ci = iris_props(i).Centroid;
            ri = (iris_props(i).MajorAxisLength + ...
                  iris_props(i).MinorAxisLength)/4;
        end
    end
    % ci(2) is y direction
    % ci(1) is x direction
    
    % Pupil
    dim1 = [1 sizes(1)];
    dim2 = [max(1, round(ci(1)-0.8*ri)) min(sizes(2), round(ci(1)+0.8*ri))];
    im3 = mask1(dim1(1):dim1(2), dim2(1):dim2(2));
    sizep = [0.1 0.29; 0.25 0.5; 0.4 0.8];
    good_fit = -1;
    for i=1:size(sizep,1)
        l = max(6, round(sizep(i,1)*ri));
        r = max(6, round(sizep(i,2)*ri));
        if r==6
            continue;
        end
        [cp0, rp0, metric] = imfindcircles(im3, [l r],...
                            'ObjectPolarity', 'dark',...
                            'Sensitivity', 0.96);
        if ~isempty(cp0)
            [fitness, idx] = max(metric);
            if fitness(1) > good_fit
               good_fit = fitness(1);
               cp = cp0(idx,:);
               rp = rp0(idx);
            end
        end
    end
    
    % Iris
    sizei = [0.90 1.2];
    good_fit = -1;
    for i=1:size(sizei,1)
        l = max(6, round(sizei(i,1)*ri));
        r = max(6, round(sizei(i,2)*ri));
        if r > sizes(1) || r > sizes(2)
            continue;
        end
        [ci0, ri0, metric] = imfindcircles(mask1, [l r],...
                            'ObjectPolarity', 'bright',...
                            'Sensitivity', 0.95);
        if ~isempty(ci0)
            [fitness, idx] = max(metric);
            if fitness(1) > good_fit
               good_fit = fitness(1);
               ci1 = ci0(idx,:);
               ri1 = floor(ri0(idx));
            end
        end
    end
    
    if rp ~= 0
        cp(1) = cp(1) + dim2(1);
    else
        success = false;
    end
    if ri1 ~= 0
        ci = ci1(1:2);
        ri = ri1(1);
    end
end

