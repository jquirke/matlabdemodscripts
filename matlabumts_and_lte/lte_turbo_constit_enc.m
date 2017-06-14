function [output term_systematic term_coded] = lte_turbo_constit_enc( input)
%instance of LTE constitutent coder

    reg = zeros(1,3);
    output = zeros(1,length(input));
    for (i=1:length(input))
        nextbit = mod(reg(3)+reg(2)+input(i),2);
        output(i) = mod(reg(3) + reg(1)  + nextbit,2);
        reg([2:3]) = reg([1:2]);
        reg(1) = nextbit;
    end
    
    term_systematic = [0 0 0];
    term_coded = [ 0 0 0];
    %trellis termination
    for (i=1:3)
        %the double add in the figure 5.1.3-2 essentially cancels the input
        %with the switch in the lower position
        
        term_systematic(i) = mod(reg(3) + reg(2), 2); %xk
        term_coded(i) = mod(reg(3) + reg(1), 2); %zk
        reg([2:3]) = reg([1:2]);
        reg(1) = 0;
    end
end

