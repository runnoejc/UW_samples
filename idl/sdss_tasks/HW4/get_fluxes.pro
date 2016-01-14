;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   GET_FLUXES matches FIRST and SDSS and returns
;   data for matching objects.  
;
; CALLING SEQUENCE:
;   get_fluxes,data_in,radius,SDSS,GALEX,FIRST 
;
; DESCRIPTION:
;   GET_FLUXES takes input coordinates and a radius
;   and matches those coordinates to the FIRST survey
;   within the given radius.  It compiles GALEX, SDSS, 
;   and FIRST data for matched sources and returns them.
;
; INPUTS:
;   data_in - a structure with input RA and dec
;   radius  - the radius to match the input data to SDSS in deg
;
; KEYWORD INPUTS:
;
; RETURNS:
;    SDSS  - a structure containing SDSS data for matched sources
;    GALEX - a structure containing GALEX data for matched sources
;    FIRST - the input structure for matched sources only 
;    SDSS and GALEX are in the same format returned from sweep process.
;
; EXAMPLE:
;
; BUGS:
;    FIRST isn't getting the right thing in it.  It's got 
;    n_elements(coords.ra)*(number of matches) in it.
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, March 2013
;   Documented, March 2013
;

pro get_fluxes,coords,radius,SDSS,GALEX,FIRST

	;JR set the environment
	setenv,'PHOTO_SWEEP=/d/quasar2/dr8/'

	;JR initialize the flux and mag arrays
	SDSS_flux  = fltarr(5,n_elements(coords.RA))-9999.
	galex_flux = fltarr(2,n_elements(coords.RA))-9999.

	;JR get all the sweep files in the survey area
	sdss_sweep_data_index,coords.RA,coords.dec,(1./(60.*60.)),swfiles,minind,maxind				;JR gives you the same as running the survey coordinates within 2 deg 
	;sdss_sweep_data_index,165,50,3,swfiles,minind,maxind

	galex_swfiles = '/d/quasar2/galex_dr8/301/aper_'+strmid(swfiles,19,30)

	;JR loop through the objects
	i=0
	start = 0
	while i lt n_elements(swfiles) do begin
		data       = mrdfits(swfiles[i],1,range=[minind[i],maxind[i]])					;JR read in the data file
		galex_data = mrdfits(galex_swfiles[i],1,range=[minind[i],maxind[i]])				;JR read in the data file

 		primaryflag = sdss_flagval('RESOLVE_STATUS','SURVEY_PRIMARY')
 		w = where((data.resolve_status AND primaryflag) ne 0, nprim)
 		data = data[w]
 		galex_data = galex_data[w]

       	   	spherematch,coords.RA,coords.dec,data.ra,data.dec,radius,m1,m2,distances,maxmatch=0		;JR match the coordinates, maxmatch=1 returns only closest match

		if (m1[0] ne -1) then begin
			if (start eq 0) then begin
				SDSS  = data[m2]
				GALEX = galex_data[m2]
				FIRST = (coords)[m1]
				start = 1	
			endif else begin
				SDSS  = [SDSS,data[m2]]
				GALEX = [GALEX,galex_data[m2]]
				FIRST = [FIRST,(coords)[m1]]
			endelse

		endif			
		i++
	endwhile
	
	print, 'Percent of FIRST sources matched to SDSS: ',100*(n_elements(SDSS.ra)/double(n_elements(coords.ra)))
		
end
