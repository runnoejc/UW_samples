;-------------------------------------------------------------
;+
; NAME:
;       FULLMONTE 
;
; PURPOSE:                                                 
;	Run a nested Monte Carlo simulation to determine the best-fitting sinusoid to a radial 
;	velocity curve.  This nested approach is appropriate for cases where the all radial 
;	velocity measurements in the curve were determined as shifts relative to the original 
;	velocity measurement.  The simulation therefore uses the first point in the radial 
;	velocity curve as an anchor.  One Monte Carlo simulation is used to perturb the anchor 
;	point velocity according to a Gaussian distribution with standard deviation equal to the 
;	anchor velocity uncertainty.  For each iteration of this simulation, the shifts in the 
;	remaining radial velocity points are resampled according to a second Monte Carlo 
;	simulation.  This simulation allows for asymmetric error bars on the shift measurements.  
;	For each realization of the full radial velocity curve, an OLS fit is performed to 
;	determine the best-fitting sinusoid and the parameters of this function are saved and 
;	returned at the end. 
;
; CALLING SEQUENCE:
;	fullmonte,t_anchor,v_anchor,v_anchor_err,dt,dv,dv_errp,dv_errm,niter1,niter2,fit_results 
;
; INPUTS:
;	t_anchor     - the obs time of the anchor point
;	v_anchor     - the velocity measurement of the anchor point
;	v_anchor_err - the uncertainty on the anchor velocity
;	dt           - the follow-up time intervals after the anchor point
;	dv           - the follow-up shifts from the anchor velocity
;	dv_errp      - the upper error bar on dv
;	dv_errm      - the lower error bar on dv
;	niter1       - the number of iterations for the anchor point MC 
;	niter2       - the number of iterations shift MC 
;
; KEYWORD PARAMETERS:
;	debug        - gives additional output while running for debugging purposes
;	hardcopy     - send debug plotting to a file called fullmonte_debug.eps
;
; OUTPUTS:
;	fit_results  - a structure containing the [v0,P,t0] tags for the [niter1,niter2] 
;		       realizations of the radial velocity curve as well as the [v0_obs,P_obs,
;	               t0_obs] tags which provide the best-fitting values to the observed radial 
;	   	       velocity curves with no errors
;
; NOTES:
;	This code uses the Coyote graphics routines.  They can be downloaded here:
;	http://www.idlcoyote.com/documents/programs.php
;
;	This code is under construction.  Improvements include handling of asymmetric error bars.
;
; EXAMPLE:
;
;	start = [2000.,100.,2030.]
;	pi    = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D], step:0.D, tied:''},3)
;	pi[0].limited  = [1,1]
;	pi[0].limits   = [-10000.,10000.]
;	pi[1].limited  = [1,1]
;	pi[1].limits   = [0.,10000.]
;	pi[2].limited  = [1,1]
;	pi[2].limited  = [0.,10000.]
;
;	v0 = 2000.
;	P  = 100.
;	t0 = 2030.
;	
;	t_anchor = 2006.						
;	dt       = 2.*dindgen(3)+2.					
;	v        = v0*sin(((2.*!pi)/P)*(t-t0)) 				
;	v_anchor = v[0]							
;	v_anchor_err = 0.1*v_anchor					
;	dv       = v[1:-1]-v_anchor					
;	for i=0,n_elements(dv)-1 do dv[i] = dv[i]+(RANDOMN(systime_seed)*0.2*dv[i])
;	dv_errp  = 0.8*dv						
;	dv_errm  = 0.5*dv						
;
;	fullmonte,t_anchor,v_anchor,v_anchor_err,dt,dv,dv_errp,dv_errm,50,50,start,pi,mc_results
;
;
; MODIFICATION HISTORY:
;        JCR, 18 December 2015: VERSION 1.00
;           -  Started writing the first version of the code for the SBHB project at Penn State.
;
;-
;-------------------------------------------------------------

function sine, t, P 
;-------------------------------------------------------------
;+
; PURPOSE:                                                 
;	Sine function with phase for a radial velocity curve.
;
;	v(t) = V0 * sin(((2.*!pi)/P)*(t-t_0))	
;
; MODIFICATION HISTORY:
;	 JCR, 18 December 2015: VERSION 1.00
;           -  Started writing the first version of the code.  Used voigtfun.pro from my Whitman
; 	       independent study as a template.
;
;-
;-------------------------------------------------------------
	; set the initial values
	A = P[0]
	B = P[1]
	C = P[2] 

	; calculate the exp function
	v = A * sin(((2.*!pi)/B)*(t-C)) 

 	return, v 
end

function robust_mpfit, x, y, y_err, start, pi, n
;-------------------------------------------------------------
;+
; PURPOSE:                                                 
;	Perform the fit to the sine curve N times with a starting
;	guess that is randomly selected from the parameter limits
;	for that property.  This is meant to determine how badly the
;	LMA gets stuck in local minima and asses the robustness of
;	the best-fit that MPFIT returns.
;
; NOTES:
;	This is currently under construction and not yet working.
;
; MODIFICATION HISTORY:
;	 JCR, 22 December 2015: VERSION 1.00
;           -  Started writing the first version of the code.  
;-
;-------------------------------------------------------------
	; initialize
	start_rmpf = fltarr(n,n_elements(start))
	results_rmpf = CREATE_STRUCT('start',fltarr(n,n_elements(start))-9999.,'result',fltarr(n,n_elements(start))-9999.,'chi',fltarr(n)-9999.)	

	; generate random starting guesses 
	; distributed evenly between the limits
	; on each property that is used in the fit
	start_rmpf[*,0] = randomu(systime_seed,n)*(pi[0].limits[1]-pi[0].limits[0])
	start_rmpf[*,1] = randomu(systime_seed,n)*(pi[1].limits[1]-pi[1].limits[0])
	start_rmpf[*,2] = randomu(systime_seed,n)*(start_rmpf[*,1]/2.-2000.)

	results_rmpf.start = start_rmpf

	; perform the fit n times with the random
	; starting guesses and save the results
	for i=0, n-1 do begin
	 	result  = mpfitfun('sine',x,y,y_err,start_rmpf[i,*],dof=dof,bestnorm=chi,perror=err,parinfo=pi) 
		results_rmpf.result[i,*] = result
		results_rmpf.chi[i] = chi
		oplot,dindgen(101)*.12+2001,sine(dindgen(101)*.12+2001,result),color=cgcolor('gray')
	endfor

	return,results_rmpf
end

pro fullmonte,t_anchor,v_anchor,v_anchor_err,dt,dv,dv_errp,dv_errm,niter1,niter2,start,pi,fit_results,$
              DEBUG=DEBUG,HARDCOPY=HARDCOPY

	; INITIALIZE VARIABLES 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	dv_sim       = fltarr(niter1,niter2,n_elements(dv))
	v_anchor_sim = fltarr(niter1)
	fill         = fltarr(niter1,niter2)-9999.
	fill2        = fltarr(n_elements(dv)+1.)-9999.
	fill3        = fltarr(niter1,niter2,n_elements(dv)+1.)-9999.
	fit_results  = CREATE_STRUCT('v0',fill,'P',fill,'t0',fill,'v0_obs',-9999.,'P_obs',-9999.,'t0_obs',-9999.,'t_sim',fill2,'v_sim',fill3)  
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 
	; PREPARE THE RADIAL VELOCITY DATA 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; make full t and v arrays
	t       = [t_anchor,replicate(t_anchor,n_elements(dt))+dt]
	v       = [v_anchor,replicate(v_anchor,n_elements(dv))+dv]
	v_errp  = [v_anchor_err,sqrt((replicate(v_anchor_err,n_elements(dt))^2.)+(dv_errp^2.))] 
	v_errm  = [v_anchor_err,sqrt((replicate(v_anchor_err,n_elements(dv))^2.)+(dv_errm^2.))] 
	
	; sort the RV curve
	srt     = sort(t)
	t       = t[srt]
	v       = v[srt]
	v_errp  = v_errp[srt]
	v_errm  = v_errm[srt]
	srt     = sort(dt)
	dt      = dt[srt]
	dv      = dv[srt]
	dv_errp = dv_errp[srt]
	dv_errm = dv_errm[srt]

	fit_results.t_sim = t

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; LAUNCH DIAGNOSTIC PLOTTING
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if keyword_set(debug) then begin
		xmin = min(t)-50.
		xmax = max(t)+50.
		if max(v) ge max(abs(v)) then begin
			ymax = 1.25*max(v+v_errp) 
			ymin = -ymax 
		endif else begin
			ymin = 1.25*min(v-v_errm) 
			ymax = -ymin
		endelse
		
		psize = 2
		if keyword_set(hardcopy) then begin
			cgps_open,'fullmonte_debug.eps',/encapsulated,xsize=7.5,ysize=6
			DEVICE, SET_FONT = 'Times-Roman'
			psize = 1
		endif

		plot,t,v,psym=sym(1),xra=[xmin,xmax],yra=[ymin,ymax],xstyle=1,ystyle=1,xtit='Year',ytit='Velocity [km s!u-1!n]',charsize=2,background=cgcolor('white'),color=cgcolor('black'),thick=2,charthick=2,xthick=2,ythick=2
	endif
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; FIT THE OBSERVED RV CURVE
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	result  = mpfitfun('sine',t,v,v/v,start,dof=dof,bestnorm=chi,perror=err,parinfo=pi,/quiet) 
	if keyword_set(debug) then fit_obs = sine(dindgen(1001)*(xmax-xmin)/1000.+xmin,result)
	fit_results.v0_obs = result[0]
	fit_results.P_obs  = result[1]
	fit_results.t0_obs = result[2]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; this is the block for the MC simulation on 
	; the anchor point for the radial velocity curve
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	print, 'Iterating the anchor point Monte Carlo simulation.'
	i = 0.
	while i lt niter1 do begin
		; run a counter on the simulation
		counter, i, niter1	

		; draw new anchor points from a Gaussian
		; centered on the measured value with a
		; stdev equal to the anchor uncertainty 
		v_anchor_sim[i] = v_anchor+(RANDOMN(systime_seed)*v_anchor_err)	

		; diangostic plotting
		if keyword_set(debug) then oplot,[t_anchor,t_anchor],[v_anchor_sim,v_anchor_sim],psym=sym(1),symsize=0.5,color=cgcolor('red')

		; this is the block for the MC simulation on 
		; the relative shifts in the radial velocity curve
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		j=0.
		while j lt niter2 do begin
			
			; draw a new set of velocity shifts from
			; Gaussian distributions centered on the 
			; measured values in the rest of the curve 
			; the Gaussians can have different widths
			; to accomodate asymmetric error bars
			for k=0,n_elements(dv)-1 do begin
				pdist = randomn(systime_seed)	
				dv_sim[i,j,k] = dv[k]+pdist*dv_errp[k]
			endfor

			v_sim = [v_anchor_sim[i],v_anchor_sim[i]+transpose(dv_sim[i,j,*])]
			
			; fill the array to save
			fit_results.v_sim[i,j,*] = v_sim

			; perform an OLS fit to the radial velocity
			; curve using MPFIT, which uses a LMA 
	 		result  = mpfitfun('sine',t,v_sim,v_sim/v_sim,start,dof=dof,bestnorm=chi,perror=err,parinfo=pi,/quiet) 
	 		if keyword_set(debug) then fit = sine(dindgen(1001)*(xmax-xmin)/1000.+xmin,result)
			fit_results.v0[i,j] = result[0]
			fit_results.P[i,j]  = result[1]
			fit_results.t0[i,j] = result[2]

			; diagnostic plotting
			if keyword_set(debug) then oplot,t,[v_anchor_sim[i],v_anchor_sim[i]+transpose(dv_sim[i,j,*])],psym=sym(1),symsize=0.5,color=cgcolor('red')
			if keyword_set(debug) then oplot,dindgen(1001)*(xmax-xmin)/1000.+xmin,fit,color=cgcolor('gray')
	
			j++
		endwhile
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
		i++
	endwhile
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; diangostic plotting
	if keyword_set(debug) then oplot,[xmin,xmax],[0,0],linestyle=2,color=cgcolor('black'),thick=2
	if keyword_set(debug) then oplot,dindgen(1001)*(xmax-xmin)/1000.+xmin,fit_obs,color=cgcolor('black'),thick=2
	if keyword_set(debug) then oploterror,t,v,v_errp,/hibar,psym=sym(1),symsize=psize,color=cgcolor('black')                      
	if keyword_set(debug) then oploterror,t,v,v_errm,/lobar,psym=3,color=cgcolor('black')   
	if keyword_set(debug) then plot,t,v,psym=sym(1),xra=[xmin,xmax],yra=[ymin,ymax],xstyle=1,ystyle=1,xtit='Year',ytit='Velocity [km s!u-1!n]',charsize=2,background=cgcolor('white'),color=cgcolor('black'),thick=2,charthick=2,xthick=2,ythick=2,/noerase
	if keyword_set(debug) then stop,'.cont to continue'
	if (keyword_set(hardcopy)) then begin
		cgps_close
		!p.font=-1	

	endif
end
