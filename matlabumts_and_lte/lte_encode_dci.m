
function dciout = lte_encode_dci( dci, numCCE)

  [d0 d1 d2 ] = lte_tailbite_enc(dci);
  v0 = lte_conv_int(d0);
  v1 = lte_conv_int(d1);
  v2 = lte_conv_int(d2);
  dcicoded = [v0 v1 v2];
  
  dci_size_bits = numCCE * 9 * 4 * 2; % 9 REGs per CCE, 4 QPSK carriers per CCE, 2 bits of QPSK
  
  dciout = lte_conv_ratematch(dcicoded, dci_size_bits);
  
end