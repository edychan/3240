* =======================================================================
* Symbol 3240 check-in program (RacWare)
*
* Revisions:
* 08.24.98: year 2000
* 08.24.98: get location parameter from raloc.dbf
*
* 12.08.08: increase form length (rrprint)
* 12.08.08: add other charge 5 & 6 (chkin)
* 12.08.08: add ERC early rental charge (chkin)
* 12.08.08: add Extra day calculation (chkin)
*
* 12.11.08: add parameter xnetprint, default is [1]
*           [1] = NET USE LPT1 \\W2K3\ZS320 >NULL
*           [2] = NET USE LPT1 \\W2K3\78 >NULL
* ------------
* 11.16.09: add option [3] for xnetprint;
*            [3] = NET USE LPT1 \\w2k3\QL174 > NULL             
* 12.17.09: fix DBR out of balance due to surchg1 (see chkin)
* -------------
* 07.15.10: add option [4] & [5] for xnetprint;
*            [4] = NET USE LPT1 \\w2k3\JACZ161 > NULL             
*            [5] = NET USE LPT1 \\w2k3\JACZ162 > NULL             
*            [9] = NET USE LPT1 \\w2k3\SAM > NULL    
* ------------
* 05.04.11: paperless ra
*           - turn off print function
*           - prompt for email
*           - process transit ra to \netmail\ramsg.dbf in racware         
* =======================================================================
parameters xnetprint
set delete on
set confirm on
set excl off

clear
@ 02, 03 say "Please Wait... "

* --3240 printer commands ...(chkin)
if pcount() > 0
   if xnetprint = [debug]    && for debug only (print to xxx.prn instead)
     xonline = .f.         
   else
     xonline = .t.
   end
   xnetprint = if(xnetprint $ [1;2;3;4;5;9], xnetprint, [1])     && 11.16.09
else
   ?
   ? "Please specify printer destination ..."
   ?
   quit
endif

* load system defaults
if .not. file ("3240.dbf") 
   f_valid (.f., "Missing Setup...")
   quit
endif
select 0
use 3240
gtitle = ftitle
gphone = fphone
gpath = alltrim(fdbfpath)
gloc = frloc
gcom = fserial
gprinter = fprinter 
if .not. file (gpath+"raloc.dbf") .or. .not. file (gpath+"raloc.ntx")
   f_valid (.f., "Connection Lost...")
   close all
   quit
endif
use (gpath+"raloc") index (gpath+"raloc")
seek gloc
if eof ()
   f_valid (.f., "Missing LOC data...")
   close all
   quit
endif
* ggraceins = fgrace
* ggracehr = fgracehr
* ggracefr = fgracefr
* gfuelchg = ffuelchg
* gfueltx = ffueltx
* gsurchg = fsurchg1
* gsurtx = fsurtx1
* gsurchg1 = fsurchg2
* gsurtx1 = fsurtx2

ggraceins = fgraceins
ggracehr = fgracehr
ggracefr = ffreehr
gfuelchg = ffuelchg
gfueltx = ffueltax
gsurchg = fsurchg
gsurtx = fsurtx
gsurchg1 = if(type("fsurchg1")=[U],"",fsurchg1)
gsurtx1 = if(type("fsurtx1")=[U],.f.,fsurtx1)
use

* main starts here
do while .t.
   clear
   * sign on
   xoper = "   "
   gdate = date ()
   @ 02, 03 say "User ID: "
   @ 02, 12 get xoper pict "!!!" valid ;
     f_valid (chk_usr(xoper), "Invalid ID...")
   f_rd ()
   * get date
   @ 03, 03 say "Today  :" get gdate pict "@D" valid ;
     f_valid(.not.empty(gdate).and.f_y2k(@gdate))
   if f_rd () = 27    && should take this out for production
      exit
   endif
   *
   do while .t.
      clear
      yans = [1]
      @ 01, 03 say "1. CHECK  IN "
      @ 02, 03 say "2. UPDATE VS "
      @ 03, 03 say "3. PRINT LBL "
      @ 05, 03 say "Enter : " get yans pict "9" valid ;
        f_valid (yans $ "123")
      if f_rd () = 27
         exit
      elseif yans = [1]
         do chkin
      elseif yans = [2]
         do upd_vs
      elseif yans = [3]
         do prt_lbl
      endif
   enddo
enddo

***********
function chk_usr
parameter xusr
private yfil, yntx, yfnd

* if empty (xusr)
*   return .f.
* endif

yfil = gpath + "rausr.dbf"
if .not. file (yfil)
   f_valid (.f., "Connection Lost...")
   close all
   quit
elseif empty(xusr)
   close all
   quit
endif
yntx = gpath + "rausr"
select 0
use &yfil index &yntx alias rausr
seek xusr
if eof ()
   yfnd = .f.
else
   yfnd = .t.
endif
select rausr
use
return yfnd
