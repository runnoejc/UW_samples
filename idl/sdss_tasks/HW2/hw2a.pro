;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   HW2a calculates the area and plots lunes of given
;   coordinates.
;
; CALLING SEQUENCE:
;
; DESCRIPTION:
;   HW2a is the wrapper for the first problem in HW2.
;   It reads in hms coordinates from a file,
;   calculates the area described by these
;   coordinates, and plots the lune to the screen.
;
; INPUTS:
;
; KEYWORD INPUTS:
;
; RETURNS:
;   Plots the lunes decribed by the input
;   coordinates and prints their areas.  
;
; EXAMPLE:
;
; BUGS:
;  PLOT_POLY has a hard time displaying:
;    1. declinations of 90 degrees.
;    2. right ascensions of 0 degrees.
;    3. ranges in right ascension greater than 180 
;       degrees.
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Feb 2013
;   Documented, Feb 2013
;

pro hw2a

	;JR - print the start time
	print, 'Start time: ', systime()

	;read in the coordinates for the lunes
	readcol,'./coords.tab',format='A,A,A,A',RA1_hms,RA2_hms,dec1_hms,dec2_hms

	;JR - convert coordinates to degrees
	RA1  = hms2dec(RA1_hms)*15.
	RA2  = hms2dec(RA2_hms)*15.
	dec1 = hms2dec(dec1_hms)
	dec2 = hms2dec(dec2_hms)

	;JR - initialize the plot
	ps_start,filename='./lunes.png'	;comment out to plot to screen

		;JR - loop through the lunes
		i=0
		while i lt n_elements(RA1) do begin
			;JR - warnings for plot_poly issues
			if ((RA2[i]-RA1[i]) gt 180.) then print, 'WARNING: Range in RA is greater than 180 degrees, plot will be incorrect.'
			if (RA1[i] eq 0.) then print, 'WARNING: Lower RA limit is 0 degrees, plot will be incorrect.'
			if (dec2[i] eq 0.) then print, 'WARNING: Lower dec limit is 0 degrees, plot will be incorrect.'

			;JR - call procedure to get area of lune
			get_area,RA1[i],RA2[i],dec1[i],dec2[i],poly
	
			;JR - plot the polygon or overplot if this is called from a loop and this is a nonzero iteration
			poly.use_caps = 15
			if i eq 0 then plot_poly,poly,color=cgcolor('pale goldenrod'),/fill,xrange=[0,400],yrange=[0,90] else plot_poly,poly,color=cgcolor('pale goldenrod'),/fill,/over
			xyouts,RA2[i]+10.,0.5*(dec2[i]-dec1[i])+dec1[i],'Lune area is: '+strtrim(poly.str,2)+' sq deg'
			print, 'The area of the lune is: ',strtrim(poly.str,2),' square degrees.'
			i++
		endwhile

	ps_end,/png	;comment out to plot to screen

	;JR - check that the get_area function correctly gets the area for a cap
	get_area,0.,360.,0.,90.,poly
	print, 'The area of a hemisphere is: ',strtrim(poly.str,2),' square degrees.'

	;JR - print the start time
	print, 'End time: ', systime()
	
stop,'.cont to continue'
end
