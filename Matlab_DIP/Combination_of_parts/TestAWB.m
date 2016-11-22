% Test AWB
clear; clc;
close all;

I = imread('Test.jpg');
J = imread('TestComparison.jpg');

% subplot(2,2,1), imshow(I);
% subplot(2,2,2), imshow(I(:,:,1));
% subplot(2,2,3), imshow(I(:,:,2));
% subplot(2,2,4), imshow(I(:,:,3));

% Calculate Illumination estimation 
p = 93:0.5:94;

for i=1:length(p)

    O = PerformAWB(I, p(i));
    
    subplot(1,3,1), imshow(I);
    subplot(1,3,2), imshow(J);
    subplot(1,3,3), imshow(O);
    
    imwrite(O, strcat('AWB_', num2str(p(i)), '.png'));
       
end




