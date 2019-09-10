% This is for processing a whole dataset.
% The processing includes computing the iris encoding and calculating
% the hamming distances, and computing EER.
% Iris segmentation is done using the FCN model


% Note, the paths are tailored for CASIA Iris Interval V4 dataset,
% but they can be easily tweaked for IITD dataset.

% load your the FCN model under test
% replace this line to test a different model
net_struct = load('FCN_models/CASIA4i/net_full_1.mat');
net = net_struct.net;
dataset = 'CASIA4i/';
base_path = './data/';
addpath('./normalize_encoding');

dataset = [base_path, dataset];
if ~isfolder(dataset)
    error('Invalid dataset path: %s\n', dataset);
end
full_map = generate_templates(dataset, '', net);
neg_d = test_negative(full_map);
pos_d = test_positive(full_map);

map_path = './maps/';
if ~exist(map_path, 'dir')
    mkdir(map_path);
end
save([map_path, 'net_fullmap.mat'], full_map);
save([map_path, 'net_negd.mat'], neg_d);
save([map_path, 'net_posd.mat'], pos_d);

fprintf("Positive data\nMean: %1.2f, StdDev %1.2f, Median: %1.2f\n",...
        mean(pos_d), std(pos_d), median(pos_d));
fprintf("Negative data\nMean: %1.2f, StdDev %1.2f, Median: %1.2f\n",...
        mean(neg_d), std(neg_d), median(neg_d));
fprintf("False negative rate using min: %1.2f\n",...
        sum(pos_d > min(neg_d))/length(pos_d));

for i=min(neg_d):0.001:max(pos_d)
    pos_err = sum(pos_d > i)/length(pos_d);
    neg_err = sum(neg_d < i)/length(neg_d);
    if abs(pos_err - neg_err) < 0.01
        fprintf("Mean (EER): %1.4f at Threshold %1.4f\n", (pos_err+neg_err)/2, i);
    end
end
