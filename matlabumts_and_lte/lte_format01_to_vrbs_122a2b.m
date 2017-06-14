function VRBs = lte_format01_to_vrbs_122a2b( NDLRB, resourceallocheader, resourcealloc_bitvector, P)
%see 36.213 7.1.6.1/2

    
    if (NDLRB <= 10 || resourceallocheader == 0)
       
        VRBs = [];
        for i=1:length(resourcealloc_bitvector)
           if (resourcealloc_bitvector(i) > 0)
               VRBs = [VRBs (i-1)*P+[0:P-1]];
           end
        end
        
        
    else %resourceallocheader ==1
        VRBs = [];

    end
    VRBs = VRBs(find(VRBs < NDLRB));
end

