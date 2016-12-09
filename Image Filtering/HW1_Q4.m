I = rgb2gray(imread('myfile.jpg')); % psnr2.png is a color image 
I = im2double(I); %covert to double

%a.
I = rgb2gray(imread('myfile.jpg'));
I = im2double(I);
A = I([1:100], [1:100]);
x = reshape(A,1,[]);
figure, plot(sort(x));

%b.
figure, hist(A,32);

%c.
newImage = A > 0.651;

%d.
newImage = newImage - mean(mean(A));
newImage(newImage<0)=0;
imshow(newImage);

%e.
y = [1:6];
z = reshape(y, [3,2]);

%f.
x = find(A == min(min(A)), 1);
r = find(min(A,[],2) == min(min(A)), 1);
c = find(min(A) == min(min(A)), 1);

%g.
v = [1 8 8 2 1 3 9 8];
unique(v);
sum(unique(v));