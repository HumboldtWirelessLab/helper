/*
 * wep.click
 *
 *  Created on: 06.07.2012
 *  modified: 20.08.2012
 *      Author: kuehne@informatik.hu-berlin.de
 */

/*
 *
 * Behaviour:
 * This element tries to decrypt and encrypt wep frames. 
 * If successful: forward
 * otherwise: discard. 
 *
 * Input:
 * 	0: to WepEncap
 * 	1: to WepDecap
 *
 * Output:
 * 	0: to network
 *  1: from network
 */

elementclass Wep {KEY $key, ACTIVE $active, DEBUG $debug |

	wep_decap	::WepDecap(KEY $key, KEYID 0);
	wep_encap	::WepEncap(KEY $key, KEYID 0, ACTIVE $active, DEBUG $debug);
	
	is_TLS 		:: Classifier(25/aa,-);

	input[0]
		-> is_TLS[1]
	    -> wep_encap
	    //-> Print("encrypted ............",100, TIMESTAMP true)
	    -> [0]output;
	    
	    is_TLS
	    	-> [0]output;

	input[1]
	    -> wep_clf::Classifier(1/40%40, -) // Test of wep frame
		-> wep_decap
		-> wep_decap_clf::Classifier(1/40%40, -) // If decap fails, we still have an undecryptable wep-frame
		-> Discard;

	wep_clf[1]
		-> [1]output;

	wep_decap_clf[1] // successful decap
		//-> Print("decrypted .............",100, TIMESTAMP true)
		-> [1]output;
}
