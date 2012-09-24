no_neighbours_max = 100;
is_Address4_requiered = 0; % 1:= yes, else no
greenfield_use = 1; % 0:= off; 1:= on
dsss_ofdm_use = 1; % 0:= off; 1:= on
packet_delivery_limit = 100;
number_of_simulation = 1000;
no_backoff_window_size_max =3000;
%------------------------Contention Window Params --------------------------------------------------------------------------
test_find_backoff_optimal_on = 2; % 0:= off; 1:= on
[vector_backoff] = func_cw_vector_get(test_find_backoff_optimal_on, no_backoff_window_size_max);


