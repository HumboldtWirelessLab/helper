function crccheck(psize,bitrate,filenames)

allp=[];
filenames
for fi=1:size(filenames,1)
    clear newp;
    newp=load(filenames(fi,:));
    allp=[allp ; newp];
end

allid=sort(unique(allp(:,2)));

for i=1:size(allid,1)
    allrecv=find(allp(:,2)==allid(i,1) &&
end
