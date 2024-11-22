function Y=high2third(X, xSize, optsOrder)
%     inverse VDT for high-order tensor
    Ytemp=zeros(optsOrder.Nway);
    YtempHigh=reshape(Ytemp,optsOrder.Nway);
    perNway=size(permute(YtempHigh,optsOrder.order));
    Y = reshape(X, perNway);
    Y = permute(Y, optsOrder.inverOrder);
    Y = reshape(Y, xSize);
    % only using reshape
%     Y=reshape(X,xSize);
end