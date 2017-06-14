%note encoded TFCI is lsb first, but that is the way it is transmitted
function encoded_tfci = umts_encode_tfci(tfci)

    M = [ ...                                                                                             
    1          0          0          0          0          1          0          0          0          0 ;
    0          1          0          0          0          1          1          0          0          0 ;
    1          1          0          0          0          1          0          0          0          1 ;
    0          0          1          0          0          1          1          0          1          1 ;
    1          0          1          0          0          1          0          0          0          1 ;
    0          1          1          0          0          1          0          0          1          0 ;
    1          1          1          0          0          1          0          1          0          0 ;
    0          0          0          1          0          1          0          1          1          0 ;
    1          0          0          1          0          1          1          1          1          0 ;
    0          1          0          1          0          1          1          0          1          1 ;
    1          1          0          1          0          1          0          0          1          1 ;
    0          0          1          1          0          1          0          1          1          0 ;
    1          0          1          1          0          1          0          1          0          1 ;
    0          1          1          1          0          1          1          0          0          1 ;
    1          1          1          1          0          1          1          1          1          1 ;
    1          0          0          0          1          1          1          1          0          0 ;
    0          1          0          0          1          1          1          1          0          1 ;
    1          1          0          0          1          1          1          0          1          0 ;
    0          0          1          0          1          1          0          1          1          1 ;
    1          0          1          0          1          1          0          1          0          1 ;
    0          1          1          0          1          1          0          0          1          1 ;
    1          1          1          0          1          1          0          1          1          1 ;
    0          0          0          1          1          1          0          1          0          0 ;
    1          0          0          1          1          1          1          1          0          1 ;
    0          1          0          1          1          1          1          0          1          0 ;
    1          1          0          1          1          1          1          0          0          1 ;
    0          0          1          1          1          1          0          0          1          0 ;
    1          0          1          1          1          1          1          1          0          0 ;
    0          1          1          1          1          1          1          1          1          0 ;
    1          1          1          1          1          1          1          1          1          1 ;
    0          0          0          0          0          1          0          0          0          0 ;
    0          0          0          0          1          1          1          0          0          0 ];

    %for each bit, starting from lsb
    encoded_tfci = zeros(1,32);
    for i=0:9,
        encoded_tfci = mod(encoded_tfci + M(:,i+1)' .* (bitand(bitshift(tfci,-i),1)),2);
    end
    
    
end




