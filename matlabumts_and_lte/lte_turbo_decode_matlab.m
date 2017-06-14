function output = lte_turbo_decode_matlab( input_softbits)
%instance of LTE turbo interleaver
    

    const_encoder = poly2trellis(4, [13 15], 13);
    assert (mod(length(input_softbits), 3) == 0);
    D = length(input_softbits)/3;
    K=D-4;
    
    interleave_pattern = lte_turbo_internal_int([1:K], K);
    turbodec = comm.TurboDecoder(const_encoder, interleave_pattern);
    
    %refactor the input into the format it expects
    

    
    reformatted_softbits  = zeros(1,length(input_softbits));
    reformatted_softbits(1:3:end) = input_softbits(1:D);
    reformatted_softbits(2:3:end) = input_softbits(D+1:2*D);
    reformatted_softbits(3:3:end) = input_softbits(2*D+1:3*D);
        
    output = step(turbodec, reformatted_softbits.').';
    
%     xk = input;
%     [zk tsys1 tcoded1] = lte_turbo_constit_enc(input);
%     [zpk tsys2 tcoded2] = lte_turbo_constit_enc(lte_turbo_internal_int(input, D));
%     
%     output = [xk tsys1(1) tcoded1(2) tsys2(1) tcoded2(2) ...
%               zk tcoded1(1) tsys1(3) tcoded2(1) tsys2(3) ...
%               zpk tsys1(2) tcoded1(3) tsys2(2) tcoded2(3)];

end

