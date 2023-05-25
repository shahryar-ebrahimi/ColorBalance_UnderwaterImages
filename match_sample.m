
function y = match_sample(img1, img2)

%% Authors       : Shahryar Ebrahimi      &   Mohsen Keshtkar
%% S.N.          : 810196093              &   810196291
%% Mail          : shr.ebrahimi@ut.ac.ir  &   mohsen.keshtkar@ut.ac.ir
%% Course Title  : Digital Image Processing (DIP)
%% Paper Title   : Color Balance and Fusion for Underwater Image Enhancement
%% Date Modified : Monday, June 11, 2018
%% 
%% Description   :

%  upsampling img2 cell which contains the pyramid image samples or 
%  downsampling img1 whcich again contaions pyramid image samples to match 
%  the coordinates of 2 img cell in all cells. this function needs to 
%  concede a Lelvel value which determines the length of the cell 
    
for i = 1:length(img1)
   
   [X1, Y1]    = size(img1{i});
   [X2, Y2,~]  = size(img2{i});
   
   X = X1 - X2;
   Y = Y1 - Y2;
   
   d1 = floor(X1/X); 
   d2 = floor(Y1/Y);
   
   del = zeros(1,X);
   for q = 1:X
       del(q) = (q-1)*d1 + 1;
   end
   img1{i}(del,:) = [];
   
   del = zeros(1,Y);
   for q = 1:Y
       del(q) = (q-1)*d2 + 1;
   end
   img1{i}(:,del) = [];
   
end
    
    y = img1;
end