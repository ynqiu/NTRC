% Color Image Completion with NTRC Methods (NTRC and FANTRC)
clear;

% Add necessary paths
addpath('eval/');
addpath('libs/');
addpath('NTRC/');
addpath(genpath('../tensor_toolbox3.6'));

%% Parameter Settings
imArray = {'house'}; % Test image
sr = 0.3;           % Sampling rate
c = 0.1;            % Noise level
lambda = 10;        % Regularization parameter
imNo = 1;
R0 = [10,10,18,18,3]; % Adjust ranks according to dimensions

% Choose dimension: 1=3D, 2=5D, 3=9D
dimension = 2;
optsOrder = orderFun512(dimension);

%% Main Loop
rng(2020, 'twister');

% Load image
folderDir = './data/Images512/';
imDir = [folderDir, 'airplane512.png'];
Xim = imread(imDir);
X = double(Xim);

% Generate random missing entries and noisy data
xSize = size(X);
Omega = zeros(xSize);
omegaIndex = randperm(prod(xSize), round(sr*prod(xSize)));
Omega(omegaIndex) = 1;
Xo = Omega .* X;

% Convert to higher-order tensor
Xoh = third2high(Xo, optsOrder);
Omegah = third2high(Omega, optsOrder);

% Add noise
Ndim = size(Xo);
Ndimh = size(Xoh);
Nh = length(Ndimh);
omegaIndexh = find(Omegah==1);

nObv = length(omegaIndex);
variance = c*norm(X(:),'fro')/sqrt(prod(Ndim));
noiseVec = (variance).*randn(nObv,1);
noiseTenh = zeros(Ndimh);
noiseTenh(omegaIndexh) = noiseVec;
XoNoiseh = Xoh + noiseTenh;

%% Run Both Methods

% 1. NTRC
fprintf('Running NTRC...\n');
optsNoisyTR = struct('lambda', lambda, 'maxit', 500, 'tol', 1e-8, 'd', floor(Nh/2),...
    'alpha', 1/Nh*ones(1,Nh), 'mu', 1e-3, 'rho', 1.1, 'max_mu', 1e10, 'DEBUG', true);

tic;
Xhat1 = NTRC(XoNoiseh, omegaIndexh, optsNoisyTR);
costTime1 = toc;

% 2. Faster NTRC
fprintf('Running Faster NTRC...\n');

faOptsNoisyTR = struct('R0', R0, 'lambda', lambda, 'maxit', 500, 'tol', 1e-8, 'd', floor(Nh/2),...
    'alpha', 1/Nh*ones(1,Nh), 'mu', 1e-3, 'rho', 1.18, 'max_mu', 1e10, 'DEBUG', true);

tic;
Xhat2 = FaNTRC(XoNoiseh, omegaIndexh, faOptsNoisyTR);
costTime2 = toc;

%% Evaluate Results
% NTRC Results
Xhat1 = high2third(Xhat1, xSize, optsOrder);
psnr1 = PSNR_RGB(Xhat1, X);
rmse1 = perfscore(Xhat1, X);
ssim1 = ssim_index(rgb2gray(uint8(Xhat1)), rgb2gray(uint8(X)));

% Faster NTRC Results
Xhat2 = high2third(Xhat2, xSize, optsOrder);
psnr2 = PSNR_RGB(Xhat2, X);
rmse2 = perfscore(Xhat2, X);
ssim2 = ssim_index(rgb2gray(uint8(Xhat2)), rgb2gray(uint8(X)));

% Print Results
fprintf('\nResults Comparison:\n');
fprintf('NTRC: PSNR=%.2f, RMSE=%.4f, SSIM=%.4f, Time=%.2fs\n', ...
    psnr1, rmse1, ssim1, costTime1);
fprintf('Faster NTRC: PSNR=%.2f, RMSE=%.4f, SSIM=%.4f, Time=%.2fs\n', ...
    psnr2, rmse2, ssim2, costTime2);

