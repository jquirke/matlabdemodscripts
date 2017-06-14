function lte_guess_nid1( fftsize, nid2, samples)
%Very simple equalisation 2x2 only
%   Detailed explanation goes here

    nid_corr0 = zeros(1,504/3);
    nid_corr5 = zeros(1,504/3);    
    for nid1=0:504,
        nid1;
        nid_corr0(nid1+1) = sum(abs(conj(samples) .* gen_sss_td(nid1,0,fftsize)));
        nid_corr5(nid1+1) = sum(abs(conj(samples) .* gen_sss_td(nid1,5,fftsize)));
    end
    
    figure(3)
    plot(abs(nid_corr0).^2);
    figure(4)
    plot(abs(nid_corr5).^2);    

end