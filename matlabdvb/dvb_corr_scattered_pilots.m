function [ scatteredcyclenumber ] =  dvb_corr_scattered_pilots(carriers_back_4, carriers)

    ncarriers = length(carriers);
%    prbs = zeros(1,ncarriers);
%    reg = ones(1,11);
%     for i=1:ncarriers,
%         bit=mod(reg(11)+reg(9),2);
%         prbs(i)=reg(11);
%         reg(2:11) = reg(1:10);
%         reg(1)=bit;
%     end   
    
%    refseq = 2 * (0.5 - prbs);
    
    scattersec = zeros(4,ncarriers);
    for i=0:3,
        scattersec(i+1,1+i*3:12:end) = 1;
    end

    scatteredcycle = zeros(1,4);
    for i=1:4,
        scatteredcycle(i) = abs(sum(scattersec(i,:) .* carriers  .* conj(carriers_back_4)));
    end
    
    [maxsc maxsci] =max(scatteredcycle);
    scatteredcycle(maxsci) = [];
    
    prs = maxsc ./ scatteredcycle;
    if (min(prs) > 2) % minimum prot ratio > 2
        scatteredcyclenumber = maxsci;
    else
        scatteredcyclenumber = -1;
    end
end

