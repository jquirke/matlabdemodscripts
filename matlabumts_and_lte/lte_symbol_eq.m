function eq_kv = lte_symbol_eq( kvector, antenna_estimates, NDLRB, ncellid, l, ns, ncp )
%Very simple equalisation 2x2 only
%   Detailed explanation goes here

%more complicated - the PBCH assumes all ref signal REs are reserved, even
%if not used

%this is not the case elsewhere (apparently)

    ks_ref0 = [];
    ks_ref1 = []; %default for non-reference signal containing symbols

    num_antennas = size(antenna_estimates, 1);
    
    if (l == 0)

        koffset0 = lte_ref_koffset(ncellid, l, ns, 0);
        koffset1 = lte_ref_koffset(ncellid, l, ns, 1);

        ks_ref0 = 0+koffset0:6:110*12-1;
        ks_ref1 = 0+koffset1:6:110*12-1;
        
    elseif (l == 1 && ns == 1 && num_antennas <= 2) %special case, there are no reference signals in this 2x2-only code, but, PBCH assumes there are

        koffset0 = lte_ref_koffset(ncellid, l, ns, 2);
        koffset1 = lte_ref_koffset(ncellid, l, ns, 3);

        ks_ref0 = 52*12+koffset0:6:58*12-1; %PBCH region only
        ks_ref1 = 52*12+koffset1:6:58*12-1;
        
    elseif (l == 1 && num_antennas == 4)
        
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
    baseRB = (110 - NDLRB)/2;

    ks_data = sort(setdiff([baseRB*12:baseRB*12+NDLRB*12-1], [ks_ref0 ks_ref1]));
    
    for i=0:length(ks_data)/2-1, %i is the pair index
        
        if (num_antennas <= 2)
            antenna_idxs = [0, 1];
        else % 4 antennas
            if (mod (i,2) == 0) 
                antenna_idxs = [0, 2]; %even pairs use antennas 0,2 in Alamouti code, antenna 1+3 are quiet
            else
                antenna_idxs = [1, 3]; %odd pairs use antenna 1,3 in Alamouti code, antenna 2+4 are quiet
            end
        end
        
        idx0 = ks_data(2*i+0+1);
        idx1 = ks_data(2*i+1+1);
        
        idx0 = idx0+1;
        idx1 = idx1+1;
        s0 = kvector(idx0);
        s1 = kvector(idx1);
        
%         h0_0 = kvest0(idx0);
%         h0_1 = kvest0(idx1);
%         h1_0 = kvest1(idx0);
%         h1_1 = kvest1(idx1);
      
        h0_0 = antenna_estimates(antenna_idxs(1)+1,idx0);
        h0_1 = antenna_estimates(antenna_idxs(1)+1,idx1);
        h1_0 = antenna_estimates(antenna_idxs(2)+1,idx0);
        h1_1 = antenna_estimates(antenna_idxs(2)+1,idx1);
        
        %build the initial matrix
        H = [h0_0 -h1_0; conj(h1_1) conj(h0_1)];
        Hinv = inv(H);

        Rp = Hinv * [s0 ; conj(s1)];

        eq_kv(idx0) = Rp(0+1);
        eq_kv(idx1) = conj(Rp(1+1));
        
    end
end

