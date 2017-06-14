function seq = dab_prbs(length)
    reg = ones(1,9);
    for i=1:length,
        bit=mod(reg(9)+reg(5),2);
        seq(i)=bit;
        reg(2:9) = reg(1:8);
        reg(1)=bit;
    end
end