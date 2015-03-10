clear all

con = [13:21 23 25 27:29];
sz = [2:7 9 12 13 15];

for i = con
    eval(['cd /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(i)]);
    [LIT,info]=BrikLoad('LITcomp1con+tlrc');
    [CM,info]=BrikLoad('CMcomp1con+tlrc');
    [NM,info]=BrikLoad('NMcomp1con+tlrc');
    [UR,info]=BrikLoad('URcomp1con+tlrc');
    LIT=LIT+1*10^(-16);
    CM=CM+1*10^(-16);
    NM=NM+1*10^(-16);
    UR=UR+1*10^(-16);
        optLIT.Prefix = 'LITcomp1conNZ';
        optLIT.View = '+tlrc';
    WriteBrik(LIT, info, optLIT);
        optCM.Prefix = 'CMcomp1conNZ';
        optCM.View = '+tlrc';
    WriteBrik(CM, info, optCM);
        optNM.Prefix = 'NMcomp1conNZ';
        optNM.View = '+tlrc';
    WriteBrik(NM, info, optNM);
        optUR.Prefix = 'URcomp1conNZ';
        optUR.View = '+tlrc';
    WriteBrik(UR, info, optUR);
end;

for i = sz
    eval(['cd /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(i)]);
    [LIT,info]=BrikLoad('LITcomp1sz+tlrc');
    [CM,info]=BrikLoad('CMcomp1sz+tlrc');
    [NM,info]=BrikLoad('NMcomp1sz+tlrc');
    [UR,info]=BrikLoad('URcomp1sz+tlrc');
    LIT=LIT+1*10^(-16);
    CM=CM+1*10^(-16);
    NM=NM+1*10^(-16);
    UR=UR+1*10^(-16);
        optLIT.Prefix = 'LITcomp1szNZ';
        optLIT.View = '+tlrc';
    WriteBrik(LIT, info, optLIT);
        optCM.Prefix = 'CMcomp1szNZ';
        optCM.View = '+tlrc';
    WriteBrik(CM, info, optCM);
        optNM.Prefix = 'NMcomp1szNZ';
        optNM.View = '+tlrc';
    WriteBrik(NM, info, optNM);
        optUR.Prefix = 'URcomp1szNZ';
        optUR.View = '+tlrc';
    WriteBrik(UR, info, optUR);
end;