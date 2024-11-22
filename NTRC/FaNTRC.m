function [X] = FaNTRC(X, omega, opts)

dim=size(X);
N=length(dim);
Rk=zeros(1,N);
% parameter setting
defopts=struct('R0', [],'lambda', 1,'maxit', 300,'tol',1e-6, ...
    'd',floor(N/2),'alpha',1/N*ones(1,N),'mu',1e-3, ...
    'rho',1.05,'max_mu',1e10,'DEBUG', true);
if ~exist('opts','var')
    opts=struct();
end
[R0, lambda, maxit, tol, d, alpha, mu, rho,max_mu, DEBUG]=scanparam(defopts,opts);

% initialize tensors
T = X;
To = zeros(size(T));
To(omega) = 1;
Tov = ~To;

% initializing the smaller size of tnesor and factor matrices.
Ttemp = tucker_als(tensor(T), R0, 'printitn', 10);
U = Ttemp.U;
Xhat = Ttemp.core;
dimHat = size(Xhat);

% equal constraint
Mmat = double(Xhat);

M = cell(N,1);
R = M;

for k=1:N
    M{k} = Mmat;
    R{k} = zeros(dimHat);
end


% initial core tensor P
P = zeros(size(X));

activeMode=1:N;
errorList = zeros(maxit, 1);


for iter = 1: maxit
    
    % updating Uk    
    Ut=U;
    for k = 1:N
        % computing Bk
        nindices = activeMode(activeMode~=k);
        Bk = ttm(tensor(Xhat), Ut(nindices), nindices);
        BkD = double(tenmat(1/mu*P+X,k))*double(tenmat(Bk,k))';
        % some thing wrong here!
        [Uk,~,Vk] = svd(BkD, 'econ');
        U{k}=Uk*Vk';
    end
    
    % updating Xhat
    D = zeros(size(Xhat));
    for k=1:N
        D = D+1/mu*R{k}+M{k};
    end
    Xhat = 1/(N+1)*double(ttm(tensor(1/mu*P+X),U,'t'))+1/(N+1)*D;
    
    % update Mk. In our paper, this is Lk.
    for k = 1:N
        XPk = trunfold(Xhat-R{k}/mu,dimHat,k,d);
        [Mk,rk] = Pro2TraceNorm(XPk, lambda*alpha(k)/mu); 
        M{k} = trfold(Mk,dimHat,k,d);
        Rk(k)=rk;
    end
    Xk=X;
    % update X. In our paper, this is T.
    XhatU=double(ttm(tensor(Xhat),U));
    Xtemp = To.*T-P+mu*XhatU;
    X = (1/(1+mu)*To+1/(mu)*Tov).*Xtemp;

    X(X>=255)=255;
    X(X<=-255)=-255;
    
    % print the result
    errorList(iter) = norm(X(:)-Xk(:))/norm(Xk(:));
    if DEBUG
        if iter == 1 || mod(iter, 10) == 0
            disp(['iter ' num2str(iter) ', mu=' num2str(mu) ',rse=' num2str(errorList(iter))]); 
        end
    end
    
    % stop criterion
    if iter>20 && errorList(iter) < tol
        break;
    end 
    
%     e_psnr0 = PSNR_RGB(X, Xtrue);
%     e_rmse0 = perfscore(X, Xtrue);
%     fprintf('iter=%d,psnr=%.4f,re=%.4f\n',iter,e_psnr0, e_rmse0);
    
%     e_psnr0Array(iter)=e_psnr0;
%     e_rmse0Array(iter)=e_rmse0;
    
    
    % update dual variables P and Rk
    P=P+mu*(X-XhatU);
    for k = 1:N
        R{k} = R{k} + mu*(M{k}-Xhat);
    end
    
    if mu< max_mu
        mu = rho*mu;
    else
        mu =max_mu;
    end
    
end
fprintf('\n');

end


    