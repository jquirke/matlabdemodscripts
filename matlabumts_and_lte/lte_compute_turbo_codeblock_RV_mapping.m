function codeblock_mapping = lte_compute_turbo_codeblock_RV_mapping(D, CircBufferSizeNcb, E, rv)
% compute the mappings from the codeblock to the transmitted data for a
% given RV

    CTCsubblock = 32;
    RTCsubblock = ceil(D/CTCsubblock);
    KPI =  RTCsubblock * CTCsubblock;
    Kw = 3 *KPI;
    soft_buffer = zeros(1,Kw);
    %interleave the values 1-Kw across the buffer to see where they end up
    soft_buffer(0*KPI+1:1*KPI) = lte_turbo_int_seq(0*D+1:1*D);
    %next 2 are intermixed
    soft_buffer(1*KPI+1+0:2:3*KPI) = lte_turbo_int_seq(1*D+1:2*D);
    soft_buffer(1*KPI+1+1:2:3*KPI) = lte_turbo_int_seq2(2*D+1:3*D);   
    
    Ncb = min(Kw, CircBufferSizeNcb);
    
    k0 = RTCsubblock * (2*ceil(Ncb/(8*RTCsubblock))*rv + 2);
    
    
    k = 0; j =0;
    while (k<E)
        if (soft_buffer(mod(j+k0, Ncb) + 1) ~= 0)
            ex(k+1) = soft_buffer(mod(j+k0, Ncb) + 1);
            k  = k+1;
        end
        j = j+1;
    end
    
    %faster method
    codeblock_mapping = ex;
    
end