function [subchbindata biterr]=dab_viterbi_eep(subchsyms, option, protlevel)

    %puncpat

    puncpat(1,:)=[1 1 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 0 0 0];
    puncpat(2,:)=[1 1 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 0 0 0  1 0 0 0];
    puncpat(3,:)=[1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 0 0 0  1 0 0 0];
    puncpat(4,:)=[1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0];
    puncpat(5,:)=[1 1 0 0  1 1 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0];
    puncpat(6,:)=[1 1 0 0  1 1 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 0 0 0];
    puncpat(7,:)=[1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 0 0 0];
    puncpat(8,:)=[1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0];
    puncpat(9,:)=[1 1 1 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0];
    puncpat(10,:)=[1 1 1 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 0 0  1 1 0 0];
    puncpat(11,:)=[1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 0 0  1 1 0 0];
    puncpat(12,:)=[1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0];
    puncpat(13,:)=[1 1 1 0  1 1 1 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0];
    puncpat(14,:)=[1 1 1 0  1 1 1 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 0 0];
    puncpat(15,:)=[1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 0 0];
    puncpat(16,:)=[1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0];
    puncpat(17,:)=[1 1 1 1  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0];
    puncpat(18,:)=[1 1 1 1  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 0  1 1 1 0];
    puncpat(19,:)=[1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 0  1 1 1 0];
    puncpat(20,:)=[1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0];
    puncpat(21,:)=[1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0];
    puncpat(22,:)=[1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 0];
    puncpat(23,:)=[1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 0];
    puncpat(24,:)=[1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1];
    puncpattail = [1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0 ];

    [nframes symspersubch] = size(subchsyms);
    nCUs=symspersubch/64;
    rates = [1/4 3/8 1/2 3/4; 4/9 4/7 2/3 4/5];
    
    rate = rates(option+1,protlevel+1);
    codedrate=nCUs*64/.024;
    decodedrate=codedrate*rate;

    %compute rate/protection level specific parameters
    if (option == 1)
        n=decodedrate/32000; %multiples of 32kbit
        I=768*n; %unpunctured vector size
        L1=24*n-3; L2=3;
        switch (protlevel+1)
            case 4
                PI1=2; PI2=1;
            case 3
                PI1=4; PI2=3;
            case 2
                PI1=6; PI2=5;
            case 1
                PI1=10; PI2=9;
            otherwise
                ;
        end
    else
        n=decodedrate/8000; %multiples of 8kbit
        I=192*n; %unpunc vector size;
        switch (protlevel+1)
            case 4
                L1=4*n-3; L2= 2*n+3;
                PI1=3; PI2=2;
            case 3
                L1=6*n-3; L2=3;
                PI1=8; PI2=7;
            case 2
                if (n ==0)
                    L1 = 5; L2 = 1;
                    PI1=12; PI2 = 12;
                else
                    L1 = 2*n -3; L2 = 4*n+3;
                    PI1=14; PI2=13;
                end
            case 1
                L1=6*n-3; L2=3;
                PI1=24; PI2=23;
            otherwise
                ;
        end        
    end
    
    if (n-floor(n) ~= 0)
        subchbindata = [];
        fprintf(1,'Input data size not suitable for this coding scheme\n');
        return;
    end
    %produce puncturing matrix
    puncvec = [];
    for i=1:L1,
        for j=1:4,
            puncvec = [puncvec  puncpat(PI1,:)];
        end
    end
    for i=L1+1:L1+L2,
        for j=1:4,
            puncvec = [puncvec  puncpat(PI2,:)];
        end
    end
    %tail bit protection
    puncvec = [puncvec puncpattail];
    % number of ones in the puncvec should be the number of input symbols..
    assert(sum(puncvec) == symspersubch);
    %decode
    trellis=poly2trellis([7], [133, 171,145,133]);
    for i=1:nframes,
        decodedword=vitdec(subchsyms(i,:),trellis,10*7, 'term', 'unquant', puncvec); 
        subchbindata(i,:)=decodedword(1:length(decodedword)-6);  
        %below - to estimate BER
        encodedword=convenc(decodedword, trellis,puncvec);
        harddecisionword=(subchsyms(i,:) <0);
        biterr(i) = sum(abs(encodedword-harddecisionword));
    end
     fprintf('encrate=%d decrate=%d\n', codedrate, decodedrate);
     fprintf('n = %d, I=%d\n', n,I);
     fprintf(1,'L1=%d L2=%d Pi1=%d PI2=%d\n', L1,L2,PI1,PI2);
     fprintf(1,'rate=%f\n', rate);
     fprintf(1,'nCUs = %d\n', nCUs);
     fprintf(1,'length punvec=%d\n nones=%d effrate=%f\n', length(puncvec), sum(puncvec), I/sum(puncvec));
     fprintf(1, 'precoding estimated err rate = %f\n', sum(biterr) / (nframes *symspersubch));
end