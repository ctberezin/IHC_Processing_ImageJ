//This is the first of 3 macros written to process immunohistochemistal (IHC) data from multiplex fluorescent z-stack confocal images obtained on a Zeiss microscope (czi files) for colocalization analysis (Costes' methods)
//*Macro 1: Denoising. Reads in czi files, does some pre-processing and saves as tif files
//Macro 2: Composite & MAX projection. Makes a color-blind friendly composite image & a maximum intensity z-projection. Also produces versions without DAPI.
//Macro 3: ROI processing. Allows the user to draw regions of interest (ROIs) around areas for colocalization analysis. Saves tifs of individual channels, composite(s) and MAX projections with & without DAPI.
//Each macro is written to process an entire directory at once (the for loop).
//Macros are hard-coded to process mrp2/occludin/dapi IHC experimental images, but can be adapted by adjusting the number/name of channels
//Macros are written assuming no underscores are used in the name of the original files so that they can be used as the delimiter here and in subsequent macros (I used dashes, deal with it)
//GOAL: dapi & occludin (blood vessel marker) channels are auto-contrast-adjusted*, despeckled to remove noise (as subsequent colocalization analysis is sensitive to noise), and saved as tifs
//CAVEAT: the mrp2 signal has a lot of background so I just convert to a tif and process manually after (auto brightness/contrast, sometimes gamma (sometimes I do that in Zen beforehand), subtract, despeckle, remove outliers)
//BONUS: 16-bit images are converted to 8-bit so future analyses don't take forever/freeze/crash
//*I would usually use auto b/c and adjust if needed. The only/default macro code available to do something similar is: ////run("Enhance Contrast", "saturated=0.35"); -- I varied the saturation amount below per channel to avoid images being too bright/bringing out noise
//<3
//CTB 8/14/22

//allows the macro run in the background without opening images; comment out to troubleshoot
setBatchMode(true);
run("Bio-Formats Macro Extensions");

//select a directory with czi files you want to process
dir = getDirectory("Choose Source Directory with CZI files");
list = getFileList(dir);
print("Processing files from: " + dir)
//create a folder to save the processed files
outDir = dir + "processing";
File.makeDirectory(outDir);
print("Saving new files to: " + outDir);
count = 0;

for (i=0; i<list.length; i++) {
	showProgress(i+1, list.length);
	filename = dir + list[i];
	bfi = "open=["+filename+"] autoscale split_channels color_mode=Colorized display_rois rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
	if (endsWith(filename, ".czi")) {
		count = count + 1;
		run("Bio-Formats Importer", bfi);
		name = getTitle();
		name = substring(name,0,indexOf(name, " ")); // remove channel info from name
		prefix = substring(name,0,indexOf(name, ".")); // remove .czi from name
		//C1 = dapi
		selectWindow(name + " - C=1");
		if (bitDepth() == 16) {
			run("8-bit");
		}
		run("Enhance Contrast", "saturated=0.1");
		run("Despeckle", "stack");
		saveAs("tiff", outDir + "/" + prefix + "_dapi-denoised.tif");
		close();
		//C2 = occludin
		selectWindow(name + " - C=2");
		if (bitDepth() == 16) {
			run("8-bit");
		}
		run("Enhance Contrast", "saturated=0.05");
		run("Despeckle", "stack");
		saveAs("tiff", outDir + "/" + prefix + "_occludin-denoised.tif");
		close();
		//C0 = mrp2
		selectWindow(name + " - C=0");
		if (bitDepth() == 16) {
			run("8-bit");
		}
		saveAs("tiff", outDir + "/" + prefix + "_mrp2.tif");
		close();
		print("Success! " + prefix + " has been processed.");
		}
	else  {
		print(filename + " is not a czi file. Functionality for tif files is coming soon!");
	}
	}
	
print("Processed " + count + " czi files in " + dir);