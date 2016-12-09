% 
 function [H] = computeHomography(x1,y1,x2,y2)
 % x1,y1,x2,y2 are nx1 matrix
   n = size(x1,1);
   A = zeros(2*n,9);
   for i = 1:n
      A((2*i-1):2*i,:) = [-x1(i,1), -y1(i,1), 1*-1,        0,        0,  0, x1(i,1)*x2(i,1), y1(i,1)*x2(i,1), x2(i,1);
                               0,        0,  0, -x1(i,1), -y1(i,1), -1.0, x1(i,1)*y2(i,1), y1(i,1)*y2(i,1), y2(i,1)];
   end
  [~,~,V] = svd(A);
  temp_H = V(:,9); 
  H = reshape(temp_H,[3,3])';
 end