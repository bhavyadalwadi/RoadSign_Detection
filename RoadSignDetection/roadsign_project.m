clear all
%Bhavya Dalwadi
%L20393359
% change imgpath to your directory!!
imgpath='C:\Users\Yuri\Downloads\VIsion_Project\Input';
IMG=dir([imgpath '*.jpg']);

% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Tcolor_red, Tcolor_green, and Tcolor_blue are three thresold values
% for color-based candidate region detrectoin;
Tcolor_red=50;
Tcolor_blue=30;
% Tsize_small and Tsize_large are two threshold values
% for the area-based filtering;
Tsize_small=100;
Tsize_large=5000;
% Taspect_ratio is the threshold value for 
% aspect ratio-based filtering;
Taspect_ratio=.4;
% Tsolidity is the threshold value for 
% solidity-based filtering;
Tsolidity = .8;
% Tstd is the theshold value for 
% standard deviation-based filtering
Tstd = 75;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for A=1:length(IMG)
    close all;
    namestr=IMG(A).name;
    origimg=imread([imgpath namestr]);
    % change original image size;
    im_small=imresize(origimg,0.3);
    figure(1)
    imshow(im_small)

    % Step 1: apply Meanshift clustering
    % bandwidth of MeanShift is 0.1;
    bw=0.1;
    % call MeanShift function;
    [im, Nms] = MeanShift(im_small,bw);
    % convert im to RGB image;
    im=uint8(im*255);
    
    % Step 2: color-based candidate region extraction
    % get RGB three channels of the input image;
    r=im(:,:,1);
    g=im(:,:,2);
    b=im(:,:,3);
    ColReg_im=zeros(size(r));
    for i=1:size(r,1)
        for j=1:size(r,2)
            % detection regions in red color using Tcolor_red
            % if the pixel at (x,y) is red, assign 1 to ColReg_im(i,j);
            
            % Your code here!!!
            if (r(i,j) - b(i,j) > Tcolor_red && r(i,j) - g(i,j) > Tcolor_red)
                ColReg_im(i,j) = 1;
            
            % detection regions in blue color using Tcolor_blue
            % if the pixel at (x,y) is blue, assign 2 to ColReg_im(i,j);
            
            % Your code here!!!
            elseif (b(i,j) - r(i,j) > Tcolor_blue && b(i,j) - g(i,j) > Tcolor_blue)
                ColReg_im(i,j) = 2;
            end
        end
    end
    % show a color image with detected red, blue, and yellow regions;
    aftercolor=ones(size(r,1),size(r,2),3)*255;
    aftercolorR=ones(size(r,1),size(r,2))*255;
    aftercolorG=aftercolorR;
    aftercolorB=aftercolorR;
    aftercolorR(ColReg_im==1)=255;
    aftercolorG(ColReg_im==1)=0;
    aftercolorB(ColReg_im==1)=0;
    aftercolorR(ColReg_im==2)=0;
    aftercolorG(ColReg_im==2)=0;
    aftercolorB(ColReg_im==2)=255;
    aftercolor(:,:,1)=aftercolorR;
    aftercolor(:,:,2)=aftercolorG;
    aftercolor(:,:,3)=aftercolorB;
    figure(2)
    subplot(1,2,1)
    imshow(im); 
    subplot(1,2,2)
    imshow(uint8(aftercolor));

    % Step 3: apply heuristic filtering
    % use imfill to fill the holes in the candidate regions
    ColReg_im=imfill(ColReg_im); 
    % use bwlabel to assign each candidate region a label;    
    [ColReg_label, n]=bwlabel(ColReg_im);
    % use regionprops to do heuristic filtering;
    
    % Your code here!!!
    stats = regionprops(ColReg_label,'Area','MajorAxisLength','MinorAxisLength','BoundingBox','Solidity'); %%
    
    % filtering based on size using Tsize_small and Tsize_large
    % idx_size saves the labels of regions that satisfy size constraint
    
    % Your code here!!!
    idx_size = zeros(1,n);
    
    for k = 1:n
        if (stats(k).Area > Tsize_small && stats(k).Area < Tsize_large)
            idx_size(i) = i;
        end
    end
    
    % filtering based on aspect ratio using Taspect_ratio
    % idx_aspectratio saves the labels of regions that satisfy aspect ratio
    % constraint
   
    % Your code here!!!
    idx_aspectratio = zeros(1,n);
    
    for k = 1:n
        if ((stats(k).MinorAxisLength/stats(k).MajorAxisLength) > Taspect_ratio)
            idx_aspectratio(i) = i;
        end
    end
    
    % filtering based on solidity using Tsolidity
    % idx_solidity saves the labels of regions that satisfy solidity
    % constraint
    
    % Your code here!!!
    idx_solidity = zeros(1,n);
    
    for k = 1:n
        if (stats(k).Solidity > Tsolidity)
            idx_solidity(i) = i;
        end
    end

    % filtering based on STD
    % idx_std saves the labels of regions that satisfy STD constraint
    
    %Your code here!!!
    idx_std = zeros(1,n); 
    
    % i is the label from 1 to n for total n regions;
    % n is the 2nd output of bwlabel function;
    for i=1:n
        r=im_small(:,:,1);
        g=im_small(:,:,2);
        b=im_small(:,:,3);
        % calculate standard deviation for each channel
        SR = std(double(r(ColReg_label==i)));
        SG = std(double(g(ColReg_label==i)));
        SB = std(double(b(ColReg_label==i)));

        % Add current region's label (i) to idx_std if at least one of SR, SG, and SB 
        % values is bigger than Tstd;

        if (SR > Tstd || SG > Tstd || SB > Tstd)
            idx_std(i) = i;
        end
        
    end

    % use intersect function to combine the lists
    
    % Your code here!!!
    idx_final = intersect(idx_size, idx_aspectratio);
    idx_final = intersect(idx_final, idx_solidity);
    idx_final = intersect(idx_final, idx_std);

    % generate the image with bounding boxes
    figh = figure(3);
    imshow(im_small);
    hold on;
    for i=1:length(idx_final)
        rectangle('Position',[ColReg_props(idx_final(i)).BoundingBox(1) ColReg_props(idx_final(i)).BoundingBox(2) ColReg_props(idx_final(i)).BoundingBox(3) ColReg_props(idx_final(i)).BoundingBox(4)],'LineWidth',2,'EdgeColor','g');
    end
    % save the output images;
    % change savepath to your directory;
    savepath='C:\Users\Yuri\Downloads\VIsion_Project\Output';
    saveas(figh,[savepath namestr '_output.jpg'],'jpg');
end