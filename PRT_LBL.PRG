*
* print bar code label from symbol 3240 w/comtec printer
*
* must run: mode comX 9600,n,8,1
*
private ysize, ypos, ydata
CLEAR

ysize = 60        && default size 60
@ 01, 01 say "Size: "
@ 01, 07  get ysize pict "999"
read
@ 01, 07 say str(ysize,3)
@ 02, 01 say "Data: "
ypos = ysize + 40
DO WHILE .T.
   ydata = SPACE(10)
   @ 02, 07 GET ydata PICT "!!!!!!!!!!"
   READ
   IF LASTKEY() = 27 .OR. empty(ydata) 
      EXIT
   ENDIF
   * 

   * set font here
   set console off
   set print on
   set printer to &gprinter
   ?"! 0 200 200 240 1"
   ?"LABEL"
   ?"CONTRAST 0"
   ?"B 128 2 1 "+alltrim(str(ysize,3))+" 75 10 "+ydata  && BAR CODE TYPE
   ?"TEXT 7 1 75 "+alltrim(str(ypos,3))+" "+ydata
   * ?"FORM"                                               && NO FORM FEED
   ?"PRINT"
   ?                                                       && DO NOT TAKE THIS OUT!!
   set print off
   set printer to
   set console on
   set device to screen
enddo

