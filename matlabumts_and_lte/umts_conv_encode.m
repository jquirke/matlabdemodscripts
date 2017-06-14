function coded_out = umts_conv_encode( data_in )
%test function to test the vitdec works

    %8 tail bits with binary value 0 shall be added to the end of the code
    %block before encoding. 
    
    %data_in = [data_in zeros(1,8)];
    
    %The initial value of the shift register of the coder shall be "all 0"
    %when starting to encode the input bits. 
    shift_reg = zeros(1,8);
    
    for i=1:length(data_in)
        input = data_in(i);
        
        output_0 = mod(input + shift_reg(2) + shift_reg(3) + shift_reg(4) + shift_reg(8),2);
        output_1 = mod(input + shift_reg(1) + shift_reg(2) + shift_reg(3) + shift_reg(5) + shift_reg(7) +shift_reg(8), 2);
        
        coded_out(2*(i-1)+1) = output_0;
        coded_out(2*(i-1)+2) = output_1;  
        
        shift_reg(2:8) = shift_reg(1:7);
        shift_reg(1) = input;
    end
    
    
end
