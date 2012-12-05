function [vector_backoff  ] = func_cw_vector_get(test_find_backoff_optimal_on,letter_of_standard, no_backoff_window_size_max,use_greenfield)

    vector_backoff = zeros(1,2); % vector_backoff init
    if(test_find_backoff_optimal_on == 0)
        %------------------- Backoff with standard contention window sizes -------------------------------------
        switch letter_of_standard
            case 'b'
                vector_backoff =  func_ieee80211b_contention_window_get();
            case 'a'
                vector_backoff =  func_ieee80211a_contention_window_get();
            case 'g'
                vector_backoff =  func_ieee80211g_contention_window_get(use_greenfield);
            case 'n'
                vector_backoff =  func_ieee80211n_contention_window_get();
            otherwise
                vector_backoff =  func_ieee80211_contention_window_get();
        end
     elseif(test_find_backoff_optimal_on == 1)
        counter_next = 2;
        counter_vector = 1;
        vector_backoff = zeros(1,no_backoff_window_size_max); % vector_backoff init
    for s=2:1:no_backoff_window_size_max
        if(s > 0 && s <=100 && s == counter_next)
        vector_backoff(1,counter_vector) = s;
        counter_next = s + 4;
        counter_vector = counter_vector +1;
        elseif (s >100 && s<=500 && s == counter_next)
            vector_backoff(1,counter_vector) = s;
            counter_next = s + 8;
            counter_vector = counter_vector +1;
        elseif (s> 500 && 2000 && s == counter_next)
            vector_backoff(1,counter_vector) = s; 
            counter_next = s + 32;
            counter_vector = counter_vector +1;
        end
        
    end
    vector_backoff = unique(vector_backoff);
    vector_backoff_eliminate = zeros(1,counter_vector-1);
    counter_vector_2 = 1;
    for s=1:1:size(vector_backoff,2) 
        if (vector_backoff(1,s) > 0)
           vector_backoff_eliminate(1,counter_vector_2)  = vector_backoff(1,s);
           counter_vector_2 = counter_vector_2 + 1;
        end
    end
     vector_backoff = vector_backoff_eliminate;
   elseif(test_find_backoff_optimal_on == 2)
       vector_backoff = zeros(1,no_backoff_window_size_max); % vector_backoff init
        for s=1:1:no_backoff_window_size_max
            vector_backoff(1,s) = s; 
        end
    end
end

