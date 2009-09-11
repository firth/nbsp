include(gp.defs.m4)dnl

#
# Generated by m4. Do not edit manually. 
#
match($awips1, 
cfw|cwf|glf|gls|hfs|ice|lsh|maw|mws|nsh|off|omr|osw|pls|smw|srf|tid, 
nwx/marine/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1,
afd|afm|afp|aws|awu|ccf|lfp|lsr|mis|now|opu|pns|rec|rer|rtp|rws|rzf|scc|sfp|sft|sls|sps|stp|swr|tav|tpt|tvl|wcn|wvm|zfp,
nwx/pub_prod/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1,
chg|dsa|hls|psh|tca|tcd|tce|tcm|tcp|tcs|tcu|tma|tsm|tsu|twd|two|tws,
nwx/tropical/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1,
npw|svr|svs|tor|wsw|flw|ffw,
nwx/watch_warn/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1,
n0.|n1p|n[a-z].|n[1-3][rsvz],
nexrad/NIDS/\U$awips2/\U$awips1, \U${awips1}_$ymd_hm,
$f_append = 0; $f_compress = 1;)dnl

match($awips, 
fwddy(.), 
nwx/fire/fwd, `$ymdh.fwddy$1')dnl

match($awips, swody([0-9]),
`nwx/spc/day$1', `$ymdh.day$1')dnl

match($awips, ptsdy([0-9]),
`nwx/spc/day$1', `$ymdh.ptsdy$1')dnl

match($wmoid, wwus20, nwx/spc/watch, $ymdh.watch)dnl

match($wmoid, wwus30, nwx/spc/watch, $ymdh.wtch2)dnl

match($awips1, wou, nwx/spc/wou, $ymdh.wou)dnl

match($wmoid, wous40, nwx/spc/public, $ymdh.public)dnl

match($wmoid, nwus2[02], nwx/spc/svr_summ, $ymdh.svr)dnl

match($awips, stahry, nwx/spc/stahry, $ymdh.hry)dnl

match($awips, stadts, nwx/spc/stadts, $ymdh.dts)dnl

match($wmoid, acus11, nwx/spc/meso, $ymdh.meso)dnl

match($wmoid, wwus44, nwx/spc/hzrd, $ymdh.hzrd)dnl

match($wmoid, wous20, nwx/spc/status, $ymdh.stat)dnl

match($awips, sev[0-9], $gdatadir/nwx/spc/sev, $ymdh.sev)dnl

match($awips, sevspc, nwx/spc/sevmkc, $ymdh.sevmkc)dnl

match($wmoid, abus2[3-6]|abxx0[567]|abca01|fpcn60|wbcn02|abcn01,
nwx/spc/tp_summ, $ymdh.tp_summ)dnl

match($wmoid, wwus0([1-3]), nwx/spc/otlkpts, `$ymdh.ptsdy$1')dnl

match($wmoid, we, nwx/seismic, $ymdh.tsuww)dnl

match($wmoid, se, nwx/seismic, $ymdh.info)dnl

match($fname, knhc_(abnt20|abpz20), nwx/nhc/outlook, $ymdh.outlk)dnl

match($fname, phfo_acpn50, nwx/nhc/outlook, $ymdh.outlk)dnl

match($fname, tjsj_abca33, nwx/nhc/outlook, $ymdh.outlk)dnl

match($fname, pgtw_abpw10, nwx/nhc/outlook, $ymdh.outlk)dnl

match($fname, knhc_(wtnt|wtpz)4[1-5], nwx/nhc/disc, $ymdh.disc)dnl

match($fname, phfo_wtpa4[1-5], nwx/nhc/disc, $ymdh.disc)dnl

match($fname, pgtw_w[dt]pn3[1-5], nwx/nhc/disc, $ymdh.disc)dnl

match($fname, knhc_(wtnt|wtpz)3[1-5], nwx/nhc/public, $ymdh.pblc)dnl

match($fname, phfo_wtpa3[1-5], nwx/nhc/public, $ymdh.pblc)dnl

match($fname, tjsj_wtca40, nwx/nhc/public, $ymdh.pblc)dnl

match($fname, tfff_whca31, nwx/nhc/public, $ymdh.pblc)dnl

match($fname, knhc_wt(nt|pz)7[1-5], nwx/nhc/probs, $ymdh.probs)dnl

match($fname, knhc_wt(nt|pz)2[1-5], nwx/nhc/marine, $ymdh.mar)dnl

match($fname, phfo_wtpa2[1-5], nwx/nhc/marine, $ymdh.mar)dnl

match($fname, nffn_w(h|t)ps01, nwx/nhc/marine, $ymdh.mar)dnl

match($fname, kmia_whxx01, nwx/nhc/model, $ymdh.mdl)dnl

match($fname, kwbc_whxx(0[1-4]|9[09]), nwx/nhc/model, $ymdh.mdl)dnl

match($fname, (knhc_urnt12|kwbc_u[rz]nt14), nwx/nhc/recon, $ymdh.rcn)dnl

match($fname, knhc_ax(nt|pz)20, nwx/nhc/tdsc, $ymdh.tdsc)dnl

match($wmoid, txus20, nwx/flood/satest, $ymdh.satest)dnl

match($awips1, cgr, nwx/marine/cguard, $ymdh.cgr)dnl

match($fname, (kz..|panc)_faus20, nwx/aviation/mis, $ymdh.mis)dnl

match($wmoid, fous14|foak1[34]|fou[emw][6-9]|focn7|fogx|fous(8[6-9]|90),
nwx/mos/ngm, $ymdh.ngmgd)dnl 

match($wmoid, fous67, nwx/mos/eta, $ymdh.etagd)dnl

match($wmoid, fqus2[1-6], nwx/mos/marine, $ymdh.marnmos)dnl

match($awips, pmdhmd, nwx/hpc/prog, $ymdh.disc)dnl

match($wmoid, fxus02, nwx/hpc/extend, $ymdh.extend)dnl

match($wmoid, fxus03, nwx/hpc/hemi, $ymdh.hemi)dnl

match($wmoid, fx(us01|us10|ca20|sa20|hw01), nwx/hpc/prog, $ymdh.prog)dnl

match($wmoid, fxus04, nwx/hpc/qpf, $ymdh.qpf)dnl

match($wmoid, fous30, nwx/hpc/qpf, $ymdh.qpferp)dnl

match($wmoid, fous11, nwx/hpc/hvysnow, $ymdh.hvysnow)dnl

match($wmoid, asus01, nwx/hpc/fronts, $ymdh.front)dnl

match($wmoid, fsus02, nwx/hpc/fronts, $ymdh.fcst)dnl

match($wmoid, fxpa00, nwx/hpc/expac, $ymdh.expac)dnl

match($awips, prb[ew]hi, nwx/hpc/heat, $ymdh.hmean)dnl

match($awips, prb[ew]hh, nwx/hpc/heat, $ymdh.hmax)dnl

match($awips, prb[ew]hl, nwx/hpc/heat, $ymdh.hmin)dnl

match($fname, (kwbc|kwno)_nous42, nwx/hpc/sdm, $ymdh.sdm)dnl

match($fname, kwbc_npxx10, nwx/hpc/intl, $ymdh.intl)dnl

match($wmoid, acus4[1-5], nwx/hpc/storm, $ymdh.storm)dnl

match($fname, kwbc_feus40, nwx/cpc/6_10_fcst, $ymdh.f610)dnl

match($fname, kwbc_fxus06, nwx/cpc/6_10_nrtv, $ymdh.n610)dnl

match($fname, kwbc_fxus07, nwx/cpc/30_nrtv, $ymdh.n30)dnl

match($fname, kwbc_fxus05, nwx/cpc/90_nrtv, $ymdh.n90)dnl

match($fname, kwbc_fxhw40, nwx/cpc/hawaii, $ymdh.hawaii)dnl

match($fname, kwnc_fxus21, nwx/cpc/threats, $ymdh.threats)dnl

match($fname, kwnc_fxus25, nwx/cpc/drought, $ymdh.drought)dnl

match($wmoid, (fvxx2|fvcn0|fvau0)[0-4], nwx/volcano/volcano, $ymdh.volc)dnl

match($wmoid, wv, nwx/volcano/volcwarn, $ymdh.vlcw)dnl

match($wmoid, fvus2[01], nwx/volcano/volcfcst, $ymdh.vlcf)dnl

dnl Alerts and Administrative Messages
match($awips1, (ad(a|m|r|x)|ini), nwx/admin/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1, agf|ago|fwl|saf|wcr|wda, 
nwx/ag_prod/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1, rr[67], nwx/asos/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1, ava|avm|avw|sab|sag|sew|wsw,
nwx/avalanche/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1, aww|oav|rfr|sad|sam|sig|wst|wsv,
nwx/aviation/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1, fa[0-9], nwx/aviation/area, $ymdh.area)dnl

match($awips1, wa[0-9], nwx/aviation/airmet, $ymdh.airm)dnl

match($awips1, ws[0-9], nwx/aviation/sigmet, $ymdh.sgmt)dnl

match($awips1, cli|clm|cmm, nwx/climate/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1, fdi|frw|fwa|fwe|fwf|fwm|fwn|fwo|fws|fww|pbf|rfd|rfw|smf,
nwx/fire/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1, esf|ffa|ffg|ffh|ffs|ffw|fln|fls|flw,
nwx/flood/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1, hcm|hmd|hyd|hym|hyw|p(rr[1-9am]),
nwx/hydro/\U$awips1, $ymdh.\U$awips1)dnl

match($awips, pmd(ca|hi|sa|epd|ep[3-7]|spd|thr|hmd)|preepd,
nwx/misc/\U$awips, $ymdh.\U$awips)dnl

match($awips, qpf(ptr|rsa|str), nwx/qpf/QPF, $ymdh.QPF)dnl

match($awips, qpferd|qpfhsd|qpfpfd, nwx/qpf/\U$awips, $ymdh.\U$awips)dnl

match($awips, qps, nwx/qpf/QPS, $ymdh.QPS)dnl

match($awips1, rva|rvd|rvf|rvi|rvm|rvr|rvs, 
nwx/river/\U$awips1, $ymdh.\U$awips1)dnl

match($awips1, scp|scv|sim, nwx/satellite/\U$awips1, $ymdh.\U$awips1)dnl


