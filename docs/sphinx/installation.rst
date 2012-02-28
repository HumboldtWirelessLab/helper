Click
*****

Installation
============

Vorbereitungen
--------------

#. Benötigte Software installieren: gcc, g++, autoconf, libx11-dev, libxt-dev, libxmu-dev, flex, bison, git

   gcc und g++ müssen zur Zeit in Version 4.4 vorliegen.
   Zum Übersetzen der Software sollten also die Pakete gcc-4.4 und g++-4.4 installiert werden und temporär
   die symbolischen Links in /usr/bin auf die entsprechenden binaries gesetzt werden::

        sudo rm /usr/bin/gcc
        sudo rm /usr/bin/g++
        sudo ln -s /usr/bin/gcc-4.4 /usr/bin/gcc
        sudo ln -s /usr/bin/g++-4.4 /usr/bin/g++

#. Account auf gitsar bei Robert beantragen

#. Folgende Einträge in der .ssh/config vornehmen: ::

    Host gruenau
        User username
        HostName gruenau.informatik.hu-berlin.de

    Host gitsar
        User username
        ProxyCommand ssh -q gruenau netcat sar 2222

Am komfortabelsten funktioniert die Verbindung beim Einsatz von
`SSH-Keys und dem ssh-agent <http://mah.everybody.org/docs/ssh>`_, da man dann
nur einmal die Passphrase für den SSH Schlüssel eingeben muss.

Software auschecken
-------------------

#. In einem separaten Terminal SSH Verbindung zu gruenau herstellen (und geöffnet halten)::

    ssh gruenau

#. click-brn auschecken::

    git clone ssh://gitsar/home/sombrutz/repository/click-brn/.git

#. brn-tools.sh ausführen::

    cp click-brn/elements/brn2/tools/brn-tools.sh .
    chmod a+x brn-tools.sh
    ./brn-tools.sh

#. Umgebungsvariablen setzen. Entweder per ``source /tmp/./brn-tools.bashrc`` oder durch das Kopieren der Einträge in ``brn-tools.bashrc`` in die eigene ``.bashrc``

Testen
------

Zum Testen der Installation kann die *simple_flow* (oder eine andere) Simulation ausgeführt werden::

    cd click-brn-scripts/003-simple_flow
    run_sim.sh


Die Ausgabe der Simulation sollte dabei folgendermaßen aussehen::

    sim is ns
    Send 26 packet, received 26 packets and 26 echo packets are received. OK !

Alternativ können über das Shellscript test.sh alle Simulationen angestoßen werden. ``test.sh``
erzeugt dabei ein pdf namens ``testbed.pdf``, welches die Resultate aller Simulationen enthält.

Troubleshooting
---------------

* Wenn die Simulation mit dem Fehler ``*** buffer overflow detected ***: ./ns terminated``
    abbricht liegt das vermutlich daran, dass die falsche TCL Version verwendet wird. Abhilfe
    schafft entweder die Deinstallation von TCL auf dem System oder aber das Sicherstellen,
    dass ns2/bin/tcl vor den Systembinaries im Pfad liegt.

* Falls das Ausführen von test.sh Warnungen und/oder Fehler erzeugt liegt dies unter Ubuntu
    Systemen evtl. daran, dass die dash als System Shell verwendet wird. Eine mögliche Lösung
    besteht darin, eine andere System Shell mittels ``sudo dpkg-reconfigure dash`` festzulegen.

Simulationen
============

Im Ordner ``simulation/click-brn-scripts/`` liegen Simulationsscripte für
verschiedene Experimente. Beim Ausführen der Scripte (siehe :ref:`running-simulations`)
werden verschiedene die Ausgaben der verschiedenen Knoten gesammelt.
Anschließend werden diese Ausgaben analysiert und ausgewertet und die
Resultate im Ordner ``simulation/click-brn-scripts/<SCRIPT>/<NUMBER_OF_EXPERIMENT>``
gespeichert.

Eine Simulation wird durch die folgenden beiden Dateien definiert:

* Mes-files beinhalten alle Geräte, die für das Experiment vorbereitet werden.
* Des-Files beinhalten eine grobe Beschreibung vom Experiment. Z.b.: Die Dauer des Experiments; das Verzeichnis für die log-files; Netzwerk-Topologie; etc. ...

.. _running-simulations:

run_sim.sh
----------

Um eine Simulation auszuführen wird das *run_sim.sh* Script verwendet, welches
sich im Verzeichnis */helper/simulation/bin/* befindet. Das Script nimmt als
Parameter den zu verwendenden Simulator (*ns* oder *jist*) und den Pfad zur
*des* Datei der Simulation entgegen::

   run_sim.sh ns <des-File>
   run_sim.sh jist <des-File>

Experimente im Testbed
======================

clickctrl.sh
------------

Mit dem *clickctrl.sh* Script (zu Finden im Ordner */helper/host/bin/* kann man
einzelne Handler von einzelnen Knoten im Netzwerk abfragen oder schreiben. Ein
Anwendungsfall ist beispielsweise das Abfragen von Statistiken zur Laufzeit
eines Experiments. Das Skript wird folgendermaßen aufgerufen::

    clickctrl.sh read address port element handler
    clickctrl.sh write address port element handler "arguments of element"


Das Skript verwendet intern das `ControlSocket <http://read.cs.ucla.edu/click/elements/controlsocket>`_
Element.

Weitere Dokumentation
=====================

* Search click documentation: http://read.cs.ucla.edu/click/docs
* Publications about click and stuff that uses click: http://read.cs.ucla.edu/click/publications
* Manual how to program click elements: http://read.cs.ucla.edu/click/doxygen/class_element.html
* Information about click elements: http://www.read.cs.ucla.edu/click/elements
* Network Simulator 2 (NS2) Docu: http://isi.edu/nsnam/ns/
