Click-Elemente bauen
********************

.. _handler:

Handler
=======

Handler bauen
-------------

Handler sind Zugangspunkte, mittels derer die Nutzer mit einzelnen Elementen
zur Laufzeit des Click-Routers interagieren können. Man unterscheidet dabei
zwischen read und write handlern, die sich jeweils wie Dateien in einem
Dateisystem verhalten. Im folgenden wird dies anhand eines Beispiels erläutert.

#. Falls nicht vorhanden, füge eine Klassen-Methode mit dem Namen
   add_handlers() zum Element hinzu. Diese Funktion dient als Sammelstelle für
   die Registrierung aller Element-Handler::

	void
	MyElement::add_handlers()
	{
		//todo
	}

#. Als nächstes folgt die read/write Handler im einzelnen. Dazu werden die
   Methoden *add_read_handler* und *add_write_handler* verwendet. Das Argument
   *name* definiert den Namen des Handlers, *func* steht für die aufzurufende
   Funktion und *thunk* für zusätzliche Parameter. Vollständige Signatur und
   Beispiel::

	void add_read_handler (const String &name, ReadHandler func, void *thunk)
	void add_write_handler (const String &name, WriteHandler func, void *thunk)

	// Beispiel
	add_read_handler("info", read_my_param, (void *) H_READ);
	add_write_handler("debug", write_my_param, (void *) H_DEBUG);

#. Nun müssen die Funktionen der neu eingeführten Handler definiert werden.
   (Die Besonderheit ist hier das Schlüsselwort static. Dies hat tiefergehende
   Gründe, die hier nicht weiter diskutiert werden.) ::

	#include <click/straccum.hh>
	...
	static String
	read_my_param(Element *e, void *thunk) {
		StringAccum sa;
		// do foo hier
		return String();
	}

	static int
	write_my_param(const String &string, Element *e, void *vparam, ErrorHandler *errh) {

		MyElement *e = (MyElement *)e; //cast
		e->cmd = string;
	}

Quelle: http://www.read.cs.ucla.edu/click/element?s[]=handler


Handler verwenden
-----------------

Handler können auf verschiedenste Weisen verwendet werden.

* In einem Click-Script: Dazu wird meist ein *Script*-Bereich am Ende eines
  Click-Scripts eingeführt. ::

	...

	Script(
	read MyElement.info,
	write MyElement.debug 3
	);

Quelle: http://www.read.cs.ucla.edu/click/elements/script?s[]=handler

* ControlSocket

Quelle: http://www.read.cs.ucla.edu/click/elements/controlsocket?s[]=handler

Weiterführende Links
--------------------
*



OpenSSL
=======
Bei der Verwendung der Funktionen aus der SSL-Library ist es notwendig, dem Compiler mitzuteilen, dass er die ssl-lib mitlinken soll. Dies geschieht durch das Hinzufügen der folgenden Zeile an das Ende der Quelldatei eines Elementes, in dem die SSL-Includes zur Anwendung kommen::

	ELEMENT_LIBS(-lssl)


