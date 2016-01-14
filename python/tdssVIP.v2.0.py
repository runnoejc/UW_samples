###########################################################
#  Visual inspection tool for TDSS data
#
#  Change History:
#  Written by: Jessie C. Runnoe, 26 Feb 2015
#	      (Modified from John Ruan's tdssVIP_SEQUELSplate_v0.5.py) 
#
#  Now writes results to a file everytime you save a comment so you
#  can't lose a whole plate's worth of work. Note that it saves up 
#  the current index so if you go back you lose any comments you made
#  for objects down the list. 07 Apr 2015. JCR.
#
#  Added ability to identify existing observations and plot the
#  existing spectra above the new TDSS spectrum. 29 Mar 2015. JCR.
#
#  Combined eBOSS and SEQUELS functionality. 1 Mar 2015. JCR.
#
#  Modified version of tdssVIP_SEQUELSplate_v0.5.py to display
#  only the spectra.  Added an axis scaling that ignores
#  noise on the red end of the spectrum.  Also added an 
#  "inspect" button that brings the spectrum up in IRAF
#  and afterwards returns the user to VIP. 26 Feb 2015. JCR.
#
#  Planned updates:
#  When there are multiple existing spectra, overplot them
#  all on the existing spectrum in the top panel so they are clear.
#
#  New modification where, if there are multiple spectra,
#  it outputs a temporary list and if you hit "inspect" it
#  loads all existing spectra into splot, not just the new one.
# 
#  Add a cycle_back button for left-arrow clicks.
###########################################################

# Initialize
##########################################################################
# Import packages
import Tkinter as tk
from pylab import *
import urllib
import pyfits
import numpy as np
from scipy.signal import boxcar
import sys
from pyraf import iraf 

# Define units 
DEG_PER_HR = 360. / 24.             # degrees per hour
DEG_PER_MIN = DEG_PER_HR / 60.      # degrees per min
DEG_PER_S = DEG_PER_MIN / 60.       # degrees per sec
DEG_PER_AMIN = 1./60.               # degrees per arcmin
DEG_PER_ASEC = DEG_PER_AMIN / 60.   # degrees per arcsec
RAD_PER_DEG = pi / 180.             # radians per degree

# Currently unused function to do simple coordinate matching
def ang_sep(ra1, dec1, ra2, dec2):
    ra1 = np.asarray(ra1);  ra2 = np.asarray(ra2)
    dec1 = np.asarray(dec1);  dec2 = np.asarray(dec2)

    ra1    = ra1 * RAD_PER_DEG      # convert to radians
    ra2    = ra2 * RAD_PER_DEG
    dec1   = dec1 * RAD_PER_DEG
    dec2   = dec2 * RAD_PER_DEG

    sra1   = sin(ra1);  sra2 = sin(ra2)
    cra1   = cos(ra1);  cra2 = cos(ra2)
    sdec1  = sin(dec1);  sdec2 = sin(dec2)
    cdec1  = cos(dec1);  cdec2 = cos(dec2)

    csep   = cdec1*cdec2*(cra1*cra2 + sra1*sra2) + sdec1*sdec2

    # An ugly work-around for floating point issues.
    csep   = np.where(csep > 1., 1., csep)

    degsep = arccos(csep) / RAD_PER_DEG
    # only works for separations > 0.1 of an arcsec or  >~2.7e-5 dec
    degsep = np.where(degsep < 1e-5, 0, degsep)
    return degsep

# Simple smooth function
def smooth(x):
    window_len=11
    s=r_[x[window_len-1:0:-1],x,x[-1:-window_len:-1]]
    w=boxcar(11)
    y=convolve(w/w.sum(),s,mode='valid')
    return y[5:-5]
##########################################################################

# Keyword handling
##########################################################################
def get_sequelstarget_class(target_bit):
    # Keywords to grab TDSS objects observed with SEQUELS 
    #####
    target_classes = []
    if (target_bit & 2**10) != 0: target_classes.append('QSO_EBOSS_CORE')
    if (target_bit & 2**11) != 0: target_classes.append('QSO_PTF')
    if (target_bit & 2**12) != 0: target_classes.append('QSO_REOBS')
    if (target_bit & 2**13) != 0: target_classes.append('QSO_EBOSS_KDE')
    if (target_bit & 2**14) != 0: target_classes.append('QSO_EBOSS_FIRST')
    if (target_bit & 2**15) != 0: target_classes.append('QSO_BAD_BOSS')
    if (target_bit & 2**16) != 0: target_classes.append('QSO_QSO_BOSS_TARGET')
    if (target_bit & 2**17) != 0: target_classes.append('QSO_SDSS_TARGET')
    if (target_bit & 2**18) != 0: target_classes.append('QSO_KNOWN')
    if (target_bit & 2**19) != 0: target_classes.append('DR9_CALIB_TARGET')
    if (target_bit & 2**20) != 0: target_classes.append('SPIDERS_RASS_AGN')
    if (target_bit & 2**21) != 0: target_classes.append('SPIDERS_RASS_CLUS')
    if (target_bit & 2**22) != 0: target_classes.append('SPIDERS_ERASS_AGN')
    if (target_bit & 2**23) != 0: target_classes.append('SPIDERS_ERASS_CLUS')
    if (target_bit & 2**30) != 0: target_classes.append('TDSS_A')
    if (target_bit & 2**31) != 0: target_classes.append('TDSS_FES_DE')
    if (target_bit & 2**32) != 0: target_classes.append('TDSS_FES_DWARFC')
    if (target_bit & 2**33) != 0: target_classes.append('TDSS_FES_NQHISN')
    if (target_bit & 2**34) != 0: target_classes.append('TDSS_FES_MGII')
    if (target_bit & 2**35) != 0: target_classes.append('TDSS_FES_VARBAL')
    if (target_bit & 2**40) != 0: target_classes.append('SEQUELS_PTF_VARIABLE ')

    return target_classes


def get_ebosstarget_class(target_bit0,target_bit1,target_bit2):
    # Keywords to grab TDSS objects observed with eBOSS
    #####
    target_classes = []
    if (target_bit0 & 2**10) != 0: target_classes.append('SEQUELS_QSO_EBOSS_CORE')
    if (target_bit0 & 2**11) != 0: target_classes.append('SEQUELS_QSO_PTF')
    if (target_bit0 & 2**12) != 0: target_classes.append('SEQUELS_QSO_REOBS')
    if (target_bit0 & 2**13) != 0: target_classes.append('SEQUELS_QSO_EBOSS_KDE')
    if (target_bit0 & 2**14) != 0: target_classes.append('SEQUELS_QSO_EBOSS_FIRST')
    if (target_bit0 & 2**15) != 0: target_classes.append('SEQUELS_QSO_BAD_BOSS')
    if (target_bit0 & 2**16) != 0: target_classes.append('SEQUELS_QSO_QSO_BOSS_TARGET')
    if (target_bit0 & 2**17) != 0: target_classes.append('SEQUELS_QSO_SDSS_TARGET')
    if (target_bit0 & 2**18) != 0: target_classes.append('SEQUELS_QSO_KNOWN')
    if (target_bit0 & 2**19) != 0: target_classes.append('SEQUELS_DR9_CALIB_TARGET')
    if (target_bit0 & 2**20) != 0: target_classes.append('SEQUELS_SPIDERS_RASS_AGN')
    if (target_bit0 & 2**21) != 0: target_classes.append('SEQUELS_SPIDERS_RASS_CLUS')
    if (target_bit0 & 2**22) != 0: target_classes.append('SEQUELS_SPIDERS_ERASS_AGN')
    if (target_bit0 & 2**23) != 0: target_classes.append('SEQUELS_SPIDERS_ERASS_CLUS')
    if (target_bit0 & 2**30) != 0: target_classes.append('SEQUELS_TDSS_A')
    if (target_bit0 & 2**31) != 0: target_classes.append('SEQUELS_TDSS_FES_DE')
    if (target_bit0 & 2**32) != 0: target_classes.append('SEQUELS_TDSS_FES_DWARFC')
    if (target_bit0 & 2**33) != 0: target_classes.append('SEQUELS_TDSS_FES_NQHISN')
    if (target_bit0 & 2**34) != 0: target_classes.append('SEQUELS_TDSS_FES_MGII')
    if (target_bit0 & 2**35) != 0: target_classes.append('SEQUELS_TDSS_FES_VARBAL')
    if (target_bit0 & 2**40) != 0: target_classes.append('SEQUELS_PTF_VARIABLE')

    if (target_bit1 & 2**9) != 0: target_classes.append('eBOSS_QSO1_VAR_S82')
    if (target_bit1 & 2**10) != 0: target_classes.append('eBOSS_QSO1_EBOSS_CORE')
    if (target_bit1 & 2**11) != 0: target_classes.append('eBOSS_QSO1_PTF')
    if (target_bit1 & 2**12) != 0: target_classes.append('eBOSS_QSO1_REOBS')
    if (target_bit1 & 2**13) != 0: target_classes.append('eBOSS_QSO1_EBOSS_KDE')
    if (target_bit1 & 2**14) != 0: target_classes.append('eBOSS_QSO1_EBOSS_FIRST')
    if (target_bit1 & 2**15) != 0: target_classes.append('eBOSS_QSO1_BAD_BOSS')
    if (target_bit1 & 2**16) != 0: target_classes.append('eBOSS_QSO_BOSS_TARGET')
    if (target_bit1 & 2**17) != 0: target_classes.append('eBOSS_QSO_SDSS_TARGET')
    if (target_bit1 & 2**18) != 0: target_classes.append('eBOSS_QSO_KNOWN')
    if (target_bit1 & 2**30) != 0: target_classes.append('TDSS_TARGET')
    if (target_bit1 & 2**31) != 0: target_classes.append('SPIDERS_TARGET')

    if (target_bit2 & 2**0) != 0: target_classes.append('SPIDERS_RASS_AGN')
    if (target_bit2 & 2**1) != 0: target_classes.append('SPIDERS_RASS_CLUS')
    if (target_bit2 & 2**2) != 0: target_classes.append('SPIDERS_ERASS_AGN')
    if (target_bit2 & 2**3) != 0: target_classes.append('SPIDERS_ERASS_CLUS')
    if (target_bit2 & 2**4) != 0: target_classes.append('SPIDERS_XMMSL_AGN')
    if (target_bit2 & 2**5) != 0: target_classes.append('SPIDERS_XCLASS_CLUS')
    if (target_bit2 & 2**5) != 0: target_classes.append('SPIDERS_XCLASS_CLUS')
    if (target_bit2 & 2**20) != 0: target_classes.append('TDSS_A')
    if (target_bit2 & 2**21) != 0: target_classes.append('TDSS_FES_DE')
    if (target_bit2 & 2**22) != 0: target_classes.append('TDSS_FES_DWARFC')
    if (target_bit2 & 2**23) != 0: target_classes.append('TDSS_FES_NQHISN')
    if (target_bit2 & 2**24) != 0: target_classes.append('TDSS_FES_MGII')
    if (target_bit2 & 2**25) != 0: target_classes.append('TDSS_FES_VARBAL')
    if (target_bit2 & 2**26) != 0: target_classes.append('TDSS_B')
    if (target_bit2 & 2**27) != 0: target_classes.append('TDSS_FES_HYPQSO')
    if (target_bit2 & 2**28) != 0: target_classes.append('TDSS_FES_HYPSTAR')
    if (target_bit2 & 2**29) != 0: target_classes.append('TDSS_FES_WDDM')
    if (target_bit2 & 2**30) != 0: target_classes.append('TDSS_FES_ACTSTAR')
    if (target_bit2 & 2**31) != 0: target_classes.append('TDSS_COREPTF')

    return target_classes
##########################################################################

# Handle manipulation of prior observations of TDSS targets
##########################################################################
class existing_SDSS_obs:
    # Load entire master list of TDSS and SDSS matches
    ####
    def __init__(self, maxra, minra, maxdec, mindec):
        self.fitsfile = ()
        self.fitsfile += ('fes_sdss_current.fits',)
	self.FES_program = []; self.FES_ra = []; self.FES_dec = []
	self.FES_mjd = []; self.FES_plate = []; self.FES_fiber = []
        self.SDSS_ra = []; self.SDSS_dec = []; self.SDSS_mjd = []
        self.SDSS_plate = []; self.SDSS_fiber = []; self.SDSS_z = []

        for filename in self.fitsfile:
            SDSSfile = pyfits.open(filename)
	    self.FES_program += list(SDSSfile[1].data['fes_program'])
	    self.FES_ra      += list(SDSSfile[1].data['fes_ra'])
	    self.FES_dec     += list(SDSSfile[1].data['fes_dec'])
	    self.FES_mjd     += list(SDSSfile[1].data['fes_mjd'])
	    self.FES_plate   += list(SDSSfile[1].data['fes_plate'])
	    self.FES_fiber   += list(SDSSfile[1].data['fes_fiber'])
            self.SDSS_ra     += list(SDSSfile[1].data['sdss_ra'])
            self.SDSS_dec    += list(SDSSfile[1].data['sdss_dec'])
            self.SDSS_z      += list(SDSSfile[1].data['sdss_z'])
	    self.SDSS_mjd    += list(SDSSfile[1].data['sdss_mjd'])
	    self.SDSS_plate  += list(SDSSfile[1].data['sdss_plate'])
	    self.SDSS_fiber  += list(SDSSfile[1].data['sdss_fiber'])

    def find_SDSS_counterpart(self, current_mjd, current_plate, current_fiber):
    # Generates indices for matches of 
    # each TDSS target
    #####
	matched_indices = ((asarray(self.FES_mjd) == current_mjd) & (asarray(self.FES_plate) == current_plate) & (asarray(self.FES_fiber) == current_fiber))
	#print 'here',current_mjd,current_plate,current_fiber
	#print asarray(self.FES_mjd)[matched_indices],asarray(self.FES_plate)[matched_indices],asarray(self.FES_fiber)[matched_indices]
	nmatches = len(asarray(self.FES_mjd)[matched_indices])
	return nmatches, matched_indices

    def get_SDSS_spec(self,current_mjd):
    # Generates filenames and titles
    # for existing obs of TDSS targets
    #####
        global nobs,SDSS_index
	SDSS_ra    = asarray(self.SDSS_ra)[SDSS_index]
	SDSS_dec   = asarray(self.SDSS_dec)[SDSS_index]
	SDSS_z     = asarray(self.SDSS_z)[SDSS_index]
	SDSS_mjd   = asarray(self.SDSS_mjd)[SDSS_index]
	SDSS_plate = asarray(self.SDSS_plate)[SDSS_index]
	SDSS_fiber = asarray(self.SDSS_fiber)[SDSS_index]
	dt         = (current_mjd-SDSS_mjd)/365.
	
	SDSS_spec = []; SDSS_title = []
	for i in range(0,len(SDSS_mjd)): 
		SDSS_spec.append('spec-'+'{0:04d}'.format(SDSS_plate[i])+'-'+str(SDSS_mjd[i])+'-'+'{0:04d}'.format(SDSS_fiber[i])+'.fits')
		SDSS_title.append('File = '+str(SDSS_spec[i])+', z = '+str(round(SDSS_z[i], 3))+', dt = '+str(round(dt[i], 1))+' yrs , Nobs = '+str(nobs))
        return dt,SDSS_z,SDSS_spec,SDSS_title 
##########################################################################

# Plotting routines
##########################################################################
def plotone(fiber_index,class0,subclass0,redshift,wavescale,wavelength,spectra,fluxerr,model):
    # Function to plot single TDSS observation
    #####
   	global ax1

    	ax1 = subplot2grid((1,1), (0,0))
    	ticklabels = ax1.get_xticklabels()
    	ticklabels.extend( ax1.get_yticklabels() )
    	for label in ticklabels:
    	    label.set_fontsize(12)
    	ax1.set_ylabel(r'F$_\lambda$ [10$^{-17}$ erg cm$^{-2}$ s$^{-1}$ $\AA^{-1}$]', size=12)
    	ax1.set_xlabel(r'wavelength [$\AA$]', size=12)
    	ax1.set_title('fiber = '+str(fiber_index+1)+', class = '+class0+', subclass = '+subclass0+', z = '+str(round(redshift, 3)), fontsize=14)
    	ystep   = 0.2*(max(smooth(spectra)[100:-100])-min(smooth(spectra)[100:-100]))
    	ymin    = min(smooth(spectra)[0:-100])-0.5*ystep
    	ymax    = max(smooth(spectra)[0:-100])+ystep
    	ax1.axis([(min(wavelength)-500)*wavescale,(max(wavelength)+500)*wavescale,ymin,ymax])
    	ax1.errorbar(wavelength*wavescale, smooth(spectra), yerr=smooth(fluxerr), ecolor='0.9', color='k', capsize=0.)
    	ax1.plot(wavelength*wavescale, model, 'r-')

def plottwo(fiber_index,class0,subclass0,redshift,wavescale,wavelength,spectra,fluxerr,model,SDSS_title,sdss_wavelength,sdss_spectra,sdss_fluxerr,sdss_model):
    # Function to plot existing observations
    # above single TDSS observation
    #####
   	global ax1, ax2
	global callback
	
    	ax1 = subplot2grid((2,1), (0,0))
    	ticklabels = ax1.get_xticklabels()
    	ticklabels.extend( ax1.get_yticklabels() )
    	for label in ticklabels:
    	    label.set_fontsize(12)
    	ax1.set_ylabel(r'F$_\lambda$ [10$^{-17}$ erg cm$^{-2}$ s$^{-1}$ $\AA^{-1}$]', size=12)
    	ax1.set_xlabel(r'wavelength [$\AA$]', size=12)
    	ax1.set_title(SDSS_title, fontsize=14)
    	ystep   = 0.2*(max(smooth(sdss_spectra)[100:-100])-min(smooth(sdss_spectra)[100:-100]))
    	ymin    = min(smooth(sdss_spectra)[0:-100])-0.5*ystep
    	ymax    = max(smooth(sdss_spectra)[0:-100])+ystep
    	ax1.axis([(min(wavelength)-500)*wavescale,(max(wavelength)+500)*wavescale,ymin,ymax])
    	ax1.errorbar(sdss_wavelength*wavescale, smooth(sdss_spectra), yerr=smooth(sdss_fluxerr), ecolor='0.9', color='k', capsize=0.)
    	ax1.plot(sdss_wavelength*wavescale, sdss_model, 'r-')
    	ax1.plot(wavelength*wavescale, smooth(spectra), 'b-')

    	ax2 = subplot2grid((2,1), (1,0))
    	ticklabels = ax2.get_xticklabels()
    	ticklabels.extend( ax2.get_yticklabels() )
    	for label in ticklabels:
    	    label.set_fontsize(12)
    	ax2.set_ylabel(r'F$_\lambda$ [10$^{-17}$ erg cm$^{-2}$ s$^{-1}$ $\AA^{-1}$]', size=12)
    	ax2.set_xlabel(r'wavelength [$\AA$]', size=12)
    	ax2.set_title('fiber = '+str(fiber_index+1)+', class = '+class0+', subclass = '+subclass0+', z = '+str(round(redshift, 3)), fontsize=14)
    	ystep   = 0.2*(max(smooth(spectra)[100:-100])-min(smooth(spectra)[100:-100]))
    	ymin    = min(smooth(spectra)[0:-100])-ystep
    	ymax    = max(smooth(spectra)[0:-100])+ystep
    	ax2.axis([(min(wavelength)-500)*wavescale,(max(wavelength)+500)*wavescale,ymin,ymax])
    	ax2.errorbar(wavelength*wavescale, smooth(spectra), yerr=smooth(fluxerr), ecolor='0.9', color='k', capsize=0.)
    	ax2.plot(wavelength*wavescale, model, 'r-')

##########################################################################

# Definition of spectral information for TDSS and existing observations 
##########################################################################
class platespectra:
    # Define TDSS spectral information for entire plate
    ####
    def __init__(self, current_platefile, current_spZbestfile):
        npix = len(current_platefile[0].data[0])
        coeff1 = current_platefile[0].header['COEFF1']
        coeff0 = current_platefile[0].header['COEFF0']
        self.plate = current_platefile[0].header['PLATEID']
        self.mjd = current_platefile[0].header['MJD']
        self.wavelength = 10.**(coeff0+coeff1*arange(npix))
        self.spectra = current_platefile[0].data
        self.ivar = current_platefile[1].data
	self.fluxerr = 0.*self.ivar													# handle cases where ivar = 0.
	self.fluxerr[self.ivar != 0.] = 1./sqrt(self.ivar[self.ivar != 0.])
	self.fluxerr[self.ivar == 0.] = 0.*self.ivar[self.ivar == 0.]
        self.redshift = current_spZbestfile[1].data['Z']
        self.plug_ra = current_spZbestfile[1].data['PLUG_RA']
        self.plug_dec = current_spZbestfile[1].data['PLUG_DEC']
        self.class0 = current_spZbestfile[1].data['CLASS']
        self.subclass0 = current_spZbestfile[1].data['SUBCLASS']
        self.fiberid = current_spZbestfile[1].data['FIBERID']
        self.source_type = current_platefile[5].data['SOURCETYPE']
        self.obj_type = current_platefile[5].data['OBJTYPE']
        self.boss_target2 = current_platefile[5].data['BOSS_TARGET2']
        self.boss_target1 = current_platefile[5].data['BOSS_TARGET1']
        self.ancillary_target2 = current_platefile[5].data['ANCILLARY_TARGET2']
        self.ancillary_target1 = current_platefile[5].data['ANCILLARY_TARGET1']
        self.eboss_target0 = current_platefile[5].data['EBOSS_TARGET0']
        if 'EBOSS_TARGET1' in current_platefile[5].columns.names: self.eboss_target1 = current_platefile[5].data['EBOSS_TARGET1']	# these exist for eBOSS, not SEQUELS 
        if 'EBOSS_TARGET2' in current_platefile[5].columns.names: self.eboss_target2 = current_platefile[5].data['EBOSS_TARGET2']
	self.prog = 0 if 'EBOSS_TARGET1' in current_platefile[5].columns.names else 1 							# EBOSS = 0, SEQUELS = 1 
        self.sourcetype = current_platefile[5].data['SOURCETYPE']
        self.model = current_spZbestfile[2].data

class sdssspectra:
    # Define spectral information for one
    # SDSS spectrum (spec-* file)
    def __init__(self, current_sdssfile):
        self.wavelength = 10.**(current_sdssfile[1].data['LOGLAM'])
        self.spectra = current_sdssfile[1].data['FLUX']
        self.ivar = current_sdssfile[1].data['IVAR']
	self.fluxerr = 0.*self.ivar													# handle cases where ivar = 0.
	self.fluxerr[self.ivar != 0.] = 1./sqrt(self.ivar[self.ivar != 0.])
	self.fluxerr[self.ivar == 0.] = 0.*self.ivar[self.ivar == 0.]
        self.model = current_sdssfile[1].data['MODEL']
##########################################################################

# Callback handling of buttons
##########################################################################
class callback_handler:
    def __init__(self):
        self.specframe = 0 # 0 = obsframe, 1 = restframe

    def next(self):
    # Plot next object
    ####
	global nobs
        global TDSS_fiber_index
	global SDSS_index
	global currentsdss
	global SDSS_spec_index, SDSS_spec_indices, SDSS_title		# needed if this is first time these are defined

        self.specframe = 0

        build_title = 'plate = '+str(currentplate.plate)+', mjd = '+str(currentplate.mjd)+', sourcetype = '+currentplate.source_type[TDSS_fiber_index]+', objtype = '+currentplate.obj_type[TDSS_fiber_index]+'\n Targeted by: '
	if currentplate.prog:
        	for target_class in get_sequelstarget_class(currentplate.eboss_target0[TDSS_fiber_index]):
            		build_title += target_class+', '
	else:
	        for target_class in get_ebosstarget_class(currentplate.eboss_target0[TDSS_fiber_index], currentplate.eboss_target1[TDSS_fiber_index], currentplate.eboss_target2[TDSS_fiber_index]):
            		build_title += target_class+', '
        title.set_text(build_title)

	if nobs > 0:
		# go get the existing spectra
		dt,SDSS_z,SDSS_spec,SDSS_title = SDSS.get_SDSS_spec(currentplate.mjd)
		SDSS_spec_indices = arange(0,nobs,1)			# index for number of existing spectra
		SDSS_spec_index = SDSS_spec_indices[dt == max(dt)]
		SDSS_spec_index = SDSS_spec_indices[0]
		currentsdss = []
    		for i in range(len(SDSS_spec_indices)): currentsdss.append(sdssspectra(pyfits.open('./data.existing_obs/'+SDSS_spec[i])))

		plottwo(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],1.,currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index],SDSS_title[SDSS_spec_index],currentsdss[SDSS_spec_index].wavelength,currentsdss[SDSS_spec_index].spectra,currentsdss[SDSS_spec_index].fluxerr,currentsdss[SDSS_spec_index].model)
	else:
		
		plotone(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],1.,currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index])	
        draw()
	
    def accept(self, event):
    # Iterate indices for next object
    # and call next()
    ####
        global inspection_flags
        global TDSS_fiber_indices, TDSS_fiber_index
	global SDSS_index, SDSS_indices
        global nobs, nobs_all

        current_index = where(TDSS_fiber_indices==TDSS_fiber_index)[0][0]
        inspection_flags[current_index] = 1
       
        next_index = current_index+1
        if next_index == len(TDSS_fiber_indices):
            self.write2file()
	    close()
        else:
            TDSS_fiber_index = TDSS_fiber_indices[next_index]
	    nobs = nobs_all[next_index]
	    SDSS_index = SDSS_indices[next_index]

            next(self)

    def flag(self, event):
    # Currently unused, overwrites
    # class in terms of bad classification
    ####
        global inspection_flags
        global TDSS_fiber_indices, TDSS_fiber_index
	global SDSS_index, SDSS_indices
	global nobs, nobs_all

        current_index = where(TDSS_fiber_indices==TDSS_fiber_index)[0][0]
        inspection_flags[current_index] = 2
        
        next_index = current_index+1
        if next_index == len(TDSS_fiber_indices):
            self.write2file()
        else:
            TDSS_fiber_index = TDSS_fiber_indices[next_index]
	    nobs = nobs_all[next_index]
	    SDSS_index = SDSS_indices[next_index]

            next(self)

    def back(self, event):
    # Subtracts from current indices
    # and calls next()
    ####
        global inspection_flags
        global TDSS_fiber_indices, TDSS_fiber_index
	global SDSS_index, SDSS_indices
	global nobs, nobs_all
		
        current_index = where(TDSS_fiber_indices==TDSS_fiber_index)[0][0]
        next_index = current_index+-1
        TDSS_fiber_index = TDSS_fiber_indices[next_index]
	nobs = nobs_all[next_index]
	SDSS_index = SDSS_indices[next_index]

        next(self)

    def goforward(self, event):
    # Probably reduandt with accept()
    ####
        global TDSS_fiber_indices, TDSS_fiber_index
	global SDSS_index, SDSS_indices
	global nobs, nobs_all

        current_index = where(TDSS_fiber_indices==TDSS_fiber_index)[0][0]
        
        next_index = current_index+1
        if next_index == len(TDSS_fiber_indices):
            close()
        else:
            TDSS_fiber_index = TDSS_fiber_indices[next_index]
	    nobs = nobs_all[next_index]
	    SDSS_index = SDSS_indices[next_index]

            next(self)

    def goback(self, event):
    # Iterates indices to go back one
    # and calls next()
    ####
        global TDSS_fiber_indices, TDSS_fiber_index
	global SDSS_index, SDSS_indices
	global nobs, nobs_all

        current_index = where(TDSS_fiber_indices==TDSS_fiber_index)[0][0]
        
        next_index = current_index-1
        TDSS_fiber_index = TDSS_fiber_indices[next_index]
	nobs = nobs_all[next_index]
	SDSS_index = SDSS_indices[next_index]

        next(self)

    def restframe(self, event):
    # Switches current plot to the rest frame
    # applies TDSS redshift to any existing obs
    ####
        global TDSS_fiber_index, nobs
        if (self.specframe == 0):
		if nobs > 0:
			plottwo(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],1./(1.+currentplate.redshift[TDSS_fiber_index]),currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index],SDSS_title[SDSS_spec_index],currentsdss[SDSS_spec_index].wavelength,currentsdss[SDSS_spec_index].spectra,currentsdss[SDSS_spec_index].fluxerr,currentsdss[SDSS_spec_index].model)


		else:
			plotone(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],1./(1.+currentplate.redshift[TDSS_fiber_index]),currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index])
        self.specframe = 1

    def obsframe(self, event):
    # Switches current plot to obs frame
    ####
        global TDSS_fiber_index, nobs
        if (self.specframe == 1):
		if nobs > 0:
			plottwo(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],1.,currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index],SDSS_title[SDSS_spec_index],currentsdss[SDSS_spec_index].wavelength,currentsdss[SDSS_spec_index].spectra,currentsdss[SDSS_spec_index].fluxerr,currentsdss[SDSS_spec_index].model)
		else:
			plotone(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],1.,currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index])
        self.specframe = 0

    def cycle(self,event):
    # On right-arrow key press, cycle
    # through existing obs of current obj
    ####
        global TDSS_fiber_index, SDSS_spec_indices, SDSS_spec_index
	global nobs, currentsdss

	# only continue for right arrow
	# or nobs >= 1
    	if event.key != 'right': return
	if nobs == 0: return

        current_index = where(SDSS_spec_indices==SDSS_spec_index)[0][0]
        
        next_index = current_index+1
        if next_index == len(SDSS_spec_indices): next_index = 0
        SDSS_spec_index = SDSS_spec_indices[next_index]

	plottwo(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],1.,currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index],SDSS_title[SDSS_spec_index],currentsdss[SDSS_spec_index].wavelength,currentsdss[SDSS_spec_index].spectra,currentsdss[SDSS_spec_index].fluxerr,currentsdss[SDSS_spec_index].model)
        draw()

    def write2file(self):
    # At the end plate, write out comments
    ####
        global inspection_flags, TDSS_fiber_indices
        outputfile = open('./plate_results/tdssVIP_plateresults-'+str(currentplate.plate)+'-'+str(currentplate.mjd)+'.txt', 'w')
        print 'Inspection results saved to file '+'tdssVIP_plateresults-'+str(currentplate.plate)+'-'+str(currentplate.mjd)+'.txt'+'.'
        outputfile.write('------------------------------ \n')
        outputfile.write('# Fiber \n# RA [deg] \n# Dec [deg] \n# z \n# eboss_target0_bit \n# class_pipeline \n# class_VI \n# subclass_pipeline \n# comment [nc = no comment] \n')
        outputfile.write('------------------------------ \n')
        for i in range(0, len(TDSS_fiber_indices[TDSS_fiber_indices <= TDSS_fiber_index])):
            outputfile.write(("%03d \t %8.5F \t %8.6F \t %F \t %s \t" % (TDSS_fiber_indices[i]+1,currentplate.plug_ra[TDSS_fiber_indices[i]],currentplate.plug_dec[TDSS_fiber_indices[i]],currentplate.redshift[TDSS_fiber_indices[i]],currentplate.eboss_target0[TDSS_fiber_indices[i]])))
            if inspection_flags[i] == 2:
                outputfile.write("%20s \t" % ('FLAGGED'))
	    else:
                outputfile.write("%20s \t" % (currentplate.class0[TDSS_fiber_indices[i]]))

            if len(str(currentplate.subclass0[TDSS_fiber_indices[i]])) > 0:
                outputfile.write("%20s \t" % (currentplate.subclass0[TDSS_fiber_indices[i]].replace(' ','')))
            else:
                outputfile.write('None\t')
            outputfile.write(comments[i]+'\n')
        outputfile.close()

    def inspect(self, event):
    # Pull up the current TDSS spectrum in IRAF SPLOT
    ####
        global TDSS_fiber_indices, TDSS_fiber_index
        global plate, mjd 

	# load packages; splot is in the onedspec package, which is in noao.
    	# the special keyword _doprint=0 turns off displaying the tasks
    	# when loading a package.
    	iraf.noao(_doprint=0)
    	iraf.onedspec(_doprint=0) 

    	# set/view IRAF task parameter.
    	#iraf.onedspec.splot.save_file = "splot_%s.log" % (root,)

    	# call IRAF task, and specify some parameters.
	iraf.onedspec.splot('spPlate-'+str(plate)+'-'+str(mjd)+'.fits[0][*,'+str(TDSS_fiber_index+1)+']')
        #iraf.onedspec.splot('./data.sdss.org/sas/ebosswork/eboss/spectro/redux/v5_7_9/'+str(plate)+'/spPlate-'+str(plate)+'-'+str(mjd)+'.fits[0][*,'+str(TDSS_fiber_index+1)+']')

    def comment(self,event):
    # Pull up a window to enter a comment on this object
    ####
		def savequit():
        		global TDSS_fiber_index, comments
        		current_index = where(TDSS_fiber_indices==TDSS_fiber_index)[0][0]

        		comments[current_index] = text_box.get("1.0", "end-1c")			# the arguments for get() grab from first to last characters 
        		if len(comments[current_index]) == 0:
            			comments[current_index] = 'nc'
			
			self.write2file()
    			root.destroy()      							# close the tk window 	

		tktitle = 'Comments for fiber '+str(TDSS_fiber_index+1)				# sets the window title	
		root = tk.Tk()									# makes a window
		root.geometry("500x400")
		root.title(tktitle)
		sbar = tk.Scrollbar(root)
		text_box = tk.Text(root)							# makes an entry box
		sbar.pack(side=tk.RIGHT, fill=tk.Y)
		text_box.pack()									# opens them together
		sbar.config(command=text_box.yview)

		text_box.focus_set()
	
		bsave = tk.Button(root, text = "Save and close", command = savequit)
		bsave.pack(side=tk.BOTTOM,padx=5,pady=5)
###############################################################



###############################################################
# Main Program
###############################################################
if len(sys.argv) == 3: # run the whole plate
    # read in the TDSS plate
    sdss = pyfits.open('fes_sdss_matched.fits')
    plate = str(sys.argv[1]); mjd = str(sys.argv[2])
    platefile = urllib.urlretrieve('http://data.sdss.org/sas/ebosswork/eboss/spectro/redux/v5_7_9/'+plate+'/spPlate-'+plate+'-'+mjd+'.fits')
    #platefile = './data.sdss.org/sas/ebosswork/eboss/spectro/redux/v5_7_9/'+plate+'/spPlate-'+plate+'-'+mjd+'.fits'
    #platefile = urllib.urlretrieve('spPlate-'+plate+'-'+mjd+'.fits')
    #platefile = 'spPlate-'+plate+'-'+mjd+'.fits'
    platefile = pyfits.open(platefile)
    #spZbestfile = urllib.urlretrieve('http://data.sdss.org/sas/ebosswork/eboss/spectro/redux/v5_7_9/'+plate+'/v5_7_6/spZbest-'+plate+'-'+mjd+'.fits')
    #spZbestfile = './data.sdss.org/sas/ebosswork/eboss/spectro/redux/v5_7_9/'+plate+'/v5_7_9/'+'spZbest-'+plate+'-'+mjd+'.fits'
    #spZbestfile = urllib.urlretrieve('spZbest-'+plate+'-'+mjd+'.fits')
    spZbestfile = 'spZbest-'+plate+'-'+mjd+'.fits'
    spZbestfile = pyfits.open(spZbestfile)
    currentplate = platespectra(platefile, spZbestfile)

    # initialize the SDSS master list
    SDSS = existing_SDSS_obs(max(currentplate.plug_ra), min(currentplate.plug_ra), max(currentplate.plug_dec), min(currentplate.plug_dec))

    # find plate indices (0-999) of the TDSS targets by matching to PS1 targets file
    TDSS_fiber_indices = []
    nobs_all = []; SDSS_indices = []
    for current_fiber in range(0, 1000):
	if currentplate.prog:
        	if ((currentplate.eboss_target0[current_fiber] & 2**30) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**31) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**32) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**33) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**34) != 0)  or ((currentplate.eboss_target0[current_fiber] & 2**35) != 0): # if TDSS target
            		TDSS_fiber_indices.append(current_fiber)
		        current_nobs,current_SDSS_indices = SDSS.find_SDSS_counterpart(currentplate.mjd, currentplate.plate, currentplate.fiberid[current_fiber])
			nobs_all.append(current_nobs)
           		SDSS_indices.append(current_SDSS_indices)
	else:
		if ((currentplate.eboss_target1[current_fiber] & 2**30) != 0): # if TDSS target
            		TDSS_fiber_indices.append(current_fiber)
		        current_nobs,current_SDSS_indices = SDSS.find_SDSS_counterpart(currentplate.mjd, currentplate.plate, currentplate.fiberid[current_fiber])
			nobs_all.append(current_nobs)
           		SDSS_indices.append(current_SDSS_indices)
    TDSS_fiber_indices = asarray(TDSS_fiber_indices); nobs_all = asarray(nobs_all); SDSS_indices = asarray(SDSS_indices)

    # initialize inspection flags
    # and also comments array
    inspection_flags = [0]*len(TDSS_fiber_indices)
    comments = ['nc']*len(TDSS_fiber_indices)

    # set plotting canvas
    figure(figsize=(13, 9), dpi=80)
    subplots_adjust(bottom=.13, wspace = .4, hspace=.25, left=.07, right=.95, top=.88)
    TDSS_fiber_index = TDSS_fiber_indices[0] # index of current TDSS fiber on plate (0 - 999)
    SDSS_index = SDSS_indices[0]	     # index of SDSS matches (T/F, same dimesion as FES_SDSS_current.fits arrays)
    nobs = nobs_all[0]

    build_title = 'plate = '+str(currentplate.plate)+', mjd = '+str(currentplate.mjd)+', sourcetype = '+currentplate.source_type[TDSS_fiber_index]+', objtype = '+currentplate.obj_type[TDSS_fiber_index]+' \n Targeted by: '
    if currentplate.prog:
    	for target_class in get_sequelstarget_class(currentplate.eboss_target0[TDSS_fiber_index]):
        	build_title += target_class+', '
    else:
	for target_class in get_ebosstarget_class(currentplate.eboss_target0[TDSS_fiber_index], currentplate.eboss_target1[TDSS_fiber_index], currentplate.eboss_target2[TDSS_fiber_index]):
        	build_title += target_class+', '
    title = suptitle(build_title, fontsize=14)

    # make plots
    if nobs > 0:
	# go get the existing spectra
	dt,SDSS_z,SDSS_spec,SDSS_title = SDSS.get_SDSS_spec(currentplate.mjd)
	SDSS_spec_indices = arange(0,nobs,1)			# index for number of existing spectra
	SDSS_spec_index = SDSS_spec_indices[dt == max(dt)]
	SDSS_spec_index = SDSS_spec_indices[0]
	currentsdss = []
    	for i in range(len(SDSS_spec_indices)): currentsdss.append(sdssspectra(pyfits.open('./data.existing_obs/'+SDSS_spec[i])))

	plottwo(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],1.,currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index],SDSS_title[SDSS_spec_index],currentsdss[SDSS_spec_index].wavelength,currentsdss[SDSS_spec_index].spectra,currentsdss[SDSS_spec_index].fluxerr,currentsdss[SDSS_spec_index].model)
    else:
	plotone(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],1.,currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index])

    # set buttons
    callback = callback_handler()
    axaccept = axes([0.7, 0.02, 0.1, 0.055])
    axback = axes([0.1, 0.02, 0.1, 0.055])
    axinspect = axes([0.21,0.02,0.1,0.055])
    axrestframe = axes([0.51, 0.02, 0.1, 0.055])
    axobsframe = axes([0.40, 0.02, 0.1, 0.055])
    axcomment = axes([0.81, 0.02, 0.1, 0.055])

    baccept = Button(axaccept, 'Accept')
    bback = Button(axback, 'Back')
    binspect = Button(axinspect,'Inspect')
    brestframe = Button(axrestframe, 'Rest Frame')
    bobsframe = Button(axobsframe, 'Obs Frame')
    bcomment = Button(axcomment, 'Comment')

    baccept.on_clicked(callback.accept)
    bback.on_clicked(callback.back)
    binspect.on_clicked(callback.inspect)
    brestframe.on_clicked(callback.restframe)
    bobsframe.on_clicked(callback.obsframe)
    bcomment.on_clicked(callback.comment)

    # set keystroke for cycling plottwo
    kcycle = connect('key_press_event', callback.cycle)
 
    show()

# NOT UPDATED TO HANDLE EXISTING OBS
elif len(sys.argv) > 3:
    sdss = pyfits.open('fes_sdss_current.fits')
    plate = str(sys.argv[1]); mjd = str(sys.argv[2]); TDSS_fiber_indices = asarray([int(x)-1 for x in sys.argv[3:]]); TDSS_fiber_index =  TDSS_fiber_indices[0]
    #platefile = urllib.urlretrieve('http://data.sdss.org/sas/ebosswork/eboss/spectro/redux/v5_7_6/'+plate+'/spPlate-'+plate+'-'+mjd+'.fits')
    #platefile = urllib.urlretrieve('./data.sdss.org/sas/ebosswork/eboss/spectro/redux/v5_7_9/'+plate+'/spPlate-'+plate+'-'+mjd+'.fits')
    platefile = urllib.urlretrieve('spPlate-'+plate+'-'+mjd+'.fits')
    platefile = pyfits.open(platefile[0])
    #spZbestfile = urllib.urlretrieve('http://data.sdss.org/sas/ebosswork/eboss/spectro/redux/v5_7_6/'+plate+'/v5_7_6/spZbest-'+plate+'-'+mjd+'.fits')
    #spZbestfile = urllib.urlretrieve('./data.sdss.org/sas/ebosswork/eboss/spectro/redux/v5_7_9/'+plate+'/v5_7_9/'+'spZbest-'+plate+'-'+mjd+'.fits')
    spZbestfile = urllib.urlretrieve('spZbest-'+plate+'-'+mjd+'.fits')
    spZbestfile = pyfits.open(spZbestfile[0])
    currentplate = platespectra(platefile, spZbestfile)

    for current_fiber in TDSS_fiber_indices:
	if currentplate.prog:
        	if ((currentplate.eboss_target0[current_fiber] & 2**30) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**31) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**32) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**33) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**34) != 0)  or ((currentplate.eboss_target0[current_fiber] & 2**35) != 0): #if TDSS target
            		TDSS_fiber_indices.append(current_fiber)
	else:
		if ((currentplate.eboss_target1[current_fiber] & 2**30) != 0): #if TDSS target
            		TDSS_fiber_indices.append(current_fiber)

    # check for multiple obs
    nobs                 = []	# number of existing spectra
    for current_fiber in TDSS_fiber_indices:
	if currentplate.prog:
    		if ((currentplate.eboss_target0[current_fiber] & 2**31) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**32) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**33) != 0) or ((currentplate.eboss_target0[current_fiber] & 2**34) != 0)  or ((currentplate.eboss_target0[current_fiber] & 2**35) != 0): #if FES target 
			nobs.append(1)
		else: 
			nobs.append(0)
	else:
		if ((currentplate.eboss_target1[current_fiber] & 2**30) != 0): #if TDSS target
            		TDSS_fiber_indices.append(current_fiber)
	    	if ((currentplate.eboss_target2[current_fiber] & 2**21) != 0) or ((currentplate.eboss_target2[current_fiber] & 2**22) != 0) or ((currentplate.eboss_target2[current_fiber] & 2**23) != 0) or ((currentplate.eboss_target2[current_fiber] & 2**24) != 0)  or ((currentplate.eboss_target2[current_fiber] & 2**25) != 0) or ((currentplate.eboss_target2[current_fiber] & 2**27) != 0) or ((currentplate.eboss_target2[current_fiber] & 2**28) != 0) or ((currentplate.eboss_target2[current_fiber] & 2**28) != 0) or ((currentplate.eboss_target2[current_fiber] & 2**30) != 0): # if FES target 
			nobs.append(1)
		else: nobs.append(0)


    # set plotting canvas
    figure(figsize=(13, 9), dpi=80)
    subplots_adjust(bottom=.13, wspace = .4, hspace=.25, left=.07, right=.95, top=.88)

    build_title = 'plate = '+str(currentplate.plate)+', mjd = '+str(currentplate.mjd)+', sourcetype = '+currentplate.source_type[TDSS_fiber_index]+', objtype = '+currentplate.obj_type[TDSS_fiber_index]+' \n Targeted by: '
    if currentplate.prog:
    	for target_class in get_sequelstarget_class(currentplate.eboss_target0[TDSS_fiber_index]):
        	build_title += target_class+', '
    else:
        for target_class in get_ebosstarget_class(currentplate.eboss_target0[TDSS_fiber_index], currentplate.eboss_target1[TDSS_fiber_index], currentplate.eboss_target2[TDSS_fiber_index]):
            	build_title += target_class+', '
    title = suptitle(build_title, fontsize=14)
    inspection_flags = [0]*len(TDSS_fiber_indices)

    #make plots
    if nobs[current_fiber]:
	plottwo(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index])
    else:
	plotone(TDSS_fiber_index,currentplate.class0[TDSS_fiber_index],currentplate.subclass0[TDSS_fiber_index],currentplate.redshift[TDSS_fiber_index],currentplate.wavelength,currentplate.spectra[TDSS_fiber_index],currentplate.fluxerr[TDSS_fiber_index],currentplate.model[TDSS_fiber_index])

    callback = callback_handler()
    axgoforward = axes([0.81, 0.02, 0.1, 0.055])
    axgoback = axes([0.7, 0.02, 0.1, 0.055])
    axinspect = axes([0.21,0.02,0.1,0.055])
    axrestframe = axes([0.51, 0.02, 0.1, 0.055])
    axobsframe = axes([0.40, 0.02, 0.1, 0.055])
    bgoforward = Button(axgoforward, 'Next')
    bgoback = Button(axgoback, 'Back')
    binspect = Button(axinspect,'Inspect')
    brestframe = Button(axrestframe, 'Rest Frame')
    bobsframe = Button(axobsframe, 'Obs Frame')
    bgoforward.on_clicked(callback.goforward)
    bgoback.on_clicked(callback.goback)
    binspect.on_clicked(callback.inspect)
    brestframe.on_clicked(callback.restframe)
    bobsframe.on_clicked(callback.obsframe)
    show()
###############################################################
