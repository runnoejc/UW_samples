;-------------------------------------------------------------
;+
; NAME:
;       CALL_MC 
;
; PURPOSE:                                                 
;	A wrapper to demonstrate the MC simulation fullmonte.pro. 
;
; CALLING SEQUENCE:
;	call_mc 
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;	debug        - gives additional output while running for debugging purposes
;	hardcopy     - send debug plotting to a file called fullmonte_debug.eps
;
; OUTPUTS:
;
; NOTES:
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;        JCR, 12 January 2016: VERSION 1.00
;           -  Wrote first version of the code.
;
;-
;-------------------------------------------------------------


pro call_mc
	
	; constrain the sine fit 
	;;;;;;;;;;;;;;;;;;;;;;;;;
	start = [2000.,100.,2030.]									; starting guess for the sinusoid
	pi    = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D], step:0.D, tied:''},3)		; parameter inputs for the fit 
	pi[0].limited  = [1,1]										; limit vel normalization 
	pi[0].limits   = [-10000.,10000.]								
	pi[1].limited  = [1,1]										; limit phase
	pi[1].limits   = [0.,10000.]									
	pi[2].limited  = [1,1]										; limit period
	pi[2].limited  = [0.,1000.]
	;;;;;;;;;;;;;;;;;;;;;;;;;

	; generate fake rv data
	;;;;;;;;;;;;;;;;;;;;;;;;;
	v0 = 2000.
	P  = 100.
	t0 = 2030.
	t  = 2.*dindgen(5.)+2006. 
	
	t_anchor     = t[0]						
	dt           = t[1:n_elements(t)-1]-t_anchor					
	v            = v0*sin(((2.*!pi)/P)*(t-t0)) 				
	v_anchor     = v[0]							
	v_anchor_err = 0.1*v_anchor					
	dv           = v[1:n_elements(v)-1]-v_anchor					
	for i = 0,n_elements(dv)-1 do dv[i] = dv[i]+(RANDOMN(systime_seed)*100.)
	dv_errp      = 0.2*dv						
	dv_errm      = 0.1*dv						
	;;;;;;;;;;;;;;;;;;;;;;;;;

	; call the sinusoid mc code
	; with debug and hardcopy mode
	;;;;;;;;;;;;;;;;;;;;;;;;;
	; set the properties of the mc
	iter1 = 50.
	iter2 = 50.	
	fullmonte,t_anchor,v_anchor,v_anchor_err,dt,dv,dv_errp,dv_errm,iter1,iter2,start,pi,mc_results,/debug;,/hardcopy
	;;;;;;;;;;;;;;;;;;;;;;;;;

	; look at the results 
	;;;;;;;;;;;;;;;;;;;;;;;;;
	plot,mc_results.t0,mc_results.P,psym=3,xra=[2000,2050],yra=[0,200],xtitle='t!d0!n [years]',ytitle='P [years]',charsize=2
	;;;;;;;;;;;;;;;;;;;;;;;;;
	


stop,'.cont to continue'
end
