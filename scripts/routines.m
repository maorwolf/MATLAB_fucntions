%% Program FixationCross.m 
[x, y] = meshgrid(-128:127, 128:-1:-127); 
M = 127 * (1- ((y == 0 & x > -8 & x < 8) | (x == 0 & y > -8 & y < 8)) ) + 1; 
showImage(M, 'grayscale');

%% Program SinewaveGratingGabor.m 
c = 0.25; % contrast of the Gabor 
f = 1/32; % spatial frequency in 1/pixels 
t = 35*pi/180; % tilt of 35 degrees into radians 
s = 24; % standard deviation of the spatial window of the Gabor 
[x, y] = meshgrid(-128:127, 128:-1:-127); 
M1 = uint8(127*(1 + c*sin(2.0*pi*f*(y*sin(t) + x*cos(t))))); 
showImage(M1, 'grayscale'); 
M2 = uint8 (127* (1 + c*sin (2.0*pi*f* (y*sin (t) + x*cos (t)) ) .*exp(-(x.^2 + y.^2)/2/s^2))); 
showImage(M2, 'grayscale');

%% Program WhiteNoiselmage.m 
M = 127 + 42*randn(10000);
M = uint8 (M) + 1; 
showImage(M, 'grayscale');


%% Program ContrastModulatedGrating.m 
c = 0.50; 
f = 1/32; 
[x, y] = meshgrid(-64:63, 64:-1:-63); 
N = 2*(rand(128,128) > 0.5) - 1; 
M = uint8(127*(1 + N.*(0.5 + c*sin(2.0*pi*f*x)))); 
showImage(M, 'grayscale');

%% Program TrueColorlmage.m 
[x, y] = meshgrid(-128:127, 128:-1:-127); 
r = sqrt(x.^2 + y.^2); 
RI = 128 + (r <32 ) *127 + (r >= 128) *127;
GI = 128 + (r >= 28 & r < 80) *127 + (r >= 128) *127; 
BI = 128 + (r >= 72)*127; M = cat(3, RI, GI, BI)/255; % cat takes 3 2-dimensional RGB matrices to create an image with 3 color planes 
showImage(M, '');


%% Program WedgeRing.m 
[x, y] = meshgrid(-1024:1023, 1024:-1:-1023); 
theta = atan2(y, x); % translates x, y to polar angle 
r = sqrt (x.^2 + y.^2) ; % and radius 
sWidth = pi/8; % width of each wedge in polar angle 
mask1 = 2 *round( (sin (theta*2* (2 *pi/sWidth) ) + 1)/2) - 1; %make wedge pattern 
r0=[ 64 96 144 208 288 400 528 672 832 1024]; % radii of different rings 
mask2 = (r < r0(1)) ; 
for i = 2:10
 mask2 = mask2 + (2*mod(i,2) - 1)*(r >= r0(i-1) & r < r0(i)); 
end
mask3 = mask1.*mask2; 
Wmask = (theta > -pi/6 & theta < pi/6) ; 
Rmask = (r > 64 & r <= 144) + (r > 672 & r < 1024); 
Wedge = Wmask.*mask3*127 + 128; 
Ring = Rmask.*mask3*127 + 128; 
showImage(Wedge, 'grayscale'); 
showImage(Ring, 'grayscale');

%% Program TexturePattern.m 
c = 0.50; % contrast of Gabor 
f = 1/8; % spatial frequency of Gabor in 1/pixels 
t = [22.5 67.5 112.5 157.5]*pi/180; % 4 different Gabor tilts in polar angles 
s = 4; % standard deviation of Gabor window 
[x, y] = meshgrid(-16:15, 16:-1:-15); 
for i = 1:4 
    M(:, :, i) = 127*(1 + c*sin(2.0*pi*f*(y*sin(t(i)) + x*cos(t(i)))).*exp(-(x.^2 + y.^2)/2/s^2)); 
end

[Tx, Ty] = meshgrid(1:40:320, 1:40:320); 
T = 127*ones(320, 320); 
for i = 1:8 
    for j = 1:8 
        M_index = round(3*rand(1)) + 1; 
        Tx(i,j) = Tx(i,j) + round(rand(1)*6); 
        Ty(i,j) = Ty(i,j) + round(rand(1)*6); 
        T(Ty(i,j):(Ty(i,j)+31), Tx(i,j):(Tx(i,j) + 31)); 
        M(:, :, M_index); 
    end
end
showlmage(T, 'grayscale');

%% Program Readlnlmage.m 
[M, map] = imread('name.jpg', 'jpeg' ); %M is a true color image in a 1944x2896x3 matrix 
showImage(M, '');

%% Program Color2Grayscale.m 
[M, map] = imread('name.jpg', 'jpeg'); 
M2 = rgb2gray(M); 
showImage(M2, 'grayscale');

%% Program Color2BW.m 
[M, map] = imread('name.jpg', 'jpeg'); 
M3 = im2bw(M) *255 + 1; % The output of im2bw consists of 0's and 1's. The values are converted into 1 and 256 for display. 
showImage(M3, 'grayscale');

%% Program IndexGrayscale.m 
[M, map] = imread('name.jpg', 'jpeg'); 
M1 = rgb2gray(M); 
clut1 = [(255:-1:0)' (255:-1:0)' (255:-1:0)']/255; 
M2 = ind2gray(M1, clut1); 
showImage(M2, 'grayscale'); 
[M3, clut2] = gray2ind(M2, 256); %gray2ind returns a grayscale image M3 with a color lookup table clut2


%% Program GeometricTransformations.m 
[M, map] = imread('name.jpg', 'jpeg');  
M2 = imresize(M, 1.75, 'bicubic'); %scale the image by 0.25 using cubic interpolation. 
showImage(M2, 'grayscale');
M3 = imrotate(M2, 45, 'bicubic'); %rotate M2 counter-clock wise by 45 degrees. 
showImage(M3, 'grayscale'); 
M4 = imcrop (M, [100 150 100 110]) ; 
showImage(M4, 'grayscale');


%% IntensityTransformation.m 
[M, map] = imread('name.jpg', 'jpg'); 
M1 = rgb2gray(M); 
bkgrd = mean2(M1); % mean computes the matrix mean. 
M2 = uint8 (0.50* (M1 - bkgrd) + bkgrd) ; %Reduce image contrast by 50 
showImage(M2, 'grayscale');

%% Program EdgeExtraction.m 
[M, map] = imread('name.jpg', 'jpeg'); 
Ml = rgb2gray (M) ; 
M3 = 255*edge(Ml, 'log', 0.005)+1; %compute edges of Ml using Laplacian of Gaussian method s
showImage(M3, 'grayscale');



%% Program RegionOflnterest.m 
[M, map] = imread('name.jpg', 'jpeg'); 
Ml = rgb2gray(M); 
mI = mean2 (M1) ; 
Sz = size (M) ; 
[x, y] = meshgrid(-Sz(2)/2:(Sz(2)/2-1), Sz(1)/2:-1:-(Sz(1)/2-1)); %A circular window mask with radius s 
s = 400; Gmaskl = ((x + 600).^2 + (y - 100).^2 < s^2); % center mask at (-600,+100) 
M2 = uint8 ( (double (Ml) - mI) .*Gmaskl + mI) ; 
showImage(M2, 'grayscale');
%A Gaussian mask with standard deviation s 
Gmaskl = exp(-((x + 600).^2 + (y - 100).^2)/2/s^2); 
M3 = uint8((double (M1) - mI).*Gmaskl + mI); 
showImage(M3, 'grayscale'); 
%AMD (age related macular degeneration example) 
Gmaskl = 1 - exp(-( (x + 600).^2 + (y - 100).^2)/2/s^2); 
M4 = uint8 ( (double (Ml) - mI).*Gmaskl + mI); 
showImage(M4, 'grayscale');

%% Program NoiseMasking.m 
[M, map] = imread('name.jpg', 'jpeg' ); 
M1 = rgb2gray(M); 
Mn = mean2(Ml); 
Sz = size (M) ; %Generating a Gaussian white noise image with standard deviation s 
s = 30; 
noisel = s*randn(Sz(1), Sz(2)); 
M2 = uint8(double(Ml) + noisel); % noise is double, so make Ml double, too 
showImage(M2, 'grayscale');

%% FourierFiltering.m 
[M, map] = imread('name.jpg', 'jpeg'); 
M1 = rgb2gray(M); 
fM = fftshift(fft2(M1 - mean2(Ml))); %Fourier transformation 
maxfM = max (max (log (abs (fM)))) ; 
showImage(uint8(256*log(abs(fM))/maxfM), 'grayscale'); 
Sz = size(Ml); 
[x, y] = meshgrid(-Sz(2)/2:(Sz(2)/2-1), Sz(1)/2:-1:-(Sz(1)/2-1)); 
r = sqrt(x.^2 + y.^2); 
r0 = 64; 
sl = 10; 
% Lowpass filtering 
lowpass = (r <= r0) + (r > r0) .*exp ((r - r0) .^2/2/sl^2) ; %Construct a lowpass filter 
showImage(uint8(256*lowpass), 'grayscale'); 
fMl = fM.*lowpass; % Apply the lowpass filter to the Fourier spectrum
showImage(uint8(256*log(abs(fMl) + 1)/maxfM), 'grayscale'); 
M2 = uint8 (ifft2 (fftshift (fMl)) + mean2(Ml) ) ; %Inverse Fourier transformation 
showImage(M2, 'grayscale'); 
%Highpass filtering 
highpass = (r >= r0) + (r < r0).*exp(-(r - r0).^2/2/sl^2); %Construct a highpass filter 
showImage(uint8(256*highpass), 'grayscale'); 
fMh = fM.*highpass; % Apply the highpass filter to the Fourier spectrum 
showImage(uint8(256*log(abs(fMh) + 1)/maxfM), 'grayscale'); 
M3=uint8 (ifft2 (fftshift (fMh)) + mean2(Ml) ) ;% Inverse Fourier transformation

%% Program DOGConvolution.m 
[M, map] = imread('name.jpg', 'jpeg'); 
M1 = rgb2gray(M); 
Sz = size(M1); 
%Construct a DOG image 
[x, y] = meshgrid(-32:31, 32:-1:-31); 
sl = 4; % standard deviation of the Gaussian center 
s2 = 16; % standard deviation of the Gaussian surround 
DOGmask = exp ((x.^2 + y.^2) /2/sl^2) - (sl/s2)^2*exp(-(x.^2 + y.^2)/2/s2^2);
%Convolve Ml with the DOG image 
M2 = conv2(double(M1), DOGmask); 
showImage (uint8 (127 + 126*DOGmask), 'grayscale'); 
%Crop the image to eliminate edge effects 
M2 = uint8 (M2 (17: (Sz (1) + 15) , 17: (Sz (2) + 15))) ; 
showImage(M2, 'grayscale');



%%








