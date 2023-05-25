
function imgout = pyr_reduce(img)

%% Authors       : Shahryar Ebrahimi      &   Mohsen Keshtkar
%% S.N.          : 810196093              &   810196291
%% Mail          : shr.ebrahimi@ut.ac.ir  &   mohsen.keshtkar@ut.ac.ir
%% Course Title  : Digital Image Processing (DIP)
%% Paper Title   : Color Balance and Fusion for Underwater Image Enhancement
%% Date Modified : Monday, June 11, 2018
%% 
%% Description   :

%   PYR_REDUCE  Image pyramid reduction
%   B = PYR_REDUCE( A )  If A is M-by-N, then the size of B 
%	is ceil(M/2)-by-ceil(N/2). Support gray or rgb image.
%	B will be transformed to double class.

kernelWidth   = 5;                               % default
cw            = .375;                            % kernel centre weight, same as MATLAB func impyramid. 0.6 in the Paper
ker1d         = [.25-cw/2 .25 cw .25 .25-cw/2];
kernel        = kron(ker1d,ker1d');

img           = im2double(img);
sz            = size(img);
imgout        = [];

for p = 1:size(img,3)
    
	img1 = img(:,:,p);
	imgFiltered = imfilter(img1,kernel,'replicate','same');
	imgout(:,:,p) = imgFiltered(1:2:sz(1),1:2:sz(2));
    
end

end