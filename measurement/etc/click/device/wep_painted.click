/*
 * wep_painted.click
 *
 *  Created on: 06.07.2012
 *      Author: aureliano
 */

/*
 * Packet oriented wep encryption mechanism.
 *
 * Input:
 * 	0: to WepEncap
 * 	1: to WepDecap
 *
 * Output:
 * 	0: to network
 *  1: from network
 */

elementclass WepPainted {KEY $key, ACTIVE $active, DEBUG $debug |

	wep_decap::WepDecap(KEY $key, KEYID 0);
	wep_encap::WepEncap(KEY $key, KEYID 0, ACTIVE $active, DEBUG $debug);

	input[0]
	    -> wep_encap_checkpaint::CheckPaint(COLOR 42) // If painted, then DONT encrypt
	    -> [0]output;

	wep_encap_checkpaint[1]
	    -> wep_encap
	    -> [0]output;

	input[1]
	    -> wep_clf::Classifier(1/40%40, -) // Test of wep frame
		-> wep_decap
		-> wep_decap_clf::Classifier(1/40%40, -) // If decap fails, we still have an undecryptable wep-frame
		-> Discard;

	wep_clf[1]
	    -> Paint(COLOR 42) // If not wep frames, then paint
		-> [1]output;

	wep_decap_clf[1] // successful decap
		-> [1]output;
}
