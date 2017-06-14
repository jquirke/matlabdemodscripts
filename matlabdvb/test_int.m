
inbits = 0:9071;


b0 = inbits(0+1:6:end);
b1 = inbits(3+1:6:end);
b2 = inbits(1+1:6:end);
b3 = inbits(4+1:6:end);
b4 = inbits(2+1:6:end);
b5 = inbits(5+1:6:end);


for i=0:length(inbits)/6/126 - 1,
   
    b0_group = b0(i*126+1:i*126+126);
    b1_group = b1(i*126+1:i*126+126);
    b2_group = b2(i*126+1:i*126+126);
    b3_group = b3(i*126+1:i*126+126);    
    b4_group = b4(i*126+1:i*126+126);
    b5_group = b5(i*126+1:i*126+126);
    
    b0_group = circshift(b0_group, [0 0]);
    b1_group = circshift(b1_group, [0 -63]);
    b2_group = circshift(b2_group, [0 -105]);
	b3_group = circshift(b3_group, [0 -42]);
	b4_group = circshift(b4_group, [0 -21]);
    b5_group = circshift(b5_group, [0 -84]);
                    
    a0(i*126+1:i*126+126) = b0_group;
    a1(i*126+1:i*126+126) = b1_group;
    a2(i*126+1:i*126+126) = b2_group;
	a3(i*126+1:i*126+126) = b3_group;
	a4(i*126+1:i*126+126) = b4_group;
	a5(i*126+1:i*126+126) = b5_group;
                
end


