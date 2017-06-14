function adtshdr = dabplus_adts_header(aulen, sfindex)
    sync = ones(1,12);
    mpeg24 = [0]; %mpeg4
    layer = [0 0]; %layer 00=aac
    protabsent = [1]; % no crc
    profile = [0 1]; %aac LC, core of AAC-HE
    samplefreq=dab_int_to_bitvector(sfindex,4);
    private = [0];
    chconfig = [0 1 0];
    original = [0];
    home = [0];
    copyrightid = [0];
    copyrightidstart = [0];
    framelen = dab_int_to_bitvector(aulen+7, 13);
    buffullness = ones(1,11);
    ausperframe = dab_int_to_bitvector(0,2);
    
    adtshdrbits = [sync mpeg24 layer protabsent profile samplefreq private chconfig original home copyrightid copyrightidstart framelen buffullness ausperframe];
    assert(mod(length(adtshdrbits),8) == 0);
    for i=1:length(adtshdrbits)/8,
        
        adtshdr(i) = dab_binval(adtshdrbits((i-1)*8+1:(i-1)*8+8));
    end
end