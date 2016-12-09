function hw5_bouns
% Load in images
imnames = {'keble/keble_b.JPG','keble/keble_a.JPG','keble/keble_c.JPG'};
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

save 2bandKeble.mat


% to reload the points:   load mypts.mat
load 2bandKeble.mat

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
        alphaMask{i} = 1 - isnan(J{i});
        mask{i} = ~isnan(R);  %interp2 puts NaNs outside the support of the warped image
        J{i}(isnan(J{i})) = 0;
    end

    for i = 1:nimages
        %blending
        I{i} = J{i};
        M{i} = alphaMask{i};
    end

    %
    % separate out frequency bands for the image and mask
    %
    filter = fspecial('gaussian', 50,0.5 );
    for i = 1:nimages
        % low frequency band is just blurred version of the image
        I_L{i} = imfilter(I{i}, filter, 'replicate');   
        % low frequency alpha should be feathered version of M1 & M2
        A_L{i} = imfilter(M{i}, filter, 'replicate'); 
    end    
    % normalize the alpha masks to sum to 1 at every pixel location
    % (we avoid dividing by zero by adding a term to the denominator 
    % anyplace the sum is 0)
    Asum = 0;
    for i = 1:nimages
        Asum = Asum + A_L{i};  
    end
    
    for i = 1:nimages
        A_L{i} = A_L{i} ./ (Asum + (Asum==0));
    end

    % high frequency band is whatever is left after subtracting the low frequencies
    for i = 1:nimages
        I_H{i} = I{i}-I_L{i};  
    end
    %for high frequencies use a very sharp alpha mask which is 
    % alpha=1 for which ever image has the most weight at each 
    % location
    for i = 1:nimages
        for j = 1:nimages
            A_H{i} = double(A_L{i} > A_L{j}); 
        end
    end 
    % normalize the alpha masks to sum to 1 
    % technically we shouldn't have to do this the way we've constructed
    % A1_H and A2_H above, but just to be safe.
    Asum = 0;
    for i = 1:nimages
        Asum = A_H{i};  
    end
    
    for i = 1:nimages
        A_H{i} = A_H{i} ./ (Asum + (Asum==0));
    end
    %
    % now combine the results using alpha blending
    %
    J_L = zeros(size(A_L{1}));
    for i = 1:nimages
        J_L = A_L{i} .* I_L{i} + J_L;  % low frequency band
    end
    
    J_H = zeros(size(A_H{1}));
    for i = 1:nimages
        J_H = A_H{i} .* I_H{i} + J_H;   % high frequency band
    end
    FJ = J_L + J_H; % combined bands
    imwrite(FJ,'2band_keble.jpg');
    imshow(FJ);




  imwrite(J{1},'2band_keble_base.jpg');
  imwrite(J{2},'2band_keble_left.jpg');
  imwrite(J{3},'2band_keble_right.jpg');


%
% display some of the intermediate results
%
% figure(1);
% k = 0;
% for i = 1:nimages
%     subplot(3,3,i); imshow(I_L{i}); 
%     k = i;
% end
% k = k + 1;
% subplot(3,3,k); imshow(J_L);  title('low frequency band');
% g = k;
% for i = g:nimages+g-1
%     i
%     subplot(3,3,i); imshow(I_H{i-g+1});
%     k = k + 1;
% end
% 
% subplot(3,3,k); imshow(J_H); title('high frequency band');
% 
% for i = g:nimages+g-1
%     subplot(3,3,i); imshow(I{i-g+1});
% end
% g = i + 1;
% subplot(3,3,g); imshow(FJ); title('combined');
  

% function [x2,y2] = applyHomography(H,x1,y1)
%     mapPts = H*[x1'; y1'; ones(1,size(x1,1))];
%     for i = 1:size(x1,1)
%         mapPts(:,i) = mapPts(:,i)/mapPts(3,i);
%     end
%     x2 = mapPts(1,:)';
%     y2 = mapPts(2,:)';
% end
% 
% function [H] = computeHomography(x1,y1,x2,y2)
% % x1,y1,x2,y2 are nx1 matrix
%   n = size(x1,1);
%   A = zeros(2*n,9);
%   for i = 1:n
%      A((2*i-1):2*i,:) = [-x1(i,1), -y1(i,1), 1*-1,        0,        0,  0, x1(i,1)*x2(i,1), y1(i,1)*x2(i,1), x2(i,1);
%                               0,        0,  0, -x1(i,1), -y1(i,1), -1.0, x1(i,1)*y2(i,1), y1(i,1)*y2(i,1), y2(i,1)];
%   end
%  [~,~,V] = svd(A);
%  h = V(:,9); 
%  H = reshape(h,[3,3])';
% end
  
end

    