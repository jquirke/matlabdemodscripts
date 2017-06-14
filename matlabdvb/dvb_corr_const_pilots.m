
function  dc_offset = dvb_corr_const_pilots(frame1, frame2, tu, tcp, activecarriers, pilotmap)

    frame1_nocp = frame1(tcp+1:tu+tcp);
    frame2_nocp = frame2(tcp+1:tu+tcp);
    
    frame1_fft = fftshift(fft(frame1_nocp));
    frame2_fft = fftshift(fft(frame2_nocp));
    
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

