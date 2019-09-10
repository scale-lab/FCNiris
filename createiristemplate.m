% createiristemplate - generates a biometric template from an iris in
% an eye image.
%
% Usage: 
% [template, mask] = createiristemplate(eyeimage_filename)
%
% Arguments:
%	eyeimage_filename   - the file name of the eye image
%
% Output:
%	template		    - the binary iris biometric template
%	mask			    - the binary iris noise mask
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003
%
% HEAVILY modified by Hokchhay Tann


function [polar_array, template, mask, success] = createiristemplate(filename,gtfile, net)

polar_array = 0;
mask=0;
template=0;

%normalisation parameters
radial_res = 16;
angular_res = 256;
eyelash_threshold=0.03;
reflect_threshold=0.10;

%feature encoding parameters
nscales=1;
minWaveLength=18;
mult=1;
sigmaOnf=0.5;

eyeimage = imread(filename); 
[m,n,k] = size(eyeimage);
if k > 1
    eyeimage = rgb2gray(eyeimage);
end

if isempty(gtfile)
    input_size = net.Layers(1).InputSize;
    if m ~= input_size(1) || n ~= input_size(2)
        im = imresize(eyeimage, input_size(1:2), 'nearest');
        im_mask = semanticseg(im, net) == 'background';
        im_mask = imresize(im_mask, [m,n], 'nearest');
    else
        im_mask = semanticseg(eyeimage, net) == 'background';
    end
else
    im_mask = imbinarize(imread(gtfile));
end


[success, ci, ri, cp, rp] = get_circles1(im_mask);
% figure, imshow(labeloverlay(eyeimage, im_mask));
% viscircles(cp,rp,'Color','m');
% viscircles(ci,ri,'Color','b');
if ~success
    return;
end

%perform normalisation
im = double(eyeimage);
im(im_mask==0) = 255;
[polar_array, noise_array] = normaliseiris(im, ci(1),...
   ci(2), ri, cp(1), cp(2), rp, radial_res, angular_res, im_mask);

% filter out eyelashes
% copy polar_array & set bad values to 1;
p2 = polar_array;
p2(noise_array == 1) = 1;
eyelashes = [];
for i = 2:size(p2, 1)-1
    for j = 2:size(p2, 2)-1
        neighbors = [p2([i-1, i+1], j-1:j+1), p2(i, [j-1, j+1])'];
        min_n = min(min(neighbors));
        max_n = max(max(neighbors));
        if min_n - eyelash_threshold > p2(i,j) || max_n + reflect_threshold < p2(i,j)
            eyelashes = [eyelashes; [i, j]];        
        end
    end
end
if ~isempty(eyelashes)
    for i = 1:size(eyelashes, 1)
        noise_array(eyelashes(i,1), eyelashes(i,2))=1;
    end
end

[template, mask] = encode(polar_array, noise_array, nscales, minWaveLength, mult, sigmaOnf);
