;+
; NAME:
;   LINE_FIT
;
; AUTHOR:
;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   LINE_FIT takes input data and a starting guess and calls
;   MPFITFUN to fit a line to the data.   
;
; CALLING SEQUENCE:
;   fit = line_fit(m,b,X,Y,Y_err)
;
; DESCRIPTION:
;   LINE_FIT is a model function that is meant to be called by 
;   MPFIT in order to fit a line using errors in only the Y 
;   direction.  LINE_MOD is not meant to be called directly, it should be
;   passed to MPFIT in a wrapper program.
;
; INPUTS:
;   m     - the initial guess for the slope 
;   b     - the initial guess for the intercept
;   X     - array of X data for the fit
;   Y     - array of Y data for the fit
;   Y_err - errors on Y data
;
; KEYWORD INPUTS:
;
; RETURNS:
;   fit.b     - the best-fit intercept
;   fit.m     - the best-fit slope
;   fit.fit   - an array of the fitted Y values
;   fit.b_err - the error on fit.b
;   fit.m_err - the error on fit.m  
;
; EXAMPLE:
;   ;generate the data
;   linedata = line_gen(m,b)
;
;   ;fit the data with m and b as initial guesses
;   fit = line_fit(m,b,linedata.X,linedata.Y,linedata.Y_err)
;
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Jan 2013
;   Documented, Jan 2013
;

function line_fit, m_start, b_start, X, Y, Y_err

	;define the starting guess
	start = [b_start,m_start]
	
	;fit the data
  	result = mpfitfun('line_mod',X,Y,Y_err,start,PARINFO=pi,BESTNORM=chi,PERROR=err,/QUIET)

	;make an array of the fit
	fitarr    = result[0] + result[1]*X					;makes y array for fit
	
	;if the errors are not physical,
	;this assumes the fit is good and scales
	;the errors to be meaningful
        errc   = err*sqrt(chi/(n_elements(Y)-2))					;scales error on parameters

	;compile the data in a structure
	fit={b:result[0], $    
  	     m:result[1], $
  	     fit:fitarr, $
  	     b_err:errc[0], $
	     m_err:errc[1]}

	return, fit
end
