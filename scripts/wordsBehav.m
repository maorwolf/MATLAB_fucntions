for sub=[0:3,5:9,12,14,15:17,19:21,23:25,27:29, 31:37,39,41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(sub),'/1']);
    cfg=[];
    conditions = [110 120 130 140 150 160 170 180 190];
    % 110 - word, no repeats, high freq
    % 120 - word, no repeats, low freq
    % 130 - non word, no repeats
    % 140 - word, first apperance, high freq
    % 150 - word, first apperance, low freq
    % 160 - word, second apperance, high freq
    % 170 - word, second apperance, low freq
    % 180 - non word, first repeat
    % 190 - non word, second repeat
    % defining trials in all the data.
    if sub == 15 || sub == 23
        cfg.dataset ='fix_xc,hb,lf_c,rfhp0.1Hz';
    elseif sub == 29
        cfg.dataset ='hb,lf_c,rfhp0.1Hz';
    elseif sub == 20 || sub == 34 || sub == 37
        cfg.dataset ='rs,xc,hb,lf_c,rfhp0.1Hz';
    else
        cfg.dataset ='xc,hb,lf_c,rfhp0.1Hz';
    end;
    cfg.trialdef.eventtype  = 'TRIGGER';
    cfg.trialdef.eventvalue = conditions;
    cfg.trialdef.prestim    = 0.3;
    cfg.trialdef.poststim   = 0.8;
    cfg.trialdef.offset=-0.3;
    cfg.trialfun='BIUtrialfun';
    if sub == 16 || sub == 24 || sub == 25
         cfg = ft_definetrial(cfg);
    else
        cfg.trialdef.visualtrig = 'visafter';
        cfg.trialdef.visualtrigwin = 0.2;
        cfg = ft_definetrial(cfg);
    end
    %--------------------------------------------------------------------------
    % creating colume 7 with correct code
    cfg.trl(1:length(cfg.trl),7) = 0;
    for i=1:length(cfg.trl)
        if ((cfg.trl(i,4)==110) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==120) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==130) && (cfg.trl(i,6)==512))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==140) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==150) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==160) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==170) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==180) && (cfg.trl(i,6)==512))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==190) && (cfg.trl(i,6)==512))
            cfg.trl(i,7)=1;
        end;
    end;
    behav = [];
    % column 1 - word, no repeat
    % column 2 - word, first apperance
    % column 3 - word, second apperance
    % column 4 - non word, no repeat
    % column 5 - non word, first apperance
    % column 6 - non word, second apperacne
    
    % 180 - non word, first repeat
    % 190 - non word, second repeat
    
    % wordNoRepeat
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if ((cfg.trl(i,4) == 110 || cfg.trl(i,4) == 120) && cfg.trl(i,7) == 1)
            behav.wordNoRepeat.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif ((cfg.trl(i,4) == 110 || cfg.trl(i,4) == 120) && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.wordNoRepeat.ER = error;
    behav.wordNoRepeat.sd = std(behav.wordNoRepeat.RT);
    behav.wordNoRepeat.mean = mean(behav.wordNoRepeat.RT);
    
    % noWordNoRepeat
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 130 && cfg.trl(i,7) == 1)
            behav.noWordNoRepeat.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 130 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.noWordNoRepeat.ER = error;
    behav.noWordNoRepeat.sd = std(behav.noWordNoRepeat.RT);
    behav.noWordNoRepeat.mean = mean(behav.noWordNoRepeat.RT);
    
    % wordFirst
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if ((cfg.trl(i,4) == 140 || cfg.trl(i,4) == 150) && cfg.trl(i,7) == 1)
            behav.wordFirst.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif ((cfg.trl(i,4) == 140 || cfg.trl(i,4) == 150) && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.wordFirst.ER = error;
    behav.wordFirst.sd = std(behav.wordFirst.RT);
    behav.wordFirst.mean = mean(behav.wordFirst.RT);
    
    % wordSecond
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if ((cfg.trl(i,4) == 160 || cfg.trl(i,4) == 170) && cfg.trl(i,7) == 1)
            behav.wordSecond.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif ((cfg.trl(i,4) == 160 || cfg.trl(i,4) == 170) && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.wordSecond.ER = error;
    behav.wordSecond.sd = std(behav.wordSecond.RT);
    behav.wordSecond.mean = mean(behav.wordSecond.RT);
    
    % noWordFirst
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 180 && cfg.trl(i,7) == 1)
            behav.noWordFirst.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 180 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.noWordFirst.ER = error;
    behav.noWordFirst.sd = std(behav.noWordFirst.RT);
    behav.noWordFirst.mean = mean(behav.noWordFirst.RT);
    
    % noWordSecond
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 190 && cfg.trl(i,7) == 1)
            behav.noWordSecond.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 190 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.noWordSecond.ER = error;
    behav.noWordSecond.sd = std(behav.noWordSecond.RT);
    behav.noWordSecond.mean = mean(behav.noWordSecond.RT);

    %% looking for outliars and calculating ERs
    % wordNorepeat
    for i = 1:length(behav.wordNoRepeat.RT)
        behav.wordNoRepeat.RT(i,2) = abs((behav.wordNoRepeat.RT(i,1) - behav.wordNoRepeat.mean) / behav.wordNoRepeat.sd);
    end;
    behav.wordNoRepeat.RTclean = behav.wordNoRepeat.RT(behav.wordNoRepeat.RT(:,2) < 2.5, 1);
    behav.wordNoRepeat.SDclean = std(behav.wordNoRepeat.RTclean);
    behav.wordNoRepeat.MEANclean = mean(behav.wordNoRepeat.RTclean);
    behav.wordNoRepeat.ER = behav.wordNoRepeat.ER/(length(behav.wordNoRepeat.RT(:,1))+behav.wordNoRepeat.ER);
    % noWordNoRepeat
    for i = 1:length(behav.noWordNoRepeat.RT)
        behav.noWordNoRepeat.RT(i,2) = abs((behav.noWordNoRepeat.RT(i,1) - behav.noWordNoRepeat.mean) / behav.noWordNoRepeat.sd);
    end;
    behav.noWordNoRepeat.RTclean = behav.noWordNoRepeat.RT(behav.noWordNoRepeat.RT(:,2) < 2.5, 1);
    behav.noWordNoRepeat.SDclean = std(behav.noWordNoRepeat.RTclean);
    behav.noWordNoRepeat.MEANclean = mean(behav.noWordNoRepeat.RTclean);
    behav.noWordNoRepeat.ER = behav.noWordNoRepeat.ER/(length(behav.noWordNoRepeat.RT(:,1))+behav.noWordNoRepeat.ER);
    % wordFirst
    for i = 1:length(behav.wordFirst.RT)
        behav.wordFirst.RT(i,2) = abs((behav.wordFirst.RT(i,1) - behav.wordFirst.mean) / behav.wordFirst.sd);
    end;
    behav.wordFirst.RTclean = behav.wordFirst.RT(behav.wordFirst.RT(:,2) < 2.5, 1);
    behav.wordFirst.SDclean = std(behav.wordFirst.RTclean);
    behav.wordFirst.MEANclean = mean(behav.wordFirst.RTclean);
    behav.wordFirst.ER = behav.wordFirst.ER/(length(behav.wordFirst.RT(:,1))+behav.wordFirst.ER);    
    % noWordFirst
    for i = 1:length(behav.noWordFirst.RT)
        behav.noWordFirst.RT(i,2) = abs((behav.noWordFirst.RT(i,1) - behav.noWordFirst.mean) / behav.noWordFirst.sd);
    end;
    behav.noWordFirst.RTclean = behav.noWordFirst.RT(behav.noWordFirst.RT(:,2) < 2.5, 1);
    behav.noWordFirst.SDclean = std(behav.noWordFirst.RTclean);
    behav.noWordFirst.MEANclean = mean(behav.noWordFirst.RTclean);
    behav.noWordFirst.ER = behav.noWordFirst.ER/(length(behav.noWordFirst.RT(:,1))+behav.noWordFirst.ER);    
    % wordSecond
    for i = 1:length(behav.wordSecond.RT)
        behav.wordSecond.RT(i,2) = abs((behav.wordSecond.RT(i,1) - behav.wordSecond.mean) / behav.wordSecond.sd);
    end;
    behav.wordSecond.RTclean = behav.wordSecond.RT(behav.wordSecond.RT(:,2) < 2.5, 1);
    behav.wordSecond.SDclean = std(behav.wordSecond.RTclean);
    behav.wordSecond.MEANclean = mean(behav.wordSecond.RTclean);
    behav.wordSecond.ER = behav.wordSecond.ER/(length(behav.wordSecond.RT(:,1))+behav.wordSecond.ER); 
    % noWordSecond
    for i = 1:length(behav.noWordSecond.RT)
        behav.noWordSecond.RT(i,2) = abs((behav.noWordSecond.RT(i,1) - behav.noWordSecond.mean) / behav.noWordSecond.sd);
    end;
    behav.noWordSecond.RTclean = behav.noWordSecond.RT(behav.noWordSecond.RT(:,2) < 2.5, 1);
    behav.noWordSecond.SDclean = std(behav.noWordSecond.RTclean);
    behav.noWordSecond.MEANclean = mean(behav.noWordSecond.RTclean);
    behav.noWordSecond.ER = behav.noWordSecond.ER/(length(behav.noWordSecond.RT(:,1))+behav.noWordSecond.ER); 
    
    eval(['behav',num2str(sub),' = behav;'])
    eval(['save behavWord behav',num2str(sub)])
        
end;

%% ------------------------------------------------------------------------
clear all;
% good subs (according to erf)
control = [0:3, 5:9, 12, 15, 20, 32, 36, 39, 41];
SZ = [14, 16, 17, 19, 21, 23:25, 27:29, 31, 33:35, 37];

a=1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/behavWord']);
    eval(['ERcontrol(a,1)=behav',num2str(i),'.wordNoRepeat.ER;']);
    eval(['RTcontrol(a,1)=behav',num2str(i),'.wordNoRepeat.MEANclean;']);
    eval(['ERcontrol(a,2)=behav',num2str(i),'.noWordNoRepeat.ER;']);
    eval(['RTcontrol(a,2)=behav',num2str(i),'.noWordNoRepeat.MEANclean;']);
    eval(['ERcontrol(a,3)=behav',num2str(i),'.wordFirst.ER;']);
    eval(['RTcontrol(a,3)=behav',num2str(i),'.wordFirst.MEANclean;']);
    eval(['ERcontrol(a,4)=behav',num2str(i),'.noWordFirst.ER;']);
    eval(['RTcontrol(a,4)=behav',num2str(i),'.noWordFirst.MEANclean;']);
    eval(['ERcontrol(a,5)=behav',num2str(i),'.wordSecond.ER;']);
    eval(['RTcontrol(a,5)=behav',num2str(i),'.wordSecond.MEANclean;']);
    eval(['ERcontrol(a,6)=behav',num2str(i),'.noWordSecond.ER;']);
    eval(['RTcontrol(a,6)=behav',num2str(i),'.noWordSecond.MEANclean;']);
    a=a+1;
end;

b=1;
for j = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(j),'/1/behavWord']);
    eval(['ERSZ(b,1)=behav',num2str(j),'.wordNoRepeat.ER;']);
    eval(['RTSZ(b,1)=behav',num2str(j),'.wordNoRepeat.MEANclean;']);
    eval(['ERSZ(b,2)=behav',num2str(j),'.noWordNoRepeat.ER;']);
    eval(['RTSZ(b,2)=behav',num2str(j),'.noWordNoRepeat.MEANclean;']);
    eval(['ERSZ(b,3)=behav',num2str(j),'.wordFirst.ER;']);
    eval(['RTSZ(b,3)=behav',num2str(j),'.wordFirst.MEANclean;']);
    eval(['ERSZ(b,4)=behav',num2str(j),'.noWordFirst.ER;']);
    eval(['RTSZ(b,4)=behav',num2str(j),'.noWordFirst.MEANclean;']);
    eval(['ERSZ(b,5)=behav',num2str(j),'.wordSecond.ER;']);
    eval(['RTSZ(b,5)=behav',num2str(j),'.wordSecond.MEANclean;']);
    eval(['ERSZ(b,6)=behav',num2str(j),'.noWordSecond.ER;']);
    eval(['RTSZ(b,6)=behav',num2str(j),'.noWordSecond.MEANclean;']);
    b=b+1;
end;

ERSZ = ERSZ.*100;
ERcontrol = ERcontrol.*100;
ERmean(1,1:6) = mean(ERSZ,1);
ERmean(2,1:6) = mean(ERcontrol,1);
RTmean(1,1:6) = mean(RTSZ,1);
RTmean(2,1:6) = mean(RTcontrol,1);
ER_SZ_sd=std(ERSZ);
ER_con_sd=std(ERcontrol);
RT_SZ_sd=std(RTSZ);
RT_con_sd=std(RTcontrol);
ERsd=[ER_SZ_sd; ER_con_sd];
RTsd=[RT_SZ_sd; RT_con_sd];
% column 1 - word, no repeat
% column 2 - non word, no repeat
% column 3 - word, first apperance
% column 4 - non word, first apperance
% column 5 - word, second apperance
% column 6 - non word, second apperacne
cd /home/meg/Data/Maor/SchizoProject/wordNoWord
save behavWord ERcontrol RTcontrol ERSZ RTSZ ER_SZ_sd ER_con_sd ERmean ERsd RT_SZ_sd RT_con_sd RTmean RTsd
clear all
load behavWord

%% plotting
figure;

subplot(2,1,1)
h1 = barwitherr(ERsd'./4, ERmean');% Plot with errorbars
title('Errors');
ylabel('Number of Errors');
ylim([0 20]);
set(h1(1), 'facecolor', [0 0.7 0.6]);
set(h1(2), 'facecolor', [0 0.2 0.5]);
set(gca, 'XTickLabel', {'Word 0';'NoneWord 0';'Word 1';'NoneWord 1';'Word 2';'NoneWord 2'});
legend('Schizophrenia','Control');


subplot(2,1,2)
h2 = barwitherr(RTsd'./4, RTmean');% Plot with errorbars
title('Reaction Times');
ylabel('ms');
ylim([0 1000]);
set(h2(1), 'facecolor', [0 0.7 0.6]);
set(h2(2), 'facecolor', [0 0.2 0.5]);
set(gca, 'XTickLabel', {'Word 0';'NoneWord 0';'Word 1';'NoneWord 1';'Word 2';'NoneWord 2'});
legend('Schizophrenia','Control');

