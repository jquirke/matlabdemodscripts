function y = dab_calc_relphase(z)
    [nsyms, fftlen] = size(z);
    y = z(2:nsyms,:) .* conj(z(1:nsyms-1,:));
    %y = z(2:nsyms,:) ./ z(1:nsyms-1,:);
end
    