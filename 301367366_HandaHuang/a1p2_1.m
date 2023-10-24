
close all
clear 
clc

apple=imread("orange.jpg"); %this is actually image2, change image2 of your choice

apple1=imresize(apple,[512 512]);

apple1=im2double(apple1);

[width,height,~]=size(apple);


%builds the laplacian pyramid for image1 
[scaled1,apple_gaus1,app_lap1,dim1]=pyramids(apple1);
[scaled2,apple_gaus2,app_lap2,dim2]=pyramids(scaled1);
[scaled3,apple_gaus3,app_lap3,dim3]=pyramids(scaled2);
[scaled4,apple_gaus4,app_lap4,dim4]=pyramids(scaled3);


recon1=reconLaplacian(scaled4,app_lap4);
recon2=reconLaplacian(recon1,app_lap3);
recon3=reconLaplacian(recon2,app_lap2);
recon4=reconLaplacian(recon3,app_lap1);


orange=imread("apple.jpg"); %this is actually image1, change your image1 here
orange1=imresize(orange,[512,512]);
orange1=im2double(orange1);


[widthO,heightO,~]=size(orange1);


[scaledO1,orange_gaus1,orange_lap1,dimO1]=pyramids(orange1);
[scaledO2,orange_gaus2,orange_lap2,dimO2]=pyramids(scaledO1);
[scaledO3,orange_gaus3,orange_lap3,dimO3]=pyramids(scaledO2);
[scaledO4,orange_gaus4,orange_lap4,dimO4]=pyramids(scaledO3);



reconO1=reconLaplacian(scaledO4,orange_lap4);
reconO2=reconLaplacian(reconO1,orange_lap3);
reconO3=reconLaplacian(reconO2,orange_lap2);
reconO4=reconLaplacian(reconO3,orange_lap1);



mask=imread("mask.jpg"); %mask here, change your mask
mask=im2double(mask);
mask1=onlyGuassian(mask);
mask2=onlyGuassian(mask1);
mask3=onlyGuassian(mask2);
mask4=onlyGuassian(mask3);


scaled4up=imresize(scaled4,2);
scaledO4up=imresize(scaledO4,2);



LC1=blend(scaled4up,scaledO4up,mask3);
LC2=blend(app_lap4,orange_lap4,mask3);
LC3=blend(app_lap3,orange_lap3,mask2);
LC4=blend(app_lap2,orange_lap2,mask1);
mask1up=imresize(mask1,2);
LC5=blend(app_lap1,orange_lap1,mask1up);


[lc1d,lc1dd,~]=size(LC1);
[lc2d,lc2dd,~]=size(LC2);


blended1=reconLC(LC1,LC2);

blend1up=imresize(blended1,2);

blended2=reconLC(blend1up,LC3);

blend2up=imresize(blended2,2);

blended3=reconLC(blend2up,LC4);

blend3up=imresize(blended3,2);

blended4=reconLC(blend3up,LC5);


lapList={app_lap1,app_lap2,app_lap3,app_lap4, scaled4up};
%montage(lapList); %unconmment this to show laplacian pyramid

LCList={LC1,LC2,LC3,LC4,LC5};
%montage(LCList); %uncomment this to show LC pyramid

result={apple1,orange1,mask,blended4};
montage(result);


function [result]=reconLC(imagef,imageLap)
    imageI=imagef;
    r_imageF=imageI(:,:,1)+imageLap(:,:,1);
    g_imageF=imageI(:,:,2)+imageLap(:,:,2);
    b_imageF=imageI(:,:,3)+imageLap(:,:,3);

    result=cat(3,r_imageF,g_imageF,b_imageF);


end


function downScaled=downSample(image)
    r_gauss_scale=image(:,:,1);
    g_gauss_scale=image(:,:,2);
    b_gauss_scale=image(:,:,3);

    r_gauss_scale(2:2:end,:)=[];
    r_gauss_scale(:,2:2:end)=[];

    g_gauss_scale(2:2:end,:)=[];
    g_gauss_scale(:,2:2:end)=[];

    b_gauss_scale(2:2:end,:)=[];
    b_gauss_scale(:,2:2:end)=[];

    downScaled=cat(3,r_gauss_scale,g_gauss_scale,b_gauss_scale);


end



function [scaled,gaussImg,lapImg,dimension]=pyramids(image)

    image_r=image(:,:,1);
    image_g=image(:,:,2);
    image_b=image(:,:,3);
   
    
    gauseKern=fspecial('gaussian',41,8);
    
    r_gauss=imfilter(image_r,gauseKern);
    g_gauss=imfilter(image_g,gauseKern);
    b_gauss=imfilter(image_b,gauseKern);
    
    gaus_combine=cat(3,r_gauss,g_gauss,b_gauss);

    scaled=downSample(gaus_combine);
    
    up=imresize(scaled,2);
    
    r_lap=image_r-up(:,:,1);
    g_lap=image_g-up(:,:,2);
    b_lap=image_b-up(:,:,3);
    
    lap=cat(3,r_lap,g_lap,b_lap);    

    gaussImg=gaus_combine;
    lapImg=lap;

    [x2,y2,~]=size(scaled);
    
    
    dimension=x2;

end


function [imageF]=reconLaplacian(imagef,imageLap)
    imageI=imresize(imagef,2);
    r_imageF=imageI(:,:,1)+imageLap(:,:,1);
    g_imageF=imageI(:,:,2)+imageLap(:,:,2);
    b_imageF=imageI(:,:,3)+imageLap(:,:,3);

    imageF=cat(3,r_imageF,g_imageF,b_imageF);


end


function [scaled_mask]=onlyGuassian(image)
    image_r=image(:,:,1);
    image_g=image(:,:,2);
    image_b=image(:,:,3);
   
    
    gauseKern=fspecial('gaussian',41,8);
    
    r_gauss=imfilter(image_r,gauseKern);
    g_gauss=imfilter(image_g,gauseKern);
    b_gauss=imfilter(image_b,gauseKern);
    
    gaus_combine=cat(3,r_gauss,g_gauss,b_gauss);
    
    
    scaled_mask=downSample(gaus_combine);

end



function blended = blend(image1,image2,mask)
  
    [widthM,heightM,~]=size(mask);
    
    r_m=mask(:,:,1);
    g_m=mask(:,:,2);
    b_m=mask(:,:,3);
    
    r_blend=zeros(widthM,heightM);
    g_blend=zeros(widthM,heightM);
    b_blend=zeros(widthM,heightM);
    
    for i=1:widthM
        for j=1:heightM
            r_blend(i,j)=r_m(i,j)*image1(i,j,1)+(1-r_m(i,j))*image2(i,j,1);
            g_blend(i,j)=g_m(i,j)*image1(i,j,2)+(1-g_m(i,j))*image2(i,j,2);
            b_blend(i,j)=b_m(i,j)*image1(i,j,3)+(1-b_m(i,j))*image2(i,j,3);
        end
    end
    
    blended=cat(3,r_blend,g_blend,b_blend);

end


    