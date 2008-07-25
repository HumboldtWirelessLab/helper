function outdoor_result_evaluation(rfilename)

  meas=load(rfilename);

  bitrate_all=unique(meas(:,5));
  size_all=unique(meas(:,4));
  channel_all=unique(meas(:,1));

  color=colormap();

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
                 scatter(m(:,2),m(:,10),0,color(b*5),'*');    
               end
            end
            xlabel('Distance');
            ylabel('PER');
            fname = strcat('dist_per_', num2str(channel_all(c)),'_',num2str(size_all(s)),'.png');
            print('-dpng', fname);

	  clearplot;
            for b=1:size(bitrate_all,1)
               m=meas(find((meas(:,5) == bitrate_all(b) ) & (meas(:,4) == size_all(s) ) & (meas(:,1) == channel_all(c) ) ),:);
               if ( (~isempty(m) ) & ( size(m,1) > 0 ) )
                 scatter(m(:,2),m(:,12),0,color(b*5),'*');    
               end
            end
            xlabel('Distance');
            ylabel('RSSI');
            fname = strcat('dist_rssi_', num2str(channel_all(c)),'_',num2str(size_all(s)),'.png');
            print('-dpng', fname);
 
	  clearplot;
            for b=1:size(bitrate_all,1)
               m=meas(find((meas(:,5) == bitrate_all(b) ) & (meas(:,4) == size_all(s) ) & (meas(:,1) == channel_all(c) ) ),:);
               if ( (~isempty(m) ) & ( size(m,1) > 0 ) )
                 scatter(m(:,12),m(:,10),0,color(b*5),'*');    
               end
            end
            xlabel('RSSI');
            ylabel('PER');
            fname = strcat('rssi_per_', num2str(channel_all(c)),'_',num2str(size_all(s)),'.png');
            print('-dpng', fname);

         end
       end
    end
  end

end
