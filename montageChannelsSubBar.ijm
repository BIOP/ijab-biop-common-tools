
<codeLibrary>
	function toolName() {
		return "Common Tools";
	}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// specific library

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
	useScale = getDataD("Use Scalebar", "Yes");
	// Scale bar position
	scalePos = getDataD("ScaleBar Position", "Lower Right");
	// scale bar size
	scaleLength = getDataD("ScaleBar Length", 100);
	// scalebar height
	scaleHeight = getDataD("ScaleBar Height", 5);
	// nrows ncols
	mRows = getDataD("Montage Rows", "As Row");
	mCols = getDataD("Montage Cols", 1);
	// position of composite
	cPos = getDataD("Channel Merge Position", "First");
	// border size
	bSize = getDataD("Montage Border", 0);

	//Ignore LUT colors and keep gray
	isIgnore = getBool("Ignore LUTs except for Merged");
	
	// border color
	bColor = getDataD("Montage Border Color", "White");

	advMon = getDataD("Advanced Montage", "");

	atImage = getDataD("Scalebar At", "");
	
	
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
				if(isIgnore) { run ("Grays"); }
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



<startupAction>
//loadParameters(false);
</startupAction>

<text><html><font size=2 color=#66666f> Please define the options for the channels montage and apply
<text><html><font size=2 color=#66666f> on the current image or select a fodler containing images.
<line>
<button>
label=Montage Options
icon=noicon
arg=<macro>
montageOptions();
</macro>

</line>
<text><html><font size=2.5 color=#00000f>Montage Apply...
<line>

<button>
label = ...on current image
icon = noicon
arg =<macro>
setBatchMode(true);
montageApply();
setBatchMode(false);
</macro>

<button>
label=...on a folder
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
		
		montageApply();			// action to perform, here

		saveAs("Tiff", savingDir+fileNameNoExt+"_montage.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}	


</macro>
</line>
