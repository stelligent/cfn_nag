#!/usr/local/bin/perl -w
while (<>) {
  $correctedvariable = $_;
  $correctedvariable =~ s/(^\S+)/$1\,/g;
  $correctedvariable =~ s/, /,/g;
  print $correctedvariable;
}
