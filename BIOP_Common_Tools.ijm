
// Action Bar description file : Oli & Romain ActionBar
//run("Action Bar","/plugins/ActionBar/test/Common_Tools.ijm");

sep = File.separator;
// Install the BIOP Library
call("BIOP_LibInstaller.installLibrary", "BIOP"+sep+"BIOPLib.ijm");


run("Action Bar","jar:file:BIOP/BIOP_Common_Tools.jar!/BIOP_Common_Tools.ijm");

exit();

<codeLibrary>

	function toolName() {
		return "Common Tools";
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// specific library
	function closeAll(type) { 
		if (type=="nonimage") {
			liste = getList("window.titles");
			if (liste.length==0)
	     			print("No non-image windows are open");
	 		else {
			     print("Non-image windows:");
				for (i=0; i<liste.length; i++) {
					
					//print(liste[i]);
					selectWindow(liste[i]);
					if (liste[i] != "Common Tools" && !endsWith(liste[i],".ijm"))
						run("Close");
				}
			}
		} 
		if(type=="image"){
			while (nImages!=0) {
		        	selectImage(1);
		        	close();
			}
		}
	}

	//function: Apply "iterations" median filter(s) with a size pixels radius, to the selected image
	function medFilter(iterations, size) {
		for(k=0; k<iterations;k++) {
			run("Median...", "radius="+size);
		}
	}
	
</codeLibrary>

<startupAction>
//loadParameters(false);
</startupAction>


<text><html><font size=FS color=#0C2981>Parameters

</line>
<line>
<button>
label=Save Parameters
arg=<macro>
saveParameters();
</macro>

<button>
label=Load Parameters
arg=<macro>
loadParameters();
</macro>
</line>

<text><html><font size=3 color=#0C2981>System Clipboard
<line>
<button>
label=Copy to System
icon=noicon
arg=<macro>
if(selectionType() == -1) {
	run("Select All");
}
run("Copy to System");
</macro>

<button>
label=Paste From System
icon=noicon
arg=<macro>
run("System Clipboard");
</macro>

</line>
<text><html><font size=3 color=#0C2981>Duplicate...
<line>
<button>
label= ... current
icon=noicon
arg=<macro>
name = getTitle();
run("Duplicate...", "title=["+name+" Copy]"); 
</macro>

<button>
label=... all
icon=noicon
arg=<macro>
name = getTitle();
getDimensions(x,y,c,z,t);
run("Duplicate...", "title=["+name+" Copy] duplicate channels=1-"+c+" slices=1-"+z+" frames=1-"+t) ; 
</macro>

<button>
label=... specify
icon=noicon
arg=<macro>
run("Duplicate...");
</macro>
</line>	//end of a line

<text><html><font size=3 color=#0C2981>Selection
<line>
<button>
label=Create 
icon=noicon
arg=<macro>
run("Create Selection");
</macro>

<line>
<button>
label=Restore 
icon=noicon
arg=<macro>
run("Restore Selection");
</macro>

</line>	//end of a line
<text><html><font size=3 color=#0C2981>Macro tool
<line>
<button>
label= Code Bar from ActionBar 
icon=noicon
arg=<macro>
run("Action Bar","jar:file:action_bar202.jar!/Code_Bar.txt");;
</macro>



</line>	//end of a line

<text><html><font size=3 color=#0C2981>Lookup Tables

<line>	//start of a line
<button>
label=Channels Tool 
icon=noicon
arg=<macro>
run("Channels Tool...");
</macro>

<button>
label=Gray
icon=noicon
arg=<macro>
run("Grays");
</macro>
</line> //end of a line

<line> //start of a line
<button>
label=Red
icon=noicon
arg=<macro>
run("Red");
</macro>

<button>
label=Green
icon=noicon
arg=<macro>
run("Green");
</macro>

<button>
label=Blue
icon=noicon
arg=<macro>
run("Blue");
</macro>
</line> //end of a line

<line> //start of a line
<button>
label=HiLo
icon=noicon
arg=<macro>
run("HiLo");
</macro>

<button>
label=Fire
icon=noicon
arg=<macro>
run("Fire");
</macro>




</line>	//end of a line 	: Channels tool



<text><html><font size=2 color=#66666f> Channels edition (sub-bar)
<line>	//start of a line 	: Channels LUT
<button>
label=Channel Edition Tools
icon=noicon
arg=<macro>
run("Action Bar","jar:file:BIOP"+File.separator+"BIOP_Common_Tools.jar!/channelManipToolsSubBar.ijm");
</macro>
</line>

<text><html><font size=3 color=#0C2981>Image Manipulation
<line>
<button>
label=Threshold
icon=noicon
arg=<macro>
run("Threshold...");
</macro>

<button>
label=B/C
icon=noicon
arg=<macro>
run("Brightness/Contrast...");
</macro>

<button>
label=To RGB
icon=noicon
arg=<macro>
getVoxelSize(width, height, depth, unit)

run("RGB Color");
run("Properties...", "unit=&unit pixel_width=&width pixel_height=&height voxel_depth=&depth");
</macro>

</line>


<line>

<button>
label=Merge Images
icon=noicon
arg=<macro>
n = nImages;

images = newArray(n+1);
images[0] = "*None*";
for (i=1; i<=n; i++) {
	selectImage(i);
	name = getTitle();
	images[i] = name;
}

Dialog.create("Color Combine");

for (i=1; i<=7; i++) {
	Dialog.addChoice("Channel "+i, images, images[0]);
}

Dialog.show();
params = "";
for (i=1; i<=7; i++) {
	I = Dialog.getChoice();
	if (I!="*None*")
		params = params+"c"+i+"="+I+" ";
}
run("Merge Channels...", params+"create keep");
run("Channels Tool... ");

</macro>
</line>
<line>
<button>
label=Add Channel to Hyperstack
icon=noicon
arg=<macro>
idTarget = getImageID();
nameTarget = getTitle();
getDimensions(x,y,c,z,t);

//Select image to add to.
nI = nImages;
imgList = newArray(nI-1);
nt = 0;
for(i=0;i<nI; i++) {
	selectImage(i+1);
	id = getImageID();
	getDimensions(x1,y1,c1,z1,t1);
	if (id != idTarget && x1 ==x && y1 == y && z1 == z && t1 ==t && c>1) {
		imgList[nt] = getTitle();
		nt++;
	}
}
if (nt !=0) {
	Dialog.create("Choose Image to add");
	Dialog.addChoice("Image", imgList);
	Dialog.addSlider("Channel Position",1,c+1,c+1);
	Dialog.show();
	img = Dialog.getChoice();
	cPos = Dialog.getNumber();
	// Add the channels...
	// 1. Find how many channels are being added.
	selectImage(img);
	getDimensions(x1,y1,c1,z1,t1);

	// First duplicate the original
	selectImage(idTarget);
	
	run("Duplicate...", "title="+nameTarget+"_Copy duplicate channels=1-"+c+" slices=1-"+z+" frames=1-"+t);
	setBatchMode(true);
	for (ch=1; ch<=c1; ch++) {
		selectImage(nameTarget+"_Copy");
 		Stack.setChannel(cPos-1+ch-1);
 		run("Add Slice", "add=channel");

 		// Now loop over the time and the Zs
 		for (ti=1; ti<=t; ti++) {
 			for(zi=1; zi<=z; zi++) {
 				selectImage(img);
 				Stack.setPosition(ch,zi,ti);
 				run("Copy");
 				selectImage(nameTarget+"_Copy");
 				Stack.setPosition(cPos-1+ch,zi,ti);
 				run("Paste");
 				
 			}
 		}
	}
	// 1. go to the desired stack position
	setBatchMode(false);
} else { showMessage("No images matching the same dimensions"); }
 	
</macro>




</line>
<line>
<button>
label=Multi-Median
icon=noicon
arg=<macro>
getDimensions(x,y,c,z,t);
name = getTitle();
Dialog.create("Romain's Multi-Median(CC-by) Filter");
Dialog.addNumber("Number of Iterations", 5,0,3,"");
Dialog.addNumber("Median Filter Size", 2, 0,3,"Pixels");

Dialog.show();

iterations = Dialog.getNumber();
size = Dialog.getNumber();
run("Duplicate...", "title=["+name+" + "+iterations+" MedFilters of "+size+" Pixels] duplicate channels=1-"+c+" slices=1-"+z+" frames=1-"+t) ; 
medFilter(iterations, size);
</macro>

<button>
label=FeatureJ
icon=noicon
arg=<macro>
run("FeatureJ Panel");
</macro>
</line>

<line>
<button>
label=Binary
icon=noicon
arg=<macro>
run("Options...");
</macro>

<button>
label=Watershed
icon=noicon
arg=<macro>
run("Watershed");
</macro>

</line>
<text><html><font size=3 color=#0C2981> Close & cleanUp


<line>
<button>
label= Images
icon=noicon
arg=<macro>
closeAll("image");
</macro>

<button>
label= Non-Images
icon=noicon
arg=<macro>
closeAll("nonimage");
</macro>
</line>

<line>
<button>
label= All
icon=noicon
arg=<macro>
closeAll("image");
closeAll("nonimage");
</macro>

<line>
<button>
label= All but Current Image
icon=noicon
arg=<macro>
close("\\Others");
</macro>
</line>	

<line>
<button>
label=Reset ROI Manager
icon=noicon
arg=<macro>
roiManager("Reset");
</macro>
<button>
label=Clear Results
icon=noicon
arg=<macro>
run("Clear Results");
</macro>
</line>