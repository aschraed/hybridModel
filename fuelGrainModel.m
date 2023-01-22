answer = questdlg("Do you have a screenshot or a black and white image?",'Selection','SS','BW','SS');
file = imgetfile;
img = imread(file); % Reads image and saves as variable
if answer == "SS"
img = imbinarize(imadjust(rgb2gray(img)));
img = imfill(img);
end
%% Step 1

prompt = {'Heigth and Width (mm): ','Regression Rate (mm/s):','Step Size (s):','Burn Time (s)'};
dlgtitle = 'Inputs';
dims = [1 20];
definp = {'50', '3', '.5', '10'};
inputs = inputdlg(prompt,dlgtitle,dims,definp);
inputs = str2double(inputs);

img = imclearborder(img);
imshow(img);
nPixX = size(img,1);
nPixY = size(img,2);
W = inputs(1); % mm
H = inputs(1); % mm
dx = W/nPixX; % mm of the width of each pixel
dy = H/nPixY; % mm of the height of each pixel
rDot = inputs(2); % Burn Regression
rDotPix = rDot/dx; % Regression in pixels
stepSize = inputs(3); % How many seconds per step
burnTime = inputs(4); % sec
reg = rDotPix*stepSize; 
steps = burnTime/stepSize;
xPlot = 1:1:steps;
P = zeros(1,steps);
A = zeros(1,steps);
%% Step 2
figure(1) % Opens figure
hold on
axis on % Shows axes
hold off
%% Step 3
bwimg = binary(img,0); % Converts image from grayscale to binary
[X,Y] = plotBoundary(bwimg); % Plots the initial outline
P(1) = sum( sqrt((diff(X)*dx).^2 + (diff(Y)*dy).^2));
A(1) = sum(bwimg,"all");
img = bwimg*255; % Converts image back to grayscale
%% Step 4
h = fspecial("disk",reg); % Creates disk filter with radius
for i = 1:steps % Iterates 100 times
%% Step 5
imgBlur = imfilter(img,h); % Blurs image using disk filter
%% Step 6
bwimg = binary(imgBlur,.1); % Changes gray pixels to white pixels, with certain % thresholding
%% Step 7
[X,Y] = plotBoundary(bwimg); % Plots outline of new image
P(i) = sum( sqrt((diff(X)*dx).^2 + (diff(Y)*dy).^2));
A(i) = sum(bwimg,"all")*dx*dy;
img = bwimg*255; % Converts back to grayscale
end
dA = diff(A)./diff(xPlot);
%fixing Andres' jank af units
dA = dA*1e-6;
lengthCC = 0.3; %chamber length 300 mm, 12";
dV = lengthCC*dA;

rhoHTPB = 0.902*1000; %g/cm^3 == ml
%1 g/cm^3 = 1e-6 kg/mm^3

mdot_f = dV*rhoHTPB;

figure
subplot(2,2,1)
plot(xPlot,P);
grid on
title("Perimeter vs Time")
xlabel("Time (s)");
ylabel("Perimeter (mm)");
subplot(2,2,2)
plot(xPlot,A)
grid on
title("Area vs Time")
xlabel("Time (s)");
ylabel("Area (mm^2)");
subplot(2,2,3)
plot(xPlot(2:end),mdot_f)
grid on
title('Fuel Mass Flow Rate vs Time');
ylabel('$\dot{m_f}$ (kg/s)', 'Interpreter','latex')
xlabel('Time (s)')

function [X,Y] = plotBoundary(bwImg)
outline = bwboundaries(bwImg);
figure(1)
hold on
if size(outline,1)>1
    for n = 1:size(outline,1)
        X = outline{n}(:, 2);
        Y = outline{n}(:, 1);
        plot(X, Y, 'r-', 'LineWidth', 1,'Color','y');
    end
else
    X = outline{1}(:, 2);
    Y = outline{1}(:, 1);
    plot(X, Y, 'r-', 'LineWidth', 1,'Color','y');
end
hold off
end

function b = binary(img,t) % input: image and threshold value
imgG = mat2gray(img); % Changes image to grayscale from 0 (black) to 1 (white)
b = imgG>t; % Changes any pixels greater than our threshold value to 1 (white), and the rest to 0 (black)
end
