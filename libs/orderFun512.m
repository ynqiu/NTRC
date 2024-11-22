function optsOrder = orderFun512(d)

switch d
case 1
    Nway = [512, 512, 3];
    Ndim = [512, 512, 3];
    order = [1, 2, 3];
    inverOrder = [1, 2, 3];
case 2
    Nway = [4,4,8,4, 4,4,4,8, 3];%  [16,16,16,16,3];%
    Ndim = [16,16,32,32,3];
    order = [1,5,2,6,3,7,4,8,9]; %[1,2,3,4,5];% 
    inverOrder = [1,3,5,7,2,4,6,8,9];%[1,2,3,4,5];%
case 3
    Nway =[2,2,2,2,2,2,4,2, 2,2,2,2,2,2,2,4, 3];% [4,4,4,4,4,4,4,4,3];% 
    Ndim = [4,4,4,4,4,4,8,8,3];
    order = [1,9,2,10,3,11,4,12,5,13,6,14,7,15,8,16,17]; %[1,2,3,4,5,6,7,8,9];%
    inverOrder =[1,3,5,7,9,11,13,15,2,4,6,8,10,12,14,16,17]; % [1,2,3,4,5,6,7,8,9];% 
end

optsOrder = struct('Nway', Nway, 'Ndim', Ndim, 'order',order, 'inverOrder', inverOrder);
end

