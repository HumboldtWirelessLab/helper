Click-Skripte bauen
*******************
Vorwissen: Click-Paper

Bevor man beginnt ein Click-Skript zu entwickeln, sollte man erst einmal einen Entwurf machen, in dem man festhält, welches Ziel man in der Simulation verfolgt. Das Skript, welches man am Ende entwickelt, liefert den Netzwerkknoten, auf dem es läuft, einen vollständigen Netzwerkstack. Dementsprechend müssen Netzwerkgeräte, Routing-Protokolle, u. Ä. in den Entwurft mit einbezogen werden. Die Vorüberlegungen beinhalten:

* Welche Elemente oder Elementklassen dafür benötigt werden und

* wie diese Elemente miteinander verbunden sind. 

Höchst wahrscheinlich benötigt man ein Wifi-Device, welches stellvertretend für die physikalische Schicht steht. Sodann wird ein Routing-Protokoll benötigt, stellvertretend für den Vermittlungsschicht.

*Achtung: Unsere Click-Architektur verwendet Ethernet-Routing und unterscheidet sich daher von üblichen Schichtenmodellen. Das bedeutet, dass bei der Verknüpfung eines Wifi-Devices mit einem Routing-Modul die Elemente BRN2EtherEncap(), BRN2EtherDecap(), BRN2Encap(), BRNDecap() verwendet werden müssen. Näheres dazu im nächsten Abschnitt.*

Elemente zum Senden und Empfangen im BRN2-Netzwerk
==================================================
Jedes zu übertragene Paket benötigt einen Header, der Netzwerkinformationen enthält, die z. B. für das Routing von Packeten wichtig sind. Um die Packete mit den entsprechenden Headern korrekt auszustatten, gibt es verschiedene Elemente. 

* BRN2EtherEncap(), BRN2EtherDecap()
Hinzufügen und Enternen der Ethernet-Header im BRN-Netz.

* BRN2Encap(), BRNDecap()
Hinzufügen und Entfernen der BRN-Header. *Achtung*: Das BRN2Encap() ist ein Element ohne In- und Outputs und ist daher als Fluss-Element nicht zu gebrauchen. Es stellt hauptsächlich eine Funktion namens "add_brn_header()" zur Verfügung, die von anderen Click-Elementen verwendet werden kann und sollte. Dies hat einen konzeptionellen Grund, nämlich eine größere Kontrolle über die zu verschickenden Packete zu erhalten. Hier ein Beispiel::

	tls
		// -> BRN2Decap() /* Diese Funktion wird vom "tls"-Element implizit übernommen*/
		-> BRN2EtherEncap(USEANNO true)
		-> [1]device_wifi;
		
In diesem Beispiel enthält das tls nicht nur die Packet-Generierungsfunktion *Packet::make()* sondern auch *BRNPacketAnno::set_ether_anno()* und *BRNProtocol::add_brn_header()*.

* EtherEncap(), EtherDecap()
Hinzufügen und Entfernen der standerd Ethernet-Header. Diese sind allerdings für das BRN-Netzwerk wenig brauchbar.


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
	
 
