;+
; NAME:
;   LINE_MOD
;
; AUTHOR:
;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   Model function for fitting a line with errors in Y.
;
; CALLING SEQUENCE:
;   result = MPFITFUN('line_mod',X,Y,Y_err,start,PARINFO=pi,BESTNORM=chi,PERROR=err)
;
; DESCRIPTION:
;   LINE_MOD is a model function that is meant to be called by 
;   MPFIT in order to fit a line using errors in only the Y 
;   direction.  LINE_MOD is not meant to be called directly, it should be
;   passed to MPFIT in a wrapper program.
;
;   When used with this function, MPFIT will return the values
;   P[0] - Y-intercept of the line
;   P[1] - slope of the line
;
; INPUTS:
;   X - the array of X values
;   P - the parameters of the line
;
; KEYWORD INPUTS:
;
; RETURNS:
;   f - an array of the line function with the same dimensions as X 
;
; EXAMPLE:
;   
;   ;define the starting guess
;   start  = [0.,0.]
;
;   ;fit the data
;   result = mpfitfun('line_mod',X,Y,Y_err,start,PARINFO=pi,BESTNORM=chi,PERROR=err)			;fits line
;
;   ;generate the fit
;   fit    = result[0]+result[1]*X
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Jan 2013
;   Documented, Jan 2013
;

function line_mod, x, p

	b = p[0]   ; Intercept
  	m = p[1]   ; Slope
  	f = b + m * x
  	return, f

end
