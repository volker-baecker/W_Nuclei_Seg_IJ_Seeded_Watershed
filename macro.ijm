setBatchMode(true);

LAP_RAD = 5;
PROEMINENCE = 0.5;

// Path to input image and output image (label mask)
inputDir = "/dockershare/666/in/";
outputDir = "/dockershare/666/out/";

// Functional parameters
LAP_RAD = 5;
PROEMINENCE = 0.5;

arg = getArgument();
parts = split(arg, ",");

for(i=0; i<parts.length; i++) {
	nameAndValue = split(parts[i], "=");
	if (indexOf(nameAndValue[0], "input")>-1) inputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "output")>-1) outputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "radius")>-1) LAP_RAD=nameAndValue[1];
	if (indexOf(nameAndValue[0], "proeminence")>-1) PROEMINENCE=nameAndValue[1];
}

images = getFileList(inputDir);

for(i=0; i<images.length; i++) {
	image = images[i];
	if (endsWith(image, ".tif")) {
		// Open image
		open(inputDir + "/" + image);
		wait(100);
		// Processing
		segmentNuclei(LAP_RAD, PROEMINENCE);
		// Export results
		save(outputDir + "/" + image);
		// Cleanup
		run("Close All");
	}
}
run("Quit");
		
function segmentNuclei(lapRad, proeminence) {	
	inputTitle = getTitle();
	inputID = getImageID();
	run("FeatureJ Laplacian", "compute smoothing="+lapRad);
	run("Find Maxima...", "prominence="+proeminence+" light output=[Segmented Particles]");
	damsTitle = getTitle();
	selectImage(inputID);
	setAutoThreshold("Yen dark");
	run("Analyze Particles...", "size=50-Infinity show=Masks clear in_situ");
	run("Fill Holes");
	imageCalculator("AND", inputTitle, damsTitle);
	run("Analyze Particles...", "size=50-Infinity show=[Count Masks] clear in_situ");
	run("3-3-2 RGB");
	close("\\Others");
}