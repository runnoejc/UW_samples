;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   HW2b randomly populates points in a lune. 
;
; CALLING SEQUENCE:
;
; DESCRIPTION:
;   HW2b takes input hms coordinates, populates the
;   sphere in uniform density with RA and dec,
;   and finds the points in the lune defined by
;   the input coordinates.  It uses the fact that
;   the ratio of points and area in the lune to the
;   total sphere should be equal as a check on the
;   lune area. 
;
; INPUTS:
;   File with HMS coordinates.
;
; KEYWORD INPUTS:
;
; RETURNS:
;  A plot of randomly generated points on the 
;  sky with those located in the lune in red.
;
; EXAMPLE:
;
; BUGS:
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Feb 2013
;   Documented, Feb 2013
;

pro hw2b
	;JR - print the start time
	print, 'Start time: ', systime()

	;read in the coordinates for the lunes
	readcol,'./coords.tab',format='A,A,A,A',RA1_hms,RA2_hms,dec1_hms,dec2_hms

	;JR - convert coordinates to degrees
	RA1  = hms2dec(RA1_hms)*15.
	RA2  = hms2dec(RA2_hms)*15.
	dec1 = hms2dec(dec1_hms)
	dec2 = hms2dec(dec2_hms)

	;JR - call procedure to get area of lune
	get_area,RA1[0],RA2[0],dec1[0],dec2[0],poly
	
	;JR - populate the sphere and find objects 
	ra = 360.*randomu(616,10000)							;using a seed number lets you reproduce the same thing every time
	dec=(180./!pi)*asin(1-randomu(663,10000)*2.)					;this populates the sphere with equal density
	
	;JR - check what's in my polygons
	poly.use_caps = 15								;tell it the region to use
	hit=is_in_window(ra=ra,dec=dec,poly)
	index = where(hit eq 1)

	;JR - plot all the points
		;JR - create a circle plot symbol
		A = findgen(17)*(!PI*2/16.)
		usersym,0.5*cos(A),0.5*sin(A),/fill

	ps_start,filename='./populated_lune.png'					;comment out to plot to screen
	!xtitle = 'Right Ascension (deg)'
	!ytitle = 'Declination (deg)'
	plot,ra,dec,psym=3,xrange=[-40,400],yrange=[-100,100],xstyle=1,ystyle=1	
	oplot,ra(index),dec(index),psym=8,color=cgcolor('dark red')			;overplots points in the lune 
	ps_end,/png									;comment out to plot to screen

	;JR - check that the area calculation is correct
	print, 'We can independently check the area calculation using the number of points in the lune.'
	print, 'Ratio of areas in lune/sphere is: ',strtrim(poly.str/(4*!dpi*180.*180./!dpi/!dpi),2)
	print, 'Ratio of points in lune/sphere is: ',strtrim(double(n_elements(index))/double(n_elements(RA)),2)

	;JR - print the start time
	print, 'End time: ', systime()

stop,'.cont to continue'
end
