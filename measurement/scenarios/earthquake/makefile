all:
	gcc -o eq_sim eq_sim.c -lm

clean:
	rm -rf eq_sim

simclean: clean
	rm -f eq.stats handler.do  placement.plm simulation.dis simulation.mes

sim:
	./gen_files.sh
