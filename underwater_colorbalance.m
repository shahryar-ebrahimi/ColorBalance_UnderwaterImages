
function [Im, Im_com, Out_white, Out_gamma, Out_sharp, Wght_Lap_Gm, Wght_Sal_Gm, Wght_Sat_Gm, Wght_Nagg_Gm, Wght_Lap_Sh, Wght_Sal_Sh, Wght_Sat_Sh, Wght_Nagg_Sh, Rec1, Rec2] = underwater_colorbalance(Im, type, Level)

%% Authors       : Shahryar Ebrahimi      &   Mohsen Keshtkar
%% S.N.          : 810196093              &   810196291
%% Mail          : shr.ebrahimi@ut.ac.ir  &   mohsen.keshtkar@ut.ac.ir
%% Course Title  : Digital Image Processing (DIP)
%% Paper Title   : Color Balance and Fusion for Underwater Image Enhancement
%% Date Modified : Monday, June 11, 2018
%% 
%% Description   :

%  underwater_colorbalance function is written based on a paper, titled as
%  'Color Balance and Fusion for Underwater Image Enhancement'. the paper
%  is published on IEEE in January 2018. 
%  [Im, Im_com, Out_white, Out_gamma, Out_sharp, Rec1, Rec2] = underwater_colorbalance(Im)
%  as it is obvious underwater_color_balance will concede an input
%  image which is degraded by underwater conditions whith the type of color
%  which is going to be compensated. Level is the number of levels of gaussian 
%  and laplacian pyramids. its value highly depends on image size. 
%  in more cases because od underwater conditions, red channel is going to 
%  get compensated. but sometimes when the planktons of seawater are alot, 
%  it has been also seen that the blue channel will be degraded. due to the
%  mentioned reasons its necessary to enter the type of compensation color. 
%  if only an Image is taken as input, default compensation will be done on 
%  red channel. 

%  underwater_colorbalance take also 7 Images to output as below :

%  Im: is exactly the same Input Image
%  Im_com: is the compensated image by the main formula used in paper
%  Out_white: is the whitened image which is gonna be available after doing
%  gray-world algorithm on compensated image.
%  Out_gamma: gamma-corrected version of whitened Image
%  Out_sharp: sharpened version of whitened image by the help of unsharp
%  masking which is then normalized.
%  Wght_Lap_Gm: laplacian weight of gamma-corrected image.
%  Wght_Sal_Gm: saliency  weight of gamma-corrected image.
%  Wght_Sat_Gm: saturation  weight of gamma-corrected image.
%  Wght_Nagg_Gm: Normalized aggregation weight of gamma-corrected image.
%  Wght_Lap_Sh: laplacian weight of sharpened image.
%  Wght_Sal_Sh: saliency  weight of sharpened image.
%  Wght_Sat_Sh: saturation  weight of sharpened image.
%  Wght_Nagg_Sh: Normalized aggregation weight of sharpened image.
%  Rec1: reconstructed Image by the Naive-reconstruction.
%  Rec2: reconstructed Image by the MultiScale-reconstruction. (better)

%% Checking

if ~ischar(type)
   error('Error. \nInput must be a char.')
end

if nargin ~= 3
    error('number of inputs must be 3 - image|type|Level-of-pyramids');
end

if strcmp (type,'red')
    type = 1;
elseif strcmp(type,'blue')
    type = 2;
else
    error('type of color compensation is red/blue');
end

%% Loading Inputs

Im        = im2double(Im);
[M, N, ~] = size (Im);

%% Image Whitening

%%%%%%%%%%%%%%%%%%%%%%%%% Image Compensation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R         = Im (:,:,1);
G         = Im (:,:,2);
B         = Im (:,:,3);

R         = R / max(max(R));
G         = G / max(max(G));
B         = B / max(max(B));

Rmean     = mean2(R);
Gmean     = mean2(G);
Bmean     = mean2(B);

switch type 
    
    % compensating red color ...
    case 1

        R_com     = R + (Gmean - Rmean) .* (1 - R) .* G ;
        Im_com    = cat (3, R_com, G, B);

    % compensating blue color ...    
    case 2

        B_com    = B + ( Gmean - Bmean ) .* (1 - B) .* G;
        Im_com   = cat (3, R, G, B_com);

end

%%%%%%%%%%%%%%%%%%%%%%%% Gray World Algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Im_com_lin  = rgb2lin(Im);
illuminant  = illumgray(Im_com_lin);
Out_white   = chrom(Im_com_lin,illuminant,'ColorSpace','linear-rgb');

Out_white   = lin2rgb(Out_white);

%% Proseccing Inputs for Multiscale Fusion Block

%%%%%%%%%%%%%%%%%%%%%%%%%% Gamma Correctio %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Out_gamma   = rgb2lin(Out_white);

%%%%%%%%%%%%%%%%%%%%%%%%% Image Sharpening %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Gauss_fil   = fspecial('gaussian', 3, 0.5);
Out_fil     = imfilter(Out_white, Gauss_fil);

dif         = Out_white - Out_fil ;
dif_Norm    = dif / max(max(max(dif)));

Out_sharp   = (Out_white + dif_Norm )/2;

%% Weight Processing
 
%%%%%%%%%%%%%%%%%% Channel type : Gamma Correction %%%%%%%%%%%%%%%%%%%%%%%%

[~,~,L1]    = rgb2hsv(Out_gamma);

R1          = Out_gamma(:,:,1);
G1          = Out_gamma(:,:,2);
B1          = Out_gamma(:,:,3);

% Laplcian Contrast Weight

Laplace_fil = fspecial('laplacian',0.2);
Wght_Lap_Gm = imfilter(L1,Laplace_fil);

% Saliency Weight

kernel_1D   = (1/16) * [1, 4, 6, 4, 1];
kernel_2D   = kron(kernel_1D, kernel_1D');

L1_mean     = mean (L1(:));
L1_whc      = conv2(L1, kernel_2D, 'same');

Wght_Sal_Gm = abs(L1_whc - L1_mean); 

% Saturation Weight

Wght_Sat_Gm = sqrt( 1/3 * ( (R1-L1).^2 + (G1-L1).^2 + (B1-L1).^2 ));

% Weight Aggregation

Wght_Agg_Gm = Wght_Lap_Gm + Wght_Sal_Gm + Wght_Sat_Gm;     

%%%%%%%%%%%%%%%%%%%%% Channel type : sharpening %%%%%%%%%%%%%%%%%%%%%%%%%%%

[~,~,L2]    = rgb2hsv(Out_sharp);

R2          = Out_sharp(:,:,1);
G2          = Out_sharp(:,:,2);
B2          = Out_sharp(:,:,3);

% Laplacian Contrast Weight 

Laplace_fil = fspecial('laplacian',0.2);
Wght_Lap_Sh = imfilter(L2,Laplace_fil);

% Saliency

kernel_1D   = (1/16) * [1, 4, 6, 4, 1];
kernel_2D   = kron(kernel_1D, kernel_1D');

L2_mean     = mean (L2(:));
L2_whc      = conv2(L2, kernel_2D, 'same');

Wght_Sal_Sh = abs(L2_whc - L2_mean); 

% Saturation Weight

Wght_Sat_Sh = sqrt( 1/3 * ( (R2-L2).^2 + (G2-L2).^2 + (B2-L2).^2 ));

% Weight Aggregation

Wght_Agg_Sh = Wght_Lap_Sh + Wght_Sal_Sh + Wght_Sat_Sh;


%%%%%%%%%%%%%%%%%%%%%%%%% Weight Normalization %%%%%%%%%%%%%%%%%%%%%%%%%%%%

sigma       = 0.1;                     % regularization factor

Wght_Nagg_Gm= (Wght_Agg_Gm + sigma) ./ (Wght_Agg_Gm + Wght_Agg_Sh + 2*sigma);
Wght_Nagg_Sh= (Wght_Agg_Sh + sigma) ./ (Wght_Agg_Gm + Wght_Agg_Sh + 2*sigma);

%% Image Reconstruction #1

Rec1        = (Wght_Nagg_Gm .* Out_gamma) + (Wght_Nagg_Sh .* Out_sharp);

%% Image Reconstruction #2

%%%%%%%%%%%%%%%%%%%% Laplacian Pyramids of Inputs %%%%%%%%%%%%%%%%%%%%%%%%%

PyrGammaL   = pyr_gen(Out_gamma, 'laplace', Level);
PyrSharpL   = pyr_gen(Out_sharp, 'laplace', Level);

%%%%%%%%%%%%%%% Gaussian Pyramids of Normalized Weights %%%%%%%%%%%%%%%%%%%

PyrAggG1    = pyr_gen(Wght_Nagg_Gm, 'gauss',Level);
PyrAggG2    = pyr_gen(Wght_Nagg_Sh, 'gauss', Level);

PyrAggG1    = match_sample(PyrAggG1, PyrGammaL);
PyrAggG2    = match_sample(PyrAggG2, PyrSharpL);
  
%%%%%%%%%%%%%%%%%%%%% Final Reconstruction Formula %%%%%%%%%%%%%%%%%%%%%%%%

Rec2cell    = cellmat(1,Level,0,0,0);

for i = 1:Level
	Rec2cell{i} = PyrAggG1{i} .* PyrGammaL{i} + PyrAggG2{i} .* PyrSharpL{i};
end

for i = Level-1:-1:1   
    Rec2cell{i} = Rec2cell{i} + imresize(Rec2cell{i+1},[size(Rec2cell{i}, 1) size(Rec2cell{i}, 2)], 'bicubic');
end

    Rec2 = Rec2cell{1};
    Rec2 = imresize(Rec2, [M N]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% The END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
end