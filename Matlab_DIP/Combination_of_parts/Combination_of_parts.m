
%CLEAR WORKSPACE
clc
clear all
close all
format compact

%BEGIN PARAMETERS DEFINITION
I_resize_width=320;%Before processing, all the images will be resized so that width=I_resize_width. -1 means no resize
%choose what to show
show_input_image = false;
%END PARAMETERS DEFINITION

%BEGIN ALGORITHM
%Get all images with .jpg format from the selected directory
image_dir = '/media/todor/User/git/bitbucket/combinened/fried_rice/';
imagefiles = dir(strcat(image_dir,'*.jpg'));
image_num = length(imagefiles) % Number of images found
%Loop over all the images
for ii=1:image_num
    disp( strcat('Working on image file:_',imagefiles(ii).name) )
    %Get the current image location
    currentfilename = strcat(image_dir,imagefiles(ii).name);
    %Read the current input image and store a copy of it
    I = imread(currentfilename);
    %Get image size
    image_size = size(I);
    %Resize image to match width=I_resize_width pixels
    if(I_resize_width>0)
        I = imresize(I,I_resize_width/image_size(2));
    end
    %show resized image
    if(show_input_image)
        figure;imshow(I);
    end
    
    %APPLY SEGMENTATION
    cd /home/todor/git/dip/Matlab_DIP/Segmentation/
    segments = food_segmentation(I); %call the segmentation method
    size_segments = size(segments);
    num_segments = size_segments(4);
    %loop over the detected segments, being segments(:,:,:,1) dummy
    for i=2:num_segments
        
      
        %Save result
        in_image_name = imagefiles(ii).name;
        in_image_name_size = size(in_image_name);
        out_image_name = in_image_name(1:in_image_name_size(2)-4);
        out_image_name = strcat(out_image_name,'_');
        out_image_name = strcat(out_image_name,num2str(i-1));
        out_image_name = strcat(out_image_name,'.jpg');
        out_image_dir = strcat(image_dir,'/segmented/');
        if(i==2 && ~exist(out_image_dir,'dir'))
            mkdir(out_image_dir);
        end
        imwrite(segments(:,:,:,i),strcat(out_image_dir,out_image_name));
    end
    
end

