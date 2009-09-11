#!/usr/bin/perl
#
# $Id$
#
# Sample script for storing the files retrieved from inn, in a 
# gempak-compatible directory tree. The script is called by
# the script rcvfominn.plm which is in turn called by innd.

use File::Basename;
use File::Path;
use Compress::Zlib;
use Sys::Syslog;
use strict;

# The file filter needs only $gdatadir; the others are used by the pipe
# filters.
our $gempak_homedir = "/var/noaaport/GEMPAK5.8.2a";
our $gempak_datadir = "$gempak_homedir/gempak";
our $gtabledir = "$gempak_datadir/tables";
our $gdecdir = "$gempak_homedir/bin/freebsd";

our $gdecoders_rootdir = "/var/noaaport";
our $gdatadir = "$gdecoders_rootdir/data/gempak";
our $glogdir = "$gdecoders_rootdir/logs";

our $gverbose = 1;
our $glogfile = 0;

our $gmpk_header_fmt = "\001\r\r\n%03d \r\r\n"; 
our $gmpk_trailer_str = "\r\r\n\003"; 

sub main() {

    my $line;
    my ($seq, $type, $cat, $code, $fpath);
    my ($fname, $dirname);

    openlog "gempak-filter", "ndelay", "nowait", "user"; 
    
    chdir($gdecoders_rootdir);

    if($glogfile == 1){
	if(open(STDOUT, ">>$glogdir/gempak-filter.log") == undef){
	    syslog("err", "Could not open logfile. $!");
	    $glogfile = 0;
	}
    }

    while($line = <STDIN>){

	if($glogfile == 1){
	    print $line;
	}

	chop($line);
	($seq, $type, $cat, $code, $fpath) = split(/\s+/, $line);

	$dirname = dirname($fpath);
	$fname = basename($fpath);

	process_product($seq, $fpath, $fname);
    }

    if($glogfile == 1){
	close(STDOUT);
    }

    closelog;
}

sub process_product(){

    my ($seq, $fpath, $fname) = @_;
    my ($station, $wmoid, $awips, $notawips, $type);
    my ($awips1, $awips2);
    my @time;
    my $ymdh;
    my $ymd_hm;
    my $pipe_cmd;
    my $pipe_options;
    my $savedir;
    my $savename;		# only the file filter uses it
    my $f_append = 1;		# only the file filter uses it
    my $f_compress = 0;

    # The file name is of the form "tjsj_sdus52-ncrjua.4" 
    # when there is an awips code, or "kwbc_ytqm52+grib.4".
    # In some cases, the third component is absent as well.

    if($fname =~ /-/){
	$notawips = "";
	($station, $wmoid, $awips, $type) = split(/[_.\-]/, $fname);
	$awips1 = substr($awips, 0, 3);
	$awips2 = substr($awips, 3);
    }elsif($fname =~ /\+/){
	$awips = "";
	$awips1 = "";
	$awips2 = "";
	($station, $wmoid, $notawips, $type) = split(/[_+.\-]/, $fname);
    }else{
	$awips = "";
	$awips1 = "";
	$awips2 = "";
	$notawips = "";
	($station, $wmoid, $type) = split(/[_.]/, $fname);
    }

    @time = gmtime();
    $time[5] += 1900;
    $time[4] += 1;
    $ymdh = sprintf("%d%02d%02d%02d", $time[5], $time[4], $time[3], $time[2]); 
    $ymd_hm = sprintf("%d%02d%02d_%02d%02d", 
		      $time[5], $time[4], $time[3], $time[2], $time[1]); 


#
# Generated by m4. Do not edit manually. 
#




if($notawips =~ /grib/){
	$pipe_cmd = "$gdecdir/dcgrib2";
	$pipe_options = "-v 1 -d $glogdir/dcgrib.log -e GEMTBL=$gtabledir";
	$savename = "";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /^s[ap]/){
	$pipe_cmd = "$gdecdir/dcmetr";
	$pipe_options = "-v 2 -a 500 -m 72 -d $glogdir/dcmetr.log -e GEMTBL=$gtabledir -s sfmetar_sa.tbl";
	$savename = "surface/YYYYMMDD_sao.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /(^s(hv|hxx|s[^x]))|(^sx(vd|v.50|us(2[0-3]|08|40|82|86)))|(^y[ho]xx84)/){
	$pipe_cmd = "$gdecdir/dcmsfc";
	$pipe_options = "-b 9 -a 10000 -d $glogdir/dcmsfc.log -e GEMTBL=$gtabledir";
	$savename = "ship/YYYYMMDDHH_sb.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /(^s[imn]v[^gins])|(^s[imn]w[^kz])/){
	$pipe_cmd = "$gdecdir/dcmsfc";
	$pipe_options = "-b 9 -a 10000 -d $glogdir/dcmsfc.log -e GEMTBL=$gtabledir";
	$savename = "ship/YYYYMMDDHH_sb.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);
}
if($wmoid =~ /(^s[imn]v[^gins])|(^s[imn]w[^kz])/){
	$pipe_cmd = "$gdecdir/dcmsfc";
	$pipe_options = "-a 6 -d $glogdir/dcmsfc_6hr.log -e GEMTBL=$gtabledir";
	$savename = "ship6hr/YYYYMMDDHH_ship.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /^u[abcdefghijklmnpqrstwxy]/){
	$pipe_cmd = "$gdecdir/dcuair";
	$pipe_options = "-b 24 -m 16 -d $glogdir/dcuair.log -e GEMTBL=$gtabledir -s snstns.tbl";
	$savename = "upperair/YYYYMMDD_upa.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /^uz/){
	$pipe_cmd = "$gdecdir/dcuair";
	$pipe_options = "-a 50 -m 24 -d $glogdir/dcuair_drop.log -e GEMTBL=$gtabledir";
	$savename = "drops/YYYYMMDD_drop.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /(^s[im]v[igns])|(^snv[ins])|(^s[imn](w[kz]|[^vw]))/){
	$pipe_cmd = "$gdecdir/dclsfc";
	$pipe_options = "-v 2 -s lsystns.upc -d $glogdir/dclsfc.log -e GEMTBL=$gtabledir";
	$savename = "syn/YYYYMMDD_syn.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}

if($wmoid =~ /fo(us14|ak1[34]|ak2[5-9])/){
	$pipe_cmd = "$gdecdir/dcnmos";
	$pipe_options = "-d $glogdir/dcnmos.log -e GEMTBL=$gtabledir";
	$savename = "mos/YYYYMMDDHH_nmos.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /fous2[1-6]|foak3[7-9]|fopa20/){
	$pipe_cmd = "$gdecdir/dcgmos";
	$pipe_options = "-d $glogdir/dcgmos.log -e GEMTBL=$gtabledir -e GEMPAK=$gempak_datadir";
	$savename = "mos/YYYYMMDDHH_gmos.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /feus2[1-6]|feak3[7-9]|fepa20/){
	$pipe_cmd = "$gdecdir/dcxmos";
	$pipe_options = "-v 2 -d $glogdir/dcxmos.log -e GEMTBL=$gtabledir -e GEMPAK=$gempak_datadir";
	$savename = "mos/YYYYMMDDHH_xmos.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /fzxx41/){
	$pipe_cmd = "$gdecdir/dcidft";
	$pipe_options = "-v 2 -d $glogdir/dcidft.log -e GEMTBL=$gtabledir";
	$savename = "idft/YYYYMMDDHH.idft";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /^fzak41/){
	$pipe_cmd = "$gdecdir/dcidft";
	$pipe_options = "-v 2 -d $glogdir/dcidft.log -e GEMTBL=$gtabledir";
	$savename = "idft/YYYYMMDDHH.idak";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($fname =~ /kwns_nwus2[02]/){
	$pipe_cmd = "$gdecdir/dcstorm";
	$pipe_options = "-m 2000 -d $glogdir/dcstorm.log -e GEMTBL=$gtabledir";
	$savename = "storm/sels/YYYYMMDD_sels.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($fname =~ /(kmkc_wwus40|kwns_wwus30)/){
	$pipe_cmd = "$gdecdir/dcwatch";
	$pipe_options = "-t 30 -d $glogdir/dcwatch.log -e GEMTBL=$gtabledir";
	$savename = "storm/watches/watches_YYYY_MM.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($awips1 =~ /tor|svr|ffw/){
	$pipe_cmd = "$gdecdir/dcwarn";
	$pipe_options = "-d $glogdir/dcwarn.log -e GEMTBL=$gtabledir";
	$savename = "storm/warn/YYYYMMDDHH_warn.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /wwus(40|08)|wous20|wwus30/){
	$pipe_cmd = "$gdecdir/dcwtch";
	$pipe_options = "-t 30 -d $glogdir/dcwtch.log -e GEMTBL=$gtabledir";
	$savename = "storm/wtch/YYYYMMDDHH_wtch.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /wwus(6[1-6]|32)/){
	$pipe_cmd = "$gdecdir/dcsvrl";
	$pipe_options = "-d $glogdir/dcsvrl.log -e GEMTBL=$gtabledir";
	$savename = "storm/svrl/YYYYMMDDHH_svrl.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($awips1 =~ /ffg|ffh/){
	$pipe_cmd = "$gdecdir/dcffg";
	$pipe_options = "-d $glogdir/dcffg.log -e GEMTBL=$gtabledir";
	$savename = "storm/ffg/YYYYMMDD_ffg.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($fname =~ /kawn_(xrxx84|yixx84|....u[abdr])/){
	$pipe_cmd = "$gdecdir/dcacft";
	$pipe_options = "-d $glogdir/dcacft.log -e GEMTBL=$gtabledir";
	$savename = "acft/YYYYMMDDHH_acf.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /waus01/){
	$pipe_cmd = "$gdecdir/dcairm";
	$pipe_options = "-d $glogdir/dcairm.log -e GEMTBL=$gtabledir";
	$savename = "airm/YYYYMMDDHH_airm.gem";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /^ft/){
	$pipe_cmd = "$gdecdir/dctaf";
	$pipe_options = "-d $glogdir/dctaf.log -e GEMTBL=$gtabledir";
	$savename = "taf/YYYYMMDD00.taf";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($wmoid =~ /fous5[1-5]/){
	$pipe_cmd = "$gdecdir/dcrdf";
	$pipe_options = "-v 4 -d $glogdir/dcrdf.log -e GEMTBL=$gtabledir";
	$savename = "rdf/YYYYMMDDHH.rdf";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($awips1 =~ /wou/){
	$pipe_cmd = "$gdecdir/dcwou";
	$pipe_options = "-d $glogdir/dcwou.log -e GEMTBL=$gtabledir";
	$savename = "storm/wou/YYYYMMDDHHNN.wou";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}
if($awips1 =~ /wcn/){
	$pipe_cmd = "$gdecdir/dcwcn";
	$pipe_options = "-d $glogdir/dcwcn.log -e GEMTBL=$gtabledir";
	$savename = "storm/wcn/YYYYMMDDHHNN.wcn";
	

    	filter_pipe($seq, $fpath, $fname,
		$pipe_cmd, $pipe_options, $savename, $f_compress);

	return;
}if($awips1 =~ /cfw|cwf|glf|gls|hfs|ice|lsh|maw|mws|nsh|off|omr|osw|pls|smw|srf|tid/){
	$savedir = "nwx/marine/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /afd|afm|afp|aws|awu|ccf|lfp|lsr|mis|now|opu|pns|rec|rer|rtp|rws|rzf|scc|sfp|sft|sls|sps|stp|swr|tav|tpt|tvl|wcn|wvm|zfp/){
	$savedir = "nwx/pub_prod/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /chg|dsa|hls|psh|tca|tcd|tce|tcm|tcp|tcs|tcu|tma|tsm|tsu|twd|two|tws/){
	$savedir = "nwx/tropical/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /^sdus[2357]/){
	$savedir = "nexrad/NIDS/\U$awips2/\U$awips1";
	$savename = "\U${awips1}_$ymd_hm";
	$f_append = 0; $f_compress = 1;

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /fwddy(.)/){
	$savedir = "nwx/fire/fwd";
	$savename = "$ymdh.fwddy$1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /swody([0-9])/){
	$savedir = "nwx/spc/day$1";
	$savename = "$ymdh.day$1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /ptsdy([0-9])/){
	$savedir = "nwx/spc/day$1";
	$savename = "$ymdh.ptsdy$1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /wwus20/){
	$savedir = "nwx/spc/watch";
	$savename = "$ymdh.watch";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /wwus30/){
	$savedir = "nwx/spc/watch";
	$savename = "$ymdh.wtch2";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /wou/){
	$savedir = "nwx/spc/wou";
	$savename = "$ymdh.wou";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /wous40/){
	$savedir = "nwx/spc/public";
	$savename = "$ymdh.public";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /nwus2[02]/){
	$savedir = "nwx/spc/svr_summ";
	$savename = "$ymdh.svr";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /stahry/){
	$savedir = "nwx/spc/stahry";
	$savename = "$ymdh.hry";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /stadts/){
	$savedir = "nwx/spc/stadts";
	$savename = "$ymdh.dts";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /acus11/){
	$savedir = "nwx/spc/meso";
	$savename = "$ymdh.meso";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /wwus44/){
	$savedir = "nwx/spc/hzrd";
	$savename = "$ymdh.hzrd";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /wous20/){
	$savedir = "nwx/spc/status";
	$savename = "$ymdh.stat";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /sev[0-9]/){
	$savedir = "$gdatadir/nwx/spc/sev";
	$savename = "$ymdh.sev";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /sevspc/){
	$savedir = "nwx/spc/sevmkc";
	$savename = "$ymdh.sevmkc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /abus2[3-6]|abxx0[567]|abca01|fpcn60|wbcn02|abcn01/){
	$savedir = "nwx/spc/tp_summ";
	$savename = "$ymdh.tp_summ";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /wwus0([1-3])/){
	$savedir = "nwx/spc/otlkpts";
	$savename = "$ymdh.ptsdy$1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /we/){
	$savedir = "nwx/seismic";
	$savename = "$ymdh.tsuww";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /se/){
	$savedir = "nwx/seismic";
	$savename = "$ymdh.info";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /knhc_(abnt20|abpz20)/){
	$savedir = "nwx/nhc/outlook";
	$savename = "$ymdh.outlk";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /phfo_acpn50/){
	$savedir = "nwx/nhc/outlook";
	$savename = "$ymdh.outlk";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /tjsj_abca33/){
	$savedir = "nwx/nhc/outlook";
	$savename = "$ymdh.outlk";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /pgtw_abpw10/){
	$savedir = "nwx/nhc/outlook";
	$savename = "$ymdh.outlk";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /knhc_(wtnt|wtpz)4[1-5]/){
	$savedir = "nwx/nhc/disc";
	$savename = "$ymdh.disc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /phfo_wtpa4[1-5]/){
	$savedir = "nwx/nhc/disc";
	$savename = "$ymdh.disc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /pgtw_w[dt]pn3[1-5]/){
	$savedir = "nwx/nhc/disc";
	$savename = "$ymdh.disc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /knhc_(wtnt|wtpz)3[1-5]/){
	$savedir = "nwx/nhc/public";
	$savename = "$ymdh.pblc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /phfo_wtpa3[1-5]/){
	$savedir = "nwx/nhc/public";
	$savename = "$ymdh.pblc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /tjsj_wtca40/){
	$savedir = "nwx/nhc/public";
	$savename = "$ymdh.pblc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /tfff_whca31/){
	$savedir = "nwx/nhc/public";
	$savename = "$ymdh.pblc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /knhc_wt(nt|pz)7[1-5]/){
	$savedir = "nwx/nhc/probs";
	$savename = "$ymdh.probs";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /knhc_wt(nt|pz)2[1-5]/){
	$savedir = "nwx/nhc/marine";
	$savename = "$ymdh.mar";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /phfo_wtpa2[1-5]/){
	$savedir = "nwx/nhc/marine";
	$savename = "$ymdh.mar";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /nffn_w(h|t)ps01/){
	$savedir = "nwx/nhc/marine";
	$savename = "$ymdh.mar";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kmia_whxx01/){
	$savedir = "nwx/nhc/model";
	$savename = "$ymdh.mdl";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kwbc_whxx(0[1-4]|9[09])/){
	$savedir = "nwx/nhc/model";
	$savename = "$ymdh.mdl";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /(knhc_urnt12|kwbc_u[rz]nt14)/){
	$savedir = "nwx/nhc/recon";
	$savename = "$ymdh.rcn";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /knhc_ax(nt|pz)20/){
	$savedir = "nwx/nhc/tdsc";
	$savename = "$ymdh.tdsc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /txus20/){
	$savedir = "nwx/flood/satest";
	$savename = "$ymdh.satest";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /cgr/){
	$savedir = "nwx/marine/cguard";
	$savename = "$ymdh.cgr";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /(kz..|panc)_faus20/){
	$savedir = "nwx/aviation/mis";
	$savename = "$ymdh.mis";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fous14|foak1[34]|fou[emw][6-9]|focn7|fogx|fous(8[6-9]|90)/){
	$savedir = "nwx/mos/ngm";
	$savename = "$ymdh.ngmgd";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fous67/){
	$savedir = "nwx/mos/eta";
	$savename = "$ymdh.etagd";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fqus2[1-6]/){
	$savedir = "nwx/mos/marine";
	$savename = "$ymdh.marnmos";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /pmdhmd/){
	$savedir = "nwx/hpc/prog";
	$savename = "$ymdh.disc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fxus02/){
	$savedir = "nwx/hpc/extend";
	$savename = "$ymdh.extend";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fxus03/){
	$savedir = "nwx/hpc/hemi";
	$savename = "$ymdh.hemi";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fx(us01|us10|ca20|sa20|hw01)/){
	$savedir = "nwx/hpc/prog";
	$savename = "$ymdh.prog";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fxus04/){
	$savedir = "nwx/hpc/qpf";
	$savename = "$ymdh.qpf";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fous30/){
	$savedir = "nwx/hpc/qpf";
	$savename = "$ymdh.qpferp";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fous11/){
	$savedir = "nwx/hpc/hvysnow";
	$savename = "$ymdh.hvysnow";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /asus01/){
	$savedir = "nwx/hpc/fronts";
	$savename = "$ymdh.front";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fsus02/){
	$savedir = "nwx/hpc/fronts";
	$savename = "$ymdh.fcst";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fxpa00/){
	$savedir = "nwx/hpc/expac";
	$savename = "$ymdh.expac";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /prb[ew]hi/){
	$savedir = "nwx/hpc/heat";
	$savename = "$ymdh.hmean";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /prb[ew]hh/){
	$savedir = "nwx/hpc/heat";
	$savename = "$ymdh.hmax";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /prb[ew]hl/){
	$savedir = "nwx/hpc/heat";
	$savename = "$ymdh.hmin";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /(kwbc|kwno)_nous42/){
	$savedir = "nwx/hpc/sdm";
	$savename = "$ymdh.sdm";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kwbc_npxx10/){
	$savedir = "nwx/hpc/intl";
	$savename = "$ymdh.intl";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /acus4[1-5]/){
	$savedir = "nwx/hpc/storm";
	$savename = "$ymdh.storm";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kwbc_feus40/){
	$savedir = "nwx/cpc/6_10_fcst";
	$savename = "$ymdh.f610";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kwbc_fxus06/){
	$savedir = "nwx/cpc/6_10_nrtv";
	$savename = "$ymdh.n610";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kwbc_fxus07/){
	$savedir = "nwx/cpc/30_nrtv";
	$savename = "$ymdh.n30";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kwbc_fxus05/){
	$savedir = "nwx/cpc/90_nrtv";
	$savename = "$ymdh.n90";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kwbc_fxhw40/){
	$savedir = "nwx/cpc/hawaii";
	$savename = "$ymdh.hawaii";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kwnc_fxus21/){
	$savedir = "nwx/cpc/threats";
	$savename = "$ymdh.threats";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($fname =~ /kwnc_fxus25/){
	$savedir = "nwx/cpc/drought";
	$savename = "$ymdh.drought";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /(fvxx2|fvcn0|fvau0)[0-4]/){
	$savedir = "nwx/volcano/volcano";
	$savename = "$ymdh.volc";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}if($wmoid =~ /wv/){
	$savedir = "nwx/volcano/volcwarn";
	$savename = "$ymdh.vlcw";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($wmoid =~ /fvus2[01]/){
	$savedir = "nwx/volcano/volcfcst";
	$savename = "$ymdh.vlcf";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /(ad(a|m|r|x)|ini)/){
	$savedir = "nwx/admin/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /npw|svr|svs|tor|wsw/){
	$savedir = "nwx/watch_warn/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /flw|ffw/){
	$savedir = "nwx/watch_warn/flood";
	$savename = "$ymdh.flood";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);
}
if($awips1 =~ /esf|ffa|ffg|ffh|ffs|fln|fls|flw|ffw/){
	$savedir = "nwx/flood/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /agf|ago|fwl|saf|wcr|wda/){
	$savedir = "nwx/ag_prod/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /rr[67]/){
	$savedir = "nwx/asos/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /ava|avm|avw|sab|sag|sew|wsw/){
	$savedir = "nwx/avalanche/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /aww|oav|rfr|sad|sam|sig|wst|wsv/){
	$savedir = "nwx/aviation/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /fa[0-9]/){
	$savedir = "nwx/aviation/area";
	$savename = "$ymdh.area";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /wa[0-9]/){
	$savedir = "nwx/aviation/airmet";
	$savename = "$ymdh.airm";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /ws[0-9]/){
	$savedir = "nwx/aviation/sigmet";
	$savename = "$ymdh.sgmt";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /cli|clm|cmm/){
	$savedir = "nwx/climate/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /fdi|frw|fwa|fwe|fwf|fwm|fwn|fwo|fws|fww|pbf|rfd|rfw|smf/){
	$savedir = "nwx/fire/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /hcm|hmd|hyd|hym|hyw|p(rr[1-9am])/){
	$savedir = "nwx/hydro/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /pmd(ca|hi|sa|epd|ep[3-7]|spd|thr|hmd)|preepd/){
	$savedir = "nwx/misc/\U$awips";
	$savename = "$ymdh.\U$awips";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /qpf(ptr|rsa|str)/){
	$savedir = "nwx/qpf/QPF";
	$savename = "$ymdh.QPF";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /qpferd|qpfhsd|qpfpfd/){
	$savedir = "nwx/qpf/\U$awips";
	$savename = "$ymdh.\U$awips";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips =~ /qps/){
	$savedir = "nwx/qpf/QPS";
	$savename = "$ymdh.QPS";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /rva|rvd|rvf|rvi|rvm|rvr|rvs/){
	$savedir = "nwx/river/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}
if($awips1 =~ /scp|scv|sim/){
	$savedir = "nwx/satellite/\U$awips1";
	$savename = "$ymdh.\U$awips1";
	

	filter_file($seq, $fpath, $fname,
		$savedir, $savename, $f_compress, $f_append);

        return;

}

}

sub filter_pipe(){

    my($seq, $fpath, $fname,
       $pipe_cmd, $pipe_options, $savename, $f_compress) = @_;
    my $status;
    my $line;
    my @body;
    my $body;
    my $cbody;
    my $size;

    if($savename ne ""){
	$savename = "$gdatadir/$savename";
    }

    if(open(FIN, $fpath)  == undef){
	syslog("err", "Could not open $fpath: $!");
	return;    
    }

    $status = open(FOUT, "|$pipe_cmd $pipe_options $savename");

    if($status == undef){
	close(FIN);
	syslog("err", "Could not open $pipe_cmd: $!");
	return;
    }

    printf(FOUT $gmpk_header_fmt, $seq % 1000);
    if($f_compress == 1){
	if($gverbose == 1){
	    syslog("info", "Compressing $fpath.");
	}

	# For gempak compatibility, the entire product must be split
	# in 4000 bytes frames (as in the raw noaaport), then compress
	# each frame individually, and then catenate the compressed
	# frames. That is prepended with the wmo and awips header 
	# (from the the first and second lines of the original uncompressed
	# file). Furthermore, the frames must be compressed with level 9
	# and with the compress() function, not with ->deflate.

	while(read(FIN, $body, 4000) > 0){
	    $cbody = compress($body, 9);
	    print(FOUT $cbody);
	}
    }else{
	@body = <FIN>;
	print(FOUT @body);
    }
    printf(FOUT $gmpk_trailer_str);

    close(FIN);
    close(FOUT);

    if($gverbose == 1){
	syslog("info", "Piping $fname to $pipe_cmd.");
    }
}

sub filter_file(){

    my($seq, $fpath, $fname, $savedir, $savename, $f_compress, $f_append) = @_;
    my @body;
    my $body;
    my $cbody;
    my $status;

    $savedir = "$gdatadir/$savedir";

    if(-e $savedir && !-d $savedir){
	syslog("err", "Exists and not dir.");
	return;
    }elsif(!-e $savedir){
	if(mkpath($savedir, 0, 0755) == 0){
	    syslog("err", "Cannot make $savedir: $!");
	    return;
	}
    }

    if(open(FIN, $fpath)  == undef){
	syslog("err", "Could not open $fpath: $!");
	next;    
    }else{
	if($f_append == 1){
	    $status = open(FOUT, ">>$savedir/$savename");
	}else{
	    $status = open(FOUT, ">$savedir/$savename");
	}
	if($status == undef){
	    close(FIN);
	    syslog("err", "Could not open $savedir/$savename: $!");
	    next;
	}
    }

    printf(FOUT $gmpk_header_fmt, $seq % 1000);
    if($f_compress == 1){
	if($gverbose == 1){
	    syslog("info", "Compressing $savename.");
	}

	# For gempak compatibility, the entire product must be split
	# in 4000 bytes frames (as in the raw noaaport), then compress
	# each frame individually, and then catenate the compressed
	# frames. That is prepended with the wmo and awips header 
	# (from the the first and second lines of the original uncompressed
	# file). Furthermore, the frames must be compressed with level 9
	# and with the compress() function, not with ->deflate.

	while(read(FIN, $body, 4000) > 0){
	    $cbody = compress($body, 9);
	    print(FOUT $cbody);
	}
    }else{
	@body = <FIN>;
	print(FOUT @body);
    }
    printf(FOUT $gmpk_trailer_str);

    close(FIN);
    close(FOUT);

    if($gverbose == 1){
	syslog("info", "Archiving $fname in $savedir/$savename.");
    }
}

main();

