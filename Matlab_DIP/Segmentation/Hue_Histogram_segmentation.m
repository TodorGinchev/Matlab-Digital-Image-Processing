%Read input image
I = imread('/media/todor/User/git/bitbucket/combinened/french_fries/15283.jpg');
%Resize image to match width=320pixels
I = imresize(I,320/image_size(2));
%Transform in HSV colour space
I_hsv = rgb2hsv(I);
%Get HSV channels
H=I_hsv(:,:,1);
S=I_hsv(:,:,2);
V=I_hsv(:,:,3);

plot(imhist(H));
pause();

Hlow=im2bw(H, 0.047);%10/180);
Hhigh=1-im2bw(H,0.130);%50/180);
H=Hlow+Hhigh;
I_hsv(:,:,1)=H(:,:);
I_grayscale=hsv2rgb(I_hsv);
figure, imshow(I_grayscale);

