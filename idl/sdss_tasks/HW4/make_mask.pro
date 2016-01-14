;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;    MAKE_MASK creates a mask from input coordinates.
;
; CALLING SEQUENCE:
;	make_mask,RA,dec,radius,bitmask,mask
;
; DESCRIPTION:
;   MAKE_MASK takes input RA and dec values plus
;   a radius and creates a mask.  The RA,dec pairs
;   are considered to be the center of circular
;   caps with the input radius.
;
; INPUTS:
;   RA      - a structure of RAs (in deg)
;   dec     - a structure of decs (in deg)
;   radius  - the radius of all circular caps (in deg)
;   bitmask - an array of bitmasks for calculating the mask area.
;
; KEYWORD INPUTS:
;
; RETURNS:
;    mask - an array of polygons defining the mask region
;
; EXAMPLE:
;	RA = [163,167]
;	dec = [50,50]
;	radius = 2
;	bitmask  = [1,2,3]							
;	
;	make_mask,RA,dec,radius,bitmask,mask
;
; BUGS:
;   Overlapping regions is handled for the area, but the
;   mask polygons are not balkanized.
;   Bitmask is currently hardcoded for two overlapping circles.
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, March 2013
;   Documented, March 2013
;

pro make_mask,RA,dec,radius,bitmask,mask

	;JR initialize a polygon structure
	poly = construct_polygon(ncaps=n_elements(RA))

	;JR populate the polygon
	poly.ncaps      = n_elements(RA)										;JR initializes the number of caps	
	i=0
	while i lt n_elements(RA) do begin
		(*poly.caps)[i] = circle_cap(radius,ra=RA[i],dec=dec[i])						;JR loads the caps into the polygon
		i++
	endwhile	

	;JR build mask array
	mask = replicate(poly,n_elements(RA))
	i=0
	while i lt n_elements(RA) do begin
		poly.use_caps = 2.^(i)
		mask[i] = poly
		i++
	endwhile

	;JR get area without overlapping regions 
	area = 0
	i=0

	while i lt n_elements(bitmask) do begin
		poly.use_caps = bitmask[i]
		if i lt 2 then begin 											;this is hard coded in --> BAD
			area          = area+garea(poly)
		endif else begin											;JR added 2/27/13
			area          = area-garea(poly)								;JR remove double counted areas where spec plates overlap
		endelse
		i++
	endwhile
	poly.str = (180*180/!pi/!pi)*area 										;JR store the area
	poly.use_caps = 0
end
