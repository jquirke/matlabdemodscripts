function sbsize = lte_turbo_softbuffersize(D, Ncb)
%instance of LTE conv deratematcher

    sbsize = min(3 * 32 * ceil(D/32),Ncb);;

    
end

