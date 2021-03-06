
%keep it simple for now, only allow frame sizes of 30N to avoid dummy bits

function output_frame = umts_2nd_deinterleave( input_frame )
%umts_2nd_interleave - [de]interleave as per 3gpp 25.212 4.2.11

    %compute the original indexes
    orig_indexes = 1:length(input_frame);
    C2 = 30;
    R2 = (length(orig_indexes)/C2);
    U = R2 * C2;

    %reshape as R2 by C2 matrix
    input_matrix = transpose(reshape(orig_indexes, C2, R2));

    permute_pattern = [0, 20, 10, 5, 15, 25, 3, 13, 23, 8, 18, 28, 1, 11, 21, 6, 16, 26, 4, 14, 24, 19, 9, 29, 12, 2, 7, 22, 27, 17];
    
    permuted_matrix = zeros(size(input_matrix)); % set same size
    permuted_matrix(:,1:30) = input_matrix(:,permute_pattern+1);
    %%permuted_matrix(:,1:30) = input_matrix(:,1:30)
    %%permuted_matrix = input_matrix;
    
    %perform inter-column permutation
    %input_matrix_permuted = 
    
    %transpose the matrix and flattern it
   
    output_indexes = reshape((permuted_matrix), 1, U);

    %so output indexes is an array such that says the array[x]'th
    %position in the input array ended up at array x in the output
   
    output_frame(output_indexes)  = input_frame(1:length(input_frame));

end

