clear all 
close all

answer = questdlg("Do you have a screenshot or a black and white image?",'Selection','SS','BW','SS');
file = imgetfile;
[~,fileName,fileExt] = fileparts(file);
gifName = sprintf('%s_%s.gif',fileName,datestr(now,'mm-dd-yyyy_HH-MM-SS'));
fullFileName = fullfile(pwd,'gifs',gifName);
img = imread(file); % Reads image and saves as variable
sz = size(img);
sz = size(sz);
if sz(2) > 2
    img = imbinarize(imadjust(rgb2gray(img)));
end

if answer == "SS"
    img = imbinarize(imadjust(rgb2gray(img)));
    img = imfill(img);  
end
img = img.*1;
%% Step 1

prompt = {'Height and Width (mm): ','Regression Rate (mm/s):','Step Size (s):','Burn Time (s)'};
dlgtitle = 'Inputs';
dims = [1 20];
definp = {'50', '2', '1', '20'};
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
reg = rDotPix/stepSize; 

maskMatrix = masking(img,nPixX,nPixY);
% imshow(img);
steps = burnTime*stepSize;
xPlot = linspace(1,burnTime,steps);
P = zeros(1,steps);
A = zeros(1,steps);
img = double(img).*maskMatrix;

%maxArea for masking 
maxArea = (pi*inputs(1).^2)/4;
%% Step 2
fig = figure(1); % Opens figure

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

%%step 7.1 
%check to see if you have met/exceeded the max area (size of CC).

% step7.2, continue with funciton 
[X,Y] = plotBoundary(bwimg); % Plots outline of new image
P(i) = sum( sqrt((diff(X)*dx).^2 + (diff(Y)*dy).^2));
A(i) = sum(bwimg,"all")*dx*dy;
img = double(bwimg).*maskMatrix;
img = img*255; % Converts back to grayscale

exportgraphics(fig,fullFileName,"Append",true);
end

%% step 8 jank af system to find when to stop it 
for i = 1:length(A)-1
    if A(i) == A(i+1)
        index = i;
        cant = "mega";
        break
    end 
    index = i;
end 

diffA = diff(A);
dA = diff(A)./diff(xPlot);

A = A(1:index);
P = P(1:index);
xPlot = xPlot(1:index);
dA = dA(1:index);

%fixing Andres' jank af units
dA = dA.*1e-6;
lengthCC = 0.3; %chamber length 300 mm, 12";
dV = lengthCC.*dA;

rhoHTPB = 0.902*1000; %g/cm^3 == ml
%1 g/cm^3 = 1e-6 kg/mm^3

mdot_f = dV*rhoHTPB;

%% 
figure('Name','Output Data','NumberTitle','off');
subplot(2,2,1)
plot(xPlot,P);
xlim([0 index]);
grid on
title("Perimeter vs Time",'fontname','Times New Roman');
xlabel("Time (s)",'fontname','Times New Roman');
ylabel("Perimeter (mm)",'fontname','Times New Roman');
Pavg = mean(P);
yline(Pavg,'--');
gravstr = sprintf('P_{avg} = %.1f',Pavg);
legend('P',gravstr);

subplot(2,2,2)
plot(xPlot,A);
xlim([0 index]);
grid on
title("Area vs Time",'fontname','Times New Roman');
xlabel("Time (s)");
ylabel("Area (mm^2)",'fontname','Times New Roman');
Aavg = mean(A);
yline(Aavg,'--');
set(gca,'fontname','Times New Roman');
gravstr = sprintf('A_{avg} = %.1f',Aavg);
legend('A',gravstr,'fontname','Times New Roman');

subplot(2,2,3);
plot(xPlot,mdot_f);
xlim([0 index]);
grid on
%title('mdot_{f} v. time');
title('$\dot{m_f}$ vs. Time','Interpreter','latex','FontWeight','bold');

title('\boldmath{$\dot{m}_f$}\textbf{ vs Time}', 'Interpreter','latex');
ylabel('$\dot{m}_f$ (kg/s)', 'Interpreter','latex'); %sup losers
xlabel('Time (s)','fontname','Times New Roman');
mdot_f_avg = mean(mdot_f);
yline(mdot_f_avg,'--');
set(gca,'fontname','Times New Roman');
gravstr = sprintf('${m_{f,avg}}$ = %.4f',mdot_f_avg);
legend('$\dot{m}_{f,avg}$  (kg/s)',gravstr,'Interpreter','latex');
%need to add an average m_dot average.
% [t,s] = title('mDot Line','Slope = 1, y-Intercept = 0',...
%     'Color','blue');

%% Step 8 Apporoximating mdot_o 
%designing to be around a constant oxidizer flux. 
OF = 6.5;
%min case (initial combustion)
mdot_f_min = mdot_f(1);
mdot_o_min = OF*mdot_f_min;

%max case (final)
mdot_f_max = mdot_f(end);
mdot_o_max = OF*mdot_f_max;

%using mdotf average; 
%average 
%OF 
mdot_f_average = mean(mdot_f);
for i = 1:length(mdot_f)
    mdot_o_average(i) = OF*mdot_f_average;
end 
mdot_total = mdot_f+mdot_o_average;

%shifting OF
OFshifting = mdot_o_average./mdot_f;
OFshifting_trimmmed = OFshifting(1:end-1);
for i = 1:length(mdot_f)
    OFshifting_average(i) = mean(OFshifting_trimmmed);
end 

%
subplot(2,2,4)

yyaxis left
plot(xPlot,mdot_total,'-m',xPlot,mdot_f,'-c',xPlot,mdot_o_average,'-b');
ylabel('$\dot{m}$ (kg/s)', 'Interpreter','latex');
yyaxis right
plot(xPlot,OFshifting,"Color","#D95319");
ylabel('O/F','fontname','Times New Roman');
yline(OFshifting_average,'--');
xlim([0 index]);
grid on
title('{\boldmath$\dot{m}_{tot}$}\textbf{, }\boldmath{$\dot{m}_f$}\textbf{, }\boldmath{$\dot{m}_o$}\textbf{, OF vs Time}','Interpreter','latex');

xlabel('Time (s)','fontname','Times New Roman')
OFshifting_average_legend = mean(OFshifting_average); %this feature sucks and idk what to do about it. 
set(gca,'fontname','Times New Roman');
gravstr = sprintf('${OF_{avg}}$ = %.3f ',OFshifting_average_legend);
m_dot_o_average_legend = mean(mdot_o_average);
mdot_o_number = sprintf('$m_{o}$ = %.3f ',m_dot_o_average_legend);
legend('$\dot{m_{tot}}$','$\dot{m_f}$',mdot_o_number,'Shifting OF',gravstr, 'Interpreter','latex');

function [X,Y] = plotBoundary(bwImg)
outline = bwboundaries(bwImg);
figure(1)
hold on
if size(outline,1)>1
    for n = 1:size(outline,1)
        X = outline{n}(:, 2);
        Y = outline{n}(:, 1);
        plot(X, Y, 'r-', 'LineWidth', 1,'Color','w');
    end
else
    X = outline{1}(:, 2);
    Y = outline{1}(:, 1);
    plot(X, Y, 'r-', 'LineWidth', 1,'Color','w');
end
hold off
end

function b = binary(img,t) % input: image and threshold value
imgG = mat2gray(img); % Changes image to grayscale from 0 (black) to 1 (white)
b = imgG>t; % Changes any pixels greater than our threshold value to 1 (white), and the rest to 0 (black)
end
%maybe an issue with radius? maybe number of pixels.
function mask = masking(image,numberOfXPixels,numberOfYPixels)
image = imbinarize(image);%changes input image to BW 
[circlex,circley] = circle(numberOfXPixels/2,numberOfYPixels/2,numberOfYPixels/2);%uses circle function to get x & y values of FG
[colGrid,rowGrid] = meshgrid(1:size(image,2),1:size(image,1));
mask = inpolygon(colGrid,rowGrid,circlex,circley);
mask = reshape(mask,size(image));
mask = double(mask);

    function [xunit,yunit] = circle(x,y,r)
    % figure(1)
    hold on
    th = 0:pi/100:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    end
end
