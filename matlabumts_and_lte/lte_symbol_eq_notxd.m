function eq_kv = lte_symbol_eq_notxd( kvector, kvest0, ncellid, l, ns, ncp )
%Very simple equalisation 1x1 only
%   Detailed explanation goes here

%more complicated - the PBCH assumes all ref signal REs are reserved, even
%if not used

%this is not the case elsewhere (apparently)

    eq_kv = kvector ./ kvest0;
end

