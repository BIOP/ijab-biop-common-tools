
<codeLibrary>
	function toolName() {
		return "Common Tools";
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// specific library


function channelsLUTSelection(){

	getDimensions(width, height, channels, slices, frames);
	
	//colorArray = getList("LUTs");
	colorArray = newArray("Red","Green","Blue","Grays","Cyan","Magenta","Yellow","Fire");
	colorSelected = newArray(channels);

	Dialog.create("LUT selection")	//ask user for LUT selection
	for (i=0;i<channels;i++){
		Dialog.addChoice("color channel "+(i+1)+", using LUT", colorArray, colorArray[i]);
	}
	Dialog.show() ;
	
	for (i=0;i<channels;i++){	//get and record user's selection
		colorSelected [i]= Dialog.getChoice();
		setData("color channel "+(i+1)+" using LUT", colorSelected[i]);
	}
}

function channelsLUTApply(){
	getDimensions(width, height, channels, slices, frames);
		
	colorFirstChannel =  getData("color channel 1 using LUT");
	
	if (colorFirstChannel ==""){
		noLutRecorded = true;
	}else{
		noLutRecorded = false;
	}
	
	if( noLutRecorded ){			//if no LUT slected  
			showMessage("Please select LUT for channels");	
	}else{					//get from the record
		for (i=0;i<channels;i++){
			chNbr=(i+1);
			recColorTemp = getData("color channel "+chNbr+" using LUT");
			Stack.setChannel(chNbr);
			run(recColorTemp);
		}
	}
}



</codeLibrary>



<startupAction>
//loadParameters(false);
</startupAction>


<text><html><font size=2 color=#66666f> Please define the LUT you want for each channels and apply
<text><html><font size=2 color=#66666f> on the current image or select a fodler containing images.

</line>
<line>
<button>
label= Channels LUT Selection
icon=noicon
arg=<macro>
channelsLUTSelection();
</macro>

</line>
<text><html><font size=2.5 color=#00000f>Apply LUT selected...
<line>
<button>
label= ... on the current image
icon=noicon
arg=<macro>
channelsLUTApply();
</macro>

<button>
label= ... on a folder
icon=noicon
arg=<macro>

dir = getDirectory("Please , select a folder containing images");			//get the folder
file = getFileList(dir);
savingDir = dir+"saving_selectedLUT"+File.separator;
File.makeDirectory(savingDir);

for (i=0; i<lengthOf(file); i++) {
	if (isImage(file[i])){
		open(dir+file[i]);						// open the image
		fileNameNoExt = File.nameWithoutExtension;			// get the file name without the extension
		
		channelsLUTApply();				// action to perform, HERE!
		
		saveAs("Tiff", savingDir+fileNameNoExt+"_selectedLUT.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}

	

</macro>
</line>