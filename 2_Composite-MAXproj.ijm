//This is the second of 3 macros written to process immunohistochemistal (IHC) data from multiplex fluorescent z-stack confocal images obtained on a Zeiss microscope (czi files) for colocalization analysis (Costes' methods)
//Macro 1: Denoising. Reads in czi files, does some pre-processing and saves as tif files
//*Macro 2: Composite & MAX projection. Makes a color-blind friendly composite image & a maximum intensity z-projection. Also produces versions without DAPI.
//Macro 3: ROI processing. Allows the user to draw regions of interest (ROIs) around areas for colocalization analysis. Saves tifs of individual channels, composite(s) and MAX projections with & without DAPI.
//Each macro is written to process an entire directory at once (the for loop).
//Macros are hard-coded to process mrp2/occludin/dapi IHC experimental images, but can be adapted by adjusting the number/name of channels
//Macros are written assuming no underscores are used in the name of the original files so that they can be used as the delimiter here and in subsequent macros (I used dashes, deal with it)
//GOAL: Opens up each of the 3 channels for the same image, makes a color-blind friendly composite (magenta/green instead of red/green) and a maximum intensity Z-projection. Also makes a composite & MAX projection without the DAPI label.
//CAVEAT: code (for loop) is written assuming each image has 3 channels (for 4 channels, i=i+3 would be i=i+4; and you'll need to code in another channel to merge into)
//<3
//CTB 8/14/22

//allows the macro run in the background without opening images; comment out to troubleshoot
setBatchMode(true);

//select a directory with czi files you want to process
dir = getDirectory("Choose a source directory with denoised tif files");
list = getFileList(dir);
print("Processing files from: " + dir)
//create a folder to save the processed files
outDir = dir + "composites";
File.makeDirectory(outDir);
print("Saving new files to: " + outDir);
count = 0;

for (i=0; i+3<list.length; i=i+3) {
	count = count + 1;
	open(dir + list[i]);
	dapi = getTitle();
	dapi = substring(dapi,0,indexOf(dapi, ".")); // remove .tif from name
	prefix = substring(dapi,0,indexOf(dapi, "_"));
	open(dir + list[i+1]);
	occludin = getTitle();
	occludin = substring(occludin,0,indexOf(occludin, ".")); // remove .tif from name
	open(dir + list[i+2]);
	mrp2 = getTitle();
	mrp2 = substring(mrp2,0,indexOf(mrp2, ".")); // remove .tif from name
	//make composite & MAX projection
	run("Merge Channels...", "c2=" +mrp2 + ".tif c5=" +dapi + ".tif c6=" +occludin + ".tif create keep ignore");
	selectWindow("Composite");
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("tiff", outDir + "/" + prefix + "_MAXproj.tif");
	close();
	selectWindow("Composite");
	saveAs("tiff", outDir + "/" + prefix + "_composite.tif");
	close();
	//make composite & MAX projection without DAPI
	run("Merge Channels...", "c2=" +mrp2 + ".tif c6=" +occludin + ".tif create keep ignore");
	selectWindow("Composite");
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("tiff", outDir + "/" + prefix + "_MAXproj_noDAPI.tif");
	close();
	selectWindow("Composite");
	saveAs("tiff", outDir + "/" + prefix + "_composite_noDAPI.tif");
	close();
	print("Success! " + prefix + " has been processed.");
}

print("Processed " + count + " images from " + dir);