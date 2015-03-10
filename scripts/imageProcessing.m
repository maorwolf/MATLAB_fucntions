clear

cd /home/meg/Data/Maor/Yuri/faces
% eli=imread('mask.JPG','jpeg');
% eli=double(eli);
% mask=eli(:,:,3);
% save mask mask
load /home/meg/Data/Maor/Yuri/faces/mask
mask = imcrop(mask,[1 147 562 561]);
% mask256=imresize(mask,0.4555);
% figure;subplot(1,2,1);imshow(mask,[]);subplot(1,2,2);imshow(mask256,[]);
% imwrite(uint8(mask),'mask1.JPG');

% set(0,'units','pixels')
% Pix_SS = get(0,'screensize');
% set(0,'units','centimeters')
% CM_SS = get(0,'screensize');
% picSizeCM = length(mask).*CM_SS(3)./Pix_SS(3);

imageSize=input('Image width (cm)? '); % 8.43
imageDistanceCM=input('Distance from screen (cm)? '); % 55
cutFreqLow=8/5; % cycles per degree, according to literature (based on Vakhrusheva et al., 2014)
cutFreqHigh=24/5; % cycles per degree, according to literature (based on Vakhrusheva et al., 2014)

% pixL=input('Pixels per degree for LSF? '); % 16
% pixH=input('Pixels per degree for HSF? '); % 6

% taking all the pictures in the folder, turnning them gray, croping them,
% masking them, filtering them, masking them again and saving them.
dir1=uigetdir('','PLEASE CHOOSE SOURCE FOLDER'); dir1=[dir1 '/'];
dir2=uigetdir('','PLEASE CHOOSE DESTINATION FOLDER'); dir2=[dir2 '/'];

source=dir(dir1);
for i=3:length(source)
    currentImage=imread([dir1 source(i).name]);
    currentImage = rgb2gray(currentImage);
    currentImage = double(currentImage);
    currentImage = imcrop(currentImage,[1 147 562 561]);
    currentImage = currentImage.*mask;
    currentImage(mask<20)=mean(mean(currentImage(mask>20)));
%     currentImage = imresize(currentImage,0.4555);
%     figure;imshow(currentImage,[]);
%     currentImageLow = filterMaor(currentImage, 1, cutFreqLow, 0.1);
%     currentImageHigh = filterMaor(currentImage, 2, 562, cutFreqHigh);
    currentImageLow=filterTry(imageSize, imageDistanceCM, currentImage, 1, cutFreqLow, cutFreqHigh);
    currentImageHigh=filterTry(imageSize, imageDistanceCM, currentImage, 2, cutFreqLow, cutFreqHigh);
    figure;subplot(1,2,1);imshow(currentImageLow,[]);subplot(1,2,2);imshow(currentImageHigh,[]);

%     currentImageLow=reshape(mfilt2(currentImage(:), 562, 562, 3.46, 'l'), [562, 562]);
%     currentImageHigh=reshape(mfilt2(currentImage(:), 562, 562, 1.16, 'h'), [562, 562]);
%    figure;subplot(1,2,1);imshow(currentImageLow,[]);subplot(1,2,2);imshow(currentImageHigh,[]);
    
    currentImageLowMin=min(min(currentImageLow));currentImageLowMax=max(max(currentImageLow));
    currentImageLow=currentImageLow-currentImageLowMin;
    currentImageLow=currentImageLow./currentImageLowMax;
    currentImageLow(mask<20)=0.5;
    
    currentImageHighMin=min(min(currentImageHigh));currentImageHighMax=max(max(currentImageHigh));
    currentImageHigh=currentImageHigh-currentImageHighMin;
    currentImageHigh=currentImageHigh./currentImageHighMax;
    currentImageHigh(mask<20)=0.5;
    
    currentImageBroad=currentImage;
    currentImageBroadMin=min(min(currentImageBroad));currentImageBroadMax=max(max(currentImageBroad));
    currentImageBroad=currentImageBroad-currentImageBroadMin;
    currentImageBroad=currentImageBroad./currentImageBroadMax;
    currentImageBroad(mask<20)=0.5;
    
%     figure;
%     subplot(1,3,1);imagesc(currentImageLow,[0 1]);colormap gray;
%     subplot(1,3,2);imagesc(currentImageHigh,[0 1]);colormap gray;
%     subplot(1,3,3);imagesc(currentImageBroad,[0 1]);colormap gray;
    
    imwrite(currentImageLow,[dir2,'low',source(i).name]);
    imwrite(currentImageHigh,[dir2,'high',source(i).name]);
    imwrite(currentImageBroad,[dir2,'broad',source(i).name]);
    close all
end


% MfilteredLowMasked = MfilteredLow.*mask;
% MfilteredHighMasked = MfilteredHigh.*mask;
% figure;subplot(1,2,1);imshow(MfilteredLowMasked, []);subplot(1,2,2);imshow(MfilteredHighMasked, []);
% 
% mean(mean(MfilteredLowMasked))
% mean(mean(MfilteredHighMasked))

%% eq_luminance
source=dir(dir2);
mask1=mask;
mask1(mask<20)=1;
mask1(mask>=20)=0;
for i=3:length(source)
    pic=double(imread([dir2, source(i).name]));
    masks(i-2).name=source(i, 1).name;
    masks(i-2).background=mask1;
    masks(i-2).means=mean(double(pic(~masks(i-2).background)));
end

means=cat(2, masks.means);
RefMean=median(means);

for i=3:length(source)
        pic=double(imread([dir2, source(i).name]));
        foreground=~masks(i-2).background;
        ForeMean=mean(pic(foreground));
        pic(foreground)=pic(foreground)*RefMean/ForeMean;
        masks(i-2).newmeans=mean(pic(foreground)); %the new mean
        pic(mask<20)=pic(1,1);
        imwrite(uint8(pic), ['.' ,  filesep, 'equalizedFaces/', source(i).name],'jpg')
end

%% moving files
cd /home/meg/Data/Maor/Yuri/faces/equalizedFaces
mkdir experimentFaces
cond1={'AF','AM'};
cond2={'AF','HA','NE'};
for k=1:length(cond1)
    if k==1
        for i=[1:3,5:9,11,13:17,19:22,24:35]
            for j=1:length(cond2)
                if i<10
                    S1 = sprintf('broad%s0%d%sS.JPG',cond1{k},i,cond2{j});
                    S2 = sprintf('low%s0%d%sS.JPG',cond1{k},i,cond2{j});
                    S3 = sprintf('high%s0%d%sS.JPG',cond1{k},i,cond2{j});
                    if exist(S1, 'file') && exist(S2, 'file') && exist(S3, 'file')
                        movefile(S1,['./experimentFaces/',S1])
                        movefile(S2,['./experimentFaces/',S2])
                        movefile(S3,['./experimentFaces/',S3])
                    else
                        disp(['no ',S1, ' file']);
                    end
                else
                    S1 = sprintf('broad%s%d%sS.JPG',cond1{k},i,cond2{j});
                    S2 = sprintf('low%s%d%sS.JPG',cond1{k},i,cond2{j});
                    S3 = sprintf('high%s%d%sS.JPG',cond1{k},i,cond2{j});
                    if exist(S1, 'file') && exist(S2, 'file') && exist(S3, 'file')
                        movefile(S1,['./experimentFaces/',S1])
                        movefile(S2,['./experimentFaces/',S2])
                        movefile(S3,['./experimentFaces/',S3])
                    else
                        disp(['no ',S1, ' file']);
                    end
                end
            end
        end
    elseif k==2
        for i=[1:11,13:15,17,18,21:23,25,27,29,31,32,34,35]
            for j=1:length(cond2)
                if i<10
                    S1 = sprintf('broad%s0%d%sS.JPG',cond1{k},i,cond2{j});
                    S2 = sprintf('low%s0%d%sS.JPG',cond1{k},i,cond2{j});
                    S3 = sprintf('high%s0%d%sS.JPG',cond1{k},i,cond2{j});
                    if exist(S1, 'file') && exist(S2, 'file') && exist(S3, 'file')
                        movefile(S1,['./experimentFaces/',S1])
                        movefile(S2,['./experimentFaces/',S2])
                        movefile(S3,['./experimentFaces/',S3])
                    else
                        disp(['no ',S1, ' file']);
                    end
                else
                    S1 = sprintf('broad%s%d%sS.JPG',cond1{k},i,cond2{j});
                    S2 = sprintf('low%s%d%sS.JPG',cond1{k},i,cond2{j});
                    S3 = sprintf('high%s%d%sS.JPG',cond1{k},i,cond2{j});
                    if exist(S1, 'file') && exist(S2, 'file') && exist(S3, 'file')
                        movefile(S1,['./experimentFaces/',S1])
                        movefile(S2,['./experimentFaces/',S2])
                        movefile(S3,['./experimentFaces/',S3])
                    else
                        disp(['no ',S1, ' file']);
                    end
                end
            end
        end
    end
end

for i=[12,16,24,28]
    for j=1:length(cond2)
        S1 = sprintf('broadBM%d%sS.JPG',i,cond2{j});
        S2 = sprintf('lowBM%d%sS.JPG',i,cond2{j});
        S3 = sprintf('highBM%d%sS.JPG',i,cond2{j});
        if exist(S1, 'file') && exist(S2, 'file') && exist(S3, 'file')
            movefile(S1,['./experimentFaces/',S1])
            movefile(S2,['./experimentFaces/',S2])
            movefile(S3,['./experimentFaces/',S3])
        else
            disp(['no ',S1, ' file']);
        end
    end
end

mkdir tirgulFaces
expres={'AFS','HAS','NES'};
freq={'broad','low','high'};
for i=1:3
    for j=1:3
        S1 = sprintf('%sAM30%s.JPG',freq{j},expres{i});
        S2 = sprintf('%sBM30%s.JPG',freq{j},expres{i});
        S3 = sprintf('%sAF23%s.JPG',freq{j},expres{i});
        S4 = sprintf('%sAF12%s.JPG',freq{j},expres{i});
        movefile(S1,['./tirgulFaces/',S1])
        movefile(S2,['./tirgulFaces/',S2])
        movefile(S3,['./tirgulFaces/',S3])
        movefile(S4,['./tirgulFaces/',S4])
    end
end
        
%% testing the functions
set(0,'units','pixels')
Pix_SS = get(0,'screensize');
set(0,'units','centimeters')
CM_SS = get(0,'screensize');
picSizeCM = 562.*CM_SS(3)./Pix_SS(3);

clear all
t = 0:0.001:1;
f1 = 8;
x = sin(2*pi*f1*t);
y=repmat(x,length(x),1);


f2 = 24;
x1 = sin(2*pi*f2*t);
y1=repmat(x1,length(x1),1);

z=y'+y1;

figure
subplot(1,2,1)
imagesc(y')
subplot(1,2,2)
imagesc(y1)
% subplot(1,3,3)
% imagesc(z)

    picFiltLow = filterMaor(z, 1, 8, 0.99);
    picFiltHigh = filterMaor(z, 2, 562, 24);

figure
subplot(1,2,1)
imagesc(picFiltLow)
subplot(1,2,2)
imagesc(picFiltHigh)