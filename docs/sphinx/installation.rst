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
        LocalForward 23452 sar.informatik.hu-berlin.de:2222

    Host gitsar
        User username
        HostName localhost
        Port 23452

Software auschecken
-------------------

#. In einem separaten Terminal SSH Verbindung zu gruenau herstellen (und geöffnet halten)::
    
    ssh gruenau

#. click-brn auschecken::

    git clone ssh://gitsar/home/sombrutz/repository/click-brn/.git

#. brn-tools.sh ausführen::

    cp click-brn/elements/brn2/brn-tools.sh .
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
    