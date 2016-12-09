% load a training example image
Itrain = im2double(rgb2gray(imread('face3.jpg')));

%have the user click on some training examples.  
% If there is more than 1 example in the training image (e.g. faces), you could set nclicks higher here and average together
nclick = 1;
figure(1); clf;
imshow(Itrain);
[x,y] = ginput(nclick); %get nclicks from the user

%compute 8x8 block in which the user clicked
blockx = round(x/8);
blocky = round(y/8); 

%visualize image patch that the user clicked on
% the patch shown will be the size of our template
% since the template will be 16x16 blocks and each
% block is 8 pixels, visualize a 128pixel square 
% around the click location.
size = 32;
figure(2); clf;
for i = 1:nclick
  patch = Itrain(8*blocky(i)+(-size*8+1:size*8),8*blockx(i)+(-size*8+1:size*8));
  figure(2); subplot(3,2,i); imshow(patch);
end

% compute the hog features
f = hog(Itrain);

% compute the average template for the user clicks
template = zeros(size*2,size*2,9);
for i = 1:nclick
  template = template + f(blocky(i)+(-size+1:size),blockx(i)+(-size+1:size),:); 
end
template = template/nclick;


%
% load a test image
%
Itest= im2double(rgb2gray(imread('face5.jpg')));


% find top 5 detections in Itest
ndet = 5;
[x,y,score] = detect(Itest,template,ndet);
ndet = length(x);

%display top ndet detections
figure(3); clf; imshow(Itest);
for i = 1:ndet
  % draw a rectangle.  use color to encode confidence of detection
  %  top scoring are green, fading to red
  hold on; 
  h = rectangle('Position',[x(i)-size*8 y(i)-size*8 size*8*2 size*8*2],'EdgeColor',[(i/ndet) ((ndet-i)/ndet)  0],'LineWidth',3,'Curvature',[0.3 0.3]); 
  hold off;
end
