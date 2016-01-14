;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   PIXELATE takes input coordinates and saves
;   their pixel numbers for various levels of
;   pixelation. 
;
; CALLING SEQUENCE:
;
; DESCRIPTION:
;   PIXELATE takes an input set of RA and dec
;   and saves a fits file with the RA, dec, and
;   a 3-array of pixel numbers for the 5th, 6th,
;   and 7th levels of HEALpix pixelation.  
;
; INPUTS:
;   File with coordinates.
;
; KEYWORD INPUTS:
;
; RETURNS:
;  A fits file with:
;  RA     - the input RA
;  dec    - the input dec
;  pixnum - a 3-array of pixel numbers corresponding
;           to the 5, 6, and 7 levels of pixelation. 
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

pro pixelate
	;JR - print the start time
	print, 'Start time: ', systime()

	;JR - read in data from file
	readcol,'../../../myers/week2/HW1quasarfile.dat',format='A',coords

	;JR - convert coordinates to degrees
	RA  = hms2dec(strmid(coords,0,2)+':'+strmid(coords,2,2)+':'+strmid(coords,4,4))*15.		;JR - reformat coordinates to HH:MM:SS.S 
	dec = hms2dec(strmid(coords,9,3)+':'+strmid(coords,12,2)+':'+strmid(coords,14,4))		;JR - use strmid(string,first char,length) to split coords	

	;JR - find where coords lie in pixels on sphere
	ra_rad  = (!dpi/180.)*ra									;JR - convert to radians
	dec_rad = (!dpi/180.)*(dec+90.) 								;JR - convert to radians and shift to N pole=0
	
	pixnum = fltarr(3,n_elements(RA))

	i=5.
	while i lt 8 do begin
		nside   = i										;JR - define the level of pixelization
		ang2pix_ring, nside, dec_rad, ra_rad, ipix
		pixnum[i-5.,*] = ipix									;JR - store the pixel numbers for this level of pixelation
		i++
	endwhile

	;JR - put the results in a structure
	pixstruct={ra:ra, $    
  		   dec:dec,$
  		   pixnum:pixnum}									;JR - this puts the 3 pixel arrays into a matrix

	;JR - and write the structure to a fits file
	mwrfits,pixstruct,'pixnums.fits',/create

	;JR - print the start time
	print, 'End time: ', systime()

stop,'.cont to continue'
end
