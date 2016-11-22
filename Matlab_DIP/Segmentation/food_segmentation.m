%This function reads an input image and returns a set of images each of
%them containing a segment as a result of colour segmentation
function segments = food_segmentation (I)

%BEGIN PARAMETERS DEFINITION
H_hist_medfilt_order= 256/32;%Median filter order applied to the Hue component histogram
H_hist_shift = -75;%Circular shift (>>,right is H_shift is positive) of the Histogram of Hue component values, needed for better study of yellow-orange-red colours, e.g.-75
hue_hist_peak_threshold = 0.01;%minimum peak height (as porcentage of the total image pixels) to be considered as a peak in the histogram.
%choose what to show
plot_hue_histogram = false;%Plot Hue histogram, median filter smooth of it and also peak detection results
show_output_images = false;%Show the filtered segments
%END PARAMETERS DEFINITION

%BEGIN ALGORITHM
    
    %Transform in HSV colour space
    I_hsv = rgb2hsv(I);
    %Get HSV channels
    H=I_hsv(:,:,1);
    S=I_hsv(:,:,2);
    V=I_hsv(:,:,3);
    
    %Remove too bright colours because their Hue value could be misleading
    smask = S>0.1;
    %Morhological closing
    smask = bwmorph(smask,'close');
    I_hsv = I_hsv.*repmat(smask,[1,1,3]);
    
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
    %loop over the different peaks
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
            H_bin= (H>H_min(i)/256) | (H<H_max(i)/256);
        else
            %Create a binary image by thresholding with H_min AND H_max
            H_bin= (H>H_min(i)/256) & (H<H_max(i)/256);
        end
        %Morhological closing
        %H_bin = bwmorph(H_bin,'close');
        %Apply mask
        I_hsv_masked = I_hsv.*repmat(H_bin,[1,1,3]);
        figure;imshow(I);
        figure;imshow(H_bin);
        active_contour_mask = activecontour(H, bwmorph(H_bin,'thin',50));
        figure;imshow(active_contour_mask);
        %Create output
        segments(:,:,:,i+1)=hsv2rgb(I_hsv_masked);%segments(:,:,:,1) is dummy
           
    end
    
end

