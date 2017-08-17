#
# $Id$
#
# Functions to support the iNbsp Stats Project
#
# Usage: http://<server>[:<port>]/<command>
#
# where <command> is
#
# /_inbsp/stats[?format=std|yaml|xml|csv|csvk]     (status file)
# /_inbsp/missing[?format=xml|csv]   (missing file: unimplemented)
# /_inbsp/<xxx>[?format=xml|csv]     (other file: unimplemented)
# /_inbsp/monitor[?format=std|yaml|xml|csv|csvk] (inventory filter <hh>.stats)
#
# _inbsp/stats data retrieved via the inventory filter tool nbspstatcounters
# _inbsp/monitor data retrieved via the inventory filter tool nbspstatmonitor
#
Direct_Url /_inbsp _inbsp;

set inbsp(conf) "inbsp.conf";
set inbsp(confdir) $Config(confdir);
set inbsp(localconfdirs) $Config(localconfdirs);

# Non-configurable - must be set in each function
set inbsp(data_type) "";
set inbsp(data_tool) "";

# The local overrides
set _inbspconf [file join $inbsp(confdir) $inbsp(conf)];
if {[file exists ${_inbspconf}]} {
    source ${_inbspconf};
}
unset _inbspconf;

proc _inbsp/stats {{format "std"}} {

    global inbsp;

    # Must be set in each function
    set inbsp(data_type) "_inbsp/stats";
    set inbsp(data_tool) "nbspstatcounters";

    # The mechanism used to return content types is to set a global
    # variable with the same name as this function.
    set _inbsp/stats "text/plain";

    if {$format eq "xml"} {
	set _inbsp/stats "text/xml";
	set r "[inbsp_output_xml_start $inbsp(data_type)]\n";
    } else {
	set r "";
    }

    append r [inbsp_output_stats $format];

    if {$format eq "xml"} {
	append r "\n[inbsp_output_xml_end $inbsp(data_type)]";
    }

    return $r;
}

proc _inbsp/monitor {{format "std"}} {

    global inbsp;

    # Must be set in each function
    set inbsp(data_type) "_inbsp/monitor";
    set inbsp(data_tool) "nbspstatmonitor";
    
    # The mechanism used to return content types is to set a global
    # variable with the same name as this function.
    set _inbsp/minitor "text/plain";

    if {$format eq "xml"} {
	set _inbsp/monitor "text/xml";
	set r "[inbsp_output_xml_start $inbsp(data_type)]\n";
    } else {
	set r "";
    }

    append r [inbsp_output_stats $format];

    if {$format eq "xml"} {
	append r "\n[inbsp_output_xml_end $inbsp(data_type)]";
    }

    return $r;
}

proc inbsp_output_stats {format} {

    global inbsp;

    set status [catch {
	set data [exec $inbsp(data_tool) -f $format];
    } errmsg];

    if {$status != 0} {
	return "";
    }

    # Prepend the data_type and any other metadata before the data
    set r "";
    foreach k [list data_type] {
	if {$format eq "std"} {
	    append r "$k=$inbsp($k)\n";
	} elseif {$format eq "csv"} {
	    append r "$inbsp($k),";
	} elseif {$format eq "csvk"} {
	    append r "$k=$inbsp($k),";
	} elseif {$format eq "xml"} {
	    set r "<$k>$inbsp($k)</$k>\n";
	}
    }

    append r [string trim $data];

    return $r;
}

proc inbsp_output_xml_start {type} {

    set r "<?${type} version=\"1.0\"?>";

    return $r;
}

proc inbsp_output_xml_end {type} {

    set r "</${type}>";

    return $r;
}
