%can be a single channel or the whole CIF
%as deinterleaving is performed bit index modulo 16 and all channels are
%aligned to 64bit boundaries anyway
function out = dab_time_deint(in)
    offsets = [0 +8 +4 +12 +2 +10 +6 +14 +1 +9 +5 +13 +3 +11 +7 +15];
    [cifs bits_per_subch]= size(in);
    if (cifs<16)
        out = [];
        return;
    end
    ncifout=cifs-15;
    out=zeros(ncifout, bits_per_subch);
    for i=1:bits_per_subch,
        offset=mod(i-1,16)+1;
        out(:,i) = in(1+offsets(offset):1+offsets(offset)+ncifout-1,i);
    end
end