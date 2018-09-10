function hoghists=getPmlHogDescriptor(Im,level,blockSize)

    numpixels=8;

    [levelImgs,numblcks]=getPyramids(Im,level,blockSize);


    fun = @(block_struct) extractHOGFeatures(block_struct.data,'CellSize', [numpixels numpixels], 'NumBins', 13,'BlockOverlap',[0 0]);


    hoghists=[];

    for j=1:numel(levelImgs)

        if size(levelImgs{j},3)>1
            grayImage=rgb2gray(levelImgs{j});
        else
            grayImage=levelImgs{j};        
        end

        aux=blockproc(grayImage,[blockSize blockSize],fun); 
        [r,c]=size(aux);

        hoghists=[hoghists;reshape(aux,r*c,1)];     

    end


    %% get pyramids ---------

    function [images,numBlocks]=getPyramids(origIm,level,blockSize)

        if isstr(origIm)
            I=imread(origIm);
        else
            I=origIm;
        end

        for i=1:level

           imSize=(level+1-i)*blockSize;
           images{i}=imresize(I,[imSize,imSize]);
           numBlocks(i)=(level+1-i);

        end
        images=images(:);
    end



end