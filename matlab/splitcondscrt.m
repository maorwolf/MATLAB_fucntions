function ndata=splitcondscrt(cfg,data);

% cfg.cond = event code to extract

tloc = 't = data.cfg';
eval(tloc);

for i=1:100;
  if(isfield(t, 'trl'));
    str = [tloc,'.trl'];
    eval(str);
    break;
 else;
    tloc = [tloc, '.previous'];
    eval(tloc);
 end;
end;

if (i<100);
    x=1;
    for j=1:length(t);
        if (t(j,4)==cfg.cond && t(j,7)==1)
            newt(x)=j;
            x=x+1;
        end;
    end;
    ndata=data;
    ndata.trial=ndata.trial(newt);
    ndata.time=ndata.time(newt);
    ndata.cfg.trl=t(newt,:);
else;
    error('no trl matrix found');
end;