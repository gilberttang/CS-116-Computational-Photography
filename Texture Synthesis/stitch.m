function [result] = stitch(leftI,rightI,overlap)

% 
% stitch together two grayscale images with a specified overlap
%
% leftI : the left image of size (H x W1)  
% rightI : the right image of size (H x W2)
% overlap : the width of the overlapping region.
%
% result : an image of size H x (W1+W2-overlap)
%
if (size(leftI,1)~=size(rightI,1)); % make sure the images have compatible heights
  error('left and right image heights are not compatible');
end

% dummy code that produces result by 
% simply pasting the left image over the
% right image. replace this with your own
% code!

%Get overlap matrix HxOverlapr from left image
%overlapLeft = zeros(size(leftI,1),overlap);
overlapLeft = leftI(:,(size(leftI,2)-overlap+1):size(leftI,2));


%Get overlap matrix HxOverlapr from right image
%overlapRight = zeros(size(rightI,1),overlap);
overlapRight = rightI(:,1:overlap);


% Compute a cost array 
overlapM = double(abs(overlapLeft - overlapRight));
path = shortest_path(overlapM);

 w = (size(leftI,2) + size(rightI,2) - overlap);
 result = zeros(size(rightI,1),w);
 for i = 1:size(result,1)
      k = path(i);
        for j = 1:size(result,2)
         if j < ((size(leftI,2)-overlap) + path(i));
              result(i,j) = leftI(i,j); 
          else
              result(i,j) = rightI(i,k);
              k = k+1;
          end;
        end;
  end;

end