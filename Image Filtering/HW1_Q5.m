      filelist = dir('images/averageimage_data/set1/*.jpg');
      for i=1:length(filelist)
               imname = ['images/averageimage_data/set1/' filelist(i).name];
               nextim = im2double(imread(imname));
               if ( i == 1)
                   aveImage = nextim;
               end
                   
              aveImage = aveImage + nextim; 
               % convert nextim to double and add it to your running average 
    
      end
      aveImage = aveImage/i;
      imshow(aveImage);