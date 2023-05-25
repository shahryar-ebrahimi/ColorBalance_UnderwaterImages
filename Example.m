

clear
close all
clc

%% Authors       : Shahryar Ebrahimi      &   Mohsen Keshtkar
%% S.N.          : 810196093              &   810196291
%% Mail          : shr.ebrahimi@ut.ac.ir  &   mohsen.keshtkar@ut.ac.ir
%% Course Title  : Digital Image Processing (DIP)
%% Paper Title   : Color Balance and Fusion for Underwater Image Enhancement
%% Date Modified : Monday, June 11, 2018
%% Example

test  = cellmat(1,8);
for i = 1:8  
     test{i}   = imread(['test (', num2str(i), ').jpg']);
end

 Level_test(1) = 7;                   % depends to image size - must be chosen in a way that
 Level_test(2) = 7;                   % the last level of pyramid image size be at least one 
 Level_test(3) = 8;                   % tenth of main image size - change it to get best 
 Level_test(4) = 8;                   % result of MultiScale-reconstruction
 Level_test(5) = 8;                   
 Level_test(6) = 7;                     
 Level_test(7) = 7;
 Level_test(8) = 7;
                                      % Warning : inappropriate Level may result in image crop.

%% Checking
 
N  = input('Please Enter the test image number, you wish to examine : ');  

if N < 1 || N > 8
    error('only 8 test images are available, N must be an integer number between 1to8');
end

if round(N) - N ~= 0
    error('N must be an integer number');
end

%% Paper Implementation

[Im, Im_com, Out_white, Out_gamma, Out_sharp, Wght_Lap_Gm, Wght_Sal_Gm, Wght_Sat_Gm, Wght_Nagg_Gm, Wght_Lap_Sh, Wght_Sal_Sh, Wght_Sat_Sh, Wght_Nagg_Sh, Rec1, Rec2] = underwater_colorbalance(test{N},'red', Level_test(N));

%% Saving

imwrite(Im_com,   'rCompensated.jpg');
imwrite(Out_white,'Whitened.jpg');
imwrite(Out_gamma,'Gamma_Corrected.jpg');
imwrite(Out_sharp,'Sharpened.jpg');
imwrite(Rec1,     'Naive_Reconstructed.jpg');
imwrite(Rec2,     'MultiScale_Reconstructed.jpg');

%% Displaying Results

figure, imshow(Im,        'InitialMagnification', 'fit'); title('Original degraded image');
figure, imshow(Im_com,    'InitialMagnification', 'fit'); title('Compensated image');
figure, imshow(Out_white, 'InitialMagnification', 'fit'); title('Whitened image');
figure, imshow(Out_gamma, 'InitialMagnification', 'fit'); title('Gamma-Corrected image');
figure, imshow(Out_sharp, 'InitialMagnification', 'fit'); title('Sharpened image');
figure, imshow(Rec1,      'InitialMagnification', 'fit'); title('Naive-Reconstructed Image');
figure, imshow(Rec2,      'InitialMagnification', 'fit'); title('MultiScale-Reconstructed image');

