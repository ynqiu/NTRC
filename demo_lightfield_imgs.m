% Light Field Image Completion with NTRC Methods (NTRC and FANTRC)
clear;

% Add necessary paths
addpath('eval/');
addpath('libs/');
addpath('NTRC/');
addpath(genpath('../tensor_toolbox3.6'));


%% Parameter Settings
imArray = {'Buddha','Buddha2','Mona','Papillon'};
sr = 0.3;     % Sampling rate
c = 0.1;      % Noise level (default=10)
lambda = 10;  % Regularization parameter (default=1)
R0 = [110,110,3,3]; % rank for FaNTRC

%% Load Data
imNo = 1;

% Load light field image
foldDir = 'data/LightField/';
imDir = dir([foldDir, imArray{imNo}, '_*192_Gray.mat']);
load([imDir.folder,'/',imDir.name]);

% Prepare data
X = T; % T is the original loaded data
xSize = size(X);
N = ndims(X);

%% Generate Observed Data
% Generate random observation positions
omegaIndex = randperm(prod(xSize), round(sr*prod(xSize)));
Omega = zeros(xSize);
Omega(omegaIndex) = 1;
Xo = Omega.*X;

% Add noise
nObv = length(omegaIndex);
variance = c*norm(X(:),'fro')/sqrt(prod(xSize));
noiseVec = (variance).*randn(nObv,1);
noiseTen = zeros(xSize);
noiseTen(omegaIndex) = noiseVec;
XoNoise = Xo + noiseTen;

%% Run Both Methods
% 1. NTRC
fprintf('Running NTRC...\n');
optsNoisyTR = struct('lambda', lambda, 'maxit', 500, 'tol', 1e-8, 'd', floor(N/2),...
    'alpha', 1/N*ones(1,N), 'mu', 1e-3, 'rho', 1.1, 'max_mu', 1e10, 'DEBUG', true);

tic;
Xhat1 = NTRC(XoNoise, omegaIndex, optsNoisyTR);
costTime1 = toc;

% 2. Faster NTRC
fprintf('Running Faster NTRC...\n');

rIndex = round(sr*10);
 
optsFaNTRC = struct('R0', R0, 'lambda', lambda, 'maxit', 500, 'tol', 1e-8, 'd', floor(N/2),...
    'alpha', 1/N*ones(1,N), 'mu', 1e-3, 'rho', 1.18, 'max_mu', 1e10, 'DEBUG', true);

tic;
Xhat2 = FaNTRC(XoNoise, omegaIndex, optsFaNTRC);
costTime2 = toc;

%% Evaluate Results
% NTRC Results
psnr1 = PSNR_RGB(Xhat1, X);
rmse1 = perfscore(Xhat1, X);

% Calculate SSIM for each view and take average
ssim1_all = zeros(9, 9);
for i = 1:9
    for j = 1:9
        view_Xhat1 = squeeze(Xhat1(:,:,i,j));
        view_X = squeeze(X(:,:,i,j));
        ssim1_all(i,j) = ssim_index(view_Xhat1, view_X);
    end
end
ssim1 = mean(ssim1_all(:));

% Faster NTRC Results
psnr2 = PSNR_RGB(Xhat2, X);
rmse2 = perfscore(Xhat2, X);

% Calculate SSIM for each view and take average
ssim2_all = zeros(9, 9);
for i = 1:9
    for j = 1:9
        view_Xhat2 = squeeze(Xhat2(:,:,i,j));
        view_X = squeeze(X(:,:,i,j));
        ssim2_all(i,j) = ssim_index(view_Xhat2, view_X);
    end
end
ssim2 = mean(ssim2_all(:));

% Print Results
fprintf('\nResults Comparison:\n');
fprintf('NTRC: PSNR=%.2f, RMSE=%.4f, SSIM=%.4f, Time=%.2fs\n', ...
    psnr1, rmse1, ssim1, costTime1);
fprintf('FaNTRC: PSNR=%.2f, RMSE=%.4f, SSIM=%.4f, Time=%.2fs\n', ...
    psnr2, rmse2, ssim2, costTime2);
