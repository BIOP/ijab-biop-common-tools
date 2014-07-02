
<codeLibrary>
  
	function toolName() {
		return "Common Tools";
	}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// specific library
function brightnessAndContrastSetting(){
	getDimensions(width, height, channels, slices, frames);
	for (i=0;i<channels;i++){
		chNbr=(i+1);
		Stack.setChannel(chNbr);
		run("Brightness/Contrast...");
		waitForUser(" Set B&C for channel "+chNbr+"\n Please set Min and Max \n and press Ok");
		getMinAndMax(min, max);
		setData("min ch"+chNbr,min);
		setData("max ch"+chNbr,max);
	}
}

function brightnessAndContrastSettingApply(){
	getDimensions(width, height, channels, slices, frames);
	for (i=0;i<channels;i++){
		chNbr=(i+1);
		Stack.setChannel(chNbr);
		min = getData("min ch"+chNbr);
		max = getData("max ch"+chNbr);
		setMinAndMax(min, max);
	}
}
</codeLibrary>



<startupAction>
//loadParameters(false);
</startupAction>

<text><html><font size=2 color=#66666f> Please define the Brightness and Contrast for each channels and apply
<text><html><font size=2 color=#66666f> on the current image or select a fodler containing images.

</line>
<line>
<button>
label= Define Brightness and Contrast 
icon=noicon
arg=<macro>
brightnessAndContrastSetting();
</macro>

</line>
<text><html><font size=2.5 color=#00000f>Apply...
<line>
<button>
label= ... on the current image
icon=noicon
arg=<macro>
brightnessAndContrastSettingApply();
</macro>

<button>
label= ... on a folder
icon=noicon
arg=<macro>

dir = getDirectory("Please , select a folder containing images");			//get the folder
file = getFileList(dir);
savingDir = dir+"saving_BandC"+File.separator;
File.makeDirectory(savingDir);

for (i=0; i<lengthOf(file); i++) {
	if (isImage(file[i])){
		open(dir+file[i]);						// open the image
		fileNameNoExt = File.nameWithoutExtension;			// get the file name without the extension

		brightnessAndContrastSettingApply();	// action to perform, here

		saveAs("Tiff", savingDir+fileNameNoExt+"_BrightnessAndContrast.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}

</macro>
</line>
