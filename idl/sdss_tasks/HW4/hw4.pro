;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   HW4 creates a survey mask, finds FIRST and SDSS matches
;   in the survey field, and plots the SED for the brightest
;   object in the FUV.
;
; CALLING SEQUENCE:
;
; DESCRIPTION:
;   HW4 takes coordinates for an imaginary survey and
;   constructs a mask for the survey footprint.  It 
;   determines the coordinates of FIRST objects in
;   the survey footprint and matches them within 1"
;   to SDSS.  It plots the SED for the brightest object
;   in the FUV using GALEX fluxes.
;
; INPUTS:
;
; KEYWORD INPUTS:
;
; RETURNS:
;   Plot of the SED of the brightest object in the FUV.
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

pro hw4
	RA = [163,167]
	dec = [50,50]
	radius = 2
	bitmask  = [1,2,3]							;JR the bitmask for the regions I want in my mask
	
	;JR create the mask
	make_mask,RA,dec,radius,bitmask,mask

	;JR get the FIRST data
	get_FIRST,mask,FIRST_survey

	;JR plot the survey
		;JR - create a circle plot symbol
		A = findgen(17)*(!PI*2/16.)
		usersym,cos(A),sin(A),/fill

	;JR get SDSS and GALEX fluxes
	sweep_rad = 1./(60.*60.)						;JR sweep radius of 1"
	get_fluxes,FIRST_survey,sweep_rad,SDSS,GALEX,FIRST	

	;JR find brightest FUV
	FUV1 = where(GALEX.fuv eq max(GALEX.fuv))
	wave = [1600,2400,3543,4770,6231,7625,9134]
	SED  = [(GALEX.fuv)[FUV1],(GALEX.nuv)[FUV1],(SDSS.psfflux)[*,FUV1]]
	ugriz= 22.5-2.5*alog10((SDSS.psfflux)[*,FUV1])

	;JR print properties of FUV1 to the screen
	print,'The object FUV1 has: '
	print, 'Right Ascension: ',strtrim((SDSS.RA)[FUV1],2)
	print, 'Declination: ',strtrim((SDSS.dec)[FUV1],2)
	print, 'U: ',strtrim(ugriz[0],2)
	print, 'G: ',strtrim(ugriz[1],2)
	print, 'R: ',strtrim(ugriz[2],2)
	print, 'I: ',strtrim(ugriz[3],2)
	print, 'Z: ',strtrim(ugriz[4],2)

	;JR plot the SED for this object
        PS_Start, FILENAME='hw4_SED.png'
	    !xtitle= 'Wavelength (!3' + STRING(197B) + '!X)'
	    !ytitle='Flux (10!u-17!n ergs s!u-1!n cm!u-2!n !3' + STRING(197B) + '!X!u-1!n)'
	    plot,wave,SED,psym=8,xrange=[1400,10000],xstyle=1
	    oplot,wave[0:1],SED[0:1],color=cgcolor('Steel Blue'),psym=8
	    oplot,wave[2:6],SED[2:6],color=cgcolor('Firebrick'),psym=8
	    legend,['SDSS','GALEX'],psym=[8,8],color=[cgcolor('Firebrick'),cgcolor('Steel Blue')],box=0,/bottom,/right
        PS_End, /PNG

	;JR print some comments about the spectrum of FUV1
	print, 'By its spectrum, FUV1 is an AGN.  My SED is a little higher flux than the spectrum from SDSS Navigator, but that is likely because my fluxes are integrated over the full UGRIZ bandpassess.  Correcting for this should bring the flux normalization into better agreement.  One of the SDSS fluxes is very high in my SED, likely because Halpha falls in that bandpass.'
	
stop,'.cont to continue'
end
