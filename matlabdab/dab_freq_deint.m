function q= dab_freq_deint(y)

    PI(1)=0;
    for i=1:2047,
        PI(i+1)=mod(13*PI(i)+511,2048);
    end
    j=1;
    for i=1:2048,
        if (PI(i) >= 256 && PI(i) <= 1792 && PI(i) ~= 1024)
            A(j) = PI(i)-1024;
            if (A(j)<0)
                A(j)=A(j)+2049;
            else
                A(j)=A(j)+1;
            end
            j = j+1;
        end
    end
    
    for i=1:1536,
        q(:,i)=y(:,A(i));
    end
    
end