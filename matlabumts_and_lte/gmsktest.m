raw = [randint(1,148,2) ones(1, 9)];

%raw = zeros(1,157);
%raw(2:2:end) = ones(1,78);

diffenc = zeros(1,length(raw));
diffenc(1) = raw(1); %pre-state are 11111s

for (i=2:length(raw))
    diffenc(i) = mod(raw(i-1)+raw(i),2);
end




modulated_from_diff(1) = 2*diffenc(1) - 1;

prevval = modulated_from_diff(1);
for (i=2:length(diffenc))
    if (diffenc(i) == 0)
        modulated_from_diff(i) = prevval * (0+j);
    else
        modulated_from_diff(i) = prevval * (0-j);
    end
    prevval = modulated_from_diff(i);
end


for (i=1:length(raw))
    modulated_from_raw(i) = 2*raw(i) - 1;
end

phase = 0;
for i=1:length(raw)
    gmsktable(i) = exp(j*phase);
    phase = phase + pi/2;
end

modulated_from_raw_out = modulated_from_raw .* gmsktable;


