******************************
* function subroutines for Symbol 3240
* ----------------------------
* 05.04.11: add f_goodem to validate email
******************************
* record lock function
*
function reclock
if .not. rlock ()
   f_valid (.f., "Connection Lost...")
   close all
   quit
endif
return .t.

* convert date to year2000 format
* pass by reference
function f_y2k
parameter xdate
if year (xdate) <= 1920   
   ydate = dtoc(xdate)
   xdate = ctod(substr(ydate,1,6)+"20"+substr(ydate,7,2))
endif
return .t.

******************************
* read function
function f_rd

set cursor on
read
set cursor off
return lastkey ()

******************************
function f_valid

parameters xcond, xmess

if xcond
   return .t.
else
   tone (500, 9)
   @ 07, 00 clear to 07, 20
   if pcount () < 2
      @ 07, 01 say "Invalid Entry ! "
      inkey (0)
   else
      @ 07, 01 say trim (xmess) 
      inkey (0)
   endif
   @ 07, 00 clear to 07, 20
   set cursor on
   return .f.
endif

***************************
function f_round
parameter xnum, xdec

return (round(xnum - .01, xdec))

******************************
function f_truncate

parameters xstr, xlen

return left (xstr + replicate (" ", xlen), xlen)

* ------------------------------------
* validate email:
*   xemail: email addr
*   xedit: if .t. => allow NA as valid 
* 1. not empty
* 2. /\A[\W+\-.]+@[a-Z\d\-.\.[a-Z]+\Z/
* -------------------------------------
function f_goodem
parameter xemail, xedit
private yok

if pcount () = 1
   xedit = .t.
endif 
   
* special case:
if xedit .and. upper(trim(xemail)) == "NA"     && not applicable 
   return .t.
endif   

if empty(xemail)
   return .f.
endif

* standard check
yok = .t.
do case
case at ("@", xemail) = 0
   yok = .f.
case at (".", xemail) = 0
   yok = .f.
otherwise
   * check valid domain
   ystr = upper(substr(xemail,at("@",xemail)+1))    && xxx@xxx.domain
   if at(".", ystr) = 0
      yok = .f.
   else
      yok = .f.
      if ".COM" $ ystr
	     yok = .t.
      elseif ".NET" $ ystr		 
	     yok = .t.
      elseif ".ORG" $ ystr		 
	     yok = .t.
      elseif ".GOV" $ ystr		 
	     yok = .t.
      elseif ".MIL" $ ystr		 
	     yok = .t.
      elseif ".EDU" $ ystr		 
	     yok = .t.
      elseif ".BIZ" $ ystr		 
	     yok = .t.
      elseif ".MOB" $ ystr		 
	     yok = .t.
      elseif ".PRO" $ ystr		 
	     yok = .t.
      elseif ".INT" $ ystr		 
	     yok = .t.
	  endif	  
   endif	  
endcase

return yok

