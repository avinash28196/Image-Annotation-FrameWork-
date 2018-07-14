function [maskOut]=kGaussian_color_EM(imageFile,k)
%% this function uses EM algorithm and gaussian distribution function to do
% image segmentation on the color space
% try: 
%   img=imread('onion.png');
%   [maskOut]=kGaussian_color_EM(img,9); figure;  imshow(maskOut)
% written by Rongwen Lu on 12/11/2011; email: rongwen@uab.edu
img=double(imageFile);





[M,N,P]=size(img);
n=M*N;
imgR=img(:,:,1); 
imgG=img(:,:,2);
imgB=img(:,:,3);
[cy,cx]=ind2sub([M,N],1:n);

%normalize each vector; delete it if normalization is not needed; weights
%are also assigned here;
% imgR=mat2gray(imgR);
% imgG=mat2gray(imgG);
% imgB=mat2gray(imgB);
% cy=mat2gray(cy);
% cx=mat2gray(cx);
imgR=imgR/255;
imgG=imgG/255;
imgB=imgB/255;
cy=cy/M;
cx=cx/N;

% %% Gaussian filter
% w=fspecial('gaussian',[5,5],4);
% imgR=imfilter(imgR,w);
% imgG=imfilter(imgG,w);
% imgB=imfilter(imgB,w);

%% assign vectors into the matrix raw
raw=zeros(n,3);
raw(:,1)=imgR(:);
raw(:,2)=imgG(:);
raw(:,3)=imgB(:);

% raw=zeros(n,5);
% raw(:,1)=cy.';
% raw(:,2)=cx.';
% raw(:,3)=imgR(:);
% raw(:,4)=imgG(:);
% raw(:,5)=imgB(:);

%% get assignment matrix p, which is also memebership probability here; u
%% is vector of the estimated means of Gaussian function, v is the vector ot the estimated SD 
[p,u,v]=em(raw,k);



imgRe=zeros(n,3);
kColor=jet(k);
kColor=u(:,1:3);
imgRe=p*kColor;



maskOut=zeros(M,N,3);
for ii=1:3
    maskOut(:,:,ii)=reshape(imgRe(:,ii),[M,N]);
end

% figure; imshow((maskOut))
% title('based on k Gaussian by EM algorithm on color space')

 function [p,u,v]=em(raw,k)
 % this function uses Expectation Maximization method to estimate k
 % Gaussian distribution functions. There are 2 input arguments. Raw's size
 % is [n,dim], where n is the NO of data and dim is the dimention of data.
 % k means using k Gaussin functions to do image segmentation.The output is
 % p, which is assignment matrix.its [ii,jj]th element means the
 % probability that Xii is generated by jjth Gaussian function.






%% the input of following codes are raw,and K

%% initialize centroid matrix u; u has k raws. NO of column is the same as
%% raw
[n,dim]=size(raw);
u=raw(randi([1,n],k,1),:);
%u=[0,0;40,40;-40,-40];

%% initialize standard diviation v, v has k raws, one column.
v=zeros(k,1);
for ii=1:k
    raw_tmp=raw(ii:k:end,1);
    v(ii,:)=std(raw_tmp);
end
%v=.5*[4,4,4]';
%% initialize weight w
w=ones(k,1)/k;



%% initialize membership probability matrix (assignment matrix) p, which is p(k|x)
p=zeros(n,k);

%% do interation to get best r
u0=u*0;
v0=0*v;
w0=w*0;
energy=sum(sum((u-u0).^2))+sum(sum((v-v0).^2))+(sum((w-w0).^2));
iteration=1;
x_u=zeros(size(raw));
while energy>10^(-6)

    %% calculate membership probability, which is also assignment matrix
    for jj=1:k
        for ss=1:dim
            x_u(:,ss)=raw(:,ss)-u(jj,ss)*ones(n,1);
        end
        x_u=x_u.*x_u;
        p(:,jj)=power(sqrt(2*pi)*v(jj),-1*dim)*exp((-1/2)*sum(x_u,2)./(v(jj).^2));
        p(:,jj)=p(:,jj)*w(jj);
       
    end
    %% normalize p on the x dimention
    pSum=sum(p,2);
    for jj=1:k
        p(:,jj)=p(:,jj)./pSum;
    end
    
    %% normlaize p on the y dimention, yielding pNorm
    pSum2=sum(p,1);
    pNorm=p*0;
    for jj=1:k
        pNorm(:,jj)=p(:,jj)/pSum2(jj);
    end
    
    %% save current u, v, and w as u0, v0 and w0
    u0=u;v0=v;w0=w;
    
    %%update u
    u=(pNorm.')*raw;
    
    %% update v
    for jj=1:k
        for ss=1:dim
            x_u(:,ss)=raw(:,ss)-u(jj,ss)*ones(n,1);
        end
        x_u=x_u.*x_u;
        x_uSum=sum(x_u,2);
        v(jj)=sqrt(1/dim*(pNorm(:,jj).')*x_uSum);
    end



    %% update w
    w=(sum(p)/n).';
    
    %% update and display iteration and energy
    
    %disp(sprintf(['iteration=',num2str(iteration),'; energy=',num2str(energy,'%g')]))
    iteration=iteration+1;
    energy=sum(sum((u-u0).^2))+sum(sum((v-v0).^2))+(sum((w-w0).^2));
    
    
   
   
end







