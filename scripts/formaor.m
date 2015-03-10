pdf=pdf4D('c,rfhp0.1Hz'); 
pdf_new=pdf4D('hb,lf_c,rfhp0.1Hz'); %change
data1 = read_data_block(pdf,[1 10173],13); %drop chi
data2 = read_data_block(pdf_new,[1 10173],13); %drop chi

[data1PSD, freq] = allSpectra(data1,1017.25,1,'FFT');
[data2PSD, freq] = allSpectra(data2,1017.25,1,'FFT');
figure;plot (freq(1,1:120),data1PSD(1,1:120),'r')
hold on;
plot (freq(1,1:120),data2PSD(1,1:120),'b')
xlabel ('Frequency Hz');
ylabel('SQRT(PSD), T/sqrt(Hz)');
title(['sub',num2str(subnum),' - PSD for all channels']);
str=['sub',num2str(subnum),'createClean_PSD.jpg'];
saveas(gcf,str);