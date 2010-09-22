function chan_load_perc = measure_channel_load_buckets(fname, with_frame_type, no_buckets)
   
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
    disp(strcat('Total duration (s) = ', num2str(total_dur)));
    bucket_len = total_dur / no_buckets;
    
    chan_load_perc = zeros(no_buckets, 4);
    for b=1:no_buckets
        start_time = (b-1)*bucket_len + v(1,1);
        end_time = b*bucket_len + v(1,1);
        bucket = v(find(v(:,1) >= start_time & v(:,1) < end_time),:);
        
        musec = zeros(size(bucket,1), 2);
        for i=1:size(bucket,1)
           timestamp = bucket(i,1);
           mac_sz_bytes = bucket(i,2);
           bitrate = bucket(i,3);
           if (with_frame_type)
            frame_type = bucket(i,4);
           else
            frame_type = -1;
           end

           musec(i,:) = [tx_time(bitrate, mac_sz_bytes); frame_type];
        end

        chan_load_perc(b, 1) = (sum(musec(:,1))/1e6)/bucket_len;
        mgmt_frames = musec(find(musec(:,2) == 0),:);
        if (with_frame_type)
            chan_load_perc(b, 2) = (sum(mgmt_frames(:,1))/1e6)/bucket_len;
            cntl_frames = musec(find(musec(:,2) == 1),:);
            chan_load_perc(b, 3) = (sum(cntl_frames(:,1))/1e6)/bucket_len;
            data_frames = musec(find(musec(:,2) == 2),:);
            chan_load_perc(b, 4) = (sum(data_frames(:,1))/1e6)/bucket_len;
        end
    end
end