%est freq adj in rad/sample, coarse offset in 1/Tu steps (carrier
%seperations)
function [fine_offset_radsamp coarse_offset_steps] = dab_est_freqadj(samples, syncstart, fftlen, cplen, nsymbols, ncarriers)
    symlen=cplen+fftlen;
    for i=0:nsymbols-1,
        phase_est=samples(syncstart+i*symlen:syncstart+i*symlen+cplen-1) .* conj(samples(syncstart+i*symlen+fftlen:syncstart+i*symlen+fftlen+cplen-1));
        phase_est_sample(i+1) = angle(sum(phase_est))/fftlen;
    end
    fine_offset_radsamp=sum(phase_est_sample)/nsymbols;
    
    %now apply the fine freq adj to sync symbol
    
    syncsym=samples(syncstart:syncstart+symlen-1);
    
    syncsym=syncsym .* exp(j*fine_offset_radsamp.*[1:symlen]);
    %remove CP
    syncsymextract=syncsym(cplen+1:symlen);
    PSDsyncsym=abs(fftshift(fft(syncsymextract))).^2;
    
    maxpwr=0;
    maxidx=1;
    for i=1:(fftlen-ncarriers),
        pwr=sum(PSDsyncsym(i:i+ncarriers/2-1)) + sum(PSDsyncsym(i+ncarriers/2+1:i+ncarriers));
        pwrs(i) = pwr;
        if (pwr>maxpwr)
            maxpwr=pwr;
            maxidx=i;
        end
        
    end
    coarse_offset_steps=-(maxidx-1-(fftlen-ncarriers)/2);
end



