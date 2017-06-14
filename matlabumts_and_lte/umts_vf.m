clear all;
fprintf(1,'Loading samples...\n');
%telstra-umts5-4436-MG.usrp
%vodafone-4363-CH-0706.usrp PSC=2
f=fopen('C:\\temp\\voda-4363-CH2.usrp', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(2:2:end)+v(1:2:end)*j; fclose(f);
clear v;
%f=fopen('C:\temp\dab_mode1_basicrx_2msps.trunc.cf', 'rb'); v=fread(f, inf, 'int'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);


fs = 4e6;
cv_usrp = cv_usrp';
%cv_usrp = cv_usrp(1:fs);
%plot ([1:length(cv_usrp)]/fs, abs(cv_usrp))

t = 0:1/fs:length(cv_usrp)/fs-1/fs;

cv_usrp = cv_usrp .* exp(j*2*pi*(-4910)*t);

cv_usrp = resample(cv_usrp, 24,25);


N_corr_samples=length(cv_usrp)-38399;
%N_corr_samples = 38400*20;

%PSC

a = [1, 1, 1, 1, 1, 1, -1, -1, 1, -1, 1, -1, 1, -1, -1, 1 ];
Cpsc = (1+j) * [ a, a, a, -a, -a, a, -a, -a, a, a, a, -a, a, -a, a, a ];

%SSC 

b=[a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8), -a(9), -a(10), -a(11), -a(12), -a(13), -a(14), -a(15),  -a(16) ];

z =  [b, b, b, -b, b, b, -b, -b, b, -b, b, -b, -b, -b, -b, -b];

H = cell(1,9);

%compute the hadamard matrix
H(1) = {[1]};
for k=2:9
    H(k) = {[cell2mat(H(k-1)) cell2mat(H(k-1)) ; cell2mat(H(k-1)) -cell2mat(H(k-1))]};
end

Hs = cell2mat(H(9));

%Hm = Hs(1+0:16:256,:); %every 16th row starting from 1st row

for i=1:16,
    Cssc(i,:) = (1+j) * Hs(1+(i-1)*16,:) .* z;
end

fprintf(1,'Correlating PSC...\n');
%attempt to correlate PSC
corr = zeros(1,N_corr_samples);
corr_diff = zeros(1,N_corr_samples*2);

% for (i=1:N_corr_samples)
%     corr(i) = sum( conj(Cpsc(1:256)) .* cv_usrp(i:i+255) ) ;
%     %+ abs(sum( conj(Cpsc(129:256)) .* cv_usrp(38400+i+128:38400+i+255) )).^2 ;
%     %corr_diff(i) = ...
%      %     abs(sum( conj(Cpsc(1:64)) .* cv_usrp(38400+i:38400+i+63) )).^2 ;%s...
%        % + abs(sum( conj(Cpsc(65:128)) .* cv_usrp(38400+i+64:38400+i+127) )).^2 ...
%        % + abs(sum( conj(Cpsc(129:192)) .* cv_usrp(38400+i+128:38400+i+191) )).^2 ...
%        % + abs(sum( conj(Cpsc(193:256)) .* cv_usrp(38400+i+192:38400+i+255) )).^2;
% end
% figure(1)
% plot([1:N_corr_samples], abs(corr).^2)




%slot_sample = 14129; %adj%
slot_sample = 65150;

%attempt to correlate SSC

scorr = zeros(1,15);

ssc_seq = [
    [1,1,2,8,9,10,15,8,10,16,2,7,15,7,16]        
[1,1,5,16,7,3,14,16,3,10,5,12,14,12,10]      
[1,2,1,15,5,5,12,16,6,11,2,16,11,15,12]      
[1,2,3,1,8,6,5,2,5,8,4,4,6,3,7]              
[1,2,16,6,6,11,15,5,12,1,15,12,16,11,2]      
[1,3,4,7,4,1,5,5,3,6,2,8,7,6,8]              
[1,4,11,3,4,10,9,2,11,2,10,12,12,9,3]        
[1,5,6,6,14,9,10,2,13,9,2,5,14,1,13]         
[1,6,10,10,4,11,7,13,16,11,13,6,4,1,16]      
[1,6,13,2,14,2,6,5,5,13,10,9,1,14,10]        
[1,7,8,5,7,2,4,3,8,3,2,6,6,4,5]              
[1,7,10,9,16,7,9,15,1,8,16,8,15,2,2]         
[1,8,12,9,9,4,13,16,5,1,13,5,12,4,8]         
[1,8,14,10,14,1,15,15,8,5,11,4,10,5,4]       
[1,9,2,15,15,16,10,7,8,1,10,8,2,16,9]        
[1,9,15,6,16,2,13,14,10,11,7,4,5,12,3]       
[1,10,9,11,15,7,6,4,16,5,2,12,13,3,14]       
[1,11,14,4,13,2,9,10,12,16,8,5,3,15,6]       
[1,12,12,13,14,7,2,8,14,2,1,13,11,8,11]      
[1,12,15,5,4,14,3,16,7,8,6,2,10,11,13]       
[1,15,4,3,7,6,10,13,12,5,14,16,8,2,11]       
[1,16,3,12,11,9,13,5,8,2,14,7,4,10,15]       
[2,2,5,10,16,11,3,10,11,8,5,13,3,13,8]       
[2,2,12,3,15,5,8,3,5,14,12,9,8,9,14]         
[2,3,6,16,12,16,3,13,13,6,7,9,2,12,7]        
[2,3,8,2,9,15,14,3,14,9,5,5,15,8,12]         
[2,4,7,9,5,4,9,11,2,14,5,14,11,16,16]        
[2,4,13,12,12,7,15,10,5,2,15,5,13,7,4]       
[2,5,9,9,3,12,8,14,15,12,14,5,3,2,15]        
[2,5,11,7,2,11,9,4,16,7,16,9,14,14,4]        
[2,6,2,13,3,3,12,9,7,16,6,9,16,13,12]        
[2,6,9,7,7,16,13,3,12,2,13,12,9,16,6]        
[2,7,12,15,2,12,4,10,13,15,13,4,5,5,10]      
[2,7,14,16,5,9,2,9,16,11,11,5,7,4,14]        
[2,8,5,12,5,2,14,14,8,15,3,9,12,15,9]        
[2,9,13,4,2,13,8,11,6,4,6,8,15,15,11]        
[2,10,3,2,13,16,8,10,8,13,11,11,16,3,5]      
[2,11,15,3,11,6,14,10,15,10,6,7,7,14,3]      
[2,16,4,5,16,14,7,11,4,11,14,9,9,7,5]        
[3,3,4,6,11,12,13,6,12,14,4,5,13,5,14]       
[3,3,6,5,16,9,15,5,9,10,6,4,15,4,10]         
[3,4,5,14,4,6,12,13,5,13,6,11,11,12,14]      
[3,4,9,16,10,4,16,15,3,5,10,5,15,6,6]        
[3,4,16,10,5,10,4,9,9,16,15,6,3,5,15]        
[3,5,12,11,14,5,11,13,3,6,14,6,13,4,4]       
[3,6,4,10,6,5,9,15,4,15,5,16,16,9,10]        
[3,7,8,8,16,11,12,4,15,11,4,7,16,3,15]       
[3,7,16,11,4,15,3,15,11,12,12,4,7,8,16]      
[3,8,7,15,4,8,15,12,3,16,4,16,12,11,11]      
[3,8,15,4,16,4,8,7,7,15,12,11,3,16,12]       
[3,10,10,15,16,5,4,6,16,4,3,15,9,6,9]        
[3,13,11,5,4,12,4,11,6,6,5,3,14,13,12]       
[3,14,7,9,14,10,13,8,7,8,10,4,4,13,9]        
[5,5,8,14,16,13,6,14,13,7,8,15,6,15,7]       
[5,6,11,7,10,8,5,8,7,12,12,10,6,9,11]        
[5,6,13,8,13,5,7,7,6,16,14,15,8,16,15       ]
[5,7,9,10,7,11,6,12,9,12,11,8,8,6,10        ]
[5,9,6,8,10,9,8,12,5,11,10,11,12,7,7        ]
[5,10,10,12,8,11,9,7,8,9,5,12,6,7,6         ]
[5,10,12,6,5,12,8,9,7,6,7,8,11,11,9         ]
[5,13,15,15,14,8,6,7,16,8,7,13,14,5,16      ]
[9,10,13,10,11,15,15,9,16,12,14,13,16,14,11 ]
[9,11,12,15,12,9,13,13,11,14,10,16,15,14,16 ]
[9,12,10,15,13,14,9,14,15,11,11,13,12,16,10 ]
];

%for each block

for group = 1:64,
    seq = ssc_seq(group,:);
    for shift = 0:40 %try all 15 shifts
        test_slot = slot_sample + shift*2560;
        %sum over all the SSCs in the block
        scorr(group,shift+1) = 0;
        for slot=0:14
            scorr(group,shift+1) = scorr(group,shift+1)+ abs(sum((Cssc(seq(slot+1),1:256) .* conj(cv_usrp(test_slot+2560*slot:test_slot+255+2560*slot))))).^2;
        end
    end
end
   

%guess the primary scrambling code group

psc_group = find (max(scorr') == max(max(scorr')));
slot_offset = find (scorr(psc_group,:) == max(max(scorr')));


%antenna 0 CPICH pattern is 00.....
%antenna 1 CPICH pattern is 0011 1100 0011.... (even slot) 1100 0011. (odd)

%CPICH channelization code in both cases is C{256,0} which is 111....

%therefore, since ch code, is unity, the CPICH pattern is directly
%chipped by scrambling code

%00 modulates to QPSK (+1+1j, 11 modulates to QPSK (-1-1j)

seq1 = commsrc.pn('genpoly', [18 7 0]);
seq2 = commsrc.pn('genpoly', [18 10 7 5 0], 'InitialStates', ones(1,18));

% reg = zeros(1,18);
% reg(18) = 1;
% for i = 1:100,
%     jqout2(i) = reg(18);
%     bit = mod(reg(18)  + reg(13) + reg(11) + reg(8),2);
%     reg(2:18) = reg(1:17);
%     reg(1) = bit;
%     
% end

seq1.reset
seq2.reset

seq1.NumBitsOut = 2^18 - 1;
seq2.NumBitsOut = 2^18 - 1;

x = seq1.generate';
y = seq2.generate';

%n'th gold seq
n = 16*2;
%no need to do modulo operation as all the codes used will never wrap
xn_lower = x(1+n:38400+n);

zn_real = mod(xn_lower + y(1:38400), 2);

xn_upper = x(1+n+131072:38400+n+131072);

zn_imag = mod(xn_upper + y(1+131072:38400+131072),2);

Sn = (1-2*zn_real) + (1-2*zn_imag)*1i;

%N_corr_samples=length(cv_usrp)-38399;
scramb_corr = zeros(1,N_corr_samples);

fprintf(1,'Correlating CPICH...\n');


%  for (i=1:N_corr_samples)
%      scramb_corr(i) = sum( conj(Sn(1:2048) .* (1+1i)) .* cv_usrp(i:i+2047) );
%      if (mod(i,10*38400) == 1)
%          fprintf(1,'*');
%      end
%  end
%  
% 
%  
%  figure(2)
%  plot([1:N_corr_samples], abs(scramb_corr));
% 
% break  

% base=1;
% xalt = zeros(1,2^18-1);
% yalt = zeros(1,2^18-1);
% 
% xalt(base+0) = 1;
% xalt(base+1:base+17) = 0;
% 
% yalt(base+0:base+17) = 1;
% 
% for i=0:2^18-20
%     xalt(base+i+18) = mod(xalt(base+i+7) + xalt(base+i),2);
%     yalt(base+i+18) = mod(yalt(base+i+10) + yalt(base+i+7) + yalt(base+i+5) + yalt(base+i),2);
% end

%strong correlation at sample 55089

%descramle

%slot sync is at 16689       55089       93489      131889      170289

%slot_syncs = [16689       55089       93489      131889      170289
%208689      247089          285489];

%slot_syncs 
 slot_syncs =  [       31559       69959      108359      146759      185159 ...
      223559      261958      300358      338758      377158 ...
      415558      453957      492357      530757      569157 ...
      607557      645956      684356      722756      761156 ...
      799556      837955      876355      914755      953155 ...
      991555     1029954     1068354     1106754     1145154 ...
     1183554     1221953     1260353     1298753     1337153 ...
     1375553     1413952     1452352     1490752     1529152 ...
     1567552     1605951     1644351     1682751     1721151 ...
     1759551     1797950     1836350     1874750     1913150 ...
     1951550     1989949     2028349     2066749     2105149 ...
     2143549     2181948     2220348     2258748     2297148 ...
     2335548     2373947     2412347     2450747     2489147 ...
     2527547     2565946     2604346     2642746     2681146 ...
     2719546     2757945     2796345     2834745     2873145 ...
     2911545     2949944     2988344     3026744     3065144 ...
     3103544     3141943     3180343     3218743     3257143 ...
     3295543     3333942     3372342     3410742     3449142 ...
     3487542     3525942     3564341     3602741     3641141 ...
     3679541     3717941     3756340     3794740     3833140 ...
     3871540     3909940     3948339     3986739     4025139 ...
     4063539     4101939     4140338     4178738     4217138 ...
     4255538     4293938     4332337     4370737     4409137 ...
     4447537     4485937     4524336     4562736     4601136 ...
     4639536     4677936     4716335     4754735     4793135 ...
     4831535     4869935     4908334     4946734     4985134 ...
     5023534     5061934     5100333     5138733     5177133 ...
     5215533     5253933     5292332     5330732     5369132 ...
     5407532     5445932     5484331     5522731     5561131 ...
     5599531     5637931     5676330     5714730     5753130 ...
     5791530     5829930     5868329     5906729     5945129 ...
     5983529     6021929     6060328     6098728     6137128 ...
     6175528     6213928     6252327     6290727     6329127 ...
     6367527     6405927     6444326     6482726     6521126 ...
     6559526     6597926     6636325     6674725     6713125 ...
     6751525     6789925     6828324     6866724     6905124 ...
     6943524     6981924     7020323     7058723     7097123 ...
     7135523     7173923     7212322     7250722     7289122 ...
     7327522     7365922     7404322     7442721     7481121 ...
     7519521     7557921     7596321     7634720     7673120 ...
     7711520     7749920     7788320     7826719     7865119 ...
     7903519     7941919     7980319     8018718     8057118 ...
     8095518     8133918     8172318     8210717     8249117 ...
     8287517     8325917     8364317     8402716     8441116 ...
     8479516     8517916     8556316     8594715     8633115 ...
     8671515     8709915     8748315     8786714     8825114 ...
     8863514     8901914     8940314     8978713     9017113 ...
     9055513     9093913     9132313     9170712     9209112 ...
     9247512     9285912     9324312     9362711     9401111 ...
     9439511     9477911     9516311     9554710     9593110 ...
     9631510     9669910     9708310     9746709     9785109 ...
     9823509     9861909     9900309     9938708     9977108 ...
    10015508    10053908    10092308    10130707    10169107 ...
    10207507    10245907    10284307    10322706    10361106 ...
    10399506    10437906    10476306    10514705    10553105 ...
    10591505    10629905    10668305    10706704    10745104 ...
    10783504    10821904    10860304    10898703    10937103 ...
    10975503    11013903    11052303    11090702    11129102 ...
    11167502    11205902    11244302    11282701    11321101 ...
    11359501    11397901    11436301    11474700    11513100 ...
    11551500    11589900    11628300    11666700    11705099 ...
    11743499    11781899    11820299    11858699    11897098 ...
    11935498    11973898    12012298    12050698    12089097 ...
    12127497    12165897    12204297    12242697    12281096 ...
    12319496    12357896    12396296    12434696    12473095 ...
    12511495    12549895    12588295    12626695    12665094 ...
    12703494    12741894    12780294    12818694    12857093 ...
    12895493    12933893    12972293    13010693    13049092 ...
    13087492    13125892    13164292    13202692    13241091 ...
    13279491    13317891    13356291    13394691    13433090 ...
    13471490    13509890    13548290    13586690    13625089 ...
    13663489    13701889    13740289    13778689    13817088 ...
    13855488    13893888    13932288    13970688    14009087 ...
    14047487    14085887    14124287    14162687    14201086 ...
    14239486    14277886    14316286    14354686    14393085 ...
    14431485    14469885    14508285    14546685    14585084 ...
    14623484    14661884    14700284    14738684    14777083 ...
    14815483    14853883    14892283    14930683    14969083 ...
    15007482    15045882    15084282    15122682    15161081 ...
    15199481    15237881    15276281    15314681    15353081 ...
    15391480    15429880    15468280    15506680    15545080 ...
    15583479    15621879    15660279    15698679    15737079 ...
    15775478    15813878    15852278    15890678    15929078 ...
    15967477    16005877    16044277    16082677    16121077 ...
    16159476    16197876    16236276    16274676    16313076 ...
    16351475    16389875    16428275    16466675    16505075 ...
    16543474    16581874    16620274    16658674    16697074 ...
    16735473    16773873    16812273    16850673    16889073 ...
    16927472    16965872    17004272    17042672    17081072 ...
    17119471    17157871    17196271    17234671    17273071 ...
    17311470    17349870    17388270    17426670    17465070 ...
    17503469    17541869    17580269    17618669    17657069 ...
    17695468    17733868    17772268    17810668    17849068 ...
    17887467    17925867    17964267    18002667    18041067 ...
    18079466    18117866    18156266    18194666    18233066 ...
    18271465    18309865    18348265    18386665    18425065 ...
    18463464    18501864    18540264    18578664    18617064 ...
    18655463    18693863    18732263    18770663    18809063 ...
    18847462    18885862    18924262    18962662    19001062 ...
    19039461    19077861    19116261    19154661    19193061 ...
    19231461    19269860    19308260    19346660    19385060 ...
    19423460    19461859    19500259    19538659    19577059 ...
    19615459    19653858    19692258    19730658    19769058 ...
    19807458    19845857    19884257    19922657    19961057 ...
    19999457    20037856    20076256    20114656    20153056 ...
    20191456    20229855    20268255    20306655    20345055 ...
    20383455    20421854    20460254    20498654    20537054 ...
    20575454    20613853    20652253    20690653    20729053 ...
    20767453    20805852    20844252    20882652    20921052 ...
    20959452    20997851    21036251    21074651    21113051 ...
    21151451    21189850    21228250    21266650    21305050 ...
    21343450    21381849    21420249    21458649    21497049 ...
    21535449    21573848    21612248    21650648    21689048 ...
    21727448    21765847    21804247    21842647    21881047 ...
    21919447    21957846    21996246    22034646    22073046 ...
    22111446    22149845    22188245    22226645    22265045 ...
    22303445    22341844    22380244    22418644    22457044 ...
    22495444    22533843    22572243    22610643    22649043 ...
    22687443    22725842    22764242    22802642    22841042 ...
    22879442    22917841    22956241    22994641    23033041 ...
    23071441    23109841    23148240    23186640    23225040 ...
    23263440    23301840    23340239    23378639    23417039 ...
    23455439    23493839    23532238    23570638    23609038 ...
    23647438    23685838    23724237    23762637    23801037 ...
    23839437    23877837    23916236    23954636    23993036 ...
    24031436    24069836    24108235    24146635    24185035 ...
    24223435    24261835    24300234    24338634    24377034 ...
    24415434    24453834    24492233    24530633    24569033 ...
    24607433    24645833    24684232    24722632    24761032 ...
    24799432    24837832    24876231    24914631    24953031 ...
    24991431    25029831    25068230    25106630    25145030 ...
    25183430    25221830    25260229    25298629    25337029 ...
    25375429    25413829    25452228    25490628    25529028 ...
    25567428    25605828    25644227    25682627    25721027 ...
    25759427    25797827    25836226    25874626    25913026 ...
    25951426    25989826    26028225    26066625    26105025 ...
    26143425    26181825    26220224    26258624    26297024 ...
    26335424    26373824    26412223    26450623    26489023 ...
    26527423    26565823    26604222    26642622    26681022 ...
    26719422    26757822    26796221    26834621    26873021 ...
    26911421    26949821    26988220    27026620    27065020 ...
    27103420    27141820    27180219    27218619    27257019 ...
    27295419    27333819    27372218    27410618    27449018 ...
    27487418    27525818    27564217    27602617    27641017 ...
    27679417    27717817    27756216    27794616    27833016 ...
    27871416    27909816    27948215    27986615    28025015 ...
    28063415    28101815    28140214    28178614    28217014 ...
    28255414    28293814    28332213    28370613    28409013 ...
    28447413    28485813    28524212    28562612    28601012 ...
    28639412    28677812    28716211    28754611    28793011 ...
    28831411    28869811    28908210    28946610    28985010 ...
    29023410    29061810    29100210    29138609    29177009 ...
    29215409    29253809    29292209    29330608    29369008 ...
    29407408    29445808    29484208    29522607    29561007 ...
    29599407    29637807    29676207    29714606    29753006 ...
    29791406    29829806    29868206    29906605    29945005 ...
    29983405    30021805    30060205    30098604    30137004 ...
    30175404    30213804    30252204    30290603    30329003 ...
    30367403    30405803    30444203    30482602    30521002 ...
    30559402    30597802    30636202    30674601    30713001 ...
    30751401    30789801    30828201    30866600    30905000 ...
    30943400    30981800    31020200    31058599    31096999 ...
    31135399    31173799    31212199    31250598    31288998 ...
    31327398    31365798    31404198    31442597    31480997 ...
    31519397    31557797    31596197    31634596    31672996 ...
    31711396    31749796    31788196    31826595    31864995 ...
    31903395    31941795    31980195    32018594    32056994 ...
    32095394    32133794    32172194    32210593    32248993 ...
    32287393    32325793    32364193    32402592    32440992 ...
    32479392    32517792    32556192    32594592    32632991 ...
    32671391    32709791    32748191    32786591    32824990 ...
    32863390    32901790    32940190    32978590    33016989 ...
    33055389    33093789    33132189    33170589    33208988 ...
    33247388    33285788    33324188    33362588    33400987 ...
    33439387    33477787    33516187    33554587    33592986 ...
    33631386    33669786    33708186    33746586    33784985 ...
    33823385    33861785    33900185    33938585    33976984 ...
    34015384    34053784    34092184    34130584    34168983 ...
    34207383    34245783    34284183    34322583    34360982 ...
    34399382    34437782    34476182    34514582    34552981 ...
    34591381    34629781    34668181    34706581    34744980 ...
    34783380    34821780    34860180    34898580    34936979 ...
    34975379    35013779    35052179    35090579    35128978 ...
    35167378    35205778    35244178    35282578    35320977 ...
    35359377    35397777    35436177    35474577    35512976 ...
    35551376    35589776    35628176    35666576    35704976 ...
    35743375    35781775    35820175    35858575    35896974 ...
    35935374    35973774    36012174    36050574    36088974 ...
    36127373    36165773    36204173    36242573    36280973 ...
    36319372    36357772    36396172    36434572    36472972 ...
    36511371    36549771    36588171    36626571    36664971 ...
    36703370    36741770    36780170    36818570    36856970 ...
    36895369    36933769    36972169    37010569    37048969 ...
    37087368    37125768    37164168    37202568    37240968 ...
    37279367    37317767    37356167    37394567    37432967 ...
    37471366    37509766    37548166    37586566    37624966 ...
    37663365    37701765    37740165    37778565    37816965 ...
    37855364    37893764    37932164    37970564    38008964 ...
    38047363    38085763    38124163    38162563    38200963 ...
    38239362    38277762    38316162    38354562             ];

descrambled_data = zeros(1,length(slot_syncs)*38400);

fprintf(1,'Descamble...\n');
%descramble all data
for frame =1:length(slot_syncs)
    

    frame_scrambled = cv_usrp(slot_syncs(frame)+0:slot_syncs(frame)+0+38399);

    frame_out = frame_scrambled .* conj(Sn);

    descrambled_data(1+(frame-1)*38400:38400+(frame-1)*38400) = frame_out;
    
end

clear cv_usrp

%compute the pilot symbols

fprintf(1,'Pilot...\n');
pilot_CPICH_channel = zeros(1,150*length(slot_syncs));

for symbol_idx = 1:length(slot_syncs)*150
    pilot_CPICH_channel(symbol_idx) = sum(descrambled_data(1+(symbol_idx-1)*256:256+(symbol_idx-1)*256) .* umts_spread_code(256,0));
end

fprintf(1,'P-CCPCH...\n');
%compute the P-CCPCH symbols

CCPCH_channel = zeros(1,150*length(slot_syncs));
for symbol_idx = 1:length(slot_syncs)*150
    CCPCH_channel(symbol_idx) = sum(descrambled_data(1+(symbol_idx-1)*256:256+(symbol_idx-1)*256) .* umts_spread_code(256,1)) ...
        ./ pilot_CPICH_channel(symbol_idx) * exp(j*pi/4);
end


fprintf(1,'PICH...\n');
%compute the PICH symbols

PICH_channel = zeros(1,150*length(slot_syncs)); 
PICH_offset = -10;

if (PICH_offset < 0)
    PICH_offset = PICH_offset + 150;
end
PICH_offset_chips = PICH_offset  *256;

%the PICH that begins in frame 'n' really is for the PCH that begins offset
%into frame n+2. i.e. the one that begins near the end of frame 1, actually
%is for SCH that starts in frame 3. So correct accordingly
for symbol_idx = 1:(length(slot_syncs)-2)*150
    PICH_channel(symbol_idx+2*150) = sum(descrambled_data(1+(symbol_idx-1)*256+PICH_offset_chips:256+(symbol_idx-1)*256+PICH_offset_chips) .* umts_spread_code(256,3)) ...
        ./ pilot_CPICH_channel(symbol_idx+2*150) * exp(j*pi/4);
end

%compute the SCCPCH(PCH) symbols  note this is SF128 on telstra


fprintf(1,'S-CCPCH...\n');
PCH_channel = zeros(1,300*length(slot_syncs)); 
PCH_offset = 20;
PCH_offset_chips = PCH_offset  *256;

for symbol_idx = 1:(length(slot_syncs)-1)*300
    PCH_channel(symbol_idx) = sum(descrambled_data(1+(symbol_idx-1)*128+PCH_offset_chips:128+(symbol_idx-1)*128+PCH_offset_chips) .* umts_spread_code(128,4)) ...
        ./ pilot_CPICH_channel(floor((symbol_idx-1)/2)+1) * exp(j*pi/4);
end

%PICH 'demod'


fprintf(1,'PICH demod...\n');

for (i=1:length(PICH_channel)/150)
    PICH_demod(i,:) = umts_qpsk_demap(PICH_channel(1+(i-1)*150:150+(i-1)*150));
    PICH_sum(i) = sum(PICH_demod(i,1:288));
end



fprintf(1,'FACH...\n');
%compute the SCCPCH(FACH) symbols  note this is SF64 on telstra

FACH_channel = zeros(1,600*length(slot_syncs)); 
FACH_offset = 0;
FACH_offset_chips = FACH_offset  *256;

for symbol_idx = 1:(length(slot_syncs))*600
    FACH_channel(symbol_idx) = sum(descrambled_data(1+(symbol_idx-1)*64+FACH_offset_chips:64+(symbol_idx-1)*64+FACH_offset_chips) .* umts_spread_code(64,1)) ...
        ./ pilot_CPICH_channel(floor((symbol_idx-1)/4)+1) * exp(j*pi/4);
end


%estimate the frequency offset by partially correlation CPICH
%CPICH in STTD mode varies every symbol (256-chips) due to STTD pattern
%therefore, look at the phase different in every pair of (128,128)chips

% N_freq_est_slots = 120;
% T_freq_est_start_symbol = slot_syncs(1);
% 
% 
% for i=1:N_freq_est_slots
%     first_half(i) = sum(cv_usrp(T_freq_est_start_symbol+(i-1)*2560:T_freq_est_start_symbol+127+(i-1)*2560) .* conj(Cpsc(1:128)));
%     second_half(i) = sum(cv_usrp(T_freq_est_start_symbol+128+(i-1)*2560:T_freq_est_start_symbol+255+(i-1)*2560) .* conj(Cpsc(129:256)));
% end

%P-CCPCH demod histogram
% figure(5)
% hist(diff(angle(symbols_out_CCPCH ./ symbols_out_CPICH))/(pi/2), 100)

%estimate modulation of the PSC

  %  angle(corr(slot_syncs))
  %  angle(scramb_corr(slot_syncs))

%reference (non STTD) CPICH is modulated with (1,1) = 1+j. Therefore, to get absolute phase, rotate phase by +angle(1+j) = pi/4     

%estimate phase

%figure(10)
% plot([1:150], angle(symbols_out_CPICH(1,:)))


fprintf(1,'decode P-CCPCH...\n');

offset = 1; % can be 1, for odd BCH

%decode BCH mapped to P-CCPCH
for (i=offset:2:length(CCPCH_channel)/150-2)


    CCPCH_symbols_corrected_stripped_0 = umts_extract_pccpch_frame(CCPCH_channel(1+i*150:150+i*150) );
    CCPCH_symbols_corrected_stripped_1 = umts_extract_pccpch_frame(CCPCH_channel(151+i*150:300+i*150) );



    figure(3)
     plot(real(CCPCH_symbols_corrected_stripped_0), imag(CCPCH_symbols_corrected_stripped_0), '+')


    figure(4)
     plot(real(CCPCH_symbols_corrected_stripped_1), imag(CCPCH_symbols_corrected_stripped_1), '+')

     
     
    CCPCH_bits_frame_0 = umts_qpsk_demap(CCPCH_symbols_corrected_stripped_0);
    CCPCH_bits_frame_1 = umts_qpsk_demap(CCPCH_symbols_corrected_stripped_1);

    CCPCH_bits_frame_2nddeint_0 = umts_2nd_deinterleave(CCPCH_bits_frame_0);
    CCPCH_bits_frame_2nddeint_1 = umts_2nd_deinterleave(CCPCH_bits_frame_1);

    trellis = poly2trellis([9], [561 753]);

    merged = zeros(1,length(CCPCH_bits_frame_2nddeint_0)*2);

    merged(1:2:end) = CCPCH_bits_frame_2nddeint_0;
    merged(2:2:end) = CCPCH_bits_frame_2nddeint_1;

    decoded = vitdec(merged,trellis, 70, 'term', 'hard');
    encoded = umts_conv_encode(decoded); 

    crcpoly=[1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];

    crc = umts_crc(decoded(1:246), crcpoly);
    if (sum(abs(crc - decoded(247:247+15))) == 0)
        fprintf(1, 'CRC matches\n');
        fname = sprintf('C:\\temp\\umts\\bch%03d.bin', floor(i/2));
        umts_write_bitstring_file(fname, decoded(1:246));
    else
        fprintf(1, 'CRC error!\n');    
    end
    fprintf(1, 'bit errors = %d\n', sum(abs(encoded - merged)));
    

end



 %correlate the half-PSCs
 
 % d

 
 break
 
 
 %FACH
 
 for i=1:length(FACH_channel)/600;
     FACH_tti = FACH_channel(1+(i-1)*600:600+(i-1)*600);
     FACH_pwr = mean(abs(FACH_tti));
     if (FACH_pwr <0.2)
         continue;
     end
     FACH_tti_softbits = umts_qpsk_demap_soft(FACH_tti);
     FACH_soft_tfci = umts_fach_extract_tfci(FACH_tti_softbits, 8);
     tfci = umts_soft_decode_tfci(FACH_soft_tfci);
     fprintf(1,'Frame %d, tfci = %d\n', i, tfci);
 end
 
 i=124;
 i=115;
 i=124;
 i=21;
 FACH_tti = FACH_channel(1+(i-1)*600:600+(i-1)*600);
 FACH_tti_softbits = umts_qpsk_demap_soft(FACH_tti);
 FACH_tti_softdatabits = umts_fach_extract_ndata(FACH_tti_softbits,8);
 FACH_tti_deintbits = umts_2nd_deinterleave(FACH_tti_softdatabits);
 %FACH_tti_deintbits = FACH_tti_deintbits(1:552);
 plot([1:length(FACH_tti_deintbits)], abs(FACH_tti_deintbits))
 
 
eplus = 2*384;
 eminus = 2*168;
 eini  =1;
 
 e = eini;
 m = 1;
 Xi = 384;
 
 bits_inserted_index = zeros(1,168);
 
 repeatcnt = 0;
 
 while (m<=Xi)
     e = e - eminus;
     while (e<=0)
         %fprintf(1, 'Repeat bit %d, post stuffed offset = %d\n', m, m+repeatcnt+1);
         bits_inserted_index(repeatcnt+1) = m+repeatcnt+1;
         e = e + eplus;
         repeatcnt = repeatcnt+1;
     end
     m = m + 1;
 end
 
 map_inserted = ones(1,552);
 map_inserted(bits_inserted_index) = 0;
 
 idx = 1;
 for i=1:552,
     if (map_inserted(i) > 0)
        output_keep(idx) = i;
        idx = idx + 1;
     end
 end

  
 
 
 %PCH
 
 eplus = 2*528;
 eminus = 2*72;
 eini  =1;
 
 e = eini;
 m = 1;
 Xi = 528;
 
 bits_inserted_index = zeros(1,72);
 
 repeatcnt = 0;
 
 while (m<=Xi)
     e = e - eminus;
     while (e<=0)
         %fprintf(1, 'Repeat bit %d, post stuffed offset = %d\n', m, m+repeatcnt+1);
         bits_inserted_index(repeatcnt+1) = m+repeatcnt+1;
         e = e + eplus;
         repeatcnt = repeatcnt+1;
     end
     m = m + 1;
 end
 
 map_inserted = ones(1,600);
 map_inserted(bits_inserted_index) = 0;
 
 idx = 1;
 for i=1:600,
     if (map_inserted(i) > 0)
        output_keep(idx) = i;
        idx = idx + 1;
     end
 end
 
 %fprintf(1,'Total repeat = %d\n', repeatcnt);
 
 for i=1:length(PCH_channel)/300-1
     PCH_tti = PCH_channel(1+(i-1)*300:300+(i-1)*300);
     PCH_bits = umts_qpsk_demap(PCH_tti);
     PCH_deint = umts_2nd_deinterleave(PCH_bits);
     PCH_depuncture = PCH_deint(output_keep);
     PCH_decoded = vitdec(PCH_depuncture,trellis, 70, 'term', 'hard');
     PCH_L3frame = PCH_decoded(1:240);
     PCH_CRC = PCH_decoded(241:256);
     PCH_calc_CRC = umts_crc(PCH_L3frame, crcpoly);
     if (sum(abs(PCH_CRC - PCH_calc_CRC)) == 0)
        fprintf(1,'%d PCH CRC matches\n', i);
        fname = sprintf('C:\\temp\\umts\\pch%03d.bin', i);
        umts_write_bitstring_file(fname, PCH_L3frame)
     else
        fprintf(1,'%d PCH CRC error\n', i);
     end
 end
 
 
     
     