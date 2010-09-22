function chan_load_perc = measure_channel_load(fname, with_frame_type)

    try
      v = load(fname);
    catch
      v = [];
    end
    
    if (isempty(v))
        chan_load_perc = 0;
        return
    end
    
    total_dur = v(end,1)-v(1,1);
    
    musec = zeros(size(v,1), 2);
    for i=1:size(v,1)
       timestamp = v(i,1);
       mac_sz_bytes = v(i,2);
       bitrate = v(i,3);
       if (with_frame_type)
        frame_type = v(i,4);
       else
        frame_type = -1;
       end
       
       musec(i,:) = [tx_time(bitrate, mac_sz_bytes); frame_type];
    end

    chan_load_perc(1) = (sum(musec(:,1))/1e6)/total_dur;
    mgmt_frames = musec(find(musec(:,2) == 0),:);
    if (with_frame_type)
        chan_load_perc(2) = (sum(mgmt_frames(:,1))/1e6)/total_dur;
        cntl_frames = musec(find(musec(:,2) == 1),:);
        chan_load_perc(3) = (sum(cntl_frames(:,1))/1e6)/total_dur;
        data_frames = musec(find(musec(:,2) == 2),:);
        chan_load_perc(4) = (sum(data_frames(:,1))/1e6)/total_dur;
    end
end
