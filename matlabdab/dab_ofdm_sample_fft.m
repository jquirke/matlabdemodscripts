function z = dab_ofdm_sample_fft(vector, t_start_sync, tu, tcp, symsframe)
    tsym=tcp+tu;
    for i=0:symsframe-1,
        ztime= vector(t_start_sync+i*tsym+tcp:t_start_sync+i*tsym+tcp+tu-1);
        z(i+1,:)=fft(ztime);
    end
end