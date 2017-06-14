function codeblock_sizes = lte_compute_codeblocksize(tbsize)

    %follow the nomenclature in TS 36.212 5.1.2
    
        
     Ks = [40 48 56 64 72 80 88 96 104 112 120 128 136 144 152 160 168 ...
        176 184 192 200 208 216 224 232 240 248 256 264 272 280 288 ... 
        296 304 312 320 328 336 344 352 360 368 376 384 392 400 408 ...
        416 424 432 440 448 456 464 472 480 488 496 504 512 528 544 ...
        560 576 592 608 624 640 656 672 688 704 720 736 752 768 784 ...
        800 816 832 848 864 880 896 912 928 944 960 976 992 1008 1024 ...
        1056 1088 1120 1152 1184 1216 1248 1280 1312 1344 1376 1408 ...
        1440 1472 1504 1536 1568 1600 1632 1664 1696 1728 1760 1792 ...
        1824 1856 1888 1920 1952 1984 2016 2048 2112 2176 2240 2304 ...
        2368 2432 2496 2560 2624 2688 2752 2816 2880 2944 3008 3072 ...
        3136 3200 3264 3328 3392 3456 3520 3584 3648 3712 3776 3840 ...
        3904 3968 4032 4096 4160 4224 4288 4352 4416 4480 4544 4608 ...
        4672 4736 4800 4864 4928 4992 5056 5120 5184 5248 5312 5376 ...
        5440 5504 5568 5632 5696 5760 5824 5888 5952 6016 6080 6144 ];


%compute the number of codewords, C
    Z=6144;
    B = tbsize + 24;

    
    if (B<=Z)
        L=0;
        C=1;
        Bprime = B;
    else
        L=24;
        C=ceil(B/(Z-L));
        Bprime = B + C*L;
    end

    codeblock_sizes = zeros(1,C);
    
    minidx = find(C*Ks >= Bprime, 1, 'first');
    Kplus = Ks(minidx);

    if (C == 1)
        Cplus = 1;
        Kminus = 0;
        Cminus = 0;
    else
        Kminus = Ks(minidx - 1);
        deltaK = Kplus - Kminus;
        Cminus = floor((C*Kplus - Bprime)/deltaK);
        Cplus = C - Cminus;
    end 
    
    F = Cplus * Kplus + Cminus * Kminus - Bprime;
%     
    %trap this for when it occurs
    assert (F==0);
    
    if (Cminus > 0)
        codeblock_sizes(1:Cminus) = Kminus;
    end
    codeblock_sizes(1+Cminus:1+Cminus+Cplus-1) = Kplus;

end

