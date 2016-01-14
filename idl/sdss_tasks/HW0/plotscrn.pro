;+
; NAME:
;   PLOTSCRN
;
; AUTHOR:
;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   PLOTSCRN plots input data and a fit to the screen. 
;
; CALLING SEQUENCE:
;   tmp = PLOTSCRN(X,Y,Y_err,Y_mod,fit) 
;
; DESCRIPTION:
;   PLOTSCN is a function to plot data to the screen.
;
; INPUTS:
;   X     - the array of X values
;   Y     - the array of Y values
;   Y_err - the array of error in the Y values
;   Y_mod - the original model that the Y values were drawn from
;   fit   - the best fit to the data 
;
; KEYWORD INPUTS:
;
; RETURNS:
;   A null value to tmp and a screen plot. 
;
; EXAMPLE:
;
;   ;generate data
;   linedata = LINE_GEN(m,b)
;
;   ;fit the data with m and b as initial guesses
;   fit = LINE_FIT(m,b,linedata.X,linedata.Y,linedata.Y_err)
;
;   ;plot to the screen
;   tmp = PLOTSCRN(linedata.X,linedata.Y,linedata.Y_err,linedata.Y_mod,fit.fit)
;   
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Jan 2013
;   Documented, Jan 2013
;

function plotscrn, X, Y, Y_err, model, fit

	;create a circle plot symbol
	A = findgen(17)*(!PI*2/16.)
	usersym,cos(A),sin(A),/fill

	;define axis labels
	!xtitle = 'X'
	!ytitle = 'Y'

	;plot the data
	plot,X,Y,psym=8,xrange=[min(X)-0.5,max(X)+0.5],yrange=[min(Y)-0.75,max(Y)+0.75],xstyle=1,ystyle=1,yminor=4,/nodata
	oplot, X, fit, color='0000FF'x,thick=2
	oplot, X, model, color='00FF00'x, linestyle=2, thick=2
	oploterror,X,Y,Y_err,psym=8
	legend,['model','best fit'],linestyle=[2,0],color=['00FF00'x,'0000FF'x],charsize=1.25,box=0, thick=[2,2]

end
