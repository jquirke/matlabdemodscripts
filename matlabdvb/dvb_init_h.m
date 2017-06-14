function h = dvb_init_h( is8k )
    if (is8k)
        Nmax = 6048;
        Nr = 13;
        xormask = [0 0 0 0 0 1 0 1 0 0 1 1];
        remap = [2 5 8 6 12 7 1 10 3 9 11 4]; % not tested %
             
         
    else
        Nmax = 1512;
        Nr = 11;
        xormask = [0 0 0 0 0 0 1 0 0 1];

        remap = [8 5 2 7 3 10 9 6 4 1 ]; % tested ok %s
    end
    
    h = zeros(1,Nmax);
    
    Mmax = 2^Nr;
    
    Riprime = zeros(1, Nr - 1);
    
    q = 0;
    
    for i=0:Mmax-1 	
        if (i == 2)
            Riprime(Nr - 1) = 1;
        elseif (i > 2)
            bit = mod(sum(Riprime .* xormask),2);
            Riprime(2:Nr - 1) = Riprime(1:Nr -1 -1);
            Riprime(1) = bit;
            
        end
        
        % permute the wires
        
        Ri = Riprime(remap);
      
        % concat
        
        reg = [mod(i,2) Ri];
        %regs
        hq = dab_binval(reg);
  
        if (hq < Nmax)
            h(q+1) = hq;
            q = q + 1;
        end
    end
    
    
    
    %sh = [0];

end

