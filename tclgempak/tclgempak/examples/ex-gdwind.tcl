#!%TCLSH%
#
# $Id$
#
package require gempak;

# Uncomment this if necessary
source /usr/local/etc/nbsp/gempak.env

# Choose a model and file. We will pick the latest gfs211.
set datadir [file join $env(GEMDATA) "model" "gfs"];
set filelist [lsort [glob -directory $datadir "*gfs211.gem"]];
set gdfile [lindex $filelist end];

# main

gempak::define gdfile $gdfile

gempak::define garea "tx";

gempak::define gvect "wnd"
gempak::define glevel 900;
gempak::define gvcord "pres";

gempak::define map "1/7";
gempak::define title "3";
gempak::define latlon "2/10/1/1/5;5";

# Set them like this or as set below
## gempak::define wind "ak4"
## gempak::define refvec "10";
## gempak::define skip "/1;1";

gempak::wind_symbol_type "a";
gempak::wind_symbol_units "k";
gempak::wind_symbol_color "4";
gempak::set_wind;

gempak::refvec_magnitude 10;
gempak::set_refvec;

gempak::skip_plot_xy 1 1;
gempak::set_skip;

# Do several forecast times
foreach t [list 24 36 48] {
    gempak::define gdattim f$t;
    gempak::define device "gif|gdwind_$t.gif";
    gempak::init logfile gdwind;
    gempak::run;
    gempak::end;
}
