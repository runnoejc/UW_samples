;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   HW3 mangles an imaginary survey and finds quasars
;   in the survey footprint.
;
; CALLING SEQUENCE:
;
; DESCRIPTION:
;   HW3 takes coordinates for an imaginary survey and
;   constructs a mask for the survey footprint.  It
;   reads in a data file of SDSS quasars and determines
;   which objects are in the survey footprint.  The 
;   area of the survey and density of objects in the
;   footprint are also returned.
;
; INPUTS:
;
; KEYWORD INPUTS:
;
; RETURNS:
;   Plots the quasars, the survey footprint,
;   and notes the quasars in the survey.
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

pro hw3
	;JR - print the start time
	print, 'Start time: ', systime()

	;JR - set the limits (all in degrees)
	RA_lo  = hms2dec('10:40:00')*15.0
	RA_hi  = hms2dec('11:20:00')*15.0
	dec_lo = 40.0
	dec_hi = 60.0
	radius = 2.0		
	dec    = 50.0												;JR - all plates have the same dec
	RA     = [159.0,163.0,167.0,171.0]	

	;JR - create 4 caps survey field 
	cap_RA_lo  = make_ra_cap(RA_lo,sign=1)									;JR - do them individually
	cap_RA_hi  = make_ra_cap(RA_hi,sign=-1)
	cap_dec_lo = make_dec_cap(dec_lo,sign=1)
	cap_dec_hi = make_dec_cap(dec_hi,sign=-1)

	;JR - initialize a polygon structure
	poly = construct_polygon(ncaps=8)

	;JR - populate the polygon
	poly.ncaps      = 8											;JR - initializes the number of caps	
	(*poly.caps)[0] = cap_RA_lo										;JR - put the survey field into the polygon
	(*poly.caps)[1] = cap_RA_hi
	(*poly.caps)[2] = cap_dec_lo 
	(*poly.caps)[3] = cap_dec_hi
	i=0
	while i lt 4 do begin
		(*poly.caps)[i+4] = circle_cap(radius,ra=RA[i],dec=dec)						;JR - loads the plates into the polygon
		print, i+3
		i++
	endwhile

	;JR - build survey region with spex coverage
	bitmask  = [31,47,79,143,63,111,206]
	polygons = [poly,poly,poly,poly]
	area     = 0
	i=0
	plot,[0,0],[0,0],xrange=[155,175],yrange=[35,65],color='FFFFFF'x
	while i lt 7 do begin
		poly.use_caps = bitmask[i]
		if i lt 4 then begin 
			polygons[i]   = poly
			area          = area+garea(poly)
			plot_poly,poly,color='0000FF'x,/over
		endif else begin										;JR - added 2/27/13
			area          = area-garea(poly)							;JR - remove double counted areas where spec plates overlap
			plot_poly,poly,color='00FFFF'x,/over
		endelse
		i++
	endwhile
	
	;JR - remove the double counted parts

	write_fits_polygons,'survey_mask.fits',polygons								;JR - saves the full survey polygons	
	
	;JR - add the area to the polygon structure
	poly.str = (180*180/!pi/!pi)*area	

	;JR - read in data from file
	readcol,'../../../myers/week4/HW3quasarfile.dat',format='A',coords

	;JR - convert coordinates to degrees
	RA  = hms2dec(strmid(coords,0,2)+':'+strmid(coords,2,2)+':'+strmid(coords,4,4))*15.			;JR - reformat coordinates to HH:MM:SS.S 
	dec = hms2dec(strmid(coords,9,3)+':'+strmid(coords,12,2)+':'+strmid(coords,14,4))			;JR - use strmid(string,first char,length) to split coords

	;JR - check what's in the survey footprint 
	hit=is_in_window(ra=ra,dec=dec,polygons)
	index = where(hit eq 1)
	cts   = n_elements(index)

	;JR - create the plot
		;JR - create a circle plot symbol
		A = findgen(17)*(!PI*2/16.)
		usersym,0.5*cos(A),0.5*sin(A),/fill

        PS_Start, FILENAME='hw3_survey.png'

	    ;JR - plot the quasars
	    !ytitle='Declination (deg)'
	    !xtitle='Right Ascension (deg)'
	    plot,ra,dec,psym=8,symsize=0.5,xrange=[145,185],yrange=[25,75],ystyle=1,xstyle=1
	
	    ;JR - overplot the plates where they overlap with the field
	    i=0
	    while i lt 4 do begin	
	        plot_poly,polygons[i],color=cgcolor('dark orchid'),/fill,/over
	        i++ 
            endwhile
  	    oplot,ra(index),dec(index),psym=8,symsize=0.5;,color=cgcolor('deep pink')				;JR - overplots points in the survey	
	    xyouts,146,72,'Survey area: '+strtrim(poly.str,2)+' sq. deg.'
	    xyouts,146,69,'Survey density: '+strtrim(cts/poly.str,2)+' per sq. deg.'

        PS_End, /PNG
	
	;JR - print the start time
	print, 'End time: ', systime()

stop,'.cont to continue'
end
