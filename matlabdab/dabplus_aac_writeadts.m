function dabplus_aac_writeadts(aacfile, au_starts,audiosuperframe)
    
    for i=1:length(au_starts) % for each au
        startoffset=au_starts(i);
        if (i==length(au_starts))
            endoffset=length(audiosuperframe);
        else
            endoffset=au_starts(i+1);
        end
        au_body = audiosuperframe(startoffset+1:endoffset-2); %discard crc
        aulen = endoffset-startoffset-2;%crc
        adtshdr = dabplus_adts_header(aulen, 6);
        fwrite(aacfile,adtshdr, 'uint8');
        fwrite(aacfile,au_body, 'uint8');
    end
end