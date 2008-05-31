FromDevice(ath0)
 ->AthdescDecap()
// ->Prism2Decap()
// ->RadiotapDecap()
  ->PrintWifi(TIMESTAMP true)
//  ->Print("-> ",200)
  ->Discard();
  
Script(                                                                                                                                                                                                             
  wait 121,                                                                                                                                                                                                        
  stop                                                                                                                                                                                                            
);
