function output = synth_quilt(tindex,tile_vec,tilesize,overlap)
%
% synthesize an output image given a set of tile indices
% where the tiles overlap, stitch the images together
% by finding an optimal seam between them
%
%  tindex : array containing the tile indices to use
%  tile_vec : array containing the tiles
%  tilesize : the size of the tiles  (should be sqrt of the size of the tile vectors)
%  overlap : overlap amount between tiles
%
%  output : the output image

if (tilesize ~= sqrt(size(tile_vec,1)))
  error('tilesize does not match the size of vectors in tile_vec');
end

% each tile contributes this much to the final output image width 
% except for the last tile in a row/column which isn't overlapped 
% by additional tiles
tilewidth = tilesize-overlap;  

% compute size of output image based on the size of the tile map
outputsize = size(tindex)*tilewidth+overlap;

% 
% stitch each row into a separate image by repeatedly calling your stitch function
% 
arrayOfRowI = zeros(tilesize,outputsize(2),outputsize(1));
for i = 1:size(tindex,1)
  %grab the first tile in the row
  row_image = tile_vec(:,tindex(i,1));
  %reshape it from a vector to a square
  row_image = reshape(row_image,tilesize,tilesize);
  for j = 2:size(tindex,2)
     %grab the selected tile
     tile_image = tile_vec(:,tindex(i,j)); 
     %reshape it from a vector to a square
     tile_image = reshape(tile_image,tilesize,tilesize);
     
     row_image = stitch(row_image, tile_image, overlap);
  end;
  %put each row image in an array
  arrayOfRowI(:,:,i) = row_image;
end;

%
% now stitch the rows together into the final result 
% (call your stitch function on transposed row images and then transpose the result back)
%
output = transpose(arrayOfRowI(:,:,1));
for i = 2:size(tindex,1)
    output = stitch(output,transpose(arrayOfRowI(:,:,i)),overlap);
end
%transpose output image back
output = transpose(output);

