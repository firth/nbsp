BEGIN {
  FS = ",";
  OFS = ",";
}

{
  print $1,$2,$3;
}
