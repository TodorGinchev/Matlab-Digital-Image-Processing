he = imread('/media/todor/User/git/bitbucket/combinened/french_fries/15283.jpg');
imshow(he), title('H&E image');
text(size(he,2),size(he,1)+15,...
     'Image courtesy of Alan Partin, Johns Hopkins University', ...
     'FontSize',7,'HorizontalAlignment','right');
 
cform = makecform('srgb2lab');
lab_he = applycform(he,cform);


ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

nColors = 3;
% repeat the clustering 3 times to avoid local minima
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
                                  

pixel_labels = reshape(cluster_idx,nrows,ncols);

figure;
imshow(pixel_labels,[]), title('image labeled by cluster index');





