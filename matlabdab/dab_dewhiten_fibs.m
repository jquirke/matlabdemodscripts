function out = dab_dewhiten_fibs(in)
    out=mod(in+dab_prbs(768),2);
end