function [path] = shortest_path(costs)

%
% given a 2D array of costs, compute the minimum cost vertical path
% from top to bottom which, at each step, either goes straight or
% one pixel to the left or right.
%
% costs:  a HxW array of costs
%
% path: a Hx1 vector containing the indices (values in 1...W) for 
%       each step along the path
%
%
%

%Find the cost of each path
costOfPaths = zeros(size(costs));
costOfPaths(1,:) = costs(1,:);
for i=2:size(costOfPaths,1),
     costOfPaths(i,1) = costs(i,1) + min( costOfPaths(i-1,1), costOfPaths(i-1,2) ); %left most path
     for j=2:size(costOfPaths,2)-1,
         costOfPaths(i,j) = costs(i,j) + min([costOfPaths(i-1,j-1), costOfPaths(i-1,j), costOfPaths(i-1,j+1)] );
     end;
     costOfPaths(i,end) = costs(i,end) + min( costOfPaths(i-1,end-1), costOfPaths(i-1,end) ); %right most path
end;


%Backtracking
path = zeros(size(costs,1),1);
[c, idx] = min(costOfPaths(end, 1:end));
path(i, 1) = idx;
for i=size(costOfPaths,1)-1:-1:1,
    for j=1:size(costOfPaths,2),
        if( (idx > 1 & (costOfPaths(i,idx-1) == min(costOfPaths(i,idx-1:min(idx+1,size(costOfPaths,2)))))))
             idx = idx-1;
        elseif( (idx < size(costOfPaths,2)) & (costOfPaths(i,idx+1) == min(costOfPaths(i,max(idx-1,1):idx+1))) )
            idx = idx+1;
        end;   
        path(i, 1) = idx;       
    end;
end;
    
end


