function output = lte_turbo_encode_matlab( input, D)
%instance of LTE turbo interleaver
    

    const_encoder = poly2trellis(4, [13 15], 13);
    interleave_pattern = lte_turbo_internal_int([1:D], D);
    turboenc = comm.TurboEncoder(const_encoder, interleave_pattern);
    
    turbo_interleaved_output = step(turboenc, input.').';
    
    output = [turbo_interleaved_output(1:3:end) turbo_interleaved_output(2:3:end) turbo_interleaved_output(3:3:end)];  
    
%     xk = input;
%     [zk tsys1 tcoded1] = lte_turbo_constit_enc(input);
%     [zpk tsys2 tcoded2] = lte_turbo_constit_enc(lte_turbo_internal_int(input, D));
%     
%     output = [xk tsys1(1) tcoded1(2) tsys2(1) tcoded2(2) ...
%               zk tcoded1(1) tsys1(3) tcoded2(1) tsys2(3) ...
%               zpk tsys1(2) tcoded1(3) tsys2(2) tcoded2(3)];

end

