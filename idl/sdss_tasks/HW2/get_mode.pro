;   Jessie Runnoe
;   jrunnoe@uwyo.edu
;
; PURPOSE:
;   GET_MODE returns the mode of the data. 
;
; CALLING SEQUENCE:
;   mode = get_mode(data)
;
; DESCRIPTION:
;   GET_MODE returns the mode of the data 
;   assuming a bin size of 1.  If multiple
;   values have the same frequency, they are 
;   all returned.
;
; INPUTS:
;   data - an array of the data 
;
; KEYWORD INPUTS:
;
; RETURNS:
;   mode - a value or array with the mode
;
; EXAMPLE:
;   data = [0,1,2,3,4,4,5]
;   mode = get_mode(data)
;   print, mode
;      4
;
; BUGS:
;
; REFERENCES:
;  Based on http://www.astro.washington.edu/docs/idl/cgi-bin/getpro/library28.html?MODE.
; 
; MODIFICATION HISTORY:
;   Written, Feb 2013
;   Documented, Feb 2013
;

function get_mode,data

	hist = histogram(data,binsize=1,locations=histx)
 	return, histx(where(hist eq max(hist)))

end
