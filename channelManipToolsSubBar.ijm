// DEBUG LINE
run("Action Bar","plugins/ActionBar/channelManipToolsSubBar.ijm");
exit();
// END DEBUG

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
			if(nSlices>1) {
				Stack.setChannel(chNbr);
			}
			run(recColorTemp);
		}
	}
}


function brightnessAndContrastSetting(){
	getDimensions(width, height, channels, slices, frames);
	for (i=0;i<channels;i++){
		chNbr=(i+1);
		if(nSlices>1) {
			Stack.setChannel(chNbr);
		}
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
		if(nSlices>1) {
			Stack.setChannel(chNbr);
		}
		min = getData("min ch"+chNbr);
		max = getData("max ch"+chNbr);
		setMinAndMax(min, max);
	}
}

//montage options
function montageOptions(){
	// Scale bar position
	scalePos = getDataD("ScaleBar Position", "Lower Right");
	// scale bar size
	scaleLength = getDataD("ScaleBar Length", 100);
	// scalebar height
	scaleHeight = getDataD("ScaleBar height", 5);
	
	// Which Position gets the scalebar
	atImage = getDataD("Scalebar At", "");
	
	// nrows ncols
	mRows = getDataD("Montage Rows", "As Row");
	mCols = getDataD("Montage Cols", 1);
	// position of composite
	cPos = getDataD("Channel Merge Position", "First");
	isIgnore = getBool("Ignore LUTs except for Merged");
	advMon = getDataD("Advanced Montage", "");
	
	// border size
	bSize = getDataD("Montage Border", 0);
	// border color
	rowChoice= newArray("As Row", "1","2", "3", "4", "5", "6");
	colChoice= newArray("As Column","1", "2", "3", "4", "5", "6");
	scalePoses=newArray("Lower Right", "Lower Left", "Upper Right", "Upper Left");
	imgPos=newArray("First", "Last");
	
	Dialog.create("Montage Options");
	Dialog.addCheckbox("Use Scalebar", true);
	Dialog.addChoice("Scalebar Position", scalePoses, scalePos);
	Dialog.addNumber("Scalebar Length", scaleLength, 0, 5, "um");
	Dialog.addNumber("Scalebar Height", scaleHeight, 0, 5, "px");
	Dialog.addString("Scalebar At Image", atImage);
	Dialog.addChoice("Montage Rows", rowChoice, mRows);
	Dialog.addChoice("Montage Columns", colChoice, mCols);
	Dialog.addChoice("Merged Image Position", imgPos, cPos);
	Dialog.addCheckbox("Ignore LUTs except for Merged", isIgnore);
	Dialog.addString("Advanced Montage", advMon);
	
	Dialog.addNumber("Montage Border", bSize,0,5,"px");
	
	Dialog.show();
	
	// Scale bar position
	useScale = Dialog.getCheckbox();
	scalePos = Dialog.getChoice();
	scaleLen = Dialog.getNumber();
	scaleHei = Dialog.getNumber();
	atImage  = Dialog.getString();
	mRows = Dialog.getChoice();
	mCols = Dialog.getChoice();
	cPos = Dialog.getChoice();
	isIgnore = Dialog.getCheckbox();
	advMon = Dialog.getString();
	bSize = Dialog.getNumber();
	
	
	setData("Use Scalebar", "Yes");
	if (!useScale)
		setData("Use Scalebar", "No");
	
	setData("ScaleBar Position", scalePos);
	setData("ScaleBar Length", scaleLen);
	setData("ScaleBar Height", scaleHei);
	setData("Scalebar At", atImage);
	setData("Montage Rows", mRows);
	setData("Montage Cols", mCols);
	setData("Channel Merge Position", cPos);
	setBool("Ignore LUTs except for Merged", isIgnore);
	setData("Advanced Montage", advMon);
	setData("Montage Border", bSize);
}

function montageApply(){
	// Use scalebar
	useScale = getData("Use Scalebar");
	// Scale bar position
	scalePos = getData("ScaleBar Position");
	// scale bar size
	scaleLength = getData("ScaleBar Length");
	// scalebar height
	scaleHeight = getData("ScaleBar Height");
	// nrows ncols
	mRows = getData("Montage Rows");
	mCols = getData("Montage Cols");
	// position of composite
	cPos = getData("Channel Merge Position");
	// border size
	bSize = getData("Montage Border");

	//Ignore LUT colors and keep gray
	isIgnore = getBool("Ignore LUTs except for Merged");
	
	// border color
	bColor = getData("Montage Border Color");

	advMon = getData("Advanced Montage");

	atImage = getData("Scalebar At");

	if(useScale == "") {
		showMessage("Montage Settings not set.");
		exit();
	}
	
	if (advMon != "") {

		Stack.setDisplayMode("composite");
		run("Duplicate...", " duplicate channels");
		name = getTitle();
		run("Split Channels");
		
		
		// Get the number of separate images we need to create
		monImages = split(advMon, ", ");
		finalImages = newArray(monImages.length);
		c =  monImages.length-1;
		for(i=0; i< monImages.length; i++) {
			channels = split(monImages[i], "+");
			str = "";
			for (ch=0; ch<channels.length; ch++) {
				str += "c"+(ch+1)+"=[C"+channels[ch]+"-"+name+"] ";
			}
			for (k=ch-1;k<7;k++) {
				str += "c"+(k+1)+"=[*None*] ";
			}
			print("Position "+(i+1)+"String: "+str);
			if(channels.length>1) {
				run("Merge Channels...", str+"create keep");
			} else {
				selectImage("C"+monImages[i]+"-"+name);
				run("Duplicate...", "title=[temp]");
			}
			run("RGB Color");
			rename("Position "+(i+1));
			finalImages[i] = "Position "+(i+1);
		}

		
		for(i=1; i< monImages.length; i++) {
			// Make Montage
			selectImage(finalImages[i]);
			
			run("Copy");
			close();
			selectImage(finalImages[0]);
			run("Add Slice");
			run("Paste");
		}
		

		
	} else {
		getDimensions(x,y,c,z,t);
			
		Stack.setDisplayMode("composite");
		name = getTitle();
		run("Duplicate...", " duplicate channels");
		name2 = getTitle();
		// Make RGB
		run("Stack to RGB");
		rgbName = getTitle();
	
		//Split the other images
		selectImage(name2);
		run("Split Channels");
		
		//Make each an RGB image
		RGBnames = newArray(c);
		for (i=1;i<=c; i++) {
			if (cPos == "First") {
				k = i;
			} else {
				k=c-i+1;
			}
				selectImage("C"+k+"-"+name2);
				if(isIgnore) { 
					getMinAndMax(min, max);
					run ("Grays");
					setMinAndMax(min, max);
				}
				
				run("RGB Color");
				run("Copy");
				close();
				selectImage(rgbName);
				run("Add Slice");
				run("Paste");
	
		}
	
		// Make the RGB first or last
		if (cPos == "Last") {
			run("Reverse");
		}
	}
	//Set the scale
	if (useScale=="Yes") {
		if (atImage=="") {
			run("Scale Bar...", "width="+scaleLength+" height="+scaleHeight+" font=9 color=White background=None location=["+scalePos+"] bold hide");
		} else {
			setSlice(parseInt(atImage));
			run("Scale Bar...", "width="+scaleLength+" height="+scaleHeight+" font=9 color=White background=None location=["+scalePos+"] bold hide");
		}
	}

	if (mRows == "As Row") {
		run("Make Montage...", "columns="+(c+1)+" rows=1 scale=1.0 border="+bSize);
	} else if (mCols == "As Column") {
		run("Make Montage...", "columns=1 rows="+(c+1)+" scale=1.0 border="+bSize);
	} else {
	// Assemble the stack for 
	run("Make Montage...", "columns="+mCols+" rows="+mRows+" scale=1.0 border="+bSize);
	}

	
	rename(name+"_Montage");
	
	selectWindow(name+"_Montage");
	
}



</codeLibrary>
<text><html><font size=1 color=#66666f>
<text><html><font size=3 color=#66666f> Lookup Table Modification
<line>
<button>
label= Channels LUT Selection
icon=noicon
arg=<macro>
channelsLUTSelection();
</macro>
</line>
<line>
<button>
label= Apply to Image
icon=noicon
arg=<macro>
channelsLUTApply();
</macro>
<button>
label= Apply To Folder...
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
		
		channelsLUTApply();
		
		saveAs("Tiff", savingDir+fileNameNoExt+"_selectedLUT.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}
</macro>
</line>
<text><html><font size=1 color=#66666f>
<text><html><font size=3 color=#66666f> Brightness & Contrast Modification
<line>
<button>
label= B&C Selection
icon=noicon
arg=<macro>
brightnessAndContrastSetting();
</macro>
</line>
<line>
<button>
label= Apply to Image
icon=noicon
arg=<macro>
brightnessAndContrastSettingApply();
</macro>
<button>
label= Apply To Folder...
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
		
		brightnessAndContrastSettingApply();
		
		saveAs("Tiff", savingDir+fileNameNoExt+"_BC.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}
</macro>
</line>
<text><html><font size=1 color=#66666f>
<text><html><font size=3 color=#66666f> Montage Settings
<line>
<button>
label= Montage Options
icon=noicon
arg=<macro>
montageOptions();
</macro>
</line>
<line>
<button>
label= Apply to Image
icon=noicon
arg=<macro>
setBatchMode(true);
montageApply();
setBatchMode(false);
</macro>
<button>
label= Apply To Folder...
icon=noicon
arg=<macro>
dir = getDirectory("Please , select a folder containing images");			//get the folder
file = getFileList(dir);
savingDir = dir+"saving_montage"+File.separator;
File.makeDirectory(savingDir);

for (i=0; i<lengthOf(file); i++) {
	if (isImage(file[i])){
		open(dir+file[i]);						// open the image
		fileNameNoExt = File.nameWithoutExtension;			// get the file name without the extension
		
		montageApply();
		
		saveAs("Tiff", savingDir+fileNameNoExt+"_montage.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}
</macro>
</line>
<text><html><font size=1 color=#66666f>
<text><html><font size=2.5 color=#00000f>All at once...
<line>
<button>
label= ... on the current image
icon=noicon
arg=<macro>
setBatchMode(true);
checkLUT = getData("color channel 1 using LUT");
checkBC = getData("min ch1");
checkMontage = getData("Channel Merge Position");

//Check process to do
if(checkLUT!="") {
	
	channelsLUTApply();				// action to perform, HERE!
}
if(checkBC!="") {
	
	brightnessAndContrastSettingApply();
}
if(checkMontage!="") {
	
	montageApply();
}
setBatchMode(false);
</macro>

<button>
label= ... on a folder
icon=noicon
arg=<macro>
dir = getDirectory("Please , select a folder containing images");	//get the folder
setBatchMode(true);
file = getFileList(dir);
savingDir = dir+"Processed"+File.separator;
File.makeDirectory(savingDir);

checkLUT = getData("color channel 1 using LUT");
checkBC = getData("min ch1");
checkMontage = getData("Channel Merge Position");


for (i=0; i<lengthOf(file); i++) {
	if (isImage(file[i])){
		open(dir+file[i]);							// open the image
		fileNameNoExt = File.nameWithoutExtension;	// get the file name without the extension
		process="";

		
		//Check process to do
		if(checkLUT!="") {
			process+="_LUT";
			channelsLUTApply();				// action to perform, HERE!
		}
		if(checkBC!="") {
			process+="_BC";
			brightnessAndContrastSettingApply();
		}
		if(checkMontage!="") {
			process+="_Montage";
			montageApply();
		}
		
		
		
		print(savingDir+fileNameNoExt+process+".tif");
		saveAs("Tiff", savingDir+fileNameNoExt+process+".tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
	setBatchMode(false);
}
</macro>
</line>