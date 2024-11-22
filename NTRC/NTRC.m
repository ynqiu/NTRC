function [X] = NTRC(X, omega, opts)

dim=size(X);
N=length(dim);
Rk=zeros(1,N);
% parameter setting
defopts=struct('lambda', 1,'maxit', 300,'tol',1e-6,'d',floor(N/2), ...
    'alpha',1/N*ones(1,N),'mu',1e-3, 'rho',1.05,'max_mu',1e10,'DEBUG', true);
if ~exist('opts','var')
    opts=struct();
end
[lambda, maxit, tol, d, alpha, mu, rho,max_mu, DEBUG]=scanparam(defopts,opts);

% initialize tensors
T = X;
To = zeros(size(T));
To(omega) = 1;
Tov = ~To;

% equal constraint
Mmat = zeros(dim);
Mmat(omega) = X(omega);
M = cell(1,N);
for k=1:N
    M{k} = Mmat;
end

% initialize lagrange dual variables
Pmat = zeros(dim);
P = cell(1,N);
for k=1:N
    P{k} = Pmat;
end

errorList = zeros(maxit, 1);
% e_psnr0Array=zeros(1,maxit);
% e_rmse0Array=zeros(1,maxit);

for iter = 1: maxit
    % update Mk. In our paper, this is Zk.
    for k = 1:N
                                    % Xk = tunfold(X,k);
        XPk = trunfold(-X+P{k}/mu,dim,k,d);
        [Mk,rk] = Pro2TraceNorm(-XPk, lambda*alpha(k)/mu); 
        Mk = trfold(Mk,dim,k,d);
        M{k}=Mk;
        Rk(k)=rk;
    end
    Xk=X;
    
    Xtemp = zeros(dim);
    Msum = Xtemp;
    for k=1:N
        Xtemp = P{k} + mu*M{k} + Xtemp;
        Msum = M{k} + Msum;
    end
    Xtemp = (To.*T) + Xtemp;
    X = (1/(1+N*mu)*To+1/(N*mu)*Tov).*Xtemp;
    
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
    
    % update dual variables Pk
    for k = 1:N
        P{k} = P{k} + mu*(M{k}-X);
    end
    if mu< max_mu
        mu = rho*mu;
    else
        mu =max_mu;
    end
    
end
fprintf('\n');

end


    