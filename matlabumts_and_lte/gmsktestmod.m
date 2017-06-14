samps_per_sym = 1;

Nsyms = 200;

synch_train_seq =  [ ...
1 0 1 1 1 0 0 1 ...
0 1 1 0 0 0 1 0 ...
0 0 0 0 0 1 0 0 ... 
0 0 0 0 1 1 1 1 ...
0 0 1 0 1 1 0 1 ...
0 1 0 0 0 1 0 1 ...
0 1 1 1 0 1 1 0 ...
0 0 0 1 1 0 1 1 ];

nrz_data_raw = mod(synch_train_seq(2:end) + synch_train_seq(1:end-1),2);
%Nsyms = length(nrz_data_raw);

%nrz_data_raw = 1-2*randint(1,Nsyms);
%nrz_data_raw = ones(1,Nsyms);
%nrz_data_raw = [1     1     1    -1     1    -1    -1     1     1     1    -1    -1    -1     1    -1    -1    -1     1     1    -1];
msk_data_in = zeros(1,length(nrz_data_raw) * samps_per_sym);

for i=1:samps_per_sym,
    msk_data_in(i:samps_per_sym:end) = nrz_data_raw/samps_per_sym;
end

%msk_pulse = ones(1,samps_per_sym)/samps_per_sym;


gmsk_t = [-3:1/samps_per_sym:3];
T=1;
BT=0.3;
d=sqrt(log(2))/(2*pi*BT);
gmsk_pulse = exp(-gmsk_t.^2/(2*d^2*T^2))/(sqrt(2*pi)*d*T) / samps_per_sym; 


integrated_data = cumsum(msk_data_in)*pi/2;

%filtered_data = conv(msk_data_in, gmsk_pulse);

%filtered_data = filtered_data(floor(length(gmsk_pulse)/2):floor(length(gmsk_pulse)/2)+length(msk_data_in));


filtered_data = conv(integrated_data,gmsk_pulse);

baseband_data = exp(j*filtered_data);


figure(1)

plot([1:length(baseband_data)], real(baseband_data))%, [1:length(baseband_data)], imag(baseband_data));

figure(2)

%plot([1:length(filtered_data)], filtered_data, [1:length(filtered_data)], phase_data);

sampled_data = baseband_data(3:samps_per_sym:end);


%baseband_data = resample(baseband_data,10,1);
figure(3)

plot([0:length(baseband_data)-1]/length(baseband_data)*samps_per_sym, 10*log10(abs(fft(baseband_data)).^2))
