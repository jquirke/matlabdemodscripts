function val = dab_binval(vector)
    nbits = length(vector);
    weights = 2.^(nbits-1-[0:nbits-1]);
    val = sum(weights.*vector);
end