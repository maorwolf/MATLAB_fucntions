cnt=1;
for i=1:size(t,1);
    if ~isempty(find(data.cfg.trl==t(i,1))) && t(i,4)==cfg.cond; %#ok<EFIND>
        ti=find(data.cfg.trl==t(i,1));
        ndata.cfg.trl(cnt,1:size(t,2))=t(i,:);
        ndata.trial{1,cnt}=data.trial{1,ti};
        ndata.time{1,cnt}=data.time{1,ti};
        cnt=cnt+1;
    end
end