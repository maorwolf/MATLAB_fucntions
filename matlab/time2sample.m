function sample=time2sample(min,sec)
% The function converts time in minutes and seconds to samples
% The input is minutes and seconds seperatly, e.g., for 2:04,
% sample=time2sample(2,4)

sample=round((min*60+sec)*1017.23);