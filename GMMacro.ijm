//Please Note: This is a draft format of an ImageJ macro
//Developed by George Merces, Newcastle University, 04.11.2024
//In a Project with Alisha Gibbs, Newcastle University
//This macro aims to automate the segmentation of nuclei and
//Measure intracellular Nox5 staining based on Level of Insulin/Glucagon Staining

//This option setting allows for arrays to be generated later in the macro for
//removing unsuitable nuclei from the analysis
setOption("ExpandableArrays", true);

//Establishes the File Chooser so Lif Files can be Converted into Tif Files
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use use_file copy_row save_column save_row");
run("Bio-Formats Macro Extensions");

//Sets the Measurements Necessary for Full Data Analysis Later
run("Set Measurements...", "area mean standard modal min centroid perimeter bounding fit shape feret's median area_fraction display redirect=None decimal=3");

//Clears the results window ready for analysis
run("Clear Results");

//Defines the folder locations necessary for the analysis:
//Home folder containing all the folders and files necessary for this macro to run
homeFolder = getDirectory("Choose The Home Folder (Where All Your Other Folders for this Macro Are)");
//Raw Folder containing all raw, unprocessed images for this macro to analyse
rawFolder = getDirectory("Choose The Home Folder (Where All Your Raw Images Are)");

//Creates folders necessary for saving output images
tifFolder = homeFolder + "Raw_Tifs/";
if (File.isDirectory(tifFolder) < 1) {
	File.makeDirectory(tifFolder); 
}
Ch1 = homeFolder + "Ch1/";
if (File.isDirectory(Ch1) < 1) {
	File.makeDirectory(Ch1); 
}
Ch1Sub = homeFolder + "Ch1_Sub/";
if (File.isDirectory(Ch1Sub) < 1) {
	File.makeDirectory(Ch1Sub); 
}
Ch2 = homeFolder + "Ch2/";
if (File.isDirectory(Ch2) < 1) {
	File.makeDirectory(Ch2); 
}
Ch3 = homeFolder + "Ch3/";
if (File.isDirectory(Ch3) < 1) {
	File.makeDirectory(Ch3); 
}
Ch4 = homeFolder + "Ch4/";
if (File.isDirectory(Ch4) < 1) {
	File.makeDirectory(Ch4); 
}
rgbFolder = homeFolder + "RGB_Folder/";
if (File.isDirectory(rgbFolder) < 1) {
	File.makeDirectory(rgbFolder); 
}
isletFolder = homeFolder + "Islet_Binary_Folder_V2/";
if (File.isDirectory(isletFolder) < 1) {
	File.makeDirectory(isletFolder); 
}
binaryFolder = homeFolder + "Binary_Folder/";
if (File.isDirectory(binaryFolder) < 1) {
	File.makeDirectory(binaryFolder); 
}
roiFolder = homeFolder + "ROI_Folder/";
if (File.isDirectory(roiFolder) < 1) {
	File.makeDirectory(roiFolder); 
}
binaryTissueFolder = homeFolder + "Binary_Tissue_Folder_V2/";
if (File.isDirectory(binaryTissueFolder) < 1) {
	File.makeDirectory(binaryTissueFolder); 
}
subtractedNuclearFolder = homeFolder + "subtracted_Nuclear_Folder_V2/";
if (File.isDirectory(subtractedNuclearFolder) < 1) {
	File.makeDirectory(subtractedNuclearFolder); 
}
binaryCh1 = homeFolder + "binary_Channel_1_V2/";
if (File.isDirectory(binaryCh1) < 1) {
	File.makeDirectory(binaryCh1); 
}


//Finds the names of image files within folder and counts the number of files
list = getFileList(rawFolder);
l = list.length;
//Opens each image sequentially, and all series within image, and converts each to individual tif
for (i=0; i<l; i++) {
	//Determines, and stores, the name of the file within your Lif folder
	fileName = rawFolder + list[i];
	//Opens the file using BioFormats Importer
	run("Bio-Formats", "check_for_upgrades open=[" + fileName + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	saveFileRaw = substring(list[i], 0, (lengthOf(list[i])-4));
	saveName = tifFolder + saveFileRaw + ".tif";
	saveAs("Tiff", saveName);
	getDimensions(width, height, channels, slices, frames);
	//Splits the channels of the image
	run("Split Channels");
	saveFileRaw = substring(list[i], 0, (lengthOf(list[i])-4));
	saveName = Ch4 + saveFileRaw + ".tif";
	saveAs("Tiff", saveName);
	close();
	saveName = Ch3 + saveFileRaw + ".tif";
	saveAs("Tiff", saveName);
	close();
	saveName = Ch2 + saveFileRaw + ".tif";
	saveAs("Tiff", saveName);
	close();
	saveName = Ch1 + saveFileRaw + ".tif";
	saveAs("Tiff", saveName);
	close();
	close("*");
}

//Finds the names of image files within folder and counts the number of files
list = getFileList(Ch2);
l = list.length;
//Opens each image sequentially, and all series within image, and converts each to individual tif
for (i=0; i<l; i++) {
	fileName = Ch2 + list[i];
	open(fileName);
	Ch2Img = getTitle();
	fileName = Ch4 + list[i];
	open(fileName);
	Ch4Img = getTitle();
	run("Merge Channels...", "c1=[" + Ch2Img + "] c2=[" + Ch4Img +"] create");
	run("RGB Color");
	saveName = rgbFolder + list[i];
	saveAs("Tiff", saveName);
	close("*");
}


// set global variables for Ilastik Project
pixelClassificationProject = homeFolder + "20241104_AG_V2.ilp";
outputType = "Probabilities"; //  or "Segmentation"
inputDataset = "data";
outputDataset = "exported_data";
axisOrder = "tzyxc";
compressionLevel = 0;

foldertoProcess = rgbFolder;
folderforOutput = homeFolder + "Ilastik_Probability_Output_V2/";
if (File.isDirectory(folderforOutput) < 1) {
	File.makeDirectory(folderforOutput); 
}

//Checks membrane folder (bfFolder Folder) for files and counts the number of them
list = getFileList(rgbFolder);
list = Array.sort(list);
list= Array.reverse(list);
l = list.length;
//
for (i=0; i<l; i++) {
	fileName = foldertoProcess + list[i];
	testName = folderforOutput + list[i];
	if( File.exists(testName) == 0){
		print("Creating New Probability Map");
		open(fileName);
		inputImage = getTitle();
		pixelClassificationArgs = "projectfilename=[" + pixelClassificationProject + "] saveonly=false inputimage=[" + inputImage + "] pixelclassificationtype=" + outputType;
		run("Run Pixel Classification Prediction", pixelClassificationArgs);
		//Saves the probability map to the appropriate folder
		run("8-bit");
		saveAs("Tiff", folderforOutput + list[i]);
		close("*");
	}
	else{
		print("Probability Map Already Existed");
	}
}



//Finds the names of image files within folder and counts the number of files
list = getFileList(folderforOutput);
l = list.length;
//Opens each image sequentially
for (i=0; i<l; i++) {
	roiManager("reset");
	//Determines, and stores, the name of the file within your folder
	fileName = folderforOutput + list[i];
	open(fileName);
	//Slightly Blurs the Image
	run("Gaussian Blur...", "sigma=20");
	run("Subtract...", "value=100");
	//Thresholds the Image
	setAutoThreshold("Huang dark no-reset");
	saveName = binaryTissueFolder + list[i];
	run("Convert to Mask");
	saveAs("Tiff", saveName);
	run("Invert");
	newRemove = getTitle();
	//OPEN UP THE NUCLEAR IMAGE 
	fileName = Ch3 + list[i];
	open(fileName);
	run("8-bit");
	nuclear = getTitle();
	imageCalculator("Subtract create stack", nuclear, newRemove);
	selectWindow(newRemove);
	close();
	selectWindow(nuclear);
	close();
	//run("RGB Color");
	//Converts to 8-bit format
	//run("8-bit");
	saveName = subtractedNuclearFolder + list[i];
	saveAs("Tiff", saveName);
	close("*");
}

//Finds the names of image files within folder and counts the number of files
list = getFileList(folderforOutput);
l = list.length;
//Opens each image sequentially
for (i=0; i<l; i++) {
	roiManager("reset");
	//Determines, and stores, the name of the file within your folder
	fileName = folderforOutput + list[i];
	open(fileName);
	//Slightly Blurs the Image
	run("Gaussian Blur...", "sigma=20");
	run("Subtract...", "value=100");
	//Thresholds the Image
	setAutoThreshold("Huang dark no-reset");
	run("Convert to Mask");
	run("Invert");
	newRemove = getTitle();
	//OPEN UP THE NUCLEAR IMAGE 
	fileName = Ch1 + list[i];
	open(fileName);
	run("8-bit");
	nuclear = getTitle();
	imageCalculator("Subtract create stack", nuclear, newRemove);
	selectWindow(newRemove);
	close();
	selectWindow(nuclear);
	close();
	//run("RGB Color");
	//Converts to 8-bit format
	//run("8-bit");
	saveName = Ch1Sub + list[i];
	saveAs("Tiff", saveName);
	close("*");
}

//COPIED TO RUN FOlLOWING MANUAL SEGMENTATION OF PATIENT 79

//Finds the names of image files within folder and counts the number of files
list = getFileList(folderforOutput);
l = list.length;
//Opens each image sequentially
for (i=0; i<l; i++) {
	roiManager("reset");
	//Determines, and stores, the name of the file within your folder
	fileName = binaryTissueFolder + list[i];
	open(fileName);
	run("Invert");
	newRemove = getTitle();
	//OPEN UP THE NUCLEAR IMAGE 
	fileName = Ch3 + list[i];
	open(fileName);
	run("8-bit");
	nuclear = getTitle();
	imageCalculator("Subtract create stack", nuclear, newRemove);
	selectWindow(newRemove);
	close();
	selectWindow(nuclear);
	close();
	//run("RGB Color");
	//Converts to 8-bit format
	//run("8-bit");
	saveName = subtractedNuclearFolder + list[i];
	saveAs("Tiff", saveName);
	close("*");
}


//Finds the names of image files within folder and counts the number of files
list = getFileList(folderforOutput);
l = list.length;
//Opens each image sequentially
for (i=0; i<l; i++) {
	roiManager("reset");
	//Determines, and stores, the name of the file within your folder
	fileName = binaryTissueFolder + list[i];
	open(fileName);
	run("Invert");
	newRemove = getTitle();
	//OPEN UP THE NUCLEAR IMAGE 
	fileName = Ch1 + list[i];
	open(fileName);
	run("8-bit");
	nuclear = getTitle();
	imageCalculator("Subtract create stack", nuclear, newRemove);
	selectWindow(newRemove);
	close();
	selectWindow(nuclear);
	close();
	//run("RGB Color");
	//Converts to 8-bit format
	//run("8-bit");
	saveName = Ch1Sub + list[i];
	saveAs("Tiff", saveName);
	close("*");
}




//Finds the names of image files within folder and counts the number of files
list = getFileList(subtractedNuclearFolder);
l = list.length;
//Opens each image sequentially, and all series within image, and converts each to individual tif
for (i=0; i<l; i++) {
	roiManager("reset");
	//Opens the nuclear image
	fileName = subtractedNuclearFolder + list[i];
	open(fileName);
	getDimensions(width, height, channels, slices, frames);
	//Applies Guassian Blur
	run("Gaussian Blur...", "sigma=1");
	//Segments the image using StarDist
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'" + list[i] + "', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.7', 'nmsThresh':'0.6', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	//Make a binary image with non-overlapping cells based on the stardist ROIs
	saveFileRaw = substring(list[i], 0, (lengthOf(list[i])-4));
	roiSaveName = roiFolder + "ROI " + saveFileRaw + ".zip";
	//Counts the number of nuclei found by the ROI manager
	n = roiManager("count");
	if (n == 0) {
		makeOval(1, 1, 1, 1);
		roiManager("Add");
	}
	n = roiManager("count");
	//If some nuclei have been identified...
	if (n > 0) {
		//Save the ROIs to the appropriate location
		roiManager("save", roiSaveName);
		//Create a blank image to draw on the nuclei for to determine cell boundary locations
		newImage("Untitled", "8-bit black", width, height, 1);
		//For each nucleus in the ROI manager
	    for (j=0; j<n; j++) {
	    	//Select the ROI
	    	roiManager("select", j);
	    	//Fill the area of the ROI with black to prevent summation of multiple touching nuclei into one super-nucleus
	    	setForegroundColor(0, 0, 0);
			roiManager("Fill");
			//Re-selects the ROI
			roiManager("select", j);
			//Shrinks the ROI down by 3 pixels
			run("Enlarge...", "enlarge=-2");
			//Fills the ROI with white for the particle analyser to find later
			roiManager("update");
			setForegroundColor(255, 255, 255);
			roiManager("Fill");
	    }
	    saveName = binaryFolder + list[i];
		saveAs("Tiff", saveName);
	}
	close("*");
	roiManager("reset");	
}


//Finds the names of image files within folder and counts the number of files
list = getFileList(Ch1);
l = list.length;
//Opens each image sequentially, and all series within image, and converts each to individual tif
for (i=0; i<l; i++) {
	fileName = Ch1 + list[i];
	open(fileName);
	setThreshold(10000, 65535, "raw");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	saveName = binaryCh1 + list[i];
	saveAs("Tiff", saveName);
	close("*");
}
