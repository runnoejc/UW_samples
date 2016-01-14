;+
; NAME:
;   MASTER_LINE
;
; AUTHOR:
;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   Generate synthetic data and plot them. 
;
; CALLING SEQUENCE: 
;
;
; DESCRIPTION:
;   MASTER_LINE generates synthetic data with errors in Y
;   from a user defined line, plots them to the screen, and
;   plots them to a PNG file titled hw0.png.
;
; INPUTS:
;
; KEYWORD INPUTS:
;
; RETURNS:
;   hw0.png
;
; EXAMPLE:
;   IDL>.r MASTER_LINE
;   IDL>go   
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Jan 2013
;   Documented, Jan 2013
;

pro go	;type 'go' to run this program
	;print the start time
	print, 'Start time: ', systime()

	;user defined line
	read,'Input line slope and intercept (m,b): ',m,b

	;generate data
	print, 'Generating data...'
	linedata = line_gen(m,b)

	;fit the data with m and b as initial guesses
	print, 'Fitting data...'
	fit = line_fit(m,b,linedata.X,linedata.Y,linedata.Y_err)

	;plot the data to the screen
	print, 'Plotting...'
	tmp = plotscrn(linedata.X,linedata.Y,linedata.Y_err,linedata.Y_mod,fit.fit)	;tmp is just a place holder, plotscrn doesn't return anything

	;plot the data to a file
	tmp = plotps(linedata.X,linedata.Y,linedata.Y_err,linedata.Y_mod,fit.fit)

	;print end time
	print, 'End time: ', systime()
end

