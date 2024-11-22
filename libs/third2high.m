function Y=third2high(X, optsOrder)
    % VDT for color images
    
    Y = reshape(X, optsOrder.Nway);
    Y = permute(Y, optsOrder.order);
    Y = reshape(Y, optsOrder.Ndim);

    % only using reshape
%     Y = reshape(X, optsOrder.Ndim);
end

