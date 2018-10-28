
BEGIN {  }
(NR==FNR) {  # file1, index by lineno and string
  ll1[FNR]=$4; ss1[$4]=FNR; nl1=FNR;
}
(NR!=FNR) {  # file2
  if ($4 in ss1) { delete ll1[ss1[$4]]; delete ss1[$4]; }
}
END {
  for (ll=1; ll<=nl1; ll++) if (ll in ll1) print ll1[ll]
}
