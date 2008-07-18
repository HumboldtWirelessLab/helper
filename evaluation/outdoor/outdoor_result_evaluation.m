function outdoor_result_evaluation(rfilename)

  meas=load(rfilename);

  bitrate_all=unique(meas(:,5));
  size_all=unique(meas(:,4));
  channel_all=unique(meas(:,1));

%distance vs per
  if ~isempty (channel_all)
    for c=1:size(channel_all,1)
      if ~isempty(size_all)
        for s=1:size(size_all,1)
          if ~isempty (bitrate_all)
	  clearplot;
            for b=1:size(bitrate_all,1)
               m=meas(find((meas(:,5) == bitrate_all(b) ) & (meas(:,4) == size_all(s) ) & (meas(:,1) == channel_all(c) ) ),:);
               if ( (~isempty(m) ) & ( size(m,1) > 0 ) )
                 scatter(m(:,2),m(:,10),'b','*');
               end
            end
          end
       end
    end
  end

end
