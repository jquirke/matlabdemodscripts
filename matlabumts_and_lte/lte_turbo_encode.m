function output = lte_turbo_encode( input, D)
%instance of LTE turbo interleaver
    

    xk = input;
    [zk tsys1 tcoded1] = lte_turbo_constit_enc(input);
    [zpk tsys2 tcoded2] = lte_turbo_constit_enc(lte_turbo_internal_int(input, D));
    
    output = [xk tsys1(1) tcoded1(2) tsys2(1) tcoded2(2) ...
              zk tcoded1(1) tsys1(3) tcoded2(1) tsys2(3) ...
              zpk tsys1(2) tcoded1(3) tsys2(2) tcoded2(3)];

end

