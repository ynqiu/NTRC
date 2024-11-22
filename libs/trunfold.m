function  Tk = trunfold(T,dims,k,d)
     N = numel(dims);
     T = shiftdim(T,N+k-d);     % k-mode is shift to d-mode
     dims = circshift(dims,d-k); % k-mode is shift to d-mode
     Tk = reshape(T,prod(dims(1:d)),[]);    
end