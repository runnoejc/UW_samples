;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   GET_AREA creates a polygon structure for a lun
;   and calculates its area. 
;
; CALLING SEQUENCE:
;   GET_AREA,RA1,RA2,dec1,dec2,poly
;
; DESCRIPTION:
;   Calculate the area of a lune with corners 
;   (RA1,dec1), (RA2,dec1), (RA2,dec2), 
;   and (RA1,dec2) and return it in a polygon
;   structure.
;
;
; INPUTS:
;   RA1  - the minimum RA limit in degrees
;   RA2  - the maximum RA limit in degrees
;   dec1 - the minimum dec limit in degrees
;   dec2 - the maximum dec limit in degrees
;
; KEYWORD INPUTS:
;
; RETURNS:
;   poly - a polygon structure containing the polygon
;          and the area of the lune.
;
; EXAMPLE:
;   ;define limits
;   RA1  = 75.
;   RA2  = 90.
;   dec1 = 30.
;   dec2 = 40.
; 
;   ;call GET_AREA
;   get_area,RA1,RA2,dec1,dec2,poly
;
;   ;plot the lune and label it with its area
;   poly.use_caps = 15
;   if i eq 0 then plot_poly,poly,color='00FFFFF'x,/fill,xrange=[-100,360],yrange=[-10,90] else plot_poly,poly,color='00FFFFF'x,/fill,/over
;   xyouts,RA2+10.,0.5*(dec2-dec1)+dec1,'Lune area is: '+strtrim(poly.str,2)+' sq deg'
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Feb 2013
;   Documented, Feb 2013
;

pro get_area,RA1,RA2,dec1,dec2,poly

	;JR - calculate the area of a lune with corners (RA1,dec1), (RA2,dec1), (RA2,dec2), and (RA1,dec2)
	area = (180./!dpi)*(RA2-RA1)*(sin((!dpi/180.)*dec2)-sin((!dpi/180.)*dec1))

	;JR - create 4 caps that bound the lune
	cap_RA1  = make_ra_cap(RA1,sign=1)
	cap_RA2  = make_ra_cap(RA2,sign=-1)
	cap_dec1 = make_dec_cap(dec1,sign=1)
	cap_dec2 = make_dec_cap(dec2,sign=-1)

	;JR - initialize a polygon structure
	poly = construct_polygon(ncaps=4)

	;JR - populate the polygon
	poly.ncaps      = 4								;initializes the number of caps	
	(*poly.caps)[0] = cap_RA1							;puts the caps into the polygon
	(*poly.caps)[1] = cap_RA2
	(*poly.caps)[2] = cap_dec1 
	(*poly.caps)[3] = cap_dec2

	;JR - add the area to the polygon structure
	poly.str = area									;saves the area

end
