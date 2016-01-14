;+
; NAME:
;   LINE_GEN
;
; AUTHOR:
;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   Take a user input of m and b for the equation
;   Y = m * X + b and return the X, Y, Y_err, and Y_mod 
;   data for a line.
;
; CALLING SEQUENCE:
;  LINE_GEN(m,b)
;
; DESCRIPTION:
;  LINE_GEN takes a user input of m and b and generates data for
;  a line with errors.  X values are randomly generated floats 
;  between 0 and 10.  Y values are scattered around m * X + b.
;  The scatter is selected from a normal distribution with a
;  standard deviation of 0.5 around the line.  Error in the Y
;  parameter is set at 0.5.  This function returns a structure. 
;
; INPUTS:
;   m - the desired line slope
;   b - the desired Y intercept 
;
; KEYWORD INPUTS:
;
; RETURNS:
;   linedata.X     - randomly distributed floating point numbers between 1 and 10 
;   linedata.Y     - floating point numbers with random offsets from a normal distribution of standard deviation 0.5 around Y = m * X + b
;   linedata.Y_err - an array of errors all equal to 0.5
;   linedata.Y_mod - an array of the unscattered Y points (i.e. the original model) 
;
; EXAMPLE:
;   
;   ;m and b values
;   m = 0.5
;   b = 2.0
;
;   ;generate line data
;   fit = LINE_GEN(m,b)
;
;   ;plot the results
;   plot,fit.X,fit.Y,psym=1
;
; REFERENCES:
;
; MODIFICATION HISTORY:
;   Written, Jan 2013
;   Documented, Jan 2013
;

function line_gen, m, b

	;generate random x values between 0 and 10
	X = (randomu(systime_seed, 10))*10.			;randomu generates random floats between 0 and 1, multplying by 10 extends the range

	;calculate y values
	Y_seed = m*X+b						;define the line from user defined parameters

	;scatter y values
	Y = (randomn(systime_seed, 1, 10)*0.5)+Y_seed		;generate random numbers and modify stddev to be 0.5 around defined line

	;set errors to 0.5
	Y_err = fltarr(10)+0.5					;y errors are a set value

	;compile the data in a structure
	linedata={X:X, $    
  	     Y:Y, $
  	     Y_err:Y_err, $
	     Y_mod:Y_seed}
	
	;return the structure
	return, linedata

end
