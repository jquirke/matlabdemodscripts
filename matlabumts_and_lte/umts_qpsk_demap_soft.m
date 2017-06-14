function softbits_out = umts_qpsk_demap_soft( symbols_in )
%demap QPSK modulation in UMTS
% the input symbols must be phase corrected
% real branch = even 
% imag branch = odd

softbits_out = zeros(1,length(symbols_in)*2);

%+1 = 0, -1 = 1

softbits_out(1:2:end) = real(symbols_in); 
softbits_out(2:2:end) = imag(symbols_in);


end

