close all
clear 
clc


image=imread("me1.jpg"); %greenscreen image, you can change it to any images in the same folder as this script
[x,y,~]=size(image);

image2=im2double(image);
bg=imread("GreatWall1.jpeg"); %background image, you can change it to any images in the same folder as this script
background=imresize(bg,[x y]);
background=im2double(background);

threshold=input("Please choose a thresh hold between 0 and 0.5: ");




alpha1=vlahos(image,1,1,threshold);

mask=repmat(alpha1,[1,1,3]);

mask=medfilt3(mask);

overlayed = mask.* image2 + (1-mask) .* background;

imlist={image2,mask,background,overlayed};

montage(imlist);






function filtered = median(im)
    filtered = zeros(size(im),class(im));
    for m = 3 : size(im,1)-2
        for n = 3 : size(im,2)-2
            list = im(m-2:m+2,n-2:n+2);
            filtered(m,n) = median(list(:));
        end
    end



end


function alpha = vlahos(im,a1,a2,threshold)
    im=double(im)/255;
  

    %alpha = 1 - k1 * ( min(bgcolor.g, G) - k2 * (k3*B + (1-k3)*R) )
    %alpha = 0.5 - a1*(im(:,:,2) - a2*(a3*im(:,:,3)+(1-a3)*im(:,:,1)));

    [width,height,~]=size(im);

    alpha=zeros(width,height);

    for w=1:width
        for h=1:height
        if(im(w,h,2)<0.3 || (im(w,h,2)<im(w,h,1)) || im(w,h,2)<im(w,h,3))
            alpha(w,h)=1;
        else
            alpha(w,h)=threshold-a1*(im(w,h,2)-a2*im(w,h,3));
            if (alpha(w,h)<0)
                alpha(w,h)=0;
            end
            if (alpha(w,h)>1)
                alpha(w,h)=1;
            end

        end
       
        
        end
    end
    

end