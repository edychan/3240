* DL-EGE
* update vs on symbol 3240
* 11.24.98: update stall #
* 01.28.00: open & close db on demand
*
set confirm on

private yans, yfil, yntx, yntx1, yntx2, yntx3 
private yunit, ymodel, ycolor, yplate, ystall

@ 05, 03 say "Please Wait..."
clear
@ 00, 01 say "Unit :"
@ 01, 01 say "Model:"
@ 02, 01 say "Color:"
@ 03, 01 say "Plate:"
@ 04, 01 say "Stat :"
@ 05, 01 say "Stall:"
do while .t.
   yunit = space(10)
   ystall = space(4)
   @ 00, 08 get yunit pict "!!!!!!!!!!"
   if f_rd () = 27 .or. empty(yunit)
      exit
   endif
   yfil = gpath + "ravm.dbf"
   if .not. file (yfil)
      f_valid (.f., "Connection Lost...")
      exit
   endif
   yntx1 = gpath + "ravm1"
   yntx2 = gpath + "ravm2"
   yntx3 = gpath + "ravm3"
   select 0
   use &yfil index &yntx1, &yntx2, &yntx3 alias ravm
   seek yunit
   if eof ()
      f_valid (.f., "Invalid Unit...")
      loop
   elseif .not. ravm->fstatus $ "I;A"
      f_valid (.f., "Invalid Stat -> " + ravm->fstatus)
      loop
   endif
   @ 01, 08 say ravm->fmodel
   @ 02, 08 say ravm->fcolor
   @ 03, 08 say ravm->flic
   @ 04, 08 say ravm->fstatus
   @ 05, 08 get ystall pict "!!!!"
   f_rd ()
   @ 07, 01 say "<Enter> | <Esc> "
   yans = inkey(0)
   if yans = 13 .or. yans = 49
      rlock ()
      replace fstatus with "A", fstall with ystall
      commit
      unlock
   endif
   select ravm
   use
   @ 01, 08 clear to 01, 20
   @ 02, 08 clear to 02, 20
   @ 03, 08 clear to 03, 20
   @ 04, 08 clear to 04, 20
   @ 05, 08 clear to 05, 20
   @ 07, 00 clear to 07, 20
enddo
close all

