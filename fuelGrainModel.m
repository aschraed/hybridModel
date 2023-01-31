clear all 
close all

answer = questdlg("Do you have a screenshot or a black and white image?",'Selection','SS','BW','SS');
file = imgetfile;
[~,fileName,fileExt] = fileparts(file);
gifName = sprintf('%s_%s.gif',fileName,datestr(now,'mm-dd-yyyy_HH-MM-SS'));
fullFileName = fullfile(pwd,'gifs',gifName);
img = imread(file); % Reads image and saves as variable
if answer == "SS"
img = imbinarize(imadjust(rgb2gray(img)));
img = imfill(img);  
end
%% Step 1

prompt = {'Heigth and Width (mm): ','Regression Rate (mm/s):','Step Size (s):','Burn Time (s)'};
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
reg = rDotPix*stepSize; 

maskMatrix = masking(img,nPixY,nPixX);
% imshow(img);
steps = burnTime/stepSize;
xPlot = linspace(1,burnTime,steps);
P = zeros(1,steps);
A = zeros(1,steps);
img = double(img).*maskMatrix;

%maxArea for masking 
maxArea = (pi*inputs(1).^2)/4;
%% Step 2
fig = figure(1); % Opens figure
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
title('Perimeter vs Time','Interpreter','latex','FontWeight','bold');
xlabel("Time (s)");
ylabel("Perimeter (mm)");
Pavg = mean(P);
yline(Pavg,'--');
gravstr = sprintf('P_{avg} = %.1f',Pavg);
legend('P',gravstr);

subplot(2,2,2)
plot(xPlot,A);
xlim([0 index]);
grid on
title('Area vs Time','Interpreter','latex','FontWeight','bold');
xlabel("Time (s)");
ylabel("Area (mm^2)");
Aavg = mean(A);
yline(Aavg,'--');
gravstr = sprintf('A_{avg} = %.1f',Aavg);
legend('A',gravstr);

subplot(2,2,3);
plot(xPlot,mdot_f);
xlim([0 index]);
grid on
%title('mdot_{f} v. time');
title('$\dot{m_f}$ vs. Time','Interpreter','latex','FontWeight','bold');

title('$\dot{m_f}$ vs. Time','Interpreter','latex','FontWeight','bold');
ylabel('$\dot{m_f}$ (kg/s)', 'Interpreter','latex'); %sup losers
xlabel('Time (s)');
mdot_f_avg = mean(mdot_f);
yline(mdot_f_avg,'--');
%legend('$\dot{m_f,avg}$ (kg/s)','mdot_avg', 'Interpreter','latex');
gravstr = sprintf('${m_{f,avg}}$ = %.4f',mdot_f_avg);
legend('$\dot{m_{f,avg}}$  (kg/s)',gravstr,'Interpreter','latex');
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
ylabel('O/F');
yline(OFshifting_average,'--');
xlim([0 index]);
grid on
title('$\dot{m_{tot}}$ vs. OF vs. $\dot{m_{o}}$ vs. $\dot{m_{f}}$ vs. Time','Interpreter','latex','FontWeight','bold');

xlabel('Time (s)')
OFshifting_average_legend = mean(OFshifting_average); %this feature sucks and idk what to do about it. 
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

function mask = masking(image,numberOfYPixels,numberOfXPixels)
image = imbinarize(image);
[circlex,circley] = circle(numberOfXPixels/2,numberOfYPixels/2,numberOfYPixels/2);
maskCircle = fill(circlex,circley,'k');
[colGrid,rowGrid] = meshgrid(1:size(image,2),1:size(image,1));
XV = maskCircle.XData';
YV = maskCircle.YData';
mask = inpolygon(colGrid,rowGrid,XV,YV);
mask = reshape(mask,size(image));
mask = double(mask);

    function [xunit,yunit] = circle(x,y,r)
    % figure(1)
    hold on
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    end
end
