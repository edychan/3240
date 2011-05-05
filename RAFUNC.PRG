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

******************************
function f_getfld

parameters xfield, xrow, xcol, xcolor, xlen, xformat, xarrow, xhlp
private ycol, ykey, ypos, yins, ycolor, yfield, ytmpfld
private yarray [3], ycnt, y, yty, ypos1

if pcount () < 8
   xhlp = ""
endif
*ycolor = setcolor (gsubget)
ycolor = setcolor ("W/N")      &&  05.04.11: edc
yins = readinsert ()
yfield = xfield
if pcount () < 5
   xlen = len (yfield)
endif
if pcount () < 6
   xformat = replicate ("X", xlen)
else
   xlen = len (xformat)
endif
if pcount () < 7
   xarrow = .f.
endif

yfield = transform (f_truncate (yfield, xlen), xformat)
ycnt = 0
for y = 1 to xlen
   if .not. (substr (xformat, y, 1) $ "9!X-")
      ycnt = ycnt + 1
      yarray [ycnt] = y
   endif
next
ytmpfld = yfield
for y = ycnt to 1 step -1
   ytmpfld = stuff (ytmpfld, yarray [y], 1, "")
next

ypos1 = 1
do while .t.
   ypos = ypos1
   yfield = ytmpfld
   for y = 1 to ycnt
      yfield = stuff (yfield, yarray [y], 0, substr (xformat, yarray [y], 1))
      if yarray [y] <= ypos
         ypos = ypos + 1
      endif
   next
   @ xrow, xcol say yfield
   @ xrow, xcol + ypos - 1 say ""
   ykey = inkey (0)
   do case
   case ykey = 27
      setcolor (ycolor)
      return .f.
   case ykey = 13 .or. ((ykey = 5 .or. ykey = 24) .and. xarrow)
      setcolor (ycolor)
      xfield = yfield
      return .t.
   case ykey = 8
      if ypos1 > 1
         if yins
            ytmpfld = stuff (ytmpfld, ypos1 - 1, 1, "") + " "
         else
            ytmpfld = stuff (ytmpfld, ypos1 - 1, 1, " ")
         endif
         ypos1 = ypos1 - 1
      endif
   case ykey = 22
      yins = .not. yins
      readinsert (yins)
   case ykey = 7
      ytmpfld = stuff (ytmpfld, ypos1, 1, "") + " "
   case ykey = 19
      if ypos1 > 1
         ypos1 = ypos1 - 1
      endif
   case ykey = 4
      if ypos1 < len (ytmpfld)
         ypos1 = ypos1 + 1
      endif
   case ykey >= 32 .and. ykey <= 127
      ykey = chr (ykey)
      yty = substr (xformat, ypos, 1)
      if yty = "9" .and. ((ykey < "0" .or.  ykey > "9") .and. ykey <> " ")
         loop
      endif
      if yty = "!"
         ykey = upper (ykey)
      endif
      if yins
         ytmpfld = left (stuff (ytmpfld, ypos1, 0, ykey), len (ytmpfld))
      else
         ytmpfld = stuff (ytmpfld, ypos1, 1, ykey)
      endif
      if ypos1 < len (ytmpfld)
         ypos1 = ypos1 + 1
      endif
   case ykey = 28
      if .not. empty (xhlp)
         do &xhlp
      endif
   endcase
enddo

