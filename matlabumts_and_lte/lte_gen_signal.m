NMAXRB = 110;
FFTSIZEMAX = 2048;
LTE_CLOCK = 30.72e6;

%physical config
NDLRB = 25;
%compute closest FFTSIZE to NDLRB
%FFTSIZE = FFTSIZEMAX / floor(NMAXRB/NDLRB);
FFTSIZE=1024;


NRE_PER_RB = 12;
NSUBCARRIERS = NMAXRB*NRE_PER_RB;

PHICH_DURATION= 0;
PHICH_RESOURCE = 1/2;

NCELLID = 298;
NID2 = mod(NCELLID,3);
NID1 = floor(NCELLID/3);
NCELLID_Us = [25 29 34];
NCELLID_U = NCELLID_Us(NID2+1);
NUM_TX_ANTENNAS = 1;
NCP = 1;
SUBFRAMES_PER_FRAME = 10;
FRAMES_PER_SEC = 100;
SLOTS_PER_SUBFRAME = 2;


if (NCP)
    PBCH_CODED_BITS = 1920;
else
    PBCH_CODED_BITS = 1728;
end

if (NDLRB <= 10)
    PDCCH_NSYMS_LIST = [2 3 4]
else
    PDCCH_NSYMS_LIST = [1 2 3];
end

LTE_CFI = [[0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1]; ...
           [1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0]; ...
           [1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1]];

PCFICH_KINDICES = lte_pcfich_kindices(NDLRB,NCELLID);

%signal config
NFRAMES = 1024;
FILENAME = 'C:\\temp\\testlte2.usrp.900.5MHz';
FILEFORMAT = 'short';

NSYMS_SLOT = 6 + (NCP ~= 0) ;

FFT_FACTOR = FFTSIZE/FFTSIZEMAX;
%open file for append
f=fopen(FILENAME, 'w+'); 

BASE_SCALE=65536; %1/4 range

PSS_SCALE= 1.0 * BASE_SCALE;
SSS_SCALE= PSS_SCALE;

REF_SCALE= 2.0 * BASE_SCALE;

PBCH_SCALE = REF_SCALE/sqrt(4);
PCFICH_SCALE = REF_SCALE/sqrt(4);
PDCCH_SCALE = REF_SCALE/sqrt(4);
SIB_SCALE = REF_SCALE/sqrt(4);

%SIB setup

SI_WINDOWLENGTH = 10;

SIBS = [];

SIB_NUMCCE = 4;

sib3.type = 3;
sib3.periodicity = 8;
sib3.N = 1;
sib3.preferredNumRBs=17;
sib3.nextRV = 0;
sib3.contents = [0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 ...
                 1 0 1 0 1 1 0 1 1 1 1 1 1 0 1 1 0 0 1 0 1 0 0 0 1 1 0 ...
                 0 0 0 0 0 0 0 1 0 1 0 1 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 ... 
                 1 1 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 ... 
                 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 ...
                 1 0 1 1 1 1 1 1 0 0 1 1 1 0 1 0 1 0 1 0 1 0 1 1 1 1 0 ...
                 0 1 0 1 0 1 1 1 1 0 1 1 1 0 0 1 0 0 0 0 0 0 0 0 0 0 1 ...
                 1 1 0 0 0 0 1 0 0 0 1 0 0 1 0 0 1 0 0 0 0 0 1 0 1 0 1 ...
                 0 1 1 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 1 0 1 0 0 0 0 ...
                 0 0 0 1 0 0 1 0 1 1 0 0 0];

SIBS = [SIBS sib3];

SIB1_contents = [0 1 0 0 0 0 0 0 0 1 ... 
                0 1 0 1 0 0 0 0 0 1 0 1 ... %MCC 3 digits
                0 1 0 0 0 1 0 0 1 ...  %MNC 1-bit + 2 digits
                 1 0 0 1 1 0 0 0 0 0 0 0 0 1 1 0 0 1 0 0 0 0 0 0 ...
                1 0 1 1 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 1 0 0 0 0 0 1 ...
                0 1 0 ...
                0 0 0 1 1 1 ... % freq band indicator 1...64
                0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 ...
                1 1 0 1 0 0 1 ];
            
SIB1_preferredNumRBs=3;
SIB1_nextRV = 0;


SI_RNTI = 65535;

outbuf = zeros(1,30.72e6 * FFT_FACTOR * 1 /100 * NFRAMES);
%outbuf = [];

for frame=0:NFRAMES-1,

    for subframe = 0:(SUBFRAMES_PER_FRAME-1),
        subframe_samples = zeros(1,LTE_CLOCK/FRAMES_PER_SEC/SUBFRAMES_PER_FRAME*FFT_FACTOR);
        slot0_kv = zeros(NSYMS_SLOT,NMAXRB*NRE_PER_RB);
        slot1_kv = zeros(NSYMS_SLOT,NMAXRB*NRE_PER_RB); 
        
        %ref signals (single antenna)
          slot0_kv = lte_refsig_to_kvector_insert(slot0_kv,REF_SCALE,NDLRB, NCELLID, 0, 2*subframe+0, NCP, 0);
          slot0_kv = lte_refsig_to_kvector_insert(slot0_kv,REF_SCALE,NDLRB, NCELLID, 4, 2*subframe+0, NCP, 0);        
% 
          slot1_kv = lte_refsig_to_kvector_insert(slot1_kv,REF_SCALE,NDLRB, NCELLID, 0, 2*subframe+1, NCP, 0);
          slot1_kv = lte_refsig_to_kvector_insert(slot1_kv,REF_SCALE,NDLRB, NCELLID, 4, 2*subframe+1, NCP, 0);   
        
        %sync signals (no clash with ref signals)
        if (subframe == 0 || subframe == 5)
            %insert PSS
            pss = gen_pss(NCELLID_U) * PSS_SCALE;
            pss_len = length(pss);

            slot0_kv(NSYMS_SLOT,NSUBCARRIERS/2-pss_len/2+1:NSUBCARRIERS/2+pss_len/2) = pss;
            
            %insert SSS
            sss = gen_sss(NCELLID,subframe) * SSS_SCALE;
            sss_len = length(sss);
            slot0_kv(NSYMS_SLOT-1,NSUBCARRIERS/2-sss_len/2+1:NSUBCARRIERS/2+sss_len/2) = sss;            

        end
        
        if (subframe == 0)
            %PBCH (%no clash with sync signals or ref signals)

            pbch = lte_pbch_encode(floor(frame/4), NDLRB, PHICH_DURATION, PHICH_RESOURCE);

            [d0 d1 d2] = lte_tailbite_enc(pbch);

            v0 = lte_conv_int(d0);
            v1 = lte_conv_int(d1);
            v2 = lte_conv_int(d2);

            e = lte_conv_ratematch([v0 v1 v2], PBCH_CODED_BITS);
            
            e_sc = mod(e+lte_pbch_seq(NCELLID, NCP), 2);

            esyms = PBCH_SCALE * lte_mod_qpsk(e_sc);

            frame_mod_4 = mod(frame, 4);
            pbch_coded_syms_div_4 = PBCH_CODED_BITS/4/2;

            slot1_kv = lte_pbch_insert_notxd(slot1_kv, esyms(frame_mod_4*pbch_coded_syms_div_4+1:(frame_mod_4+1)*pbch_coded_syms_div_4), NCELLID, NCP);

        end
        
        pdcch_syms = 0;
        
        TX_SIB_rv = -1; %disable by default
        
        if (mod(frame, 2) == 0 && subframe == 5) %SIB1
            
            %queue for TX
            TX_SIB_contents = SIB1_contents;
            TX_SIB_rv = SIB1_nextRV;
            TX_SIB_preferredNumRBs = SIB1_preferredNumRBs;
          
            %advance the RV
            SIB1_nextRV = lte_get_next_rv(SIB1_nextRV);
            
        else
            % normal SIB
            for (sibidx = 1:length(SIBS))
            
                sib = SIBS(sibidx);
                x = (sib.N - 1) * SI_WINDOWLENGTH;
                y = (sib.N ) * SI_WINDOWLENGTH; 

                %system frame number is 10-bits (1024), max periodicity is
                %512 => no need for complex modulo arithmetic
                if ((mod(x,10) <= subframe && mod(frame,sib.periodicity) == floor(x/10)) ... %base case
                    || (mod(y,10) > subframe && mod(frame,sib.periodicity) == floor(y/10)) ...
                    || ( mod(frame,sib.periodicity) > floor(x/10) && mod(frame,sib.periodicity) < floor(y/10)))
                        
                    fprintf(1,'frame %d subframe %d is mapping sib %d\n', frame,subframe,sib.type);
                    %flag it for transmission
                    TX_SIB_contents = sib.contents;
                    TX_SIB_rv = sib.nextRV;
                    TX_SIB_preferredNumRBs = sib.preferredNumRBs;
                     %update the SIB
                    sib.nextRV = lte_get_next_rv(sib.nextRV);

                end
                SIBS(sibidx) = sib;                
            end
        end
        
        if (TX_SIB_rv >= 0) % is there a SIB to TX?
            
            %create PCFICH
            pdcch_syms = 1;
            cfi_idx = find (PDCCH_NSYMS_LIST == pdcch_syms);
            cfi = LTE_CFI(cfi_idx,:);
            cfi_scrambled = mod(cfi + lte_pcfich_seq(NCELLID, subframe * 2), 2);
            cfi_syms = PCFICH_SCALE*lte_mod_qpsk(cfi_scrambled);
            %insert into RBs.
            slot0_kv = lte_insert_regs(slot0_kv, cfi_syms, NDLRB, PCFICH_KINDICES, NCELLID, NCP, NUM_TX_ANTENNAS);

            %compute MCS and n1aprb for SIB - these index the
            %transport block size
            desiredtbsize = floor((length(TX_SIB_contents)+7)/8)*8; %round to next 8
            [TX_SIB_mcs TX_SIB_n1aprb TX_SIB_actualtbsize] = lte_get_mcs_from_TB_size(desiredtbsize,1,1);
            
            %create DCI-1A for the SIB1
            startRB = 0;
            
            TX_sib_dci = lte_create_dci1a_ccch(NDLRB,startRB,TX_SIB_preferredNumRBs, SI_RNTI, TX_SIB_mcs, 0, TX_SIB_rv, TX_SIB_n1aprb, 0);
            TX_sib_coded = lte_encode_dci(TX_sib_dci, SIB_NUMCCE);

            
            %compute the REGs for PDCCH (need to work out PHICH first)
            phich_kindices = lte_phich_indices(NDLRB,NCELLID,PCFICH_KINDICES,NCP,NUM_TX_ANTENNAS,PHICH_RESOURCE,PHICH_DURATION,pdcch_syms);
            pdcch_kindices = lte_pdcch_kindices(NDLRB,NCELLID,PCFICH_KINDICES,phich_kindices,NCP,NUM_TX_ANTENNAS,PHICH_DURATION,pdcch_syms);
            
            pdcch_total_length = length(pdcch_kindices) * 4 * 2;
            % map the sib1coded PDCCH into the first CCEs only
            pdcch_combined_dcis = [TX_sib_coded NaN(1,pdcch_total_length-length(TX_sib_coded))];
            pdcch_combined_dcis_scrambled = mod(pdcch_combined_dcis + lte_pdcch_seq(NCELLID,subframe*2,pdcch_total_length/8),2);
            pdcch_combined_dcis_scrambled_syms = PDCCH_SCALE * lte_mod_qpsk(pdcch_combined_dcis_scrambled);
            %then the whole block of symbols gets interleaved
            pdcch_combined_dcis_scrambled_syms_int = lte_pdcch_int(pdcch_combined_dcis_scrambled_syms, NCELLID);
            %insert into the grid
            
            slot0_kv = lte_insert_regs(slot0_kv, pdcch_combined_dcis_scrambled_syms_int, NDLRB, pdcch_kindices, NCELLID, NCP, NUM_TX_ANTENNAS);
            
            %and the data itself
            
            %align to actual tb size with 0s (36.331 section 8.5 padding)
            TX_SIB_contents = [TX_SIB_contents zeros(1,TX_SIB_actualtbsize - length(TX_SIB_contents))];
            %attach CRC
            crcpoly24A = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1];
            crc = lte_crc(TX_SIB_contents,crcpoly24A);
            TB_with_crc = [TX_SIB_contents crc];
            % dont need to worry about code block segmentation, because SI
            % max size ~2000 is well below codeblock max size (6144)
            D = length(TB_with_crc);
            turbo_coded_bits = lte_turbo_encode(TB_with_crc, D);
            
            %now need to know how much we can ratematch it to - dependent
            %on pdcch_syms
            avail_symbols = lte_calc_prbs_avail_symbols(NDLRB,[startRB:startRB+TX_SIB_preferredNumRBs-1],NCELLID,subframe*2,NCP,NUM_TX_ANTENNAS,pdcch_syms);
            E = avail_symbols * 2; %QPSK
            %rate match, set the buffer size to something huge since it
            %won't be an issue for SI messages
            ratedmatched_bits = lte_turbo_ratematch(turbo_coded_bits, 10e6,E,TX_SIB_rv);
            
            %scramble them
            scrambled_bits = mod(ratedmatched_bits+ lte_pdsch_seq(SI_RNTI,0,NCELLID,subframe*2,length(ratedmatched_bits)),2);
            %modulate them
            modulated_syms = SIB_SCALE*lte_mod_qpsk(scrambled_bits);
            %insert the PRBs
            
           	[slot0_kv slot1_kv] = lte_insert_prbs(slot0_kv,slot1_kv,1,modulated_syms,NDLRB,[startRB:startRB+TX_SIB_preferredNumRBs-1], ...
                NCELLID, subframe*2,NCP,NUM_TX_ANTENNAS,pdcch_syms);
        end
        
        %TEMP - resource nullification - nullify bottom and top 4 RBs.
        %gives 7.56 MHz, hopefully enough to reduce distortion
        
%         slot0_kv(:,361:360+48) = 0;
%         slot0_kv(:,961:960+48) = 0;
        
%         slot1_kv(:,361:360+48) = 0;
%         slot1_kv(:,961:960+48) = 0;
        
        slot0_samples_cplx = lte_kvectors_to_slot(FFTSIZE,slot0_kv, NCP);
        slot1_samples_cplx = lte_kvectors_to_slot(FFTSIZE,slot1_kv, NCP);
        
        slot0_samples = zeros(1,2*length(slot0_samples_cplx));
        slot0_samples(1:2:end) = real(slot0_samples_cplx);
        slot0_samples(2:2:end) = imag(slot0_samples_cplx);
        
        slot1_samples = zeros(1,2*length(slot1_samples_cplx));
        slot1_samples(1:2:end) = real(slot1_samples_cplx);
        slot1_samples(2:2:end) = imag(slot1_samples_cplx);
        
        %outbuf = [outbuf slot0_samples_cplx slot1_samples_cplx];
         
        subframelen = 30.72e6 * FFT_FACTOR * 1/1000;
        sampleoffset = frame * 10 * subframelen + subframe * subframelen;
        
        outbuf(1+sampleoffset:subframelen+sampleoffset) = [slot0_samples_cplx slot1_samples_cplx];

        
%         fwrite(f,slot0_samples,'short');
%         fwrite(f,slot1_samples,'short');
    end %subframe
end %frame

fsnative = 15.36e6
t = 0:1/fsnative:length(outbuf)/fsnative-1/fsnative;
%outbuf = outbuf .* exp(2*pi*j*1e6.*t); %upshift 1MHz
resamplebuf = resample(outbuf, 25,48,100);
clear outbuf;
writebuf = zeros(1,2*length(resamplebuf));
writebuf(1:2:end) = real(resamplebuf);
writebuf(2:2:end) = imag(resamplebuf);
clear resamplebuf;
fwrite(f,writebuf,'short');



fclose(f);
