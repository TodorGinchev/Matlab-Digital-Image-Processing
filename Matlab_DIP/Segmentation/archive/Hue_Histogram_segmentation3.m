%This function read input images that contain french fries and returns the french fries as a segmented object

%CLEAR WORKSPACE
clc
clear all
close all
format compact
%BEGIN PARAMETERS DEFINITION
I_resize_width=320;%Before processing, all the images will be resized so that width=I_resize_width. -1 means no resize
H_hist_medfilt_order= 256/32;%Median filter order applied to the Hue component histogram
H_hist_shift = -75;%Circular shift (>>,right is H_shift is positive) of the Histogram of Hue component values, needed for better study of yellow-orange-red colours, e.g.-75
hue_hist_peak_threshold = 0.01;%minimum peak height (as porcentage of the total image pixels) to be considered as a peak in the histogram.
%choose what to show
show_input_image = false;
plot_hue_histogram = false;%Plot Hue histogram, median filter smooth of it and also peak detection results
show_output_images = false;%Show the filtered segments
%END PARAMETERS DEFINITION

%BEGIN ALGORITHM
%Get all images with .jpg format from the selected directory
image_dir = '/media/todor/User/git/bitbucket/combinened/french_fries/';
imagefiles = dir(strcat(image_dir,'*.jpg'));
image_num = length(imagefiles) % Number of images found
%Loop over all the images
%for ii=1:image_num
for ii=1:image_num
    disp( strcat('Working on image file:_',imagefiles(ii).name) )
    %Get the current image location
    currentfilename = strcat(image_dir,imagefiles(ii).name);
    %Read the current input image and store a copy of it
    I = imread(currentfilename);
    I_origin = I;
    %Get image size
    image_size = size(I);
    %Resize image to match width=I_resize_width pixels
    if(I_resize_width>0)
        I = imresize(I,I_resize_width/image_size(2));
    end
    if(show_input_image)
        %show resized image
        figure;imshow(I);
    end
    
    %Transform in HSV colour space
    I_hsv = rgb2hsv(I);
    %Get HSV channels
    H=I_hsv(:,:,1);
    S=I_hsv(:,:,2);
    V=I_hsv(:,:,3);
    
    figure;plot(imhist(S));
    continue
%     smask = S>0.1;
%     I_hsv = I_hsv.*repmat(smask,[1,1,3]);
%     I=hsv2rgb(I_hsv);
%     figure;imshow(I);
%     continue;
    
    %Shift left Hue component histogram by 75 units
    H_hist = imhist(H);
    H_hist_shifted = circshift(H_hist,H_hist_shift);
    %Apply median filter of order H_hist_medfilt_order over the histogram
    H_hist_med = medfilt1(H_hist_shifted,H_hist_medfilt_order);
    
    %Find the peaks which histogram value is higher than hue_hist_peak_threshold
    %Documentation: https://se.mathworks.com/help/signal/ref/findpeaks.html
    %Plot image histogram before and after filtering and then plot peak detection
    im_size = size(I);
    if(plot_hue_histogram)
        figure; plot(H_hist_shifted);
        hold on; plot(H_hist_med);
        findpeaks(H_hist_med,'Annotate','extents','WidthReference','halfheight','MinPeakHeight',hue_hist_peak_threshold*im_size(1)*im_size(2));
    end
    
    [PKS,LOCS,W,P] = findpeaks(H_hist_med,'Annotate','extents','WidthReference','halfheight','MinPeakHeight',hue_hist_peak_threshold*im_size(1)*im_size(2));
    
    %Find derivative
    %     H_med_der(1)=1;
    %     H_med_der(2)=1;
    %     for i=2 : (size(H_hist_med)-1)
    %         H_hist_med_der(i+1) = (H_hist_med(i+1)+500)/(H_hist_med(i)+500);
    %     end
    %     figure;plot(H_hist_med_der);
    
    %Calculate threshold filter bandwidth, take into account the hue shift
    H_min = LOCS-W-H_hist_shift;
    H_max = LOCS+W-H_hist_shift;
    
    %Init matrixes
    H_bin = zeros(size(H));
    I_hsv_masked = zeros(size(H));
    for i=1:size(H_min(:))
        %Restore the shift
        if(H_min(i)>256)
            H_min(i) = H_min(i)-256;
        end
        if(H_max(i)>256)
            H_max(i) = H_max(i)-256;
        end
        %Keep restoring issues due to hue shift
        if(H_min(i)>H_max(i))
            %Create a binary image by thresholding with H_min OR H_max
            H_bin1= (H>H_min(i)/256) | (H<H_max(i)/256);
        else
            %Create a binary image by thresholding with H_min AND H_max
            H_bin= (H>H_min(i)/256) & (H<H_max(i)/256);
        end
        %Apply mask
        I_hsv_masked = I_hsv.*repmat(H_bin,[1,1,3]);
%         I_hsv_masked(:,:,1)=I_hsv(:,:,1).*H_bin(:,:);
%         I_hsv_masked(:,:,2)=I_hsv(:,:,2).*H_bin(:,:);
%         I_hsv_masked(:,:,3)=I_hsv(:,:,3).*H_bin(:,:);
        
        I_segmented=hsv2rgb(I_hsv_masked);
        if(show_output_images)
            figure, imshow(I_segmented);
        end
        
        %Save result
        in_image_name = imagefiles(ii).name;
        in_image_name_size = size(in_image_name);
        out_image_name = in_image_name(1:in_image_name_size(2)-4);
        out_image_name = strcat(out_image_name,'_');
        out_image_name = strcat(out_image_name,num2str(i));
        out_image_name = strcat(out_image_name,'.jpg');
        out_image_dir = strcat(image_dir,'/segmented/');
        %mkdir(out_image_dir);
        imwrite(I_segmented,strcat(out_image_dir,out_image_name));
        
    end
    
    
    % Hlow=im2bw(H, 0.047);%10/180);
    % Hhigh=1-im2bw(H,0.130);%50/180);
    % H=Hlow+Hhigh;
    % I_hsv(:,:,1)=H(:,:);
    % I_grayscale=hsv2rgb(I_hsv);
    % figure, imshow(I_grayscale);
end

