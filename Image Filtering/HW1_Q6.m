function demosaic

I = im2double(imread('IMG_1308.pgm'));
    figure(1); clf; imshow(I(1:500,1:500));
J = mydemosaic(I(1:500,1:500));
figure(2); clf; imshow(J);

function [J] = mydemosaic(Input)
%mydemosaic - demosaic a Bayer RG/GB image to an RGB image
    %
% I: RG/GB mosaic image  of size  HxW
% J: RGB image           of size  HxWx3

InputI = im2double(Input);
A = size(InputI);   
H = A(1);
W = A(2);

RChannel=InputI.*repmat([1 0; 0 0], H/2, W/2); %multiple red pattern
GChannel=InputI.*repmat([0 1; 1 0], H/2, W/2); %multiple green pattern
BChannel=InputI.*repmat([0 0; 0 1], H/2, W/2); %multiple blue pattern
GFilter = [0 1 0; 1 0 1; 0 1 0]/4;
RBFilter = [1 0 1; 0 0 0; 1 0 1]/4;
  

% Interpolation for both red and blue and add them together to create a
% green pattern like matrix
    RChannel = RChannel + imfilter(RChannel,RBFilter); 
    BChannel = BChannel + imfilter(BChannel,RBFilter);
     
%Interpolation for green and those modified blue & red matrices
    RChannel = RChannel + imfilter(RChannel,GFilter);
    GChannel = GChannel + imfilter(GChannel,GFilter);
    BChannel = BChannel + imfilter(BChannel,GFilter);
    
%Bring RGB channel back to the original image
    J(:,:,1)=RChannel; J(:,:,2)=GChannel; J(:,:,3)=BChannel; 
end
 

end


    
    