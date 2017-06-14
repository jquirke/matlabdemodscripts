
function  [dc_offset sumcorr] = CHECK_dvb_corr_const_pilots(frame1_k, frame2_k, tu, tcp, activecarriers, pilotmap)


    frame1_fft = zeros(1,8192);
    frame2_fft = zeros(1,8192);
    
    frame1_fft(4096-3408:4096+3408) = frame1_k;
    frame2_fft(4096-3408:4096+3408) = frame2_k;    

    conj_frames = frame2_fft .* conj(frame1_fft);
    %correlate
    %figure(8)
    %plot([1:8192], abs(frame1_fft).^2)
    %figure(9)
    %plot([1:8192], abs(frame2_fft).^2)  
    
    
    kminmax = (tu - activecarriers - 1)/2;
    
    shifted_pilotmap = zeros(1,tu);
    sumcorr = zeros(1,2*kminmax+1);
    
    for i=-kminmax:1:kminmax

        if (i>0) % shift right     
            shifted_pilotmap(i+1:tu) = pilotmap(1:tu-i);
        else %shift left
            shifted_pilotmap(1:tu-(-i)) = pilotmap(1+(-i):tu);
        end
    
        sumcorr(i+kminmax+1) = abs(sum( shifted_pilotmap .* conj_frames));
    end
    
    [maxcorr dcoffsets] = max(sumcorr);
    %pick the closest to centres
    dcoffsets = dcoffsets - (kminmax+1);
    absmin = min(abs(dcoffsets));
    if (any(dcoffsets(:) == absmin))
        dc_offset =absmin;
    else
        dc_offset =-absmin;
        ends
end

