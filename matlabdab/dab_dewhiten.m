function out = dab_dewhiten(in)
    [nframes bitsframe] = size(in);
    for i=1:nframes,
        out(i,:)=mod(in(i,:)+dab_prbs(bitsframe),2);
    end
end