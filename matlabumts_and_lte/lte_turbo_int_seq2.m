function intbits = lte_turbo_int_seq2( deintbits)
%Remap the input bits to output bits - stuff with 0 bits
%   Detailed explanation goes here

    CsubblockCC = 32;
    RsubblockCC = ceil(length(deintbits)/CsubblockCC);
    ND = CsubblockCC * RsubblockCC - length(deintbits);
    
    KPI = CsubblockCC * RsubblockCC;
    
    matrix = zeros(1,KPI);
    matrix(1:ND) = 0;
    matrix(ND+1:end) = deintbits;
    
    %read in row by row
    %matrix = reshape(matrix,CsubblockCC, RsubblockCC)';
    
    %matrix_permute = zeros(RsubblockCC,CsubblockCC);
    %permute cols
    %P_conv = [1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31, 0, 16,
    %8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, 30 ];
    P_turbo = [0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, 30, ...
        1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31 ]; 
    
%     for i=0:CsubblockCC-1,
%         matrix_permute(:,i+1) = matrix(:,P_turbo(i+1)+1);
%     end
%     
%     %read out col by col
%     matrix_out = reshape(matrix_permute, 1, RsubblockCC*CsubblockCC);
    k = 0:KPI-1;
    pi_k = mod(P_turbo(floor(k/RsubblockCC)+1) + CsubblockCC * mod(k, RsubblockCC) +1, KPI);
    
    
    
    intbits = matrix(pi_k+1);
    
end

