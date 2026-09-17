%LOADING FILE

%Load the full image
full_image = imread("film1_big.jpg");

%Crop the images 
% (first middle)
image1 = full_image(1:287, 385:765, :);
% (second middle)
image2 = full_image(291:575, 385:765, :);
% (third middle)
image3 = full_image(579:864, 385:765, :);
% (fourth middle)
image4 = full_image(868:1151, 385:765, :);
% (fifth middle)
image5 = full_image(1155:1439, 385:765, :);

%SAVE THE IMAGES
imwrite(image1, 'middleimage1.jpg');
imwrite(image2, 'middleimage2.jpg');
imwrite(image3, 'middleimage3.jpg');
imwrite(image4, 'middleimage4.jpg');
imwrite(image5, 'middleimage5.jpg');
