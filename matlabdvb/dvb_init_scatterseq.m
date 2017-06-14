function scattersec = dvb_init_scatterseq( ncarriers )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


    scattersec = zeros(4,ncarriers);
    for i=0:3,
        scattersec(i+1,1+i*3:12:end) = 1;
    end

end

