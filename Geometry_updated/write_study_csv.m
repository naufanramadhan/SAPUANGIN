function write_study_csv(path,headers,rows)
% Small portable CSV writer; no MATLAB table dependency.
f=fopen(path,'w'); assert(f>=0,'Cannot write %s',path);
cleanup=onCleanup(@() fclose(f));
for row=0:size(rows,1)
    if row==0, values=headers; else, values=rows(row,:); end
    for col=1:numel(headers)
        if col>1, fprintf(f,','); end
        v=values{col};
        if ischar(v)
            fprintf(f,'"%s"',strrep(v,'"','""'));
        else
            assert(isscalar(v));
            fprintf(f,'%.15g',v);
        end
    end
    fprintf(f,'\n');
end
end
