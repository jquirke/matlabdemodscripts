function pdcch_deint = lte_pdcch_deint(int_symbols, ncellid)
%int_symbols = interleaved QPSK symbols, multiple of 4 

    Mquad = length(int_symbols)/4;
    %remove cyclic shifting - original shift is LEFT, so this must be a
    %right shift
    sym_shift = mod(ncellid, Mquad);
    
    pdcch_deshift = circshift(int_symbols',sym_shift*4)';
    
    % same (de)interleaver is used as in the convolutional case, but
    % operates in groups of 4 symbols
    
    
    CsubblockCC = 32;
    RsubblockCC = ceil(Mquad/CsubblockCC);
    ND = CsubblockCC * RsubblockCC - Mquad;
    
    matrix = zeros(1,CsubblockCC * RsubblockCC);
    matrix(1:ND) = 0;
    matrix(ND+1:end) = [1:Mquad];
    
    %read in row by row
    matrix = reshape(matrix,CsubblockCC, RsubblockCC)';
    
    matrix_permute = zeros(RsubblockCC,CsubblockCC);
    %permute cols
    P = [1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31, 0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, 30 ];
    
    for i=0:CsubblockCC-1,
        matrix_permute(:,i+1) = matrix(:,P(i+1)+1);
    end
    
    %read out col by col
    matrix_out = reshape(matrix_permute, 1, RsubblockCC*CsubblockCC);
    
    matrix_nonulls = matrix_out(find(matrix_out));
    
    %deintbits = zeros(1,length(intbits));
    pdcch_deint = zeros(1,Mquad*4);
    pdcch_deint((matrix_nonulls-1)*4+1+0) = pdcch_deshift(1:4:end);
    pdcch_deint((matrix_nonulls-1)*4+1+1) = pdcch_deshift(2:4:end);
    pdcch_deint((matrix_nonulls-1)*4+1+2) = pdcch_deshift(3:4:end);
    pdcch_deint((matrix_nonulls-1)*4+1+3) = pdcch_deshift(4:4:end);
    
end

