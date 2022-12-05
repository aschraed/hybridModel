%% Step 1
img = imread('./Grains/pinwheel.tif'); % Reads image and saves as variable
imshow(img);
%% Step 2
figure(1) % Opens figure
hold on
axis on % Shows axes
hold off
%% Step 3
bwimg = binary(img,0); % Converts image from grayscale to binary
outline = plotBoundary(bwimg); % Plots the initial outline
img = bwimg*255; % Converts image back to grayscale
%% Step 4
h = fspecial("disk",60); % Creates disk filter with radius
for i = 1:100 % Iterates 100 times
%% Step 5
imgBlur = imfilter(img,h); % Blurs image using disk filter
%% Step 6
bwimg = binary(imgBlur,.15); % Changes gray pixels to white pixels, with certain % thresholding
%% Step 7
outline = plotBoundary(bwimg); % Plots outline of new image
img = bwimg*255; % Converts back to grayscale
end

function outline = plotBoundary(bwImg)
outline = bwboundaries(bwImg);
figure(1)
hold on
x = outline{1}(:, 2);
y = outline{1}(:, 1);
outline = plot(x, y, 'r-', 'LineWidth', 1,'Color','y');
hold off;
end

function b = binary(img,t) % input: image and threshold value
imgG = mat2gray(img); % Changes image to grayscale from 0 (black) to 1 (white)
b = imgG>t; % Changes any pixels greater than our threshold value to 1 (white), and the rest to 0 (black)
end
