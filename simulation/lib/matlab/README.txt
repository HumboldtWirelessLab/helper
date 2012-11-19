Matlab-Simulator
================
Die Matlab-Simulation simuliert Kollisionen zwischen einer unterschiedlichen Anzahl von Nachbarn und verschiedenen Backoff-Fenstergrößen. Ergebnisse für diese Simulation sind in dem Verzeichnis "messungen" vorgeneriert worden. 

Weiterhin werden dann mit den Simulationsergebnissen der maximale Durchsatz für verschiedene Datenraten (je nach Spezifikation 802.11a/b/g/n) und verschiedene MSDU-Größen berechnet.

Anschließend werden die Ergebnisse nach dem maximalen Durchsatz für die Bandbreiteneffizienz, Kollisionswahrscheinlichkeit und Backoff-Fenstergrößen gefiltert und mit dem Geburtstagspradoxon und einer Approximation für das Geburtstagsparadoxon verglichen.

Hauptdatei:
===========
sim_main.m

Ausführung:
===========
1. Zuerst "./configure.sh" ausführen

"./configure.sh" erzeugt "./run_sim.sh", wobei "./run_sim.sh" wiederum "./run_matlab.sh" mit verschiedenen Parametern aufruft

Es gibt folgende Parameter:
1. Matlab-Datei ohne (*.m)-Endung angeben
2. Wird der Simulator auf einem Server, wie z. B. "Grüenau" ausgeführt oder auf dem lokalen PC ausgeführt?
3. Wenn der Simulator auf dem lokalen PC ausgeführt wird, dann erhält man noch folgende Optionen:
    3.1 Sollen die Graphiken ausgegeben werden?
    3.2 Wird ein Pfad zum Matlab-Programm benötigt?

    3.3 Anmerkungen:
    ===============
    - Falls Graphiken ausgegeben werden sollen, kann man die Graphiken und Matlab mit einem beliebigen Tastendruck beenden, indem mit der Maus eine beliebige Graphik ausgewählt wird 
      und anschließend eine beliebige Taste gedrückt wird.
    - Wird der Simulator auf einem Server ausgeführt, wird automatisch keine graphische Ausgabe generiert

4. Simulator mit "./run_sim.sh" starten


