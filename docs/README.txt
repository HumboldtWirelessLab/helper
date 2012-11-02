Dokumentation mit Sphinx
------------------------

    Installation:
    -------------

    1. Unter Ubuntu Sphinx installieren: apt-get install python-sphinx
    
    2. In "helper/docs/sphinx/" befindet sich zum Generieren der Dokumentation ein Makefile ("make help" liefert alle Varianten)
        z. B. make latexpdf oder make html

    3. Nun befindet sich die Dokumentation in folgenden Verzeichnissen:
        1.  HTML-Dokumentation ("make html") befindet sich nach der Generierung in "helper/docs/sphinx/_build/html/index.html"
        2. PDF-Dokumentation ("make latexpdf") befindet sich nach der Generierung in "helper/docs/sphinx/_build/latex/HWL.pdf"
   
   Sphinx-Layout:
   --------------
   Die Dokumentation selber wird in reStructured Text geschrieben (siehe http://docutils.sourceforge.net/docs/user/rst/quickref.html#enumerated-lists)

