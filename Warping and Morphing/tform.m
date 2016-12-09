function T = tform(tri1,tri2)

%
% compute the transformation T which transformation 
%
%  T : the resulting tranformation, should be a 3x3
%      matrix which works on points described in 
%      homogeneous coorindates 
%

%
% your code here should figure out the matrix T
%

%Create an matrix for tril1 to transform to origin with all edges have 1
A = [tri1(3)-tri1(1),tri1(5)-tri1(1),tri1(1); tri1(4)-tri1(2),tri1(6)- tri1(2),tri1(2);0,0,1];
A = inv(A);

%Create an matrix for trasformating a triangle at origin with all edges have 1 to tril2
B = [tri2(3)-tri2(1),tri2(5)-tri2(1),tri2(1); tri2(4)-tri2(2),tri2(6)- tri2(2),tri2(2);0,0,1];
T = B*A;

%
% test code to make sure we have done the right thing
%
% apply mapping to corners of tri1 and 
% make sure the result is close to tri2
err1 = sum((T*[tri1(:,1);1] - [tri2(:,1);1]).^2);
assert(err1 < eps)

err2 = sum((T*[tri1(:,2);1] - [tri2(:,2);1]).^2);
assert(err2 < eps)

err3 = sum((T*[tri1(:,3);1] - [tri2(:,3);1]).^2);
assert(err3 < eps)


end

