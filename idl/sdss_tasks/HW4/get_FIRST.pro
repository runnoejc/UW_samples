;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   GET_FIRST returns the coordinates of FIRST objects
;   in a given mask area.
;   
;
; CALLING SEQUENCE:
;   get_FIRST,mask,FIRST_data 
;
; DESCRIPTION:
;   GET_FIRST takes an input mask, reads in the coordinates
;   of objects in the FIRST survey, and compiles the coordinates
;   of objects in the mask area.  It returns the coordinates
;   and a plot of the mask field with objects in the field
;   distinguished. 
;
; INPUTS:
;   mask - an array of polygons difining the region of interest
;
; KEYWORD INPUTS:
;
; RETURNS:
;   FIRST - a structure with the RA and dec of objects in the
;           mask area
;   Also plots the mask area and objects in it.
;
; EXAMPLE:
;
; BUGS:
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, March 2013
;   Documented, March 2013
;

pro get_FIRST,mask,FIRST

	;JR read in objects in SDSS with FIRST
	;FIRST = mrdfits('../../../../local_ASTR5160/week5/first_08jul16.fits',1)
	FIRST = mrdfits('/d/quasar2/FIRST/first_08jul16.fits',1)							;JR use this when running on network

	;JR check what's in the survey footprint
	hit=is_in_window(ra=(FIRST.ra),dec=(FIRST.dec),mask)
	index = where(hit eq 1)
	cts   = n_elements(index)

		;JR create a circle plot symbol
		A = findgen(17)*(!PI*2/16.)
		usersym,0.5*cos(A),0.5*sin(A),/fill

	;JR plot the survey
		;JR - create a circle plot symbol
		A = findgen(17)*(!PI*2/16.)
		usersym,cos(A),sin(A),/fill

        PS_Start, FILENAME='hw4_survey.png'
	    !ytitle= 'Declination (deg)'
	    !xtitle='Right Ascension (deg)'
	    plot,FIRST.RA,FIRST.dec,psym=3,xrange=[155,175],yrange=[45,55],color=cgcolor('black'),xstyle=1,ystyle=1
	    oplot,(FIRST.RA)[index],(FIRST.dec)[index],psym=8,symsize=0.25,color=cgcolor('firebrick')
	    plot_poly,mask,color=cgcolor('red'),/over
        PS_End, /PNG	

	;JR write objects in mask to fits file
		;compile the data in a structure
		FIRST={RA:(FIRST.ra)[index], $
	               dec:(FIRST.dec)[index]}
		;write it to a fits file
		mwrfits,FIRST,'FIRST_data.fits',/create

end
