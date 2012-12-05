% For this backoff calculation, see formula (3) in paper: 
%       Geng Cheng, Wei Liu, Yunzhao Li, Wenqing Cheng :
%           "Spectrum Aware On-demand Routing in Cognitive Radio Networks"
function [ delay_backoff ] = func_medium_access_delay(number_of_contending_nodes, likelihood_collision, cw_min)
nenner = (1-likelihood_collision) * ( 1 - ((1 -likelihood_collision)^(1/(number_of_contending_nodes - 1))));
delay_backoff = (1/nenner) * cw_min;

end

