;+
; NAME:
;   PLOTPS
;
; AUTHOR:
;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   PLOTPS plots input data and a fit to a PNG file. 
;
; CALLING SEQUENCE:
;   tmp = PLOTPS(X,Y,Y_err,Y_mod,fit) 
;
; DESCRIPTION:
;   PLOTPS is a function to plot to a PNG file suitable
;   for display on a webpage.
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
;   A null value to tmp and a hw0.png. 
;
; EXAMPLE:
;
;   ;generate data
;   linedata = LINE_GEN(m,b)
;
;   ;fit the data with m and b as initial guesses
;   fit = LINE_FIT(m,b,linedata.X,linedata.Y,linedata.Y_err)
;
;   ;create a file called hw0.png
;   tmp = PLOTPS(linedata.X,linedata.Y,linedata.Y_err,linedata.Y_mod,fit.fit)
;   
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Jan 2013
;   Documented, Jan 2013
;

function plotps, X, Y, Y_err, Y_mod, fit

	;create a circle plot symbol
	A = findgen(17)*(!PI*2/16.)
	usersym,cos(A),sin(A),/fill

	;define some nice colors
	loadCT,40														;load the rainbow+black color table
	tvlct,204,17,0,100													;blood orange
	tvlct,176,23,31,101													;indian red
	tvlct,0,205,0,102													;green
	tvlct,255,127,0,103													;dark orange
	tvlct,255,193,37,104													;goldenrod
	tvlct,25,25,112,105													;midnight blue
	tvlct,138,181,220,106													;transparent blue
	tvlct,200,200,200,107													;gray
	tvlct,250,128,114,108													;salmon

	;define plot range
	xmin = min(X)-0.5
	xmax = max(X)+0.5 
	ymin = min(Y)-0.75													;the y axis needs more space to accomodate errors
	ymax = max(Y)+0.75

	;plot the data
        PS_Start, FILENAME='hw0.ps'

	plot,X,Y,psym=8,xtitle='X',ytitle='Y',xrange=[xmin,xmax],yrange=[ymin,ymax],xstyle=1,ystyle=1,yminor=4,/nodata		;plot the box
	oplot,X,fit,color=100,thick=4												;plot the fit
	oplot,X,Y_mod,color=107,thick=4,linestyle=2										;plot the origial model
	oploterror,X,Y,Y_err,psym=8												;plot the data over the fit
	legend,['model','best fit'],linestyle=[2,0],color=[107,100],thick=[4,4],charsize=1.25,box=0

        PS_End, /PNG
	

end
