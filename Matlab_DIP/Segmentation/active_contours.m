 I = imread('/media/todor/User/git/bitbucket/combinened/french_fries/15283.jpg');
 %Get image size
 image_size = size(I);
 %Resize image to match width=320pixels
 I = imresize(I,320/image_size(2));
 imshow(I)
 %Get RGB channels
 R=I(:,:,1);
 G=I(:,:,2);
 B=I(:,:,3);
 %Get HSV channels
 I_hsv = rgb2hsv(I);
 H=I_hsv(:,:,1);
 S=I_hsv(:,:,2);
 V=I_hsv(:,:,3);
 
 %Igray = R-B; %R-B for salmon
 %Igray = (R-G); %For yellow-red french fries
 Hlow=im2bw(H, 0.047);%10/180);
 Hhigh=1-im2bw(H,0.130);%50/180);
 H=Hlow+Hhigh;
 I_hsv(:,:,1)=H(:,:);
 Igray=hsv2rgb(I_hsv);
 figure, imshow(Igray);
 Igray=H;
 %title('R-B');

 mask = zeros(size(Igray));
 mask(25:end-25,25:end-25) = 1;
  
 %figure, imshow(mask);
 %title('Initial Contour Location');
 
 bw = activecontour(Igray,mask,100);
  
 %figure, imshow(bw);
 %title('Segmented Image');
 
 crop_mask = repmat(bw,[1,1,3]);
 I(~crop_mask) = 0;
 figure, imshow(I);
 %title('Active contour segmentation result');
 
 