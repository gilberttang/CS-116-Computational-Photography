function [mag,ori] = mygradient(I)
%
% compute image gradient magnitude and orientation at each pixel
%
% 
%I = im2double(rgb2gray(imread('1.jpg')));
hx = [-1,0,1;-2,0,2;-1,0,1];
hy = transpose(hx);
dx = imfilter(I, hx, 'replicate');
dy = imfilter(I, hy, 'replicate');

mag = sqrt(dx.^2 + dy.^2);
ori=atan2(dy,dx).*-180/pi;
%test mygradient
% imagesc(mag)
% colorbar
% colormap jet
% title('Magnitude')
% 
% imagesc(ori)
% colorbar
% colormap jet
% title('Orientation')
