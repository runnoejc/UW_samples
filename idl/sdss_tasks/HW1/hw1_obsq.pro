;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   HW1_OBSQ completes the fourth task of HW1.
;   It takes an input month from the user and
;   returns the quasar with the lowest airmass
;   for each night that month.
;
; CALLING SEQUENCE:
;   IDL>.r hw1_obsq
;   IDL>go 
;
; DESCRIPTION:
;   HW1_OBSQ takes a user input for the month and reads in
;   a file of SDSS i=18 quasars.  It determines the quasar
;   with the lowest airmass from KPNO on each night and
;   prints that to the screen. 
;
; INPUTS:
;   User input month.  January=01,...,December=12.
;
; KEYWORD INPUTS:
;
; RETURNS:
;   List of days and names of quasars with the lowest airmass
;   at 11PM MST that day.
;
; EXAMPLE:
;
;   IDL> go
;   Start time: Fri Feb  1 17:55:01 2013
;   % READCOL: 1066 valid lines read
;   What month (01=January,...,12=December) do you want to calculate observations for? 12
;   The quasar with the lowest airmass at 11PM MST each day of December is: 
;           Day   Object
;           1     020141.61+145026.5
;           2     020141.61+145026.5
;           3     020141.61+145026.5
;           4     020141.61+145026.5
;           5     020141.61+145026.5
;           6     020141.61+145026.5
;           7     020141.61+145026.5
;           8     020141.61+145026.5
;           9     020141.61+145026.5
;          10     020141.61+145026.5
;          11     035219.08+010934.7
;          12     035219.08+010934.7
;          13     035219.08+010934.7
;          14     035219.08+010934.7
;          15     035219.08+010934.7
;          16     035219.08+010934.7
;          17     035219.08+010934.7
;          18     035219.08+010934.7
;          19     035219.08+010934.7
;          20     035219.08+010934.7
;          21     035219.08+010934.7
;          22     035219.08+010934.7
;          23     035219.08+010934.7
;          24     072839.20+383336.3
;          25     072839.20+383336.3
;          26     072839.20+383336.3
;          27     072839.20+383336.3
;          28     072839.20+383336.3
;          29     072839.20+383336.3
;          30     072839.20+383336.3
;          31     072839.20+383336.3
;    End time: Fri Feb  1 17:55:03 2013
;  
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Feb 2013
;   Documented, Feb 2013
;

pro go
	;JR - print the start time
	print, 'Start time: ', systime()

	;JR - get the quasar coordinates 
	readcol,'../../../myers/week2/HW1quasarfile.dat',format='A',coords
	RA  = hms2dec(strmid(coords,0,2)+':'+strmid(coords,2,2)+':'+strmid(coords,4,4))*15.						;JR - reformat coordinates to HH:MM:SS.S 
	dec = hms2dec(strmid(coords,9,3)+':'+strmid(coords,12,2)+':'+strmid(coords,14,4))						;JR - use strmid(string,first char,length) to split coords

	;JR - get coordinates for KPNO
	observatory,'kpno',obs

	;JR - generate dates
	year = 2013. 
	hour = (23.+7.)
	read, 'What month (01=January,...,12=December) do you want to calculate observations for? ', month				;JR - get the month from the user

	;JR - define calendar
	month_name=['January','February','March','April','May','June','July','August','September','October','November','December']
	numdays = 31.															;JR - set the number of days in each month
	if ((month eq 4) or (month eq 6) or (month eq 9) or (month eq 11)) then numdays = 30.
	if (month eq 2) then numdays = 28.

	;JR - print the header for the loop information
	print, 'The quasar with the lowest airmass at 11PM MST each day of ',month_name(month-1),' is: '
	print,'	   Day 	 Object'

	;JR - loop through the days of the month
	i =0L
	while i lt numdays do begin

		day = i+1.														;JR - set the day
		juldate = JULDAY(month,day,year,hour,00,00)										;JR - get JD on that date
		airmass = tai2airmass(RA, dec, jd=juldate, longitude=360.-obs.longitude, latitude=obs.latitude, altitude=obs.altitude)	;JR - calculate airmass at KPNO
		lo = where(airmass eq min(airmass(where(airmass gt 0.))))								;JR - find the object with the lowest airmass
		print,long(day),'	',coords[lo]											;JR - print to screen

		i++
	endwhile

	;JR - print end time
	print, 'End time: ', systime()
stop,'.cont to continue'
end
