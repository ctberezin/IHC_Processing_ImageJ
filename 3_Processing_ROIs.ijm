//This is the last of 3 macros written to process immunohistochemistal (IHC) data from multiplex fluorescent z-stack confocal images obtained on a Zeiss microscope (czi files) for colocalization analysis (Costes' methods)
//Macro 1: Denoising. Reads in czi files, does some pre-processing and saves as tif files
//Macro 2: Composite & MAX projection. Makes a color-blind friendly composite image & a maximum intensity z-projection. Also produces versions without DAPI.
//*Macro 3: ROI processing. Allows the user to draw regions of interest (ROIs) around areas for colocalization analysis. Saves tifs of individual channels, composite(s) and MAX projections with & without DAPI.
//Each macro is written to process an entire directory at once (the for loop).
//Macros are hard-coded to process mrp2/occludin/dapi IHC experimental images, but can be adapted by adjusting the number/name of channels
//Macros are written assuming no underscores are used in the name of the original files so that they can be used as the delimiter here and in subsequent macros (I used dashes, deal with it)
//GOAL 1: Opens up a MAX projection image (here, without DAPI) and waits for the user to draw ROIs around areas they want to perform colocalization analysis on. 
//TIP: You should name your ROIs something useful (e.g. 1,2,3; gcl1, gcl2, inl1, etc.) so it's easier to navigate your results later. Go to https://imagej.nih.gov/ij/macros/RoiManagerMacros.txt to download ROI manager shortcuts; you will be able to press 2 to quickly add an ROI and name it.
//GOAL 2: Transfers the ROIs you drew to the composite image, crops it out, then saves tifs of the ROI as a composite, a MAX projection, and as individual channels. ALso saves a composite & MAX projection without DAPI.
//TIP: The individual channel ROI images are ready for colocalization analysis (Costes' methods) with JACoP
//<3
//CTB 8/14/22

setTool("rectangle");

//select a directory with czi files you want to process
dir = getDirectory("Choose a source directory with MAX projection & composite images");
list = getFileList(dir);
print("Processing images from: " + dir)
//create a folder to save the processed files
outDir = dir + "ROI_processing";
File.makeDirectory(outDir);
print("Saving new files to: " + outDir);

// clear ROI manager
roiManager("reset");	

//open up each MAXproj (without DAPI) and draw ROIs around areas for colocalization analysis
for (i=0; i<list.length; i++) {
	showProgress(i+1, list.length);
	filename = dir + list[i];
	if (endsWith(filename, "_MAXproj_noDAPI.tif")) {
		open(list[i]);
		name = getTitle();
		prefix = substring(name,0,indexOf(name, ".")); // remove .czi from name
		print("User is drawing ROIs on: " + prefix);
		run("ROI Manager...");
		setTool("rectangle");
		waitForUser("Draw ROIs", "Draw boxes around areas of interest to use for colocalization analysis. If you have the shortcut, press 2 to add & name. Click More>Open to open ROIs you already drew.");
		//select all roi's
		count = roiManager("count");
		array = newArray(count);
  			for (j=0; j<array.length; j++) {
      			array[j] = j;
  			}
		roiManager("select", array);
		//save roi's
		roiManager("save", outDir + "/" + prefix + ".zip");
		// clear list
		roiManager("delete")
		close(list[i]);
	}
}

//allows the macro run in the background without opening images; comment out to troubleshoot
setBatchMode(true);
//process the ROIs we drew in the composite
for (i=0; i<list.length; i++) {
	showProgress(i+1, list.length);
	filename = dir + list[i];
	if (endsWith(filename, "composite.tif")) {
		open(list[i]);
		name = getTitle();
		prefix = substring(name,0,indexOf(name, ".")); // remove .czi from name
		basename = substring(name,0,indexOf(name, "_")); // remove .czi from name
		roiManager("Open", outDir + "/" + basename + "_MAXproj_noDAPI.zip");
		n = roiManager('count');
		print("Found " + n + " ROI(s) to process for " + basename);
		//loop over each ROI to crop it out
		for (j = 0; j < n; j++) {
    		open(list[i]);
    		roiManager('select', j);
    		foo = Roi.getName;
    		print("Working on roi " + j+1 + "/" + n + " for " + basename + " (" + foo + ")");
    		//crop roi and save
    		run("Crop");
    		saveAs("tiff", outDir + "/" + basename + "_" + foo);
			//make MAX projection of roi
			run("Z Project...", "projection=[Max Intensity]");
			saveAs("tiff", outDir + "/" + basename +  "_" + foo + "_MAXproj.tif");
			close();
			//make composite & MAX projection without DAPI
			//split the roi into channels
			selectWindow(basename + "_" + foo + ".tif");
			run("Split Channels");
			//C1 = mrp2
			selectWindow("C1-" + basename + "_" + foo + ".tif");
			mrp2 = basename + "_" + foo;
			saveAs("tiff", outDir + "/" + basename + "_" + foo + "_mrp2.tif");
			//C2 = dapi
			selectWindow("C2-" + basename + "_" + foo + ".tif");
			saveAs("tiff", outDir + "/" + basename + "_" + foo + "_dapi.tif");
			close();
			//C3 = occludin
			selectWindow("C3-" + basename + "_" + foo + ".tif");
			occludin = basename + "_" + foo;
			saveAs("tiff", outDir + "/" + basename + "_" + foo + "_occludin.tif");
			//make MAX projection without DAPI
			run("Merge Channels...", "c2=" +mrp2 + "_mrp2.tif c6=" +occludin + "_occludin.tif create keep ignore");
			selectWindow("Composite");
			run("Z Project...", "projection=[Max Intensity]");
			saveAs("tiff", outDir + "/" + basename + "_" + foo + "_MAXproj_noDAPI.tif");
			close();
			selectWindow("Composite");
			saveAs("tiff", outDir + "/" + basename + "_" + foo + "_noDAPI.tif");
			}
		// clear ROI manager
		roiManager("delete");	
		}
	}

print("Success! All ROIs from " + prefix + " has been processed.");
close("*");