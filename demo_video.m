% Video Completion with NTRC Methods (NTRC and FANTRC)
clear;

% Add necessary paths
addpath('eval/');
addpath('NTRC/');
addpath('libs/');
addpath(genpath('../tensor_toolbox3.6'));

%% Parameter Settings
sr = 0.4;       % Sampling rate
d4 = 50;        % Number of video frames
c = 0.1;        % Noise level
lambda = 100;   % Regularization parameter
R0 = [40,40,3,20]; % Adjust according to video dimensions

load('data/YUV/akiyoRGB.mat')

%% Main loop
rng(2020, 'twister');

X = T(:,:,:,1:d4);
optsOrder = size(X);
% Generate observation data
xSize = size(X);
omegaIndex = randperm(prod(xSize), round(sr*prod(xSize)));
nObv = length(omegaIndex);

Omega = zeros(xSize);
Omega(omegaIndex) = 1;
Xo = Omega.*X;

% Add noise
Ndim = size(Xo);
N = length(Ndim);

variance = c*norm(X(:),'fro')/sqrt(prod(Ndim));
noiseVec = (variance).*randn(nObv,1);
noiseTen = zeros(Ndim);
noiseTen(omegaIndex) = noiseVec;
XoNoise = Xo + noiseTen;

%% Run both methods
% 1. NTRC
fprintf('Running NTRC...\n');
optsNoisyTR = struct('lambda', lambda, 'maxit', 500, 'tol', 1e-8, 'd', floor(N/2),...
    'alpha', 1/N*ones(1,N), 'mu', 1e-3, 'rho', 1.1, 'max_mu', 1e10, 'DEBUG', true);

tic;
Xhat1 = NTRC(XoNoise, omegaIndex, optsNoisyTR);
costTime1 = toc;

% 2. Faster NTRC
fprintf('Running Faster NTRC...\n');

faOptsNoisyTR = struct('R0', R0, 'lambda', lambda, 'maxit', 500, 'tol', 1e-8, 'd', floor(N/2),...
    'alpha', 1/N*ones(1,N), 'mu', 1e-3, 'rho', 1.18, 'max_mu', 1e10, 'DEBUG', true);

tic;
Xhat2 = FaNTRC(XoNoise, omegaIndex, faOptsNoisyTR);
costTime2 = toc;

%% Evaluate Results
% NTRC results
psnr1 = PSNR_RGB(Xhat1, X);
rmse1 = perfscore(Xhat1, X);

% Calculate SSIM for each frame and average
ssim1_all = zeros(1, d4);
for i = 1:d4
    frame_Xhat1 = squeeze(Xhat1(:,:,:,i));
    frame_X = squeeze(X(:,:,:,i));
    ssim1_all(i) = ssim_index(rgb2gray(uint8(frame_Xhat1)), rgb2gray(uint8(frame_X)));
end
ssim1 = mean(ssim1_all);

% Faster NTRC results
psnr2 = PSNR_RGB(Xhat2, X);
rmse2 = perfscore(Xhat2, X);

% Calculate SSIM for each frame and average
ssim2_all = zeros(1, d4);
for i = 1:d4
    frame_Xhat2 = squeeze(Xhat2(:,:,:,i));
    frame_X = squeeze(X(:,:,:,i));
    ssim2_all(i) = ssim_index(rgb2gray(uint8(frame_Xhat2)), rgb2gray(uint8(frame_X)));
end
ssim2 = mean(ssim2_all);

% Print Results
fprintf('\nVideo Completion Results Comparison:\n');
fprintf('NTRC: PSNR=%.2f, RMSE=%.4f, SSIM=%.4f, Time=%.2fs\n', ...
    psnr1, rmse1, ssim1, costTime1);
fprintf('Faster NTRC: PSNR=%.2f, RMSE=%.4f, SSIM=%.4f, Time=%.2fs\n', ...
    psnr2, rmse2, ssim2, costTime2);
 