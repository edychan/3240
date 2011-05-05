* =====================================================================
* DL-EGE
* print ra program for symbol 3240
*
* 01.15.98: change CONFESSION FEE to ARPT ACCESS FEE
*
* 12.14.06: use CPCL to print to Zebra QL320 plus
* ---------------------------------------------------------------------
* 12.08.08: add add'l charge 5 & 6 (ERC: early rental charge)
*           increase form length=1500 
* 12.08.08: print extra day total if any
* 12.17.08: print 'PEC' instead of 'PAI'
* =====================================================================
private yline, yfld

* QL320 system commands
xpre = [T 7 1 43 ]             && resident font 7 size 1 x=43
xpos = 40                      && start pos
xsp = 45                       && height of each line

set console off
set print on

if xonline
   set printer to &gprinter
else
   set printer to xxx           && debug
endif

* -- 12.08.08
* ? [! 0 200 200 1300 1]         && form length=1300 (6.5 in)
? [! 0 200 200 1500 1]         && form length=1500 (7.5 in)
? [LABEL]                      && 
? [CONTRAST 0]                 && 0 (default) - 5 (very dark)
? [TONE 0]                     && tone 0 = contrast 0 
? [SPEED 5]                    && 0 - 5, 5 being the fastest speed 
? [PAGE-WIDTH 500]             && page width=500 (2.5 in)
? [BAR-SENSE]                  && default
? [;// PAGE 0000000005001300]  && comment 
? [;//{{BEGIN-BT]              && comment

prtln ("") 
prtln (gtitle)
prtln ("") 
prtln ("RA# "+trim(l_floc)+"-"+str(l_frano,6)+space(6)+"Oper : "+xoper)
prtln (l_fname)
prtln ("OUT: "+dtoc(l_fdateout)+" "+l_ftimeout+space(2)+"UNIT : "+alltrim(l_funit))
prtln ("IN : "+dtoc(l_fdatein)+" "+l_ftimein+space(2)+"CLASS: "+l_fclass)
prtln ("MILES DRIVEN: "+str(l_fmlg,5)+space(2)+"LOC  : "+alltrim(gloc))
prtln ("") 
if l_fmlgtot > 0
   yline = f_truncate (str(l_fmlgs,6)+" @ "+str(l_fmlgchg,7,2) ,16)+  ;
           " = "+str(l_fmlgtot,13,2)
   prtln (yline)
endif
if l_fhrtot > 0
   yline = f_truncate (str(l_fhr,3)+" HR @ "+str(l_fhrchg,7,2), 16)+  ;
           " = "+str(l_fhrtot,13,2)
   prtln (yline)
endif
if l_fdlytot > 0
   yline = f_truncate (str(l_fdly,3)+" DY @ "+str(l_fdlychg,7,2), 16)+  ;
           " = "+str(l_fdlytot,13,2)
   prtln (yline)
endif

* --12.08.08: add'l date total (xtra day)
if l_fwkdtot > 0
   yline = f_truncate (str(l_fwkd,3)+" XD @ "+str(l_fwkdchg,7,2), 16)+  ;
           " = "+str(l_fwkdtot,13,2)
   prtln (yline)
endif
* --

if l_fwktot > 0
   yline = f_truncate (str(l_fwk,3)+" WK @ "+str(l_fwkchg,7,2), 16)+  ;
           " = "+str(l_fwktot,13,2)
   prtln (yline)
endif
if l_fmthtot > 0
   yline = f_truncate (str(l_fmth,3)+" MO @ "+str(l_fmthchg,7,2), 16)+  ;
           " = "+str(l_fmthtot,13,2)
   prtln (yline)
endif
if l_fcdwtot > 0
   prtln ("  CDW CHARGE     = " + str(l_fcdwtot,13,2))
endif
if l_fpaitot > 0
   prtln ("  PEC CHARGE     = " + str(l_fpaitot,13,2))
endif
if l_ffueltot > 0
   prtln ("  FUEL CHARGE    = " + str(l_ffueltot,13,2))
endif
* add'l charge
if l_fotot1 > 0
   prtln (f_truncate ("  " + l_foitem1, 16) + " = " + str(l_fotot1,13,2))
endif
if l_fotot2 > 0
   prtln (f_truncate ("  " + l_foitem2, 16) + " = " + str(l_fotot2,13,2))
endif
if l_fotot3 > 0
   prtln (f_truncate ("  " + l_foitem3, 16) + " = " + str(l_fotot3,13,2))
endif
if l_fotot4 > 0
   prtln (f_truncate ("  " + l_foitem4, 16) + " = " + str(l_fotot4,13,2))
endif

* --12.08.08
if l_fotot5 > 0
   prtln (f_truncate ("  " + l_foitem5, 16) + " = " + str(l_fotot5,13,2))
endif
if l_fotot6 > 0
   prtln (f_truncate ("  " + l_foitem6, 16) + " = " + str(l_fotot6,13,2))
endif
* --

if l_fsurchg > 0
   prtln ("  AIRP ACCESS FEE= " + str(l_fsurchg,13,2))
endif
if l_ftaxtot > 0
   prtln (f_truncate ("  TAX  @ "+str(l_ftax,7,2), 16)+"%= "+str(l_ftaxtot,13,2))
endif
if l_fdisctot > 0
   prtln (" LESS DISCOUNT   = " + str(l_fdisctot,13,2))
endif
prtln ("")
prtln ("         TOTAL   = " + str(l_ftotal,13,2))
if l_fdepamt > 0
   prtln ("  LESS DEPOSIT   = " + str(l_fdepamt,13,2))
   prtln ("       NET DUE   = " + str(l_famtdue,13,2))
endif
* need to only print last 4 digits of cc #
yfld = alltrim(l_fccnum1)
yfld = substr(yfld, len(yfld)-3)

prtln ("BILL TO:  " + l_fpaytyp1 + yfld)
prtln ("")
prtln ("FOR CUSTOMER INQUIRIES PLEASE CALL")
prtln (space(10)+gphone)
prtln ("")
prtln ("----------------------------------")
prtln ("")
prtln ("THANK YOU FOR RENTING FROM US")
prtln ("      This is your receipt.")
prtln ("No other copies will be provided.")
prtln ("Closed rental subject to final audit")
prtln ("")
prtln ("")

* printer command to print form
? [;//{{END-BT]        && comment 
* ? [FORM]             && form feed: prevent excess form feed
? [PRINT]              && print form
?                      && DO NOT TAKE THIS OUT !!!

set print off
set printer to
set console on
set device to screen

******************
function prtln
parameter xfld

? xpre + strtran(str(xpos,4)," ","") + [ ] + xfld
xpos = xpos + xsp

return .t.
