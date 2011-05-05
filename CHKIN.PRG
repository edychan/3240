* =========================================================================
* RacWare check in for symbol 3240
* DL-EGE
* 12.20.98: open & close tables as needed
* 01.28.00: open & close db on demand
* 02.20.02: save rental calculation subtotals
* 01.02.07: Add DATE field
* 12.20.07: add NET USE LPT1 command
* -------------------------------------------------------------------------
* 12.08.08: add add'l charge 5 & 6
*           add extra day total if any (late charge) 
*           add ERC: early rental charge
* -----
* 11.16.09: add xnetprinter = [3] ==> .../QL174
* -----
* 07.15.10: add xnetprinter;
*            [4] = NET USE LPT1 \\w2k3\JACZ161 > NULL             
*            [5] = NET USE LPT1 \\w2k3\JACZ162 > NULL             
*            [9] = NET USE LPT1 \\w2k3\SAM > NULL     
* ------
* 05.04.11: add paperless
*           - add femail field in raagrt
*           - turn off print
*           - prompt for email        
* =========================================================================
set confirm on

private yfil, yntx1, yntx2, yntx3
* declare local var for printing purpose
private l_fmlg, l_fmlgs, l_fmlgtot, l_fmlgchg
private l_frhr, l_fhr, l_fhrchg, l_fhrtot
private l_fdly, l_fdlychg, l_fdlytot
private l_fwk, l_fwkchg, l_fwktot
private l_fwkd, l_fwkdtot
private l_fmth, l_fmthchg, l_fmthtot

@ 07, 03 say "Please Wait..."
declare l_FAUTHCD1,l_FCALDAY,l_FCCEXP1,l_FCCNUM1,l_FCDW,l_FCDWTAX   
declare l_FCLASS,l_FCUSTNO,l_FDATEIN,l_FDATEOUT,l_FDAYS,l_FDBACCT1  
declare l_FDEPAMT,l_FDISC,l_FDLYCHG,l_FDLYMLG,l_FEFUELIN,l_FEFUELOUT 
declare l_FEFUELTOT,l_FEMLG,l_FEMLGIN,l_FEMLGOUT,l_FEMLGS,l_FFNAME    
declare l_FFUELOUT,l_FHLDAMT,l_FHRCHG,l_FID1,l_FLNAME,l_FLOC,l_FMLGCHG   
declare l_FMLGOUT,l_FMTHCHG,l_FMTHMLG
declare l_FODLY1,l_FODLY2,l_FODLY3,l_FODLY4,l_FODLY5,l_FODLY6
declare l_FOITEM1,l_FOITEM2,l_FOITEM3,l_FOITEM4,l_FOITEM5,l_FOITEM6
declare l_FORATE1,l_FORATE2,l_FORATE3,l_FORATE4,l_FORATE5,l_FORATE6
declare l_FOTAX1,l_FOTAX2,l_FOTAX3,l_FOTAX4,l_FOTAX5,l_FOTAX6
declare l_FOTOT1,l_FOTOT2,l_FOTOT3,l_FOTOT4,l_FOTOT5,l_FOTOT6
declare l_FPAI,l_FPAITAX,l_FPAYCOD1,l_FPAYTYP1,l_FRANO,l_FRATE,l_FRESVNO,l_FRLOC     
declare l_FSTAMP,l_FTAX,l_FTIMEIN,l_FTIMEOUT,l_FTMTYP,l_FUCLASS,l_FULIC     
declare l_FUNIT,l_FWKCHG,l_FWKDCHG,l_FWKDDAY,l_FWKDMAX,l_FWKDMIN,l_FWKDMLG   
declare l_FWKMLG,l_FMILEAGE,l_FSURCHG,l_FOTHCHG   
declare l_fduein, l_ftmechg, l_festchg
* -- 07.15.10: Jackson surchrge calc. include; IF(L_FREFERAL = 'LOCAL' ...
declare L_FREFERAL, L_FDMGTOT, l_femail      && 05.04.11
declare l_fdmgtot, l_fcredtot, l_ftmetot, l_fmlgtot, l_fdisctot, l_fcdwtot 
declare l_fpaitot, l_ffueltot, l_fsurchg, l_fothtot1, l_fothtot2, l_ftaxtot
declare l_ftotal, l_famtdue, l_fname, l_fdatein, l_ftimein
*

do while .t.
   @ 07, 03 say "Please Wait..."
   *
   clear
   @ 00, 01 say "Date :"
   @ 01, 01 say "Unit :"
   @ 02, 01 say "Ra   :"    
   @ 03, 01 say "Name :"
   @ 04, 01 say "Out  :"
   @ 05, 01 say "In   :"
   @ 06, 01 say "Fuel :"
   @ 06, 12 say "/8"

   gdate = date()        && 01.02.07
   l_frano = 0
   l_fmlgin = 0
   l_ffuelin = 0
   l_funit = space(10)
   l_femail = ""
   ysave = .f.
   @ 00, 08 get gdate pict "@D" valid ;       && 01.02.07
     f_valid(.not.empty(gdate).and.f_y2k(@gdate))
   @ 01, 08 get l_funit pict "!!!!!!!!!!" valid f_ckunit ()
   @ 05, 08 get l_fmlgin  pict "999999" valid f_ckmlg ()
   @ 06, 08 get l_ffuelin pict "9" valid f_calrate ()
   
   if f_rd () = 27 
      exit
   *elseif lastkey () = 27
   *   if raagr->frastat = "X"
   *      select raagr
   *      reclock ()
   *      replace frastat with " "
   *      commit
   *      unlock
   *   endif
   endif
   * --05.05.11: prompt for email
   e1 = f_truncate(substr(l_femail,1,20),20)
   e2 = f_truncate(substr(l_femail,21),20)
   @ 00, 01 say "Date : "+dtoc(gdate)
   @ 01, 01 say "Unit : "+l_funit
   @ 04, 01 clear to 06,30
   @ 04, 01 say "Total: " + alltrim(str(l_ftotal,8,2))
   @ 06, 01 say "Email:"
   ysave = .t.
   do while .t.
      @ 06, 08 get e1 picture replicate ("x", 20)
	  @ 07, 08 get e2 picture replicate ("x", 20)
	  if f_rd () = 27
	     ysave = .f.
	  endif	 
	  l_femail = alltrim(e1)+alltrim(e2)
	  if f_valid (f_goodem(l_femail, .t.), "NA if NONE!")      && allow NA as valid email
	     exit
	  endif
   enddo
   
   if ysave
      ysave = f_save ()
   endif
   
   *close data
   *
enddo

*******************
* 08.20.06
function f_ckmlg

if lastkey () = 5 .or. empty (l_funit)
   return .t.
endif

return f_valid (l_fmlgin > l_fmlgout .and. l_fmlgin - l_fmlgout <=3000)   && 03.12.07

******************
function f_calrate
private yemail

if lastkey () = 5 .or. empty (l_funit)
   return .t.
endif

if l_ffuelin > 8       && 01.02.07
   f_valid (.f.)
   return .f.
endif

l_fdmgtot = 0      && 07.15.10: For JAC surchg calculation
l_fcredtot = 0

l_ftmetot = 0
l_fmlgtot = 0
l_fdisctot = 0
l_fcdwtot = 0
l_fpaitot = 0
l_ffueltot = 0
l_fsurchg = 0
l_fothtot1 = 0
l_fothtot2 = 0
l_ftaxtot = 0
l_ftotal = 0
l_famtdue = 0
l_fname = alltrim(l_ffname)+" "+alltrim(l_flname)
l_fdatein = gdate
l_ftimein = substr(time(),1,5)
do cal_tnm
* 02.06.07: stop 0 total
if l_ftotal <= 0       
   f_valid (.f.,"Err: Total="+str(l_ftotal,6,2))
   return .f.
endif
***

* @ 07, 01 say "Total: "+alltrim(str(l_ftotal,8,2))
@ 08, 01 say "<Enter> | <Esc> "                               

return .t.

* ===================
* --05.05.11: save transit ra
* ===================
function f_save

yans = 13     && set this to always save for paperless-ra
if yans = 13 .or. yans = 49

   * -- 05.04.11: turn off print
   * Print ra
   *if xonline    && can turn this off for debug in 3240.prg
   *  run NET USE LPT1 /DELETE >NULL
   *   if xnetprint = [1]
   *      run NET USE LPT1 \\W2K3\ZS320 >NULL   
   *   elseif xnetprint = [2]
   *      run NET USE LPT1 \\W2K3\78 >NULL
   *   elseif xnetprint = [3]
   *      run NET USE LPT1 \\W2K3\QL174 >NULL      && 11.16.09
   *   elseif xnetprint = [4]
   *      run NET USE LPT1 \\W2K3\JACZ161 >NULL    && 07.15.10
   *   elseif xnetprint = [5]
   *      run NET USE LPT1 \\W2K3\JACZ162 >NULL
   *   elseif xnetprint = [9]
   *      run NET USE LPT1 \\W2K3\SAM >NULL
   *   endif
   *endif
   * --
   *do rrprint

   * 05.04.11 --
   if .not.xonline    && debug mode
      do rrprint
      f_valid (.f., "debug mode (xxx.prn)")
	  close all
      quit
   endif
   *
   @ 08, 00 clear to 08, 30
   @ 08, 01 say "UPDATING UNIT....."
   yfil = gpath + "ravm.dbf"
   if .not. file (yfil)
      f_valid (.f., "Connection Lost...")
      return .f.
   endif
   yntx1 = gpath + "ravm1"
   yntx2 = gpath + "ravm2"
   yntx3 = gpath + "ravm3"
   select 0
   use &yfil index &yntx1, &yntx2, &yntx3 alias ravm
   select ravm 
   seek l_funit
   if .not. eof ()
      reclock ()
      if .not. empty (freason)
         replace fstatus with "H"
      else
         replace fstatus with "I"
      endif
      replace floc with gloc
      replace futime with dtos (l_fdatein) + l_ftimein
      replace fcurra with 0, frenter with " "
      replace flastra with l_frano, fckindt with l_fdatein
      replace fmileage with l_fmlgin, fdueback with ctod ("  /  /  ")
      commit
      unlock
   endif
   use
   *
   @ 08, 00 clear to 08, 20
   @ 08, 01 say "UPDATING TRANSIT.."
   yfil = gpath + "raagrt.dbf"
   if .not. file (yfil)
      f_valid (.f., "Connection Lost...")
      return .f.
   endif
   yntx1 = gpath + "raagrt"
   select 0 
   use &yfil index &yntx1 alias raagrt
   select raagrt
   seek l_floc+str(l_frano,6)
   if eof ()
      seek space(10)+str(0,6)
      if eof ()
         append blank
      endif
   endif
   reclock ()
   replace FLOC with l_floc, FRANO with l_frano, FUNIT with l_funit     
   replace FRLOC with gloc
   replace FDATEIN with l_fdatein, FTIMEIN with l_ftimein, FDAYS with l_fdays
   replace FMLG with l_fmlg, FDEPAMT with l_fdepamt, FDISCTOT with l_fdisctot
   replace FCDWTOT with l_fcdwtot, FPAITOT with l_fpaitot, FFUELTOT with l_ffueltot
   replace FTMETOT with l_ftmetot, FMLGTOT with l_fmlgtot, FSURCHG with l_fsurchg
   replace FTAXTOT with l_ftaxtot, FTOTAL with l_ftotal
   * --12.08.08
   replace FOITEM1 with l_foitem1, FOITEM2 with l_foitem2, FOITEM3 with l_foitem3
   replace FOITEM4 with l_foitem4, FOITEM5 with l_foitem5, FOITEM6 with l_foitem6
   replace FOTOT1 with l_fotot1, FOTOT2 with l_fotot2, FOTOT3 with l_fotot3
   replace FOTOT4 with l_fotot4, FOTOT5 with l_fotot5, FOTOT6 with l_fotot6
   * --
   replace FNAME with l_fname
   * 02.20.02
   * replace fhr with l_fhr, fhrtot with l_fhrtot     
   replace fhr with l_frhr, fhrtot with l_fhrtot     && 01.24.07: save rental hours
   replace fdly with l_fdly, fdlytot with l_fdlytot
   replace fwk with l_fwk, fwktot with l_fwktot
   replace fwkd with l_fwkd, fwkdtot with l_fwkdtot
   replace fmth with l_fmth, fmthtot with l_fmthtot
   replace ffuelout with l_ffuelout, ffuelin with l_ffuelin
   * 05.04.11:
   replace femail with l_femail
   commit
   unlock
   use
   *
   * --05.04.11: disable re-print (paperless)
   *@ 08, 00 clear to 08, 20
   *do while .t.
   *   @ 08, 01 say "1> Print | 2> Exit"
   *   yans = inkey(0)
   *   if yans = asc("1")
   *      @ 08, 01 say "Please Wait...    "
   *      do rrprint
   *   elseif yans = asc ("2")
   *      exit
   *   endif
   *enddo
   @ 07, 00 clear to 08, 30
   return .t.
else
   * release open ra
   *select raagr
   *seek l_funit
   *if .not. eof ()
   *   reclock ()
   *   replace frastat with " "
   *   commit
   *   unlock
   *endif
   @ 07, 00 clear to 08, 20
   keyboard chr(5)
   return .f.
endif

******************
function f_ckunit
private yfil, yntx1, yflg

if empty(l_funit)
   f_valid (.f., "Invalid Unit #!")
   return .f.
endif

yflg = .t.
yfil = gpath + "raagr.dbf"
if .not. file (yfil)
   f_valid (.f., "Connection Lost...")
   return .f.
endif
yntx1 = gpath + "raagr3"      && by unit #
select 0
use &yfil index &yntx1 alias raagr

select raagr
seek l_funit 
if eof ()
   f_valid (.f., "Invalid Unit #....")
   l_funit = space(10)
   yflg = .f.
elseif raagr->frastat = "X"
   f_valid (.f., "RA in Transit...")
   l_funit = space(10)
   yflg = .f.
elseif .not.empty(raagr->fremark)
   f_valid (.f., "Pending Message...")
   l_funit = space(10)
   yflg = .f.
elseif raagr->fdateout > gdate
   f_valid (.f., "Invalid Date...")
   l_funit = space(10)
   yflg = .f.
else
   * mark open ra
   *reclock ()
   *replace frastat with "X"
   *commit
   *unlock
   *
   l_FAUTHCD1 = FAUTHCD1  
   l_FCALDAY  = FCALDAY   
   l_FCCEXP1  = FCCEXP1   
   l_FCCNUM1  = FCCNUM1   
   l_FCDW     = FCDW      
   l_FCDWTAX  = FCDWTAX   
   l_FCLASS   = FCLASS    
   l_FCUSTNO  = FCUSTNO   

   l_FDATEIN  = FDATEIN
   l_FDATEOUT = FDATEOUT  
   l_FDAYS    = FDAYS     

   l_fduein  = fduein
   l_ftmechg  = ftmechg
   l_festchg  = festchg

   l_FDBACCT1 = FDBACCT1
   l_FDEPAMT  = FDEPAMT   
   l_FDISC    = FDISC     
   l_FDLYCHG  = FDLYCHG   
   l_FDLYMLG  = FDLYMLG   
   l_FEFUELIN = FEFUELIN  
   l_FEFUELOUT= FEFUELOUT 
   l_FEFUELTOT= FEFUELTOT 
   l_FEMLG    = FEMLG     
   l_FEMLGIN  = FEMLGIN   
   l_FEMLGOUT = FEMLGOUT  
   l_FEMLGS   = FEMLGS    
   l_FFNAME   = FFNAME    
   l_FFUELOUT = FFUELOUT  
   l_FHLDAMT  = FHLDAMT   
   l_FHRCHG   = FHRCHG    
   l_FID1     = FID1      
   l_FLNAME   = FLNAME    
   l_FLOC     = FLOC      
   l_FMLGCHG  = FMLGCHG   
   l_FMLGOUT  = FMLGOUT   
   l_FMTHCHG  = FMTHCHG   
   l_FMTHMLG  = FMTHMLG   

   l_FODLY1   = FODLY1
   l_FODLY2   = FODLY2    
   l_FODLY3   = FODLY3    
   l_FODLY4   = FODLY4    
   l_FODLY5   = FODLY5    
   l_FODLY6   = FODLY6    

   l_FOITEM1  = FOITEM1
   l_FOITEM2  = FOITEM2   
   l_FOITEM3  = FOITEM3   
   l_FOITEM4  = FOITEM4   
   l_FOITEM5  = FOITEM5   
   l_FOITEM6  = FOITEM6   

   l_FORATE1  = FORATE1
   l_FORATE2  = FORATE2   
   l_FORATE3  = FORATE3   
   l_FORATE4  = FORATE4   
   l_FORATE5  = FORATE5   
   l_FORATE6  = FORATE6   

   l_FOTAX1   = FOTAX1
   l_FOTAX2   = FOTAX2    
   l_FOTAX3   = FOTAX3    
   l_FOTAX4   = FOTAX4    
   l_FOTAX5   = FOTAX5    
   l_FOTAX6   = FOTAX6    

   l_FPAI     = FPAI
   l_FPAITAX  = FPAITAX   
   l_FPAYCOD1 = FPAYCOD1  
   l_FPAYTYP1 = FPAYTYP1  
   l_FPHONE   = FPHONE    
   l_FRANO    = FRANO     
   l_FRATE    = FRATE     
   l_FRESVNO  = FRESVNO   
   l_FRLOC    = gloc     
   l_FSTAMP   = FSTAMP    
   l_FTAX     = FTAX      
   l_FTIMEIN  = FTIMEIN   
   l_FTIMEOUT = FTIMEOUT  
   l_FTMTYP   = FTMTYP    
   l_FUCLASS  = FUCLASS   
   l_FULIC    = FULIC     
   l_FUNIT    = FUNIT     
   l_FWKCHG   = FWKCHG    
   l_FWKDCHG  = FWKDCHG   
   l_FWKDDAY  = FWKDDAY   
   l_FWKDMAX  = FWKDMAX   
   l_FWKDMIN  = FWKDMIN   
   l_FWKDMLG  = FWKDMLG   
   l_FWKMLG   = FWKMLG    
   l_FMILEAGE = FMILEAGE  
   l_FSURCHG  = FSURCHG   
   l_FOTHCHG  = FOTHCHG   
   * --07.15.10
   l_FREFERAL = FREFERAL
   l_femail = trim(femail)         && 05.04.11
   *
   @ 02, 08 say alltrim(str(l_frano,6))
   @ 03, 08 say f_truncate (alltrim(l_flname)+","+substr(alltrim(l_ffname),1,1),12)
   @ 04, 08 say str(l_fmlgout,6)
endif
select raagr
use
return yflg

******************************
* time and mileage calculation
******************************
procedure cal_tnm
private y1, y2, y3, yto, yti, yrtot, yfdays, yfhr
private ymhr, ytotd, ytotw, ytotm, yrdays, yrwk, yrmlg, yrmlgd, yrmlgw, yrmlgm

store 0 to l_fdlytot, l_fwkdtot, l_fwktot, l_fmthtot, l_fhrtot

yto = val (substr (l_ftimeout, 1, 2)) * 60 + ;
   val (substr (l_ftimeout, 4, 2))
yti = val (substr (l_ftimein, 1 ,2)) * 60 + val (substr (l_ftimein, 4, 2))
ymins = (l_fdatein - l_fdateout) * 24 * 60 + yti - yto
if l_fhrchg = 0 .or. l_fdlychg > 0 .or. l_fwkdchg > 0 .or.   ;
   l_fwkchg > 0 .or. l_fmthchg > 0
   l_fdays = int (ymins / 1440)
   ymins = ymins - l_fdays * 1440
else
   l_fdays = 0
endif
if l_fdays < 1  .and. l_fdlychg > 0 
   l_fdays = 1
   ymins = 0
endif
* 
if ggraceins
   ydaychg = if(ymins<=ggracehr,l_fdays,l_fdays + 1)
else
   ydaychg = if(ymins<=0,l_fdays,l_fdays + 1)
endif

if ymins <= ggracehr
   ymins = 0
elseif ggracefr
   ymins = ymins - ggracehr
endif

l_fhr = int (ymins / 60)
ymins = ymins - l_fhr * 60
if ymins > 0
   if l_fhr >= 23 .and. l_fdlychg > 0 
      l_fdays = l_fdays + 1
      l_fhr = 0
   else
      l_fhr = l_fhr + 1
   endif
   ymins = 0
endif

l_fcdwdays = ydaychg
l_fpaidays = ydaychg
l_fcdwtot = l_fcdwdays * l_fcdw
l_fpaitot = l_fpaidays * l_fpai

l_fmlg = l_fmlgin - l_fmlgout
l_fmlgs = l_fmlg + l_femlgs
l_frhr = l_fhr
l_fdly = l_fdays

if (l_fhr * l_fhrchg) >= l_fdlychg .and. l_fdlychg > 0
   l_fdly = l_fdly + 1
   l_fhr = 0
endif

* -- 12.08.08
l_fwkd = 0
if l_fdatein > l_fduein
   l_fwkd = l_fdly - (l_fduein-l_fdateout)
endif

if l_fwkd > 0
   *if l_fwkdchg <= 0        && calc add'l date rate if missing ...
   *   if ygfadlychg > 0
   *      l_fwkdchg = l_fdlychg + ygfadlychg      
   *   else
   *      l_fwkdchg = round(l_fdlychg * (1 + ygfadlypct / 100), 2)
   *   endif
   *endif
   if l_fwkdchg > 0
      l_fwkdtot = l_fwkdchg * l_fwkd    && use add'l date rate
      l_fdly = l_fdly - l_fwkd
   else
      l_fwkd = 0
   endif
endif
* -- 12.08.08

store 99999.99 to ytotd, ytotw, ytotm, yrtot

yfdays = l_fdly
yfhr = l_fhr              && save for week/month calc.

* estimate daily chg 01/07/95:(edc)
if l_fdlychg > 0.00
   if l_fdlymlg = 0       && unlimited
      yrmlgd = 0
   else
      yrmlg = l_fmlgs - (l_fdlymlg * l_fdly) 
      yrmlgd = if(yrmlg > 0, yrmlg * l_fmlgchg, 0)
   endif
   ytotd = l_fdly * l_fdlychg + l_fhr * l_fhrchg + yrmlgd
   yrtot = ytotd
endif

ylowrchg = .t.          && assume to be true
yrdays = l_fdly
yrhr = l_fhr
* estimate weekly chg 01/07/95:(edc)
l_fwk = 0
if l_fwkchg > 0.00       &&  .and. (l_ftmtyp = 3 .or. ylowrchg)
   if ylowrchg
      l_fwk = int (yfdays/7)
      l_fdly = yfdays - l_fwk * 7
      l_fhr = yfhr
      if l_fdly * l_fdlychg + l_fhr * l_fhrchg > l_fwkchg
         l_fwk = l_fwk + 1
         l_fdly = 0
         l_fhr = 0
      endif
      if l_fdly > 0 .and. l_fdlychg <= 0
         l_fwk = l_fwk + 1
         l_fdly = 0
         l_fhr = 0
      endif
      if l_fwkmlg = 0       && unlimited
         yrmlgw = 0
      else
         * compare weekly charge taking into account of mileage calc.
         yrmlg = l_fmlgs - ((l_fwkmlg * l_fwk) + (l_fdlymlg * l_fdly)) 
         yrmlgw = if(yrmlg > 0, yrmlg * l_fmlgchg, 0)
      endif
      if l_fwk > 0
         ytotw = l_fwk * l_fwkchg + l_fdly * l_fdlychg +   ;
                 l_fhr * l_fhrchg + yrmlgw
         if ytotw > ytotd
            l_fwk = 0
            l_fdly = yrdays 
            l_fhr = yrhr
         else
            yrtot = ytotw
         endif
      else
         * restore old values
         l_fdly = yrdays 
         l_fhr = yrhr
      endif

   elseif l_ftmtyp = 3
      do while l_fdly >= ygwkmin
         l_fwk = l_fwk + 1
         l_fdly = l_fdly - ygwkmax
         if l_fdly < 0
            l_fhr = 0
            l_fdly = 0
         endif
      enddo
   endif
   l_fwktot = l_fwkchg * l_fwk
else
   l_fwktot = 0.00
endif

* estimate monthly chg 01/07/95:(edc)
yrwk = l_fwk
yrdays = l_fdly
yrhr = l_fhr
l_fmth = 0
if l_fmthchg > 0.00         && .and. (l_ftmtyp = 4 .or. ylowrchg)
   if ylowrchg
   * 01/07/95: (edc) stll need to compare mileage....
      l_fmth = int (yfdays/30)
      l_fdly = yfdays - l_fmth * 30
      l_fwk = int (l_fdly/7)
      l_fdly = l_fdly - l_fwk * 7
      l_fhr = yfhr          && restore org. hr.
      if l_fdly * l_fdlychg + l_fhr * l_fhrchg > l_fwkchg
         l_fwk = l_fwk + 1
         l_fdly = 0
         l_fhr = 0
      endif
      if l_fdly > 0 .and. l_fdlychg <= 0 
         l_fwk = l_fwk + 1
         l_fdly = 0
         l_fhr = 0
      endif 
      if l_fwk * l_fwkchg + l_fdly * l_fdlychg + l_fhr * l_fhrchg > l_fmthchg
         l_fmth = l_fmth + 1
         l_fwk = 0
         l_fdly = 0
         l_fhr = 0
      endif
      if l_fmthmlg = 0       && unlimited
         yrmlgm = 0
      else
         * compare monthly charge taking into account of mileage calc.
         yrmlg = l_fmlgs - ((l_fmthmlg * l_fmth) + (l_fwkmlg * l_fwk) +  ;
                            (l_fdlymlg * l_fdly)) 
         yrmlgm = if(yrmlg > 0, yrmlg * l_fmlgchg, 0)
      endif
      if l_fmth > 0
         ytotm = l_fmth * l_fmthchg + l_fwk * l_fwkchg +    ;
                 l_fdly * l_fdlychg + l_fhr * l_fhrchg + yrmlgm
         if ytotm > yrtot 
            * restore old values
            l_fmth = 0
            l_fwk = yrwk
            l_fdly = yrdays 
            l_fhr = yrhr
         else
            l_fdly = yfdays - (l_fmth * 30) - (l_fwk * 7)
            l_fdly = if(l_fdly > 0, l_fdly, 0)
            l_fwktot = l_fwk * l_fwkchg
         endif
      else
         l_fwk = yrwk
         l_fdly = yrdays 
         l_fhr = yrhr
      endif

   elseif l_ftmtyp = 4
      do while l_fdly >= ygmthmin
         l_fmth = l_fmth + 1
         l_fdly = l_fdly - ygmthmax
         if l_fdly < 0
            l_fhr = 0
            l_fdly = 0
         endif
      enddo
   endif
   l_fmthtot = l_fmthchg * l_fmth
else
   l_fmthtot = 0.00
endif

if l_fdlychg > 0.00
   l_fdlytot = l_fdlychg * l_fdly
elseif l_fwkchg > 0.00
   if l_fdly > 0      && 01/10/94:(edc)  
      l_fwk = l_fwk + 1
      l_fwktot = l_fwktot + l_fwkchg
      l_fdly = 0
      l_fhr = 0 
   endif
elseif l_fmthchg > 0
   if l_fdly > 0.00 .or. l_fwk > 0.00
      l_fmth = l_fmth + 1
      l_fmthtot = l_fmthtot + l_fmthchg
      l_fwk = 0
      l_fdly = 0
      l_fhr = 0
   endif
endif
l_fhrtot = l_fhr * l_fhrchg
l_ftmetot = l_fdlytot + l_fwkdtot + l_fwktot + l_fmthtot + l_fhrtot

* --12.08.08: check if early rental fee apply by compare to est T&M in open RA
* if l_ftmechg > l_ftmetot
* --01.12.09: Grace = 1 day per allen
if l_ftmechg - l_ftmetot > l_fdlychg .or.  ;
   l_fduein - l_fdatein >=2                   && 01.14.09: return >2 days early
   * -- Apply early rental charge as [ERC]
   for i = 1 to 6      && add 2 add'l charge
      ystr1 = "L_FOITEM" + str (i, 1)
      if  empty(&ystr1) .or. &ystr1 = [ERC]
         &ystr1 = [ERC ]
         ystr2 = "L_FORATE" + str(i,1)
         &ystr2 = l_ftmechg - l_ftmetot
         exit
      endif
   next
else
   * -- zero out ERC just in case
   for i = 1 to 6      && add 2 add'l charge
      ystr1 = "L_FOITEM" + str (i, 1)
      if &ystr1 = [ERC]
         &ystr1 = [ERC ]
         ystr2 = "L_FORATE" + str(i,1)
         &ystr2 = 0
         exit
      endif
   next
endif
* --

l_fmlgfree = 0
if l_fwkd > 0
   if l_fwkdmlg = 0
      l_fmlgfree = l_fmlgs
   elseif l_fwkdmlg > 1
      l_fmlgfree = l_fmlgfree + l_fwkd * l_fwkdmlg
   endif
endif
if l_fdly > 0
   if l_fdlymlg = 0
      l_fmlgfree = l_fmlgs
   elseif l_fdlymlg > 1
      l_fmlgfree = l_fmlgfree + l_fdly * l_fdlymlg
   endif
endif
if l_fwk > 0
   if l_fwkmlg = 0
      l_fmlgfree = l_fmlgs
   elseif l_fwkmlg > 1
      l_fmlgfree = l_fmlgfree + l_fwk * l_fwkmlg
   endif
endif
if l_fmth > 0
   if l_fmthmlg = 0
      l_fmlgfree = l_fmlgs
   elseif l_fmthmlg > 1
      l_fmlgfree = l_fmlgfree + l_fmth * l_fmthmlg
   endif
endif

if l_fmlgfree >= l_fmlgs
   l_fmlgs = 0
else
   l_fmlgs = l_fmlgs - l_fmlgfree
endif
l_fmlgtot = l_fmlgs * l_fmlgchg
l_fdisctot = round (l_fdisc * (l_ftmetot + l_fmlgtot) / 100.00, 2)
l_fcdwtot = l_fcdwdays * l_fcdw
l_fpaitot = l_fpaidays * l_fpai

* Calculate other charge
l_fothtot1 = 0
l_fothtot2 = 0
l_fpo = .f.                && fuel purchase option

yothcnt = 1                && add'l charge item count
for i = 1 to 6

   ystr1 = "L_FOITEM" + str (i, 1)
   if .not. empty(&ystr1)
      yothcnt = yothcnt + 1
   endif

   if  &ystr1 = "FPO"     && Fuel purchase option
      ystr2 = "L_FORATE" + str (i, 1)
      l_fpo = if(&ystr2 > 0, .t., .f.)
   endif
   *
   ystr1 = "L_FORATE" + str (i, 1)
   ystr2 = "L_FODLY" + str (i, 1)
   if &ystr2
      ychg = &ystr1 * ydaychg
   else
      ychg = &ystr1
   endif
   ystr2 = "L_FOTOT" + str (i, 1)
   &ystr2 = ychg
   ystr1 = "L_FOTAX" + str (i, 1)
   if &ystr1
      l_fothtot1 = l_fothtot1 + ychg
   else
      l_fothtot2 = l_fothtot2 + ychg
   endif
next 
* --07.15.10: handle surchg1 for JAC
if gloc = [JAC]
   ychg = &gsurchg1
   ystr1 = "L_FOITEM" + str (yothcnt, 1)
   &ystr1 = "SUR1"     
   ystr1 = "L_FODLY" + str (yothcnt, 1)
   &ystr1 = .f.
   ystr1 = "L_FORATE" + str (yothcnt, 1)
   &ystr1 = ychg
   ystr1 = "L_FOTOT" + str (yothcnt, 1)
   &ystr1 = ychg
   ystr1 = "L_FOTAX" + str (yothcnt, 1)
   &ystr1 = gsurtx1   
   if &ystr1
      l_fothtot1 = l_fothtot1 + ychg
   else
      l_fothtot2 = l_fothtot2 + ychg
   endif
endif
* --

* Calculate fuel charge
l_ffueltot = 0
if .not. l_fpo
   yfil = gpath + "ravm.dbf"
   if .not. file (yfil)
      f_valid (.f., "Connection Lost...")
      close all
      quit
   endif
   yntx1 = gpath + "ravm1"
   select 0
   use &yfil index &yntx1 alias ravm
   select ravm
   seek l_funit
   if found ()
      if l_fmlgin - l_fmlgout > 50
         if l_ffuelin < l_ffuelout
            l_ffueltot = l_ffueltot + round (ftank * (l_ffuelout - l_ffuelin) / ;
               8 * gfuelchg, 2)
         endif
      elseif fepa > 0  
         l_ffueltot = l_ffueltot + round ((l_fmlgin - l_fmlgout) / ;
            fepa * gfuelchg, 2)
      endif
   endif
   select ravm
   use
endif

* Calculate surcharge
if empty(gsurchg)
   l_fsurchg = 0
else
   l_fsurchg = &gsurchg
endif

* --12.17.09: fix DBR out of balance due to add'l surcharge 
* note: SUR1 define in rrnoa as one of the other charge
*       therefore it is already include in the other charge calculation
*if .not. empty(gsurchg1)
*
*   ychg = &gsurchg1
*
*   if gsurtx1
*      l_fothtot1 = l_fothtot1 + ychg
*   else
*      l_fothtot2 = l_fothtot2 + ychg
*   endif
*endif
* --

ytot1 = l_ftmetot + l_fmlgtot - l_fdisctot + if (l_fcdwtax, l_fcdwtot, 0.00) ;
    + if (l_fpaitax, l_fpaitot, 0.00) + if (gfueltx, l_ffueltot, 0.00)  ;
    + if (gsurtx, l_fsurchg, 0.00) + l_fothtot1 - l_fcredtot
l_ftaxtot = round (ytot1 * l_ftax / 100.00, 2)

ytot2 = if (l_fcdwtax, 0.00, l_fcdwtot) + if (l_fpaitax, 0.00, l_fpaitot) ;
   + if (gsurtx, 0.00, l_fsurchg) + l_fothtot2   ;
   + if (gfueltx, 0.00, l_ffueltot) 
l_ftotal = round (ytot1 + ytot2 + l_ftaxtot, 2)
l_famtdue = round (l_ftotal - l_fdepamt, 2)


