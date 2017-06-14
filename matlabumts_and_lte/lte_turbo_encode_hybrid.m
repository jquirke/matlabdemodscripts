function output = lte_turbo_encode_hybrid( input, D)
%instance of LTE turbo interleaver
    

    xk = input;
    [zk tsys1 tcoded1] = lte_turbo_constit_enc(input);
    [zpk tsys2 tcoded2] = lte_turbo_constit_enc(internal_interleaver_bw(input, D));
    
    %xk zk
    %xk zk'
%     output = [xk    tsys1(1) tcoded1(2) tsys2(1) tcoded2(2) ...
%               zk    tcoded1(1) tsys1(3) tcoded2(1) tsys2(3) ...
%               zpk   tsys1(2) tcoded1(3) tsys2(2) tcoded2(3)];

      output = [xk    tsys1(1) tcoded1(2) tsys2(1) tcoded2(2) ...
                zk    tcoded1(1) tsys1(3) tcoded2(1) tsys2(3) ...
                zpk   tsys1(2) tcoded1(3) tsys2(2) tcoded2(3)];
          
end

