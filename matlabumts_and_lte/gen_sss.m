function d = gen_pss(nid, subframe )

    d = zeros(1,62);
    
    nid1 = floor(nid/3);
    nid2 = mod(nid,3);
    
    qp = floor(nid1/30);
    q = floor((nid1+qp*(qp+1)/2)/30);
    mp = nid1+q*(q+1)/2;
    
    m0 = mod(mp,31);
    m1 = mod((m0+floor(mp/31)+1),31);
    
    xs = zeros(1,31);
    xs(4+1) = 1;
    
    for i=0:25,
        xs(i+5+1) = mod(xs(i+2+1)+xs(i+1),2);
    end
    s = 1-2*xs;
    
    s0_m0 = circshift(s', -m0)';
    s1_m1 = circshift(s', -m1)';
    
    xc = zeros(1,31);
    xc(4+1) = 1;
    for i=0:25,
       xc(i+5+1) = mod(xc(i+3+1) + xc(i+1),2);
    end
    c = 1-2*xc;
    
    c0 = circshift(c', -nid2)';
    c1 = circshift(c', -(nid2+3))';
    
    xz = zeros(1,31);
    xz(4+1) = 1;
    for i=0:25,
        xz(i+5+1) = mod(xz(i+4+1)+xz(i+2+1) + xz(i+1+1) + xz(i+1), 2);
    end
    z = 1-2*xz;
    

        
    z1_m0 = circshift(z', -mod(m0,8))';
    z1_m1 = circshift(z', -mod(m1,8))';
    
    if (subframe == 0)
        d(1:2:61) = s0_m0 .* c0;
        d(2:2:62) = s1_m1 .* c1 .* z1_m0;
    else
        d(1:2:61) = s1_m1 .* c0;
        d(2:2:62) = s0_m0 .* c1 .* z1_m1;
    end
 
    
    
    
end

