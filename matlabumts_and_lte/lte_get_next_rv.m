
function nextrv = lte_get_next_rv( rv )

    RVs = [0 2 3 1];
    
    rvidx = find(RVs == rv) - 1;
    rvidx = mod(rvidx+1,4);
    rvidx = rvidx + 1;
    
    nextrv = RVs(rvidx);
    
end