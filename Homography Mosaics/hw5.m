function hw5
% Load in images
%imnames = {'atrium/IMG_1347.JPG','atrium/IMG_1348.JPG','atrium/IMG_1349.JPG'};
imnames = {'keble/keble_b.JPG','keble/keble_a.JPG','keble/keble_c.JPG'};
%imnames = {'bedroom/bedroom_a.JPG','bedroom/bedroom_b.JPG','bedroom/bedroom_c.JPG'};
nimages = length(imnames);
baseim = 1; %index of the central "base" image

for i = 1:nimages
  ims{i} = im2double(imread(imnames{i}));
  ims_gray{i} = rgb2gray(ims{i});
  [h(i),w(i),~] = size(ims{i});
end


% get corresponding points between each image and the central base image
for i = 1:nimages
   if (i ~= baseim)
     %run interactive select tool to click corresponding points on base and non-base image
     [movingPoints, fixedPoints] = cpselect(ims{baseim},ims{i},'Wait',true);

     %refine the user clicks using cpcorr
     movingPoints = cpcorr(movingPoints,fixedPoints,ims_gray{i},ims_gray{baseim});
     
     movPts{i} = movingPoints;
     fixedPts{i} = fixedPoints;
   end
end

%
% verify that the points are good!
% some example code to plot some points, you will need to modify
% this based on how you are storing the points etc.
%
    base_image = ims{baseim};
    for i = 2:nimages
        input_image{i} = ims{i};
        x1{i} = movPts{i}(:,1);
        y1{i} = movPts{i}(:,2);
        x2{i} = fixedPts{i}(:,1);
        y2{i} = fixedPts{i}(:,2);
    end
    for i = 2:nimages
        subplot(2,1,1); 
        imagesc(base_image);
        hold on;
    
        plot(x1{i}(1),y1{i}(1),'r*',x1{i}(2),y1{i}(2),'b*',x1{i}(3),y1{i}(3),'g*',x1{i}(4),y1{i}(4),'y*');
        subplot(2,1,2);
        imshow(input_image{i});
        hold on;
        plot(x2{i}(1),y2{i}(1),'r*',x2{i}(2),y2{i}(2),'b*',x2{i}(3),y2{i}(3),'g*',x2{i}(4),y2{i}(4),'y*');
    end

%
% at this point it is probably a good idea to save the results of all your clicking
% out to a file so you can easily load them in again later on
%

save keble.mat
%save atrium.mat
%save bedroom.mat

% to reload the points:   load mypts.mat
load keble.mat
%load atrium.mat
%load bedroom.mat

%
% estimate homography for each image
%
for i = 1:nimages
   if (i ~= baseim)
     H{i} = computeHomography(x2{i},y2{i},x1{i},y1{i});
   else
     H{i} = eye(3); %homography for base image is just the identity matrix
   end
end

%
% compute where corners of each warped image end up
%
for i = 1:nimages
  cx = [1;1;w(i);w(i)];  %corner coordinates based on h,w for each image
  cy = [1;h(i);1;h(i)];
  [cx_warped{i},cy_warped{i}] = applyHomography(H{i},cx,cy);
end

% 
% find corners of a rectangle that contains all the warped images
% 
%
minX = w(baseim);maxX = -w(baseim);
minY = h(baseim);maxY = -h(baseim); 
for i = 1:nimages
    if min(cx_warped{i}) < minX 
        minX = min(cx_warped{i});
    end
    if max(cx_warped{i}) > maxX 
        maxX = max(cx_warped{i});
    end
    if min(cy_warped{i}) < minY 
        minY = min(cy_warped{i});
    end
    if max(cy_warped{i}) > maxY 
        maxY = max(cy_warped{i});
    end
end

% Use H and interp2 to perform inverse-warping of the source image to align it with the base image

[xx,yy] = meshgrid(minX:maxX,minY:maxY);  %range of meshgrid should be the containing rectangle
[wp hp] = size(xx); 
for i = 1:nimages
   [newX, newY] = applyHomography(inv(H{i}),xx(:),yy(:));
   clear Ip;
   xI = reshape(newX,wp,hp)'; 
   yI = reshape(newY,wp,hp)';  
   R = interp2(ims{i}(:,:,1), xI, yI, '*bilinear')'; % red 
   G = interp2(ims{i}(:,:,2), xI, yI, '*bilinear')'; % green 
   B = interp2(ims{i}(:,:,3), xI, yI, '*bilinear')'; % blue 
   J{i} = cat(3,R,G,B);

   % blur and clip mask to get an alpha map
    alphaMask = 1 - isnan(J{i});
    h = fspecial('gaussian', 50, 0.5 );
    alpha{i} = imfilter(alphaMask, h, 'replicate');
    
    mask{i} = ~isnan(R);  %interp2 puts NaNs outside the support of the warped image
    J{i}(isnan(J{i})) = 0;
end

% scale alpha maps to sum to 1 at every pixel location
sum = zeros(size(J{1}));
for i = 1:nimages
    sum = sum + alpha{i};
end

for i = 1:nimages
    alpha{i} = alpha{i}./sum;
end

% finally blend together the resulting images into the final mosaic

K = zeros(size(J{1}));
for i = 1:nimages
    K  = K + J{i}.*alpha{i};
end


% display the result
  imshow(K);


% save the result
%  imwrite(J{1},'Base_Atrium.jpg');
%  imwrite(J{2},'Top_Atrium.jpg');
%  imwrite(J{3},'Bottom_Atrium.jpg');

  imwrite(J{1},'Base_keble.jpg');
  imwrite(J{2},'Left_keble.jpg');
  imwrite(J{3},'Top_keble.jpg');

%  imwrite(J{1},'Base_Bedroom.jpg');
%  imwrite(J{2},'Top_Bedroom.jpg');
%  imwrite(J{3},'Bottom_Bedroom.jpg');


%imwrite(K,'final_atrium.jpg');
imwrite(K,'final_keble.jpg');
%imwrite(K,'final_bedroom.jpg');
end
