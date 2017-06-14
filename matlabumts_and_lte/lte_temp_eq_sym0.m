function eq_kv = lte_temp_eq_sym0( kvector, kvest0, kvest1, ncellid, l, ns, ncp )
%Very simple equalisation 2x2 only
%   Detailed explanation goes here


    ks_ref0 = [];
    ks_ref1 = []; %default for non-reference signal containing symbols

    if (l == 0)

        koffset0 = lte_ref_koffset(ncellid, l, ns, 0);
        koffset1 = lte_ref_koffset(ncellid, l, ns, 1);

        ks_ref0 = 0+koffset0:6:110*12-1;
        ks_ref1 = 0+koffset1:6:110*12-1;
        
    elseif (l == 1)

        koffset0 = lte_ref_koffset(ncellid, l, ns, 2);
        koffset1 = lte_ref_koffset(ncellid, l, ns, 3);

        ks_ref0 = 0+koffset0:6:110*12-1;
        ks_ref1 = 0+koffset1:6:110*12-1;
    
    elseif ((ncp == 1 && l == 4) || (ncp ==0 && l == 3))
        
        koffset0 = lte_ref_koffset(ncellid, l, ns, 0);
        koffset1 = lte_ref_koffset(ncellid, l, ns, 1);

        ks_ref0 = 0+koffset0:6:110*12-1;
        ks_ref1 = 0+koffset1:6:110*12-1;
        
    end 

    eq_kv = zeros(1,110*12);
    
    ks_data = sort(setdiff([0:110*12-1], [ks_ref0 ks_ref1]));
    
    for i=0:length(ks_data)/2-1,
        
        idx0 = ks_data(2*i+0+1);
        idx1 = ks_data(2*i+1+1);
        
        idx0 = idx0+1;
        idx1 = idx1+1;
        s0 = kvector(idx0);
        s1 = kvector(idx1);
        h0_0 = kvest0(idx0);
        h0_1 = kvest0(idx1);
        h1_0 = kvest1(idx0);
        h1_1 = kvest1(idx1);

        %build the initial matrix
        H = [h0_0 -h1_0; conj(h1_1) conj(h0_1)];
        Hinv = inv(H);

        Rp = Hinv * [s0 ; conj(s1)];

        eq_kv(idx0) = Rp(0+1);
        eq_kv(idx1) = conj(Rp(1+1));
        
    end
end

