function austarts = dabplus_aac_info(audiosuperframe)
    firepoly = [1 0 1 1 1 1 0 0 0 0 0 1 0 1 1 1 1];
    aucrcpoly=[1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1]; %x^16 + x^12 + x^5 + 1
    nbytes = length(audiosuperframe);
    inputbits=zeros(1,nbytes*8);
    for i=1:nbytes,
        inputbits((i-1)*8+1:(i-1)*8+8) = dab_int_to_bitvector(audiosuperframe(i),8);
    end

    fire = inputbits(1:16);
    fireinput = inputbits(17:17+9*8-1);
    firecheck=dabplus_firecheck(fireinput, firepoly);
    fireok = sum(abs(firecheck - fire)) == 0;
   
    dac_rate=inputbits(18);
    sbr_flag=inputbits(19);
    aac_channel_mode=inputbits(20);
    ps_flag=inputbits(21);
    mpeg_surround_config=dab_binval(inputbits(22:24));
    
    switch (dac_rate * 2 + sbr_flag)
        case 1
            num_aus=2;
        case 3
            num_aus=3;
        case 0
            num_aus=4;
        case 2 
            num_aus=6;
        otherwise
    end
    bitindex = 25;
    
    for au=1:num_aus-1,
        au_start(au+1) = dab_binval(inputbits(bitindex:bitindex+11));
        bitindex = bitindex+12;
    end

    if (~((dac_rate==1) && (sbr_flag==1)))
        bitindex=bitindex+4;
    end    
    assert(mod(bitindex-1,8) == 0);
    au_start(1) = (bitindex-1)/8;
    

    fprintf(1, 'Audio superframe fireok=%d len=%d bytes dac_rate=%d sbr=%d stereo=%d PS=%d ', fireok, nbytes, dac_rate, sbr_flag, aac_channel_mode, ps_flag);
    fprintf(1, 'surround=%d numaus=%d AUstarts={',mpeg_surround_config,num_aus);
    
    lastau=0;
    for au=1:num_aus
        if (au==num_aus)
            endoffset=nbytes;
        else
            endoffset=au_start(au+1);
        end
        if (au_start(au) < lastau || au_start(au)+1 > nbytes || endoffset >nbytes)
            fprintf(1,'%d [err:before last/exceeds bounds] ', au_start(au));
        else
            % get the end of the au
            startoffset = au_start(au);

            % extract the au
            au_data = audiosuperframe(startoffset+1:endoffset);
            aucrcok = dabplus_aucrc_verify(au_data,aucrcpoly);
            if (aucrcok)
                aucrcresult = 'CRCOK';
            else
                aucrcresult = 'CRCFAIL';
            end
            fprintf(1,'%d(%s) ', au_start(au),aucrcresult);
        end
        lastau = au_start(au);
    end
   
    fprintf(1,'}\n'); 
    austarts = au_start;
end