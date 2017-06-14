function ref_seq = dvb_init_refseq(ncarriers)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
   prbs = zeros(1,ncarriers);
   reg = ones(1,11);
    for i=1:ncarriers,
        bit=mod(reg(11)+reg(9),2);
        prbs(i)=reg(11);
        reg(2:11) = reg(1:10);
        reg(1)=bit;
    end   
    
     ref_seq = 2 * (0.5 - prbs);;
     

end

