function bits_out = umts_qpsk_demap( symbols_in )
%demap QPSK modulation in UMTS
% the input symbols must be phase corrected
% real branch = even 
% imag branch = odd

bits_out = zeros(1,length(symbols_in)*2);

%+1 = 0, -1 = 1

bits_out(1:2:end) = sign(real(symbols_in))*-0.5 + 0.5; %maps +1->0, -1->1 
bits_out(2:2:end) = sign(imag(symbols_in))*-0.5 + 0.5;


end

