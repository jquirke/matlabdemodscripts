%test alternative gmsk methods


g_samps_per_sym = 10;

g_synch_train_seq =  [ ...
1 0 1 1 1 0 0 1 ...
0 1 1 0 0 0 1 0 ...
0 0 0 0 0 1 0 0 ... 
0 0 0 0 1 1 1 1 ...
0 0 1 0 1 1 0 1 ...
0 1 0 0 0 1 0 1 ...
0 1 1 1 0 1 1 0 ...
0 0 0 1 1 0 1 1 ];

% method 1 - convolve with filter, integrate

m1_data_in = g_synch_train_seq;
m1_data_diff = 1-2*mod(m1_data_in(2:end) + m1_data_in(1:end-1), 2);
m1_samps_per_sym = g_samps_per_sym;

m1_pulses = upsample(m1_data_diff, m1_samps_per_sym);

m1_tt = -1:1/m1_samps_per_sym:1;

m1_T=1;
m1_BT=0.3;
m1_d=sqrt(log(2))/(2*pi*m1_BT);
m1_gmsk_pulse = exp(-m1_tt.^2/(2*m1_d^2*m1_T^2))/(sqrt(2*pi)*m1_d*m1_T) / m1_samps_per_sym; 
m1_data_conv = conv(m1_pulses, m1_gmsk_pulse);

m1_data_integrated = cumsum(m1_data_conv) * pi/2;

m1_out = exp(j*m1_data_integrated);

figure(1)
plot([1:length(m1_out)], real(m1_out));


% method 1 - integrate, convolve with filter

m2_data_in = g_synch_train_seq;
m2_data_diff = 1-2*mod(m2_data_in(2:end) + m2_data_in(1:end-1), 2);
m2_samps_per_sym = g_samps_per_sym;

m2_pulses = upsample(m2_data_diff, m2_samps_per_sym);

m2_tt = -1:1/m2_samps_per_sym:1;

m2_T=1;
m2_BT=0.3;
m2_d=sqrt(log(2))/(2*pi*m2_BT);
m2_gmsk_pulse = exp(-m2_tt.^2/(2*m2_d^2*m2_T^2))/(sqrt(2*pi)*m2_d*m2_T) / m2_samps_per_sym; 

m2_data_integrated = cumsum(m2_pulses) * pi/2;

m2_data_conv = conv(m2_data_integrated, m2_gmsk_pulse);


m2_out = exp(j*m2_data_conv);

figure(2)
plot([1:length(m2_out)], real(m2_out));









