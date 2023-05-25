
function pyr = pyr_gen(img, type, level)

%% Authors       : Shahryar Ebrahimi      &   Mohsen Keshtkar
%% S.N.          : 810196093              &   810196291
%% Mail          : shr.ebrahimi@ut.ac.ir  &   mohsen.keshtkar@ut.ac.ir
%% Course Title  : Digital Image Processing (DIP)
%% Paper Title   : Color Balance and Fusion for Underwater Image Enhancement
%% Date Modified : Monday, June 11, 2018
%% 
%% Description   :

%   PYR_GEN generate Gaussian or Laplacian pyramid
%   PYR = GENPYR(A,TYPE,LEVEL) A is the input image, 
%	can be gray or rgb, will be forced to double. 
%	TYPE can be 'gauss' or 'laplace'.
%	PYR is a 1*LEVEL cell array.

%% Loading

pyr    = cell(1,level);
pyr{1} = im2double(img);

for p = 2:level
	pyr{p} = pyr_reduce(pyr{p-1});
end

if strcmp(type,'gauss')
    return; 
end

% adjust the image size

for p = level-1:-1:1 
	osz = size(pyr{p+1})*2-1;
	pyr{p} = pyr{p}(1:osz(1),1:osz(2),:);
end

for p = 1:level-1
	pyr{p} = pyr{p}-pyr_expand(pyr{p+1});
end

end