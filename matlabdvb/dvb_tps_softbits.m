function tps_softbits = dvb_tps_softbits(carriers1, carriers2, dvb_tps)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    tps_softbits = real(carriers2(dvb_tps+1) .* conj( carriers1(dvb_tps+1)));

end

