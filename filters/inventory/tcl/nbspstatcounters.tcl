#!%TCLSH%
#
# $Id$
#
# Usage: nbspstatcounters [-f <fmt>] [-c <chstatsfile>]
#                         [-q <qstatefile>] [-s <statusfile>]
#
# nbsp counters in the last minute (ending at "stats_time" (unix_seconds)).
#
# The default files are:
#
#     <statusfile>  stats/nbspd.status
#     <qstatefile>  stats/nbspd.qstate
#     <chstatsfile> inv/<hh>.stats
#
# The <fmt> can be: std (default), yaml, xml, csv, csvk

# The motivation for the existence of this tool is to use it for extracting
# and feeding the data to rrdtool or similar programs (it is used
# by the _inbsp extension in the web interface).

package require cmdline;
set usage {nbspstatcounters [-f <fmt>] [-c <chstatsfile>]
                            [-q <qstatefile>] [-s <statusfile>]};
set optlist {{f.arg "std"} {c.arg ""} {q.arg ""} {s.arg ""}};

## The common defaults
set _defaultsfile "/usr/local/etc/nbsp/filters.conf";
if {[file exists ${_defaultsfile}] == 0} {
    puts "${_defaultsfile} not found.";
    return 1;
}
source ${_defaultsfile};
unset _defaultsfile;

# nbspd.init is needed for the stats files and variables (log periods)
set nbspd_init_file [file join $common(libdir) nbspd.init];
if {[file exists $nbspd_init_file] == 0} {
    puts "$nbspd_init_file not found.";
    return 1;
}
source $nbspd_init_file;
unset nbspd_init_file;

# inventory.init is needed for the chstats file
set inventory_init_file [file join $common(libdir) inventory.init];
if {[file exists $inventory_init_file] == 0} {
    puts "$inventory_init_file not found.";
    return 1;
}
source $inventory_init_file;
unset inventory_init_file;

array set option [::cmdline::getoptions argv $optlist $usage];
set argc [llength $argv];

# defaults
set fmt $option(f);
set pidfile $nbspd(pidfile);
set qstatefile $nbspd(qstatelogfile);
set statusfile $nbspd(statusfile);
set chstatsfile [inventory_mk_chstats_fpath [clock seconds]];

#
set nbspstats_logperiod_secs $nbspd(nbspstats_logperiod_secs);
set qstate_logperiod_secs $nbspd(qstate_logperiod_secs);
#
# not configurable
#
set data_format 3;

# Initialization
set nbspd_start_time "";       # determined from the pid file

if {$option(c) ne ""} {
    set chstatsfile $option(c);
}

if {$option(q) ne ""} {
    set qstatefile $option(q);
}

if {$option(s) ne ""} {
    set statusfile $option(s);
}

# The data is prepended by meta data (log periods)
if {[file exists $pidfile]} {
    set nbspd_start_time [file mtime $pidfile];
}

set keywords [list \
		  data_format \
		  nbspd_start_time \
		  nbspstats_logperiod_secs \
		  qstate_logperiod_secs];
set values [list \
		$data_format \
		$nbspd_start_time \
		$nbspstats_logperiod_secs \
		$qstate_logperiod_secs];

#
# These are the fields of the nbspd.status file, followed by the 
# nbspd.qstate file, and then the chstats file.
#
lappend keywords \
    stats_time \
    frames_received \
    frames_processed \
    frames_jumps \
    frames_bad \
    frames_data_size \
    products_transmitted \
    products_completed \
    products_missed \
    products_retransmitted \
    products_retransmitted_complete \
    products_retransmitted_processed \
    products_retransmitted_ignored \
    products_retransmitted_recovered \
    products_rejected \
    products_aborted \
    products_bad \
    qstate_time \
    queue_processor \
    queue_filter \
    queue_server \
    chstats_start_time \
    chstats_hhmm \
    chstats_files_1 \
    chstats_files_2 \
    chstats_files_3 \
    chstats_files_4 \
    chstats_files_5 \
    chstats_files_6 \
    chstats_files_7 \
    chstats_files_8 \
    chstats_files_9 \
    chstats_bytes_1 \
    chstats_bytes_2 \
    chstats_bytes_3 \
    chstats_bytes_4 \
    chstats_bytes_5 \
    chstats_bytes_6 \
    chstats_bytes_7 \
    chstats_bytes_8 \
    chstats_bytes_9;

if {[file exists $statusfile]} {
    set svalues [split [exec tail -n 1 $statusfile]];
}

if {[file exists $qstatefile]} {
    set qvalues [split [exec tail -n 1 $qstatefile]];
}

if {[file exists $chstatsfile]} {
    set chvalues [split [exec tail -n 1 $chstatsfile]];
}

set values [concat $values $svalues $qvalues $chvalues];

if {$fmt eq "yaml" } {
    foreach k $keywords v $values {
	puts "${k}:${v}";
    }
} elseif {$fmt eq "std"} {
    foreach k $keywords v $values {
	puts "$k=$v";
    }
} elseif {$fmt eq "csv"} {
    puts [join $values ","];
} elseif {$fmt eq "csvk"} {
    set r "";
    foreach k $keywords v $values {
	append r "$k=$v,";
    }
    puts [string trim $r ","];
} elseif {$fmt eq "xml"} {
    foreach k $keywords v $values {
	puts "<$k>$v</$k>";
    }
} else {
    puts "Invalid format: $fmt";
    return 1;
}
