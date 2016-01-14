;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   HW1_PLANETS completes the first two tasks of HW1.
;   It gets the coordinates of the first 5 planets,
;   plots them in two formats, and returns the date of lowest
;   airmass of each planet.
;
; CALLING SEQUENCE:
;   IDL>.r hw1_planets
;   IDL>go 
;
; DESCRIPTION:
;   HW1_PLANETS gets the ecliptic and celestial coordinates
;   of the first five planets at 7AM and 7PM MST on January
;   1st for the years 2011-2020, plots them, returns the date
;   of lowest airmass for each planet, and marks the
;   coordinates at the date of lowest airmass on the plot.
;
; INPUTS:
;
; KEYWORD INPUTS:
;
; RETURNS:
;   hw1_planets.png      - plot of the first five planets in
;                          ecliptic coordinates
;   hw1_celesplanets.png - plot of the first five planets in
;			   celestial coordinates with the
;			   observation of lowest airmass marked
;
; EXAMPLE:
;
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Jan 2013
;   Documented, Jan 2013
;

pro go
	;JR - print the start time
	print, 'Start time: ', systime()

	;JR - populate array of years between 2011 and 2020, two of each year 
	year = [indgen(10)+2011.,indgen(10)+2011.]				;JR - generate year array

	;JR - populate an array of times
	hour = [replicate(7.+7.,10),replicate(19.+7.,10)]			;JR - convert 7AM and 7PM MST to UTC

	;JR - get julian dates
	juldates = JULDAY(01,01,year,hour,00,00)				
	juldates = juldates(sort(juldates))					;JR - sort so 7AM and 7PM of the same year are together

	;JR - get equatorial coordinates for planets 
	planet_coords,juldates,RA_merc,dec_merc,planet='mercury',/JD
	planet_coords,juldates,RA_ven,dec_ven,planet='venus',/JD
	planet_coords,juldates,RA_mars,dec_mars,planet='mars',/JD
	planet_coords,juldates,RA_jup,dec_jup,planet='jupiter',/JD
	planet_coords,juldates,RA_sat,dec_sat,planet='saturn',/JD
	
	;JR - convert them to ecliptic coordinates
	euler, RA_merc, dec_merc, l_merc, b_merc,select=3
	euler, RA_ven, dec_ven, l_ven, b_ven,select=3
	euler, RA_mars, dec_mars, l_mars, b_mars,select=3
	euler, RA_jup, dec_jup, l_jup, b_jup,select=3
	euler, RA_sat, dec_sat, l_sat, b_sat,select=3
		
	;JR - get coordinates for KPNO
	observatory,'kpno',obs

	;JR - get airmasses
	airmass_merc = tai2airmass(RA_merc, dec_merc, jd=juldates, longitude=360.-obs.longitude, latitude=obs.latitude, altitude=obs.altitude)
	airmass_ven  = tai2airmass(RA_ven, dec_ven, jd=juldates, longitude=360.-obs.longitude, latitude=obs.latitude, altitude=obs.altitude)
	airmass_mars = tai2airmass(RA_mars, dec_mars, jd=juldates, longitude=360.-obs.longitude, latitude=obs.latitude, altitude=obs.altitude)
	airmass_jup  = tai2airmass(RA_jup, dec_jup, jd=juldates, longitude=360.-obs.longitude, latitude=obs.latitude, altitude=obs.altitude)
	airmass_sat  = tai2airmass(RA_sat, dec_sat, jd=juldates, longitude=360.-obs.longitude, latitude=obs.latitude, altitude=obs.altitude)

	;JR - find index of lowest airmass for each planet
	lo_merc = where(airmass_merc eq min(airmass_merc(where(airmass_merc gt 0.)))) 
	lo_ven = where(airmass_ven eq min(airmass_ven(where(airmass_ven gt 0.))))
	lo_mars = where(airmass_mars eq min(airmass_mars(where(airmass_mars gt 0.)))) 
	lo_jup = where(airmass_jup eq min(airmass_jup(where(airmass_jup gt 0.)))) 
	lo_sat = where(airmass_sat eq min(airmass_sat(where(airmass_sat gt 0.)))) 

	;JR - plotting 
		;JR - create a circle plot symbol
		A = findgen(17)*(!PI*2/16.)
		usersym,0.75*cos(A),0.75*sin(A),/fill

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

	;JR - plot the planets in ecliptic coordinates
        PS_Start, FILENAME='hw1_planets.png'

	!ytitle = 'Latitude'
	!xtitle = 'Longitude'

	plot,l_merc,b_merc,psym=8,xrange=[0,360]
	oplot,l_ven,b_ven,psym=8,color=104
	oplot,l_mars,b_mars,psym=8,color=101
	oplot,l_jup,b_jup,psym=8,color=106
	oplot,l_sat,b_sat,psym=8,color=102
	legend,['Mercury','Venus','Mars','Jupiter','Saturn'],color=[200,104,101,106,102],psym=[8,8,8,8,8],charsize=1.25,pos=[2.5,125]

        PS_End, /PNG

	;JR - plot the planets in equatorial coordinates
        PS_Start, FILENAME='hw1_celesplanets.png'

	!ytitle = 'Declination'
	!xtitle = 'Right Ascenscion'

	;JR - plot the planets
	plot,RA_merc,dec_merc,psym=8,yrange=[-25,25],xrange=[0,360]
	oplot,RA_ven,dec_ven,psym=8,color=104
	oplot,RA_mars,dec_mars,psym=8,color=101
	oplot,RA_jup,dec_jup,psym=8,color=106
	oplot,RA_sat,dec_sat,psym=8,color=102
	;JR - plot the planets when they have the lowest airmasses
	oplot,RA_merc[lo_merc],dec_merc[lo_merc],psym=1,symsize=3
	oplot,RA_ven[lo_ven],dec_ven[lo_ven],psym=1,color=104,symsize=3
	oplot,RA_mars[lo_mars],dec_mars[lo_mars],psym=1,color=101,symsize=3
	oplot,RA_jup[lo_jup],dec_jup[lo_jup],psym=1,color=106,symsize=3
	oplot,RA_sat[lo_sat],dec_sat[lo_sat],psym=1,color=102,symsize=3

	legend,['Mercury','Venus','Mars','Jupiter','Saturn'],color=[200,104,101,106,102],psym=[8,8,8,8,8],charsize=1.25,pos=[325,27]
	xyouts,10,-27,'Cross indicates lowest airmass for each planet.',charsize=1.0

        PS_End, /PNG

	;JR - print dates of lowest airmass for each planet
	print, 'Mercury has lowest airmass on January 1 at: ', dec2hms(hour(lo_merc)-7.),',',long(year(lo_merc))
	print, 'Venus has lowest airmass on January 1 at: ', dec2hms(hour(lo_ven)-7.),',',long(year(lo_ven))
	print, 'Mars has lowest airmass on January 1 at: ', dec2hms(hour(lo_mars)-7.),',',long(year(lo_mars))
	print, 'Jupiter has lowest airmass on January 1 at: ', dec2hms(hour(lo_jup)-7.),',',long(year(lo_jup))
	print, 'Saturn has lowest airmass on January 1 at: ', dec2hms(hour(lo_sat)-7.),',',long(year(lo_sat))

	;JR - print end time
	print, 'End time: ', systime()
stop,'.cont to continue'
end

