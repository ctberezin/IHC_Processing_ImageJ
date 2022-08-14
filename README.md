# IHC_Processing_ImageJ

This is a set of 3 macros written to process immunohistochemistal (IHC) data from multiplex fluorescent z-stack confocal images obtained on a Zeiss microscope (czi files) for colocalization analysis (Costes' methods).  

Macro 1: Denoising. Reads in czi files, does some pre-processing and saves as tif files.  
Macro 2: Composite & MAX projection. Makes a color-blind friendly composite image & a maximum intensity z-projection. Also produces versions without DAPI.  
Macro 3: ROI processing. Allows the user to draw regions of interest (ROIs) around areas for colocalization analysis. Saves tifs of individual channels, composite(s) and MAX projections with & without DAPI.  

Each macro is written to process an entire directory at once (the for loop).  
Macros are hard-coded to process mrp2/occludin/dapi IHC experimental images, but can be adapted by adjusting the number/name of channels.  
Macros are written assuming no underscores are used in the name of the original files so that they can be used as the delimiter (I used dashes, deal with it).  

Add these macros to the /plugins folder in Image/Fiji and they will appear at the bottom of the Plugins menu tab (after restarting the program).
