BRN-Tools
************

Overview
============

brn-tools
--------------

#. Folgende Verzeichnisse enthaelt brn-tools: 
    #. brn-ns2-click
    #. click-brn
    #. click-brn-scripts
    #. helper
    #. jist-brn
    #. ns2
    #. ns-3-brn


click-brn
=========

Enthaelt das Click-Framework inklusive der BRN-Erweiterung.


helper
======

Enthaelt die Tools und Werkzeuge zum starten von Simlulationen, Messungen im Testbed und zur Auswertung.


run-sim.sh
----------

Zum Starten einer Simulation: run_sim.sh [ns|ns3|jist] [des-file] [target-dir]

#. Parameter
    #. Verwendeter Simulator (NS2, NS3 oder JiST)
    #. des-File (Beschreibung der Simulation)
    #. Ziel-Verzeichnis


#. Umgebungsvariablen

Das Skript kann ueber Umgebungsvariablen zusaetzliche Optionen erhalten. Folgende Mglichkeiten lassen sich so nutzen:
* Debugger (gdb): GDB
* Leak-Checker (Valgrind): VALGRIND
* Profiler (Callgrind): PROFILER
* Abschalten der Simulation (benutzt von parasim): PREPARE_ONLY
* Abschalten der Evaluation (benutzt von parasim): DELAYEVALUATION


Wichtig
=====================

Die wichtigsten Verzeichnisse sind:
#. click-brn
#. click-brn-scripts
#. helper

Das wichtigste Kommando:
#. run_sim.sh
