function seq = gen_pss(u  )

    seq = zeros(1,62);
    
    seq(1:31) = exp(-j*pi*u*(0:30).*((0:30)+1)/63);
    
    seq(32:62) = exp(-j*pi*u*((31:61)+1).*((31:61)+2)/63);
    
end

