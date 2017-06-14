function [syncsample estsnr] =dab_find_sync(samples, startsearch, framelen, nullsymlen, minsnrdb)
    N=framelen/2;
    alpha=1/N;
    startidx=startsearch+N;
    threshold=0;
    minsnr=10^(minsnrdb/10);
    %nlocalmin=0;
    %estimate of the sliding window average power
    averagepwr=sum(abs(samples(startsearch:startidx-1)).^2)/N;
    movingsum=sum(abs(samples(startidx-nullsymlen:startidx-1)).^2);
    for i=startidx:length(samples),
        %update the averagepwr
        averagepwr = (1-alpha)*averagepwr+alpha*abs(samples(i))^2;
        movingsum = movingsum + abs(samples(i))^2 - abs(samples(i-nullsymlen))^2;
        movingsumavg=movingsum/nullsymlen;
        if (threshold == 1)
            if (movingsumavg < minpwr)
                minpwr=movingsumavg;
                minidx=i;
                estsnr=averagepwr/minpwr;
            end
            if (movingsumavg >= (averagepwr/minsnr))
                threshold=0;
                %mins(nlocalmin+1)=minidx;
                %nlocalmin = nlocalmin+1;
                syncsample=minidx;
                return;
            end
        else %threshold == 0            
            if (movingsumavg < (averagepwr/minsnr))
                threshold=1;
                minpwr=movingsumavg;
                minidx=i;
            end
        end
    end
    if i == length(samples)
        syncsample=-1;
        estsnr=-100;
    end
end
