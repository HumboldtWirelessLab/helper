Click-Skripte bauen für Networking
**********************************
Vorwissen: Click-Paper (http://read.cs.ucla.edu/click/publications)

Zuvor eine historische Notiz, die dem Leser den Ursprung einiger hier
verwendeter Elemente erklären soll.

Historisch ist das HWL-Netzwerk aus zwei Projekten hervorgegangen: Zum einen aus
dem MIT-Projekt "Click Modular Router", welches das Framework liefert, und zum
anderen aus der Kooperation zwischen dem Berliner Freifunk-Projekt
"Berlin-Roof-Net" (BRN) und der HU-Berlin (SAR-Group). Diese Kooperation hatte
die Erforschung und Konstruktion eines drahtlosen Ad-Hoc-Netzwerkes zum Zweck
und ergänzte das Framework um weitere wichtige Netzwerkelemente, die den
Betrieb des BRN-Netzwerkes ermöglichten. Die weitere Entwicklungs- und
Forschungsarbeit wurde am Institut für Informatik in Form des BRN2-Netzwerkes
fortgesetzt, baut jedoch nach wie vor auf den Arbeiten von Click und BRN auf.
Die Kombination aus Click-System (Framework), BRN (speziell entwickeltes
Netzwerk) und BRN2 (zusätzliche Komponenten) ist Teil des HWL-Netzwerkes
(Humboldt Wireless Lab).

Diese historischen Vorgänge spiegeln sich im ganzen Dateisystem und der
Namensgebung wider.

Bevor man beginnt ein Click-Skript zu entwickeln, sollte man erst einmal einen
Entwurf machen, in dem man festhält, welches Ziel man in der Simulation
verfolgt. Das Skript, welches man am Ende entwickelt, liefert den
Netzwerkknoten, auf dem es läuft, einen vollständigen Netzwerkstack.
Dementsprechend müssen Netzwerkgeräte, Routing-Protokolle, u. Ä. in den
Entwurf mit einbezogen werden. Die Vorüberlegungen beinhalten:

    * Welche Elemente oder Elementklassen dafür benötigt werden und
    * wie diese Elemente miteinander verbunden sind.

Höchst wahrscheinlich benötigt man ein Wifi-Device, welches stellvertretend
für die physikalische Schicht steht. Sodann wird ein Routing-Protokoll
benötigt, stellvertretend für den Vermittlungsschicht.

*Achtung: Unsere Click-Architektur verwendet Ethernet-Routing und unterscheidet
sich daher von üblichen Schichtenmodellen. Das bedeutet, dass bei der
Verknüpfung eines Wifi-Devices mit einem Routing-Modul die Elemente
BRN2EtherEncap(), BRN2EtherDecap(), BRN2Encap(), BRNDecap() verwendet werden
müssen. Näheres dazu im nächsten Abschnitt.*

Elemente zum Senden und Empfangen im BRN2-Netzwerk
==================================================

Jedes zu übertragene Paket
benötigt einen Ethernet-Header, um einfache Ad-Hoc-Kommunikation,
Infrastruktur-Kommunikation oder Ethernet-Routing (unter Zuhilfenahme eines
Routing-Protokolls) durchzuführen. Der Ethernet-Header enthält unter anderem
die Quell- und Zieladresse. Für das Hinzufügen und Entfernen der
Ethernet-Header benötigt man die folgenden Click-Elemente:

    * BRN2EtherEncap()
    * BRN2EtherDecap()


Zusätzliche Informationen, die für die BRN2-Netzwerkkommunikation wichtig
sind, werden in einem sogenannten BRN2-Header verpackt. Für das Hinzufügen und
Entfernen der BRN-Header, benötigt man folgende Click-Elemente (die Makros in
BRN2Encap dienen der Default-Einstellung):

    * BRN2Encap(BRN_PORT_FLOW, BRN_PORT_FLOW, BRN_DEFAULT_TTL, BRN_DEFAULT_TOS)
    * BRN2Decap()

Beispiel::

    tls
        -> BRN2Encap(BRN_PORT_FLOW, BRN_PORT_FLOW, BRN_DEFAULT_TTL, BRN_DEFAULT_TOS)
        -> BRN2EtherEncap(USEANNO true)
        -> [1]device_wifi;

Neben der Verwendung von BRN2Encap im Click-Script, lässt sich dieser Header
auch direkt bei der Paketverarbeitung innerhalb der Click-Elemente (C++)
einsetzen. Dies ermöglicht eine größere Kontrolle über die
Paketinformationen. Die entsprechende Funktion nennt sich "add_brn_header()".
Hier ein Beispiel::

    tls
        // -> BRN2Encap() /* Diese Funktion wird vom "tls"-Element implizit übernommen*/
        -> BRN2EtherEncap(USEANNO true)
        -> [1]device_wifi;

In diesem Beispiel enthält das tls nicht nur die Packet-Generierungsfunktion
*Packet::make()* sondern auch *BRNProtocol::add_brn_header()* und
*BRNPacketAnno::set_ether_anno()*.


Aufbau eines BRN-Basispakets
============================

Aufbau::

       +-----------------------------------------------------------+
       |      |       | Typ    ||  Src  |  Dst   |     ||          |
       | Dst  |  Src  | 00086  ||  Port |  Port  |  ?  || Payload  |
       |      |       |        ||       |        |     ||          |
       +-----------------------------------------------------------+
          \______ Ether_______/   \_______BRN________/


Beim Einsatz von DSR wird aus dem Ether-Header ein DSR-Header gemacht.

Besonderheiten in der BRN-Architektur
=====================================

Das Click-Skript wird beim Aufruf mit run_sim.sh vorbereitet. Dabei werden einige
Variablen durch spezifische Informationen über das Netzwerkgerät, den Knoten,
etc. ersetzt. Die wichtigsten Informationen stehen in der mes-Datei (oder auch
Nodetable genannt).

Hilfsscripte
============

Mittlerweile existieren eine Reihe von Hilfsscripten welche häufig benötigte
Funktionalität implementieren. Diese script finden sich im *helper* repository
unter *helper/measurement/etc/click* und können mit *#include* Anweisungen
eingebunden werden. Wichtige Script sind zum Beispiel:

    * brn/brn.click Definition von Konstanten, insbesondere die Konstanten welche
      im BRN Header gesetzt werden um die unterschiedlichen Protokolle
      auseinanderzuhalten (z.B. BRN_PORT_DSR). Diese Konstanten können von
      *Classifier* Elementen verwendet werden, um einzelne Pakete unterschiedlicher
      Protokolle getrennt zu behandeln.

    * device/wifidev_linkstat Definition von WIFIDEV einer Abstraktion der WLAN
      Karte, welche sich unter anderem um das Link Probing kümmert. Die Zuordnung
      der Ein- und Ausgänge ist:

      output:

        * 0: To me and BRN
        * 1: Broadcast and BRN
        * 2: Foreign and BRN
        * 3: To me and NO BRN
        * 4: BROADCAST and NO BRN
        * 5: Foreign and NO BRN
        * 6: Feedback BRN
        * 7: Feedback Other

      input:

        * 0: brn
        * 1: client
        * 2: high priority stuff ( higher than linkprobes)

    * brn/helper.inc Definition von Macros FROMDEVICE und TODEVICE für
      unterschiedliche Szenarien (z.B. Simulation)
    * routing/routing.click Abstraktion der unterschiedlichen Routingprotokolle.
      Stellt ein einheitliches Interface für alle Routingprotokolle zur Verfügung.

Simulation & Debugging
======================

Wer eine genauere Analyse des
Netzwerkverkehrs machen möchte, der sollte sich die Dumps anschauen. Das
Dumping muss jedoch zuvor aktiviert werden im Click-Skript. Dazu fügt man diese
beiden Zeilen an vorderster Stelle im Click-Skript ein::

    #define RAWDUMP
    #define RAWDEV_DEBUG


Problembehandlung
=================

In den äußersten Fällen, da plötzlich
Fehler unangemeldet auftreten und bei allen Debugging-Anstrengungen hartnäckig
bestehen bleiben, hilft ein kompletter Neubau::

    make clean
    make elemlist all

Dies ist typischerweise der Fall, wenn die Initialisierungsliste des
Konstruktors verändert wird. Zum Beispiel so::

   BRN2DSREncap::BRN2DSREncap()
     : _link_table(),
           _me(),
           _neuer_Eintrag()
   {
     BRNElement::init();
   }


