function flowstats(f,of)
  d = load(f,'-ASCII');
  
  %TODO: check: mean over mean? 
  avg_time = mean(d(:,10))

  csvwrite(of,avg_time);
	
end