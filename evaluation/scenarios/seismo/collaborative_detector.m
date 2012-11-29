% Author: kuehne@informatik.hu-berlin.de
% Purpose: This program computes the false-positives, true-negatives and true-positives 
%			of an experiment having real events and the sensoric detections of a mesh node.
% Input: vector of event data; vector of detected data
% Output: false-positives, true-negatives and true-positives

% Checks
% - Bound-checking
% - type-checking: no types

function collaborative_detector(events, detected, offset, range)

%clear;
%close all;


%offset = 0;
%range = 5;

%events = [1 19 21 58 113 161 196 239 268 295 318 384 411 445 486];
%detected = [1 18 22 60 113 164 172 196 239 293 318 349 384 445 486];


events = (events+offset);
detected = (detected);

cnt_false_pos = 0;
cnt_false_neg = 0;
cnt_true_pos = 0;

% bound-checking
if any(events<0) || any(detected<0)
	disp("Error: Values < 0");
	return;
end


j=1;

for i=1:length(events)
	# Get the detection value into the range of the event 
	while (j <= length(detected) &&  detected(j) < events(i)-range)
		j += 1;
		# Every event not in the range of detections is a false positive
		cnt_false_pos += 1;
	end
	
	% store true positives to encounter false negatives
	tmp_cnt_true_pos = cnt_true_pos;
	
	for k = j:length(detected)
		if ( events(i)-range <= detected(k) && detected(k) <= events(i)+range ) 
			cnt_true_pos += 1;
			j += 1;
			
			both = [events(i) detected(k)];
			disp(both);
			
			% match only one detection on event, further matches are counted as false positives
			break;
		end
	end
	
	% if by a new event we got no new true positives than we hit a false negative
	if (tmp_cnt_true_pos == cnt_true_pos)
		cnt_false_neg += 1;
	end
end

disp(cnt_true_pos);
disp(cnt_false_pos);
disp(cnt_false_neg);

end
