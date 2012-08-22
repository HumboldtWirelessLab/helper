Click-Skripte bauen
*******************
Vorwissen: Click-Paper

Zuvor eine historische Notiz, die dem Leser den Ursprung einiger hier verwendeter Elemente erkären soll.

Historisch ist das HWL-Netzwerk aus zwei Projekten hervorgegangen: zum einen aus dem MIT-Projekt "Click Modular Router", welches das Framework liefert und zum anderen aus der Kooperation zwischen dem berliner Freifunkt-Projekt "Berlin-Roof-Net" (BRN) und der HU-Berlin (SAR-Group). Diese Kooperation hatte die Erforschung und Konstruktion eines drahtlosen Ad-Hoc-Netzwerkes zum Zweck und ergänzte das Framework um weitere wichtige Netzwerkelemente, die den Betrieb des BRN-Netzwerkes ermöglichten. Die weitere Entwicklungs- und Forschungsarbeit wurde am Informatik-Institut in Form des BRN2-Netzwerkes fortgesetz, baut jedoch nach wie vor auf den Arbeiten von Click und BRN auf. Die Kombination aus Click-System (Framework), BRN (speziell entwickeltes Netzwerk) und BRN2 (zusätzliche Komponenten) ist Teil des HWL-Netzwerkes (Humbold Wireless Lab).

Diese historischen Vorgänge spiegeln sich im ganzen Dateisystem und der Namensgebung wider und sollten dem Leser bewußt sein.

Bevor man beginnt ein Click-Skript zu entwickeln, sollte man erst einmal einen Entwurf machen, in dem man festhält, welches Ziel man in der Simulation verfolgt. Das Skript, welches man am Ende entwickelt, liefert den Netzwerkknoten, auf dem es läuft, einen vollständigen Netzwerkstack. Dementsprechend müssen Netzwerkgeräte, Routing-Protokolle, u. Ä. in den Entwurft mit einbezogen werden. Die Vorüberlegungen beinhalten:

* Welche Elemente oder Elementklassen dafür benötigt werden und

* wie diese Elemente miteinander verbunden sind. 

Höchst wahrscheinlich benötigt man ein Wifi-Device, welches stellvertretend für die physikalische Schicht steht. Sodann wird ein Routing-Protokoll benötigt, stellvertretend für den Vermittlungsschicht.

*Achtung: Unsere Click-Architektur verwendet Ethernet-Routing und unterscheidet sich daher von üblichen Schichtenmodellen. Das bedeutet, dass bei der Verknüpfung eines Wifi-Devices mit einem Routing-Modul die Elemente BRN2EtherEncap(), BRN2EtherDecap(), BRN2Encap(), BRNDecap() verwendet werden müssen. Näheres dazu im nächsten Abschnitt.*

Elemente zum Senden und Empfangen im BRN2-Netzwerk
==================================================
Jedes zu übertragene Paket benötigt einen Ethernet-Header, um einfache Ad-Hoc-Kommunikation, Infrastruktur-Kommunikation oder Ethernet-Routing (unter Zuhilfenahme eines Routing-Protokolls) durchzuführen. Der Ethernet-Header enthält unter anderem die Quell- und Zieladresse. Für das Hinzufügen und Entfernen der Ethernet-Header benötigt man die folgenden Click-Elemente:

* BRN2EtherEncap()
* BRN2EtherDecap()


Zusätzliche Informationen, die für die BRN2-Netzwerkkommunikation wichtig sind, werden in einem sogenannten BRN2-Header verpackt. Für das Hinzufügen und Entfernen der BRN-Header, benötigt man folgende Click-Elemente (die Makros in BRN2Encap dienen der Default-Einstellung):

* BRN2Encap(BRN_PORT_FLOW, BRN_PORT_FLOW, BRN_DEFAULT_TTL, BRN_DEFAULT_TOS)
* BRN2Decap()

Beispiel::

	tls
		-> BRN2Encap(BRN_PORT_FLOW, BRN_PORT_FLOW, BRN_DEFAULT_TTL, BRN_DEFAULT_TOS)
		-> BRN2EtherEncap(USEANNO true)
		-> [1]device_wifi;

Neben der Verwendung von BRN2Encap im Click-Script, lässt sich dieser Header auch direkt bei der Paketverarbeitung innerhalb der Click-Elemente (C++) einsetzen. Dies ermöglicht eine größere Kontrolle über die Paketinformationen. Die entsprechende Funktion nennt sich "add_brn_header()". Hier ein Beispiel::

	tls
		// -> BRN2Encap() /* Diese Funktion wird vom "tls"-Element implizit übernommen*/
		-> BRN2EtherEncap(USEANNO true)
		-> [1]device_wifi;
		
In diesem Beispiel enthält das tls nicht nur die Packet-Generierungsfunktion *Packet::make()* sondern auch *BRNProtocol::add_brn_header()* und *BRNPacketAnno::set_ether_anno()*.


Besonderheiten in der BRN-Architektur
=====================================
Das Click-Skript wird beim Aufruf mit run_sim.sh vorbereitet. Dabei werden einige Variablen durch spezifische Informationen über das Netzwerkgerät, den Knoten, etz. ersetzt. Die wichtigsten Informationen stehen in der mes-Datei (oder auch Nodetable genannt). 



Simulation & Debugging
======================
Wer eine genauere Analyse des Netzwerkverkehrs machen möchte, der sollte sich die dumps anschauen. Das dumping muss jedoch zuvor aktiviert werden im Click-Skript. Dazu fügt man diese beiden Zeilen an forderster Stelle im Click-Skript ein::

	#define RAWDUMP
	#define RAWDEV_DEBUG
	
	
Problembehandlung
=================
In den äußersten Fällen, da plötzlich Fehler unangemeldet auftreten und bei allen Debugging-Anstrengungen hartnäckig bestehen bleiben, hilft ein kompletter Neubau::
	
	make clean
	make elemlist all
	
 
