#!%TCLSH%
#
# $Id$
# 
# Usage: nbspradmos [-a] [-b] [-c] [-C] [-d <outputdir>] [-D <defs>]
#        [-f <fmt>] [-i] [-k] [-l <logfile>] [-L] [-o <outputname>]
#        [-r <rcfile> | -R <rcfilepath>]
#	 [-u <legendfile> | -U <legendfilepath>]
#        [-s <devsize>] [-t <tmpdir>] <gdfile>
#
# -a => run anyway; override the setting in nbspradmos(enable)
# -b => background mode
# -c => create the <outputdir>
# -C => cd to <workdir> defined by nbspradmos(Cdir)
# -d => output directory
# -D => key=value,... comma separated list of gdplot2(key)=val pairs
# -f => output file format (gif, ...)
# -i => interpret <gdfile> to be relative to nbspgdradr(Cdir)
# -k => keep the log file (the default is to delete it)
# -l => use the given logfile (implies -k).
# -L => the <gdfile> argument is a link to the real data file
# -o => output file name
# -r => rcfile, searched in the standard directories
# -R => rcfilepath, used as given
# -s => device size
# -t => cd to tmp directory (all partial paths are still relative
#       to the current directory.
# -u => use this legend file (in the nbspradmos(legend_dir) directory)
# -U => use this legend file, as given
#
# This program ends up calling gdplot2.
# If the <rcfile> is not specified, the program uses the same logic as
# nbspradmap to search for the default file "radcomp.rc".
#
set usage {nbspradmos [-a] [-b] [-c] [-C] [-d outputdir] [-D <defs>]
    [-f fmt] [-i] [-k] [-l <logfile>] [-L] [-o outputname]
    [-r <rcfile> | -R <rcfilepath>]
    [-u <legendfile> | -U <legendfilepath>]    
    [-s <devsize>] [-t <tmpdir>] <gdfile>};

set optlist {a b c C {d.arg ""} {D.arg ""} {f.arg ""} i k {l.arg ""} L
    {o.arg ""} {r.arg ""} {R.arg ""} {s.arg ""} {t.arg ""}
    {u.arg ""} {U.arg ""}};

proc log_warn s {

    ::nbsp::syslog::warn $s;
}

proc log_err s {

    ::nbsp::syslog::err $s;
}

proc source_template {rcfile} {
#
# The template is sourced in a function so that the template cannot affect
# the main script environment.
#
    global gdplot2 gpcolor;
    
    source $rcfile;
}

## The common initialization
set initfile "/usr/local/libexec/nbsp/nbspradmos.init";
if {[file exists $initfile] == 0} {
   log_err "$initfile not found.";
}
source $initfile;

# private settings
set nbspradmos(_tmpfext) ".tmp";
set nbspradmos(_logfext) ".log";

#
# main
#
array set option [::cmdline::getoptions argv $optlist $usage];
set argc [llength $argv];

if {($option(a) == 0) && ($nbspradmos(enable) == 0)} {
    return;
}

if {$option(b) == 1} {
    ::nbsp::syslog::usesyslog
}

if {$argc == 0} {
    log_err $usage;
}

set gdplot2(gdfile) [lindex $argv 0];
if {$option(i) == 1} {
    set gdplot2(gdfile) [file join $nbspgdradr(Cdir) $gdplot2(gdfile)];
}

# Get the real file if the given <gdfile> is supposed to be a link
if {$option(L) == 1} {
    # Do it safely
    set pdir [file dirname $gdplot2(gdfile)];
    set fbasename [file tail [file link $gdplot2(gdfile)]];
    set gdplot2(gdfile) [file join $pdir $fbasename];
}

if {$option(C) == 1} {
    cd $nbspradmos(Cdir);
}

# Get the rc file
if {$option(R) eq ""} {
    # Search for the rcfile 
    source $common(filterslib);
    if {$option(r) eq ""} {
	set option(r) $nbspradmos(rcfile);
    }
    set option(rcfile) [::nbsp::util::find_local_rcfile $option(r) \
			    $nbspradmos(localconfdirs) \
			    $nbspradmos(rcsubdir)];
} else {
    set option(rcfile) $option(R);
}
#
# Check that it exists
#
if {[file exists $option(rcfile)] == 0} {
    log_err "$option(rcfile) not found.";
}

# Similar for legend file
if {$option(U) ne ""} {
    set option(legendfile) $option(U);
} else {
    if {$option(u) eq ""} {
	set option(u) $nbspradmos(legend_file);
    }
    set option(legendfile) [file join $nbspradmos(legend_dir) $option(u)];
}
if {($nbspradmos(legend_enable) == 1) && \
	([file exists $option(legendfile)] == 0)} {
    log_err "$option(legendfile) not found.";
}

# Definitions - Override any gdplot2() settings in conf file.
if {$option(D) ne ""} {
    set Dlist [split $option(D) ","];
    foreach pair $Dlist {
        set p [split $pair "="];
        set var [lindex $p 0];
        set val [lindex $p 1];
        set gdplot2($var) $val;
    }
}

if {$option(f) ne ""} {
    set gdplot2(devfmt) $option(f);
}

if {$option(s) ne ""} {
    set gdplot2(devsize) $option(s);
}

if {$option(o) ne ""} {
    set gdplot2(devfile) $option(o);
    set outrootname [file rootname [file tail $gdplot2(devfile)]];
} else {
    set outrootname [file rootname [file tail $gdplot2(gdfile)]];
    set gdplot2(devfile) $outrootname;
    append gdplot2(devfile) "." $gdplot2(devfmt);
}

# logfile
if {$option(l) eq ""} {
    set option(l) $nbspradmos(logfile);
}
if {$option(l) eq ""} {
    append logfile $outrootname $nbspradmos(_logfext);
} else {
    set logfile $option(l);
    set option(k) 1;
}

if {$option(d) ne ""} {
    set gdplot2(devfile) [file join $option(d) $gdplot2(devfile)];
    if {$option(c) == 1} {
	file mkdir $option(d);
    }
}

if {$option(t) ne ""} {
    if {[file isdirectory $option(t)] == 0} {
	log_err "No such directory: $option(t)";
    } else {
	set cwd [pwd];
	set option(rcfile) [file join $cwd $option(rcfile)];
	set gdplot2(gdfile) [file join $cwd $gdplot2(gdfile)];
	set gdplot2(devfile) [file join $cwd $gdplot2(devfile)];
	# If a logfile was given, it is relative to the original dir.
	if {$option(l) ne ""} {
	    set logfile [file join $cwd $logfile];
	}
	cd $option(t);
    }
}

file delete "gemglb.nts" "last.nts";
if {$option(k) == 0} {
    file delete $logfile;
}

# Create the img file in a tmp file, then rename it at the end
set _real_devfile $gdplot2(devfile);
append gdplot2(devfile) $nbspradmos(_tmpfext);

set status [catch {
    source_template $option(rcfile);

    if {([info exists gdplot2(script)] == 0) || \
	    ([info exists gpcolor(script)] == 0)} {
	return;
    }

    set fout [open "|gpcolor >& $logfile" w];
    fconfigure $fout -translation binary -encoding binary;
    set script [subst $gpcolor(script)];
    puts $fout $script;
    close $fout;
    unset fout;

    set fout [open "|gdplot2 >>& $logfile" w];
    fconfigure $fout -translation binary -encoding binary;
    set script [subst $gdplot2(script)];
    puts $fout $script;
} errmsg];

if {[info exists fout]} {
    catch {close $fout};
}
catch {exec gpend};

file delete "gemglb.nts" "last.nts";
if {$option(k) == 0} {
    file delete $logfile;
}

if {$status != 0} {
    # In case gdplot2 created the file.
    file delete $gdplot2(devfile);
    log_err $errmsg;
}

# Add the legend if that option is enabled
if {$nbspradmos(legend_enable) == 1} {
    set _1 $gdplot2(devfile);
    set _2 $option(legendfile);
    set _3 ${_real_devfile};
    eval exec $nbspradmos(legend_cmd);
    file delete $gdplot2(devfile);
} else {
    file rename -force $gdplot2(devfile) ${_real_devfile};
}
set gdplot2(devfile) ${_real_devfile}; 

if {[info exists gdplot2(post)]} {
    eval $gdplot2(post);
}
