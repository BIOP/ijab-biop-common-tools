
<codeLibrary>
	function toolName() {
		return "Common Tools";
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// specific library


function setImageCalibration(){

	
	getVoxelSize(px,py,pz,u);
	Stack.getUnits(xu, yu,zu, tu, iu);
	ti = Stack.getFrameInterval();
	
	Dialog.create("Voxel Size Tool");
	Dialog.addString("Pixel Unit", "micron");
	Dialog.addNumber("Pixel Size [xy]", px);
	Dialog.addNumber("Pixel Size [z]", pz);

	Dialog.addMessage("Camera Pixel Size Calculator");
	Dialog.addCheckbox("Use Pixel Size Calculator instead", false);
	Dialog.addNumber("Magnification", 10, 0, 3, "x");
	Dialog.addNumber("C-mount", 1.0, 1, 3, "x");
	Dialog.addNumber("CCD pixel size", 6.45, 2, 4, "um");
	Dialog.addNumber("Binning", 1, 0, 3, "");	

	Dialog.addMessage("Other Calibrations");
	Dialog.addString("Time Unit", tu);
	Dialog.addNumber("Time Interval", ti);
	
	
	Dialog.show();

	pxU      = Dialog.getString();
	pxXY     = Dialog.getNumber();
	pxZ      = Dialog.getNumber();
	 
	isPxCalc = Dialog.getCheckbox();
	mag      = Dialog.getNumber();
	cm       = Dialog.getNumber();
	ccd      = Dialog.getNumber();
	bin      = Dialog.getNumber();

	tu      = Dialog.getString();
	ti      = Dialog.getNumber();

	
	pixelsize=(ccd*bin)/(mag*cm);

	if(isPxCalc) {
		setVoxelSize(pixelsize,pixelsize,pxZ, pxU);
		setData("XY Voxel Size", pixelsize);
	} else {
		setVoxelSize(pxXY,pxXY,pxZ, pxU);
		setData("XY Voxel Size", pxXY);
	}

	setData("Z Voxel Size", pxZ);
	setData("Spacial Units", pxU);

	setData("Time Unit", tu);
	setData("Time Interval", ti);

	
	
}


function applyImageCalibration(){
	pxy = parseFloat(getData("XY Voxel Size"));
	pz = parseFloat(getData("Z Voxel Size"));
	pu = getData("Spacial Units");

	tu = getData("Time Unit");
	ti = parseFloat(getData("Time Interval"));

	setVoxelSize(pxy,pxy,pz,pu);
	Stack.setTUnit(tu);
	Stack.setFrameInterval(ti);
}

function setDimensions() {
	getDimensions(width, height, channels, slices, frames);

	ordering = newArray("xyczt(default)", "xyctz", "xyzct", "xyztc", "xytcz", "xytzc");
	dispMode = newArray("Color", "Composite", "Grayscale");
	
	Dialog.create("Set Dimensions of Image");
	Dialog.addChoice("Order", ordering);
	Dialog.addNumber("Channels (c)", channels);
	Dialog.addNumber("Slices (z)", slices);
	Dialog.addNumber("Frames (t)", frames);
	Dialog.addChoice("Display Mode", dispMode);

	Dialog.show();

	order    = Dialog.getChoice();
	channels = Dialog.getNumber();
	slices   = Dialog.getNumber();
	frames   = Dialog.getNumber();
	disp     = Dialog.getChoice();

	setData("Order", order);
	setData("Channels", channels);
	setData("Slices", slices);
	setData("Frames", frames);
	setData("Display", disp);

}

function applyDimensions() {
	order    = getData("Order");
	channels = parseInt(getData("Channels"));
	slices   = parseInt(getData("Slices"));
	frames   = parseInt(getData("Frames"));
	disp     = getData("Display");
	
	// Run the "Stack To HyperStack tool
	run("Stack to Hyperstack...", "order="+order+" channels="+channels+" slices="+slices+" frames="+frames+" display="+disp);
	

}


</codeLibrary>

<text><html><font size=2 color=#66666f> Please set the calibration for the current image
<text><html><font size=2 color=#66666f> you can then apply it to the current image or to a folder

<line>
<button>
label= Set Calibration
icon=noicon
arg=<macro>
setImageCalibration();
setDimensions();

</macro>

</line>
<text><html><font size=2.5 color=#00000f>Apply Calibrations...
<line>
<button>
label= ... on the current image
icon=noicon
arg=<macro>
applyDimensions();
applyImageCalibration();
</macro>

<button>
label= ... on a folder
icon=noicon
arg=<macro>

dir = getDirectory("Please , select a folder containing images");			//get the folder
file = getFileList(dir);
savingDir = dir+"saving_Calibrated"+File.separator;
File.makeDirectory(savingDir);

for (i=0; i<lengthOf(file); i++) {
	if (isImage(file[i])){
		open(dir+file[i]);						// open the image
		fileNameNoExt = File.nameWithoutExtension;			// get the file name without the extension
		
		applyDimensions();
		applyImageCalibration();			// action to perform, HERE!
		
		saveAs("Tiff", savingDir+fileNameNoExt+"_Calibrated.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}

	

</macro>
</line>