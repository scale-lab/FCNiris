% This is for processing a single image.

% Note, the paths are tailored for CASIA Iris Interval V4 dataset,
% but they can be easily tweaked for IITD dataset.

% load your the FCN model under test
% replace this line to test a different model
net_struct = load('FCN_models/CASIA4i/net_full_1.mat');
net = net_struct.net;
filename = '../data/examples/CASIA4i/img0.jpg';
addpath('./normalize_encoding');
% the encoding and masks are stored in variable t and m
[~, t, m, success] = createiristemplate(filename, '', net);
str = input('Show encoding and mask? [y/n]: ', 's');
if contains(str, 'y')
    figure, montage({t, m});
end
