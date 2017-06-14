clear all;
fprintf(1,'Loading samples...\n');
%telstra-umts5-4436-MG.usrp
%vodafone-4363-CH-0706.usrp PSC=2
f=fopen('C:\\temp\\optusu900_ch_9476.usrp', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(2:2:end)+v(1:2:end)*j; fclose(f);
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

N_corr_samples=length(cv_usrp)-38399;

%N_corr_samples = 38400;
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
 slot_syncs = [       20347       58747       97147      135547      173946      212346      250746  ...
      289146      327546      365945      404345      442745      481145      519545  ...
      557945      596344      634744      673144      711544      749944      788343  ...
      826743      865143      903543      941943      980342     1018742     1057142  ...
     1095542     1133942     1172341     1210741     1249141     1287541     1325941  ...
     1364340     1402740     1441140     1479540     1517940     1556339     1594739  ...
     1633139     1671539     1709939     1748338     1786738     1825138     1863538  ...
     1901938     1940337     1978737     2017137     2055537     2093937     2132336  ...
     2170736     2209136     2247536     2285936     2324335     2362735     2401135  ...
     2439535     2477935     2516334     2554734     2593134     2631534     2669934  ...
     2708333     2746733     2785133     2823533     2861933     2900332     2938732  ...
     2977132     3015532     3053932     3092332     3130731     3169131     3207531  ...
     3245931     3284331     3322730     3361130     3399530     3437930     3476329  ...
     3514729     3553129     3591529     3629929     3668329     3706728     3745128  ...
     3783528     3821928     3860328     3898727     3937127     3975527     4013927  ...
     4052327     4090726     4129126     4167526     4205926     4244326     4282725  ...
     4321125     4359525     4397925     4436325     4474724     4513124     4551524  ...
     4589924     4628324     4666723     4705123     4743523     4781923     4820323  ...
     4858722     4897122     4935522     4973922     5012322     5050721     5089121  ...
     5127521     5165921     5204321     5242720     5281120     5319520     5357920  ...
     5396320     5434719     5473119     5511519     5549919     5588319     5626718  ...
     5665118     5703518     5741918     5780318     5818717     5857117     5895517  ...
     5933917     5972317     6010716     6049116     6087516     6125916     6164316  ...
     6202715     6241115     6279515     6317915     6356315     6394714     6433114  ...
     6471514     6509914     6548314     6586713     6625113     6663513     6701913  ...
     6740313     6778712     6817112     6855512     6893912     6932312     6970711  ...
     7009111     7047511     7085911     7124311     7162710     7201110     7239510  ...
     7277910     7316310     7354709     7393109     7431509     7469909     7508309  ...
     7546708     7585108     7623508     7661908     7700308     7738707     7777107  ...
     7815507     7853907     7892307     7930707     7969106     8007506     8045906  ...
     8084306     8122706     8161105     8199505     8237905     8276305     8314705  ...
     8353104     8391504     8429904     8468304     8506704     8545103     8583503  ...
     8621903     8660303     8698703     8737102     8775502     8813902     8852302  ...
     8890702     8929101     8967501     9005901     9044301     9082701     9121100  ...
     9159500     9197900     9236300     9274700     9313099     9351499     9389899  ...
     9428299     9466699     9505098     9543498     9581898     9620298     9658698  ...
     9697097     9735497     9773897     9812297     9850697     9889096     9927496  ...
     9965896    10004296    10042696    10081095    10119495    10157895    10196295  ...
    10234695    10273094    10311494    10349894    10388294    10426694    10465093  ...
    10503493    10541893    10580293    10618693    10657092    10695492    10733892  ...
    10772292    10810692    10849091    10887491    10925891    10964291    11002691  ...
    11041090    11079490    11117890    11156290    11194690    11233089    11271489  ...
    11309889    11348289    11386689    11425088    11463488    11501888    11540288  ...
    11578688    11617087    11655487    11693887    11732287    11770687    11809086  ...
    11847486    11885886    11924286    11962686    12001085    12039485    12077885  ...
    12116285    12154685    12193084    12231484    12269884    12308284    12346684  ...
    12385083    12423483    12461883    12500283    12538683    12577082    12615482  ...
    12653882    12692282    12730682    12769081    12807481    12845881    12884281  ...
    12922681    12961080    12999480    13037880    13076280    13114680    13153079  ...
    13191479    13229879    13268279    13306679    13345079    13383478    13421878  ...
    13460278    13498678    13537078    13575477    13613877    13652277    13690677  ...
    13729076    13767476    13805876    13844276    13882676    13921075    13959475  ...
    13997875    14036275    14074675    14113075    14151474    14189874    14228274  ...
    14266674    14305074    14343473    14381873    14420273    14458673    14497073  ...
    14535472    14573872    14612272    14650672    14689072    14727471    14765871  ...
    14804271    14842671    14881071    14919470    14957870    14996270    15034670  ...
    15073070    15111469    15149869    15188269    15226669    15265069    15303468  ...
    15341868    15380268    15418668    15457068    15495467    15533867    15572267  ...
    15610667    15649067    15687466    15725866    15764266    15802666    15841066  ...
    15879465    15917865    15956265    15994665    16033065    16071464    16109864  ...
    16148264    16186664    16225064    16263463    16301863    16340263    16378663  ...
    16417063    16455462    16493862    16532262    16570662    16609062    16647461  ...
    16685861    16724261    16762661    16801061    16839460    16877860    16916260  ...
    16954660    16993060    17031459    17069859    17108259    17146659    17185059  ...
    17223458    17261858    17300258    17338658    17377058    17415457    17453857  ...
    17492257    17530657    17569057    17607456    17645856    17684256    17722656  ...
    17761056    17799455    17837855    17876255    17914655    17953055    17991454  ...
    18029854    18068254    18106654    18145054    18183453    18221853    18260253  ...
    18298653    18337053    18375452    18413852    18452252    18490652    18529052  ...
    18567451    18605851    18644251    18682651    18721051    18759450    18797850  ...
    18836250    18874650    18913050    18951449    18989849    19028249    19066649  ...
    19105049    19143448    19181848    19220248    19258648    19297048    19335448  ...
    19373847    19412247    19450647    19489047    19527446    19565846    19604246  ...
    19642646    19681046    19719445    19757845    19796245    19834645    19873045  ...
    19911444    19949844    19988244    20026644    20065044    20103443    20141843  ...
    20180243    20218643    20257043    20295442    20333842    20372242    20410642  ...
    20449042    20487442    20525841    20564241    20602641    20641041    20679440  ...
    20717840    20756240    20794640    20833040    20871440    20909839    20948239  ...
    20986639    21025039    21063439    21101838    21140238    21178638    21217038  ...
    21255437    21293837    21332237    21370637    21409037    21447437    21485836  ...
    21524236    21562636    21601036    21639436    21677835    21716235    21754635  ...
    21793035    21831435    21869834    21908234    21946634    21985034    22023434  ...
    22061833    22100233    22138633    22177033    22215433    22253832    22292232  ...
    22330632    22369032    22407432    22445831    22484231    22522631    22561031  ...
    22599431    22637830    22676230    22714630    22753030    22791430    22829829  ...
    22868229    22906629    22945029    22983428    23021828    23060228    23098628  ...
    23137028    23175427    23213827    23252227    23290627    23329027    23367426  ...
    23405826    23444226    23482626    23521026    23559426    23597825    23636225  ...
    23674625    23713025    23751425    23789824    23828224    23866624    23905024  ...
    23943424    23981823    24020223    24058623    24097023    24135422    24173822  ...
    24212222    24250622    24289022    24327422    24365821    24404221    24442621  ...
    24481021    24519420    24557820    24596220    24634620    24673020    24711420  ...
    24749819    24788219    24826619    24865019    24903419    24941818    24980218  ...
    25018618    25057018    25095418    25133817    25172217    25210617    25249017  ...
    25287417    25325816    25364216    25402616    25441016    25479416    25517815  ...
    25556215    25594615    25633015    25671415    25709814    25748214    25786614  ...
    25825014    25863414    25901813    25940213    25978613    26017013    26055413  ...
    26093812    26132212    26170612    26209012    26247412    26285811    26324211  ...
    26362611    26401011    26439411    26477810    26516210    26554610    26593010  ...
    26631410    26669809    26708209    26746609    26785009    26823409    26861808  ...
    26900208    26938608    26977008    27015407    27053807    27092207    27130607  ...
    27169007    27207407    27245806    27284206    27322606    27361006    27399405  ...
    27437805    27476205    27514605    27553005    27591405    27629804    27668204  ...
    27706604    27745004    27783404    27821803    27860203    27898603    27937003  ...
    27975403    28013802    28052202    28090602    28129002    28167402    28205801  ...
    28244201    28282601    28321001    28359401    28397800    28436200    28474600  ...
    28513000    28551400    28589799    28628199    28666599    28704999    28743399  ...
    28781798    28820198    28858598    28896998    28935398    28973797    29012197  ...
    29050597    29088997    29127397    29165796    29204196    29242596    29280996  ...
    29319396    29357795    29396195    29434595    29472995    29511395    29549794  ...
    29588194    29626594    29664994    29703394    29741793    29780193    29818593  ...
    29856993    29895393    29933792    29972192    30010592    30048992    30087392  ...
    30125791    30164191    30202591    30240991    30279391    30317790    30356190  ...
    30394590    30432990    30471390    30509789    30548189    30586589    30624989  ...
    30663389    30701788    30740188    30778588    30816988    30855388    30893787  ...
    30932187    30970587    31008987    31047387    31085786    31124186    31162586  ...
    31200986    31239386    31277785    31316185    31354585    31392985    31431385  ...
    31469784    31508184    31546584    31584984    31623384    31661783    31700183  ...
    31738583    31776983    31815383    31853782    31892182    31930582    31968982  ...
    32007382    32045781    32084181    32122581    32160981    32199381    32237780  ...
    32276180    32314580    32352980    32391380    32429779    32468179    32506579  ...
    32544979    32583379    32621778    32660178    32698578    32736978    32775378  ...
    32813777    32852177    32890577    32928977    32967377    33005776    33044176  ...
    33082576    33120976    33159376    33197775    33236175    33274575    33312975  ...
    33351375    33389774    33428174    33466574    33504974    33543374    33581773  ...
    33620173    33658573    33696973    33735373    33773772    33812172    33850572  ...
    33888972    33927372    33965771    34004171    34042571    34080971    34119371  ...
    34157770    34196170    34234570    34272970    34311370    34349769    34388169  ...
    34426569    34464969    34503369    34541768    34580168    34618568    34656968  ...
    34695368    34733767    34772167    34810567    34848967    34887367    34925766  ...
    34964166    35002566    35040966    35079366    35117765    35156165    35194565  ...
    35232965    35271365    35309764 ];

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
 
 
     
     