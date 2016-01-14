;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   HW1_QUASARS completes the third task of HW1.
;   It gets the coordinates of SDSS i=18 quasars,
;   plots them in Galactic coordinates, and makes
;   and discuses a histogram of their b values. 
;
; CALLING SEQUENCE:
;   IDL>.r hw1_quasars
;   IDL>go 
;
; DESCRIPTION:
;   HW1_QUASARS gets the time coordinates of 1066 SDSS
;   i=18 quasars from a data file, calculates and plots
;   their Galactic coordinates, and makes and discusses
;   a histogram of their Galactic latitudes. 
;
; INPUTS:
;
; KEYWORD INPUTS:
;
; RETURNS:
;   hw1_quasars.png    - plot of 1066 SDSS i=18 quasars
;			 in Galactic coordinates 
;                          
;   hw1_quasarhist.png - histogram of Galactic latitude
;                        for 1066 SDSS i=18 quasars
;   Also plots the histogram to the screen with some
;   discussion points.
;
; EXAMPLE:
;
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

	;JR - read in data from file
	readcol,'../../../myers/week2/HW1quasarfile.dat',format='A',coords

	;JR - convert coordinates to degrees
	RA  = hms2dec(strmid(coords,0,2)+':'+strmid(coords,2,2)+':'+strmid(coords,4,4))*15.		;JR - reformat coordinates to HH:MM:SS.S 
	dec = hms2dec(strmid(coords,9,3)+':'+strmid(coords,12,2)+':'+strmid(coords,14,4))		;JR - use strmid(string,first char,length) to split coords

	;JR - convert to galactic coordinates
	euler, RA, dec, l, b,select=1								

	;JR - plot galactic coordinates
		;JR - create a circle plot symbol
		A = findgen(17)*(!PI*2/16.)
		usersym,0.5*cos(A),0.5*sin(A),/fill

		;JR - define some nice colors
		loadCT,40														;JR - load the rainbow+black color table
		tvlct,204,17,0,100													;JR - blood orange
		tvlct,176,23,31,101													;JR - indian red
		tvlct,0,205,0,102													;JR - green
		tvlct,255,127,0,103													;JR - dark orange
		tvlct,255,193,37,104													;JR - goldenrod
		tvlct,25,25,112,105													;JR - midnight blue
		tvlct,138,181,220,106													;JR - transparent blue
		tvlct,200,200,200,107													;JR - gray
		tvlct,250,128,114,108													;JR - salmon
		tvlct,0,0,0,200

	;JR - plot the quasars in galactic coordinates
        PS_Start, FILENAME='hw1_quasars.png'

	!ytitle = 'Galactic Latitude (b)'
	!xtitle = 'Galactic Longitude (l)'
	plot,l,b,psym=8,xrange=[0,360],xstyle=1

        PS_End, /PNG

	;JR - plot a histogram of the galactic latitude 
        PS_Start, FILENAME='hw1_quasarhist.png'

	!ytitle = 'Number'
	!xtitle = 'Galactic Latitude (b)'
	plothist,b,bin=5.0,psym=10,xrange=[-90,90],xstyle=1

        PS_End, /PNG

	;JR - plot histogram to screen and print comments about histogram plot to screen
	!ytitle='Number'
	!xtitle='Galactic Latitude (b)'
	plothist,b,bin=5.0,psym=10,thick=3,xrange=[-90,90]	 
	print, 'The SDSS quasars have a distribution in Galactic latitude that has a weak peak at -50 degrees, a strong peak at +50 degrees, and a dearth of objects at b=0.  Objects at b=0 will be difficult to observe in the i band through the disk of the Galaxy, creating a local minimum in the histogram for that latitude.  I would assume the location of the peaks in the histogram is related to the SDSS sky coverage.'

	;JR - print end time
	print, 'End time: ', systime()

stop,'.cont to continue'
end
