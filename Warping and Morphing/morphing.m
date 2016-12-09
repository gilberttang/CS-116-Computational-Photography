%
% morphing script
%

% load in two images...
I1 = im2double(imread('58.jpg'));
I2 = im2double(imread('59.jpg'));

% get user clicks on keypoints
imshow(I1);
[x1,y1] = getpts;
pts_img1(1,:) = transpose(x1);
pts_img1(2,:) = transpose(y1);

imshow(I2);
[x2,y2] = getpts;
pts_img2(1,:) = transpose(x1);
pts_img2(2,:) = transpose(y1);
% generate triangulation 
  tri1 = delaunay(x1,y1);
  tri2 = delaunay(x2,y2);

% now produce the frames of the morph sequence
    for fnum = 1:61
      t = (fnum-1)/61;
      pts_target = (1-t)*pts_img1 + t*pts_img2;                % intermediate key-point locations
      I1_warp = warp(I1,pts_img1,pts_target,tri1);              % warp image 1
      I2_warp = warp(I2,pts_img2,pts_target,tri2);              % warp image 2
      Iresult = (1-t)*I1_warp + t*I2_warp;                     % blend the two warped images
      imwrite(Iresult,sprintf('frame_%2.2d.jpg',fnum),'jpg')
    end