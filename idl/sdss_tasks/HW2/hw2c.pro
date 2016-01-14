;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   HW2c takes input coordinates and pixels numbers
;   and plots the data with the five most overdense
;   regions highlighted. 
;
; CALLING SEQUENCE:
;
; DESCRIPTION:
;  HW2c takes input RA, dec, and pixels for the
;  5, 6, and 7 levels of HEALpix and plots the
;  data and the 5 most overdense regions to a
;  file.
;
; INPUTS:
;  Fits file with coordinates and pixel numbers. 
;
; KEYWORD INPUTS:
;
; RETURNS:
;  A plot of the data and overdense regions.
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

pro hw2c
	;JR - print the start time
	print, 'Start time: ', systime()

	;JR - read in the data
	data = mrdfits('./pixnums.fits',1,header)

	;JR - plot the data
	;JR - initialize the plot
	ps_start,filename='./overdensity.png'	;comment out to plot to screen
	
		;JR - create a circle plot symbol
		A = findgen(17)*(!PI*2/16.)
		usersym,0.5*cos(A),0.5*sin(A),/fill

		;JR - define an array of colors
		colors = ['red','orange','gold','forest green','blue']

		!xtitle = 'Right Ascension (deg)'
		!ytitle = 'Declincation (deg)'
		plot,data.ra,data.dec,psym=3,xrange=[-10,370],yrange=[-20,90],xstyle=1,ystyle=1

		;JR - make a dummy array of pixel numbers
		pixels = data.pixnum[0,*]

		i=0
		while i lt 5 do begin
		
			mode = min(get_mode(pixels(where(pixels ne -1.))))				;get the pixel that occurs most often (i.e. the mode), ignore previous modes 
			pixels(where(pixels eq mode)) = -1						;set mode pixels in dummy array to -1
			index = where(data.pixnum[0,*] eq mode)						;find where the pixel is equal to the mode
			oplot,data.ra(index),data.dec(index),color=cgcolor(colors[i]),psym=8		;plot
			i++

		endwhile

	ps_end,/png	;comment out to plot to screen

	;JR - print the start time
	print, 'End time: ', systime()

stop,'.cont to continue'
end
