function func_sim_generator_random_set(seed_value)
if (seed_value >= 0)
    %see http://blogs.mathworks.com/loren/2008/11/05/new-ways-with-random-numbers-part-i/
    %see http://blogs.mathworks.com/loren/2008/11/13/new-ways-with-random-numbers-part-ii/
    %see http://www.mathworks.de/de/help/matlab/ref/randstream.html
    stream0 = RandStream('mt19937ar','Seed',seed_value); % Mersenne Twister, change seed value 
    RandStream.setGlobalStream(stream0);
elseif (seed_value == -1)
    rng shuffle % creates a different seed each time; see http://www.mathworks.de/help/techdoc/math/bs1qb_i.html
end

end

