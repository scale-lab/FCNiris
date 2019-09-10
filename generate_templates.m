function full_map = generate_templates(dataset, ground_truth, net)

imds = imageDatastore(dataset,'IncludeSubfolders', 1);
if isdir(ground_truth)
    disp('Using ground truth segmentation instead');
    gtds = imageDatastore(ground_truth,'IncludeSubfolders', 1);
end

full_map = containers.Map('KeyType', 'char', 'ValueType', 'any');
success_rate = 0;
for num = 1:length(imds.Files)
    filename = imds.Files{num};
    if isdir(ground_truth)
        % if we are just using ground truth segmentation mask
        % i.e. we are not using the FCN to do segmentation
        [~, t, m, success] = createiristemplate(filename, gtds.Files{num}, net);
    else
        [~, t, m, success] = createiristemplate(filename, '', net);
    end
    
    if ~success
        continue;
    end
    success_rate = success_rate+1;
   
    % trying to get unique id for each iris subject
    if contains(dataset, 'CASIA')
        subject_num = filename(end-11:end-6);
    elseif contains(dataset, 'IITD')
        C = strsplit(filename, '/');
        if contains(C{end}, 'L')
            subject_num = [C{end-1}, 'L'];
        elseif contains(C{end}, 'R')
            subject_num = [C{end-1}, 'R'];
        else
            disp('error name');
        end
    else
        error('dataset path %s does not contain ''CASIA'' or ''IITD''\n', dataset);
    end

    if full_map.isKey(subject_num)
        full_map(subject_num) = [full_map(subject_num), [t;m]];
    else
        full_map(subject_num) = [t;m];
    end
    
    if mod(num, 50) == 0
        disp(num);
    end
end
fprintf('Num success: %d out of %d\n',success_rate, num);
