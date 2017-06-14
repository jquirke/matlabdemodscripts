%input = [5xN] matrix of 5 consecutive logical frames forming the audio
%superframe
function [rs_corrected rs_errorcount] = dabplus_rs_correct(input)

    [nlogframes bitsframe] = size(input);
    assert (nlogframes == 5);
    
    %collapse it into a 1x5*nbitsframe vector
    inputvector = reshape(transpose(input), 1, nlogframes*bitsframe);
    %convert it to 8-bit symbols in rows of 120byte packets
    ntotalbytes=length(inputvector)/8;
    ntotalpackets=ntotalbytes/120;
    assert (mod(length(inputvector), 120*8) == 0);

    rsgrid = zeros(ntotalpackets,120);
    for i=1:120, % for each column
        for j=1:ntotalpackets,
            colstart = i-1;
            byteoffset= j-1;
            rsgrid(j,i) = dab_binval(inputvector((colstart*ntotalpackets*8+byteoffset*8+1):(colstart*ntotalpackets*8+byteoffset*8+8)));
        end
    end    
    
    rs_gf_poly = dab_binval([1 0 0 0 1 1 1 0 1]) ;
    rs_dabplus_poly = rsgenpoly(255,245,rs_gf_poly, 0); %PROD(i=0..9)(x+-alpha^i)
    rsgrid_gf = gf(rsgrid, 8, rs_gf_poly);
    [rs_corrected_gf rs_errorcount] = rsdec(rsgrid_gf, 120,110,rs_dabplus_poly);
    
    %convert the galois field elements back to integers 
    rs_corrected_grid = rs_corrected_gf.x;
    %& de-interleave the corrected bytes back to the correct order 
    rs_corrected_bytes = zeros(1,ntotalpackets*110);
    for i=1:110,
        for j=1:ntotalpackets
            offset = (i-1) * ntotalpackets + (j-1) + 1;
            rs_corrected_bytes(offset)=rs_corrected_grid(j,i);
        end
    end
    fprintf(1,'Reed-Solomon errors: {'); for i=1:ntotalpackets, fprintf(1,'%d ', rs_errorcount(i));end; fprintf(1,'}\n');
    rs_corrected = rs_corrected_bytes;
    
end