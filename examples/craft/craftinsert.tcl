#!/usr/local/bin/tclsh8.6
#
# $Id$
#
# Installation -
#
# CRAFT <tab> ^L2-BZIP2/(....)/([0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9]) \
#                       ([0-2][0-9][0-5][0-9])([0-9][0-9])/([0-9]*)/([0-9]*)/E
# <tab> EXEC <tab> bin/craftinsert data/gempak/nexrad/craft/\1/\1_\2_\3

proc err {s} {
    
    puts stderr $s;
    exit 1;
}

proc proc_nbsp {ppath} {

    global craftinsert;

    set spooldir $craftinsert(nbspd_craftspooldir);
    set wmoid $craftinsert(nbspd_wmoid);

    # The spooldir must exist
    if {[file isdirectory $spooldir] == 0} {
	return -code error "Sppol directory does not exist: $spooldir";
    }

    # extract info from input name
    set input_name [file tail $ppath];
    if {[regexp {^([A-Z]{4})_(\d{8})_(\d{4})} \
	     $input_name match STATION ymd hm] == 0} {
	return -code error "Invalid file name: $input_name";
    }

    set station [string tolower $STATION];
    append dhm [string range $ymd 6 7] $hm;
    append seq $ymd $hm;

    append fname $station "_" $wmoid;
    append fbasename $fname "." $dhm "_" $seq;
    
    set fpath [file join $spooldir $station $fbasename];
    set finfo "$seq 0 0 0 0 $fname $fpath";

    file mkdir [file dirname $fpath];
    file rename -force $ppath $fpath;
    # exec nbspinsert -f $craftinsert(nbspd_infifo) $finfo;
}

#
# main
#
set craftinsert(conf) "/usr/local/etc/craftinsert/craftinsert.conf";
#
set craftinsert(nbspd_enable) 0;
set craftinsert(nbspd_craftspooldir) "/var/noaaport/nbsp/spool/craft";
set craftinsert(nbspd_infifo) "/var/run/nbsp/infeed.fifo";
set craftinsert(nbspd_wmoid) "level2";
set craftinsert(nbspd_mvtospool) 1;  # move or copy to spool dir

# Read optional config file
if {[file exists $craftinsert(conf)]} {
    source $craftinsert(conf);
}

set argc [llength $argv];
if {$argc == 0} {
    err "Requires an argument.";
}

# Get the (partial) path
set ppath [lindex $argv 0];

# Strategy -
#
# Ldm is setup such that:
#
# (1) the ppath argument is of the form
#    <directory>/<name>
# (2) the tmp file that contains the data is
#    ${ppath}.tmp
#

append tmppath $ppath ".tmp";
if {[file exists $tmppath]} {
    file rename -force $tmppath $ppath;
}

if {$craftinsert(nbspd_enable) == 1} {
    proc_nbsp $ppath;
}
