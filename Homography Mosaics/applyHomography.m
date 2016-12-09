 function [x2,y2] = applyHomography(H,x1,y1)
     mapPts = H*[x1'; y1'; ones(1,size(x1,1))];
     for i = 1:size(x1,1)
         mapPts(:,i) = mapPts(:,i)/mapPts(3,i);
     end
     x2 = mapPts(1,:)';
     y2 = mapPts(2,:)';
 end