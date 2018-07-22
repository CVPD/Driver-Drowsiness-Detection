function lbphists=getPmlLbpDescriptor(Im,level,blockSize)

    mapping=getmapping(8,'u2');
    mode='nh';
    radio=1;
    fun = @(block_struct) lbp(block_struct.data,radio,8,mapping,mode);

    [levelImgs,numblcks]=getPyramids(Im,level,blockSize);

    lbphists=[];

    for j=1:numel(levelImgs)

        if size(levelImgs{j},3)>1
            grayImage=rgb2gray(levelImgs{j});
        else
            grayImage=levelImgs{j};        
        end

        lbphist=blockproc(grayImage,[blockSize blockSize],fun); 
        [r,c]=size(lbphist);
        lbphists=[lbphists;reshape(lbphist,r*c,1)]; 

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
             
             