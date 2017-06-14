function carriersout = dvb_ofdm_sample_and_shift(samples, tu, tcp, dvb_num_active_carriers, dc_offset)

    frame_nocp = samples(tcp+1:tu+tcp);
    spectrum = fftshift(fft(frame_nocp));
    kminmax = (dvb_num_active_carriers-1)/2;
    carriersout = spectrum(tu/2+1+dc_offset-kminmax:tu/2+1+dc_offset+kminmax);


end

