close all
clear 
clc


image = imread("me3.jpg");  %greenscreen image, you can change it to any images in the same folder as this script
bg1 = imread("GreatWall3.jpeg"); %background image, you can change it to any images in the same folder as this script
[imx,imy,~]=size(image);

background=imresize(bg1,[imx,imy]);
background=im2double(background);
%figure,subplot(211), imshow(image);

alpha_map=compose(image);
alphaR=alpha_map(:,:,1);
image=im2double(image);
imageR=image(:,:,1);

result= alpha_map.*image + (1-alpha_map) .* background;

imlist={image,alpha_map,background,result};
montage(imlist);


function alphaa=compose(origin_image)
    [x,y,~]=size(origin_image);
    alphaaR=ones(x,y);
    alphaaG=ones(x,y);
    alphaaB=ones(x,y);

    for i=1:x
        for j=1:y  
           if(origin_image(i,j,2)>80 && (origin_image(i,j,2)>origin_image(i,j,1)))

                alphaaR(i,j)=0;
                alphaaG(i,j)=0;
                alphaaB(i,j)=0;
                

            end
        end
    end

    alphaa=cat(3,alphaaR,alphaaG,alphaaB);
end





%%

