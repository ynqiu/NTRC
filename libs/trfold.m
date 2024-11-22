function T = trfold(Tk,dims,k,d)
        N = numel(dims);
        dims = circshift(dims,d-k); % k-mode is shift to d-mode
        T = reshape(Tk,dims);        
        T = shiftdim(T,N+d-k);    % d-mode is shift to k-mode, so T with the original dims.    
end