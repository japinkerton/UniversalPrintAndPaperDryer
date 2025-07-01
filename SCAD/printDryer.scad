/* [Build Params] */

//Units used for paper sizing (inches or millimeters)
PAPER_UNITS = "inch"; //["inch","mm"]

//Height (smaller side) of the largest paper size to be supported.  This can be undersized slightly as the paper can overhang the dryer a bit (ex, 8 can hold 8.5x11 paper)
MAX_PAPER_HEIGHT = 8; 

//Array of the different paper widths (larger side) to be supported 
PAPER_WIDTH = [4,5,10,11];

//Amount in mm to oversize paper dimensions
PAPER_TOLERANCE =1; //[0.0:5.0]

//Maximum number of sheets to hold.  NOTE: Larger slot counts may create performance issues when slicing.
SLOT_COUNT = 75; //[5:200]

//Thickness of each sheet slot (mm)
SLOT_THICK = 1.5; //[0.5:10.0]

//Thickness of the tabs separating each slot (mm)
TAB_THICK = 1; //[0.5:5.0]

//How far each separating tab sticks out (mm)
TAB_WIDTH = 3; //[1:10]

//Thickness of the sides (mm)
SIDE_WALL_THICK = 3; //[1:10]

//Thickness of the base (mm)
BASE_THICK = 5; //[1:10]

//Width of the tabs that seat the sides to the base (mm)
BASE_TAB_WIDTH = 8; //[2:20]

//How far in to cut the chamfers on the ends of the base (mm)
BASE_CHAMFER_DIST = 0; //[0:20]

//How much to oversize the holes in the base to fit the corresponding tabs (mm)
BASE_TAB_TOLERANCE = .5; //[0.0:2.0]



/* [Advanced] */

//False will render 1 copy of each part.  True will render 2 sides and 4 base brackets.
BUILD_ALL_PARTS = false;

//Distance between each part in the render (mm)
PART_OFFSET = 10;

module buildBaseInch()
{
    maxWidth = inchToMM(max(PAPER_WIDTH));
    t= BASE_TAB_TOLERANCE;
    difference()
    {
        cube([maxWidth+(SIDE_WALL_THICK * 4)+PAPER_TOLERANCE*len(PAPER_WIDTH),BASE_TAB_WIDTH + SIDE_WALL_THICK,BASE_THICK]);
        translate([SIDE_WALL_THICK-t/2,SIDE_WALL_THICK/2,0])
        {
            cube([SIDE_WALL_THICK+t,BASE_TAB_WIDTH+t,BASE_THICK]);
        }
        for (wCount = [0:1:len(PAPER_WIDTH)-1])
        {   
            width = inchToMM(PAPER_WIDTH[wCount])+SIDE_WALL_THICK*2;
            translate([width+t/2+PAPER_TOLERANCE,SIDE_WALL_THICK/2,0])
            {
                cube([SIDE_WALL_THICK+t,BASE_TAB_WIDTH+t,BASE_THICK]);
            }
        }
        
        zeroChamfer = sqrt((BASE_TAB_WIDTH*BASE_TAB_WIDTH)/2)*2;
        translate([0,-zeroChamfer+BASE_CHAMFER_DIST,0])rotate([0,0,45])cube([BASE_TAB_WIDTH,BASE_TAB_WIDTH,BASE_TAB_WIDTH]);
        translate([maxWidth+(SIDE_WALL_THICK * 4)+PAPER_TOLERANCE*len(PAPER_WIDTH),-zeroChamfer+BASE_CHAMFER_DIST,0])rotate([0,0,45])cube([BASE_TAB_WIDTH,BASE_TAB_WIDTH,BASE_TAB_WIDTH]);
        translate([0,BASE_TAB_WIDTH + SIDE_WALL_THICK-BASE_CHAMFER_DIST,0])rotate([0,0,45])cube([BASE_TAB_WIDTH,BASE_TAB_WIDTH,BASE_TAB_WIDTH]);
        translate([maxWidth+(SIDE_WALL_THICK * 4)+PAPER_TOLERANCE*len(PAPER_WIDTH),BASE_TAB_WIDTH + SIDE_WALL_THICK-BASE_CHAMFER_DIST,0])rotate([0,0,45])cube([BASE_TAB_WIDTH,BASE_TAB_WIDTH,BASE_TAB_WIDTH]);
    }

}
module buildBaseMM()
{
    maxWidth = max(PAPER_WIDTH);
    t= BASE_TAB_TOLERANCE;
    difference()
    {
        cube([maxWidth+(SIDE_WALL_THICK * 4)+PAPER_TOLERANCE*len(PAPER_WIDTH),BASE_TAB_WIDTH + SIDE_WALL_THICK,BASE_THICK]);
        translate([SIDE_WALL_THICK-t/2,SIDE_WALL_THICK/2,0])
        {
            cube([SIDE_WALL_THICK+t,BASE_TAB_WIDTH+t,BASE_THICK]);
        }
        for (wCount = [0:1:len(PAPER_WIDTH)-1])
        {   
            width = PAPER_WIDTH[wCount]+SIDE_WALL_THICK*2;
            translate([width+t/2+PAPER_TOLERANCE,SIDE_WALL_THICK/2,0])
            {
                cube([SIDE_WALL_THICK+t,BASE_TAB_WIDTH+t,BASE_THICK]);
            }
        }
        zeroChamfer = sqrt((BASE_TAB_WIDTH*BASE_TAB_WIDTH)/2)*2;
        translate([0,-zeroChamfer+BASE_CHAMFER_DIST,0])rotate([0,0,45])cube([BASE_TAB_WIDTH,BASE_TAB_WIDTH,BASE_TAB_WIDTH]);
        translate([maxWidth+(SIDE_WALL_THICK * 4),-zeroChamfer+BASE_CHAMFER_DIST,0])rotate([0,0,45])cube([BASE_TAB_WIDTH,BASE_TAB_WIDTH,BASE_TAB_WIDTH]);
        translate([0,BASE_TAB_WIDTH + SIDE_WALL_THICK-BASE_CHAMFER_DIST,0])rotate([0,0,45])cube([BASE_TAB_WIDTH,BASE_TAB_WIDTH,BASE_TAB_WIDTH]);
        translate([maxWidth+(SIDE_WALL_THICK * 4),BASE_TAB_WIDTH + SIDE_WALL_THICK-BASE_CHAMFER_DIST,0])rotate([0,0,45])cube([BASE_TAB_WIDTH,BASE_TAB_WIDTH,BASE_TAB_WIDTH]);
    }
}

module buildBases()
{   
    if(BUILD_ALL_PARTS)
    {
        for( bCount = [0:1:3])
        {
            if(PAPER_UNITS == "inch")
                translate([0,(BASE_TAB_WIDTH + SIDE_WALL_THICK + PART_OFFSET)* bCount,0])   buildBaseInch();
            else
                translate([0,(BASE_TAB_WIDTH + SIDE_WALL_THICK + PART_OFFSET)* bCount,0])   buildBaseMM();

        }
    }
    else
    {
        if(PAPER_UNITS == "inch")
            buildBaseInch();
        else
            buildBaseMM();
    }

}
module buildSide()
{
    for ( slot = [0 :1:SLOT_COUNT-1] )
    {
        translate([0,slot*(SLOT_THICK+TAB_THICK),0])
        {
            if(PAPER_UNITS == "inch")
                buildSideSlotInch();
            else
                buildSideSlotMM();
        }
    
    }
    if(PAPER_UNITS == "inch")
        buildSideTabsInch();
    else
        buildSideTabsMM();
}
module buildSideTabsInch()
{
    maxDepth = inchToMM(MAX_PAPER_HEIGHT);

    translate([0,-BASE_THICK,0])   cube([BASE_TAB_WIDTH,BASE_THICK,SIDE_WALL_THICK]);
    translate([maxDepth-BASE_TAB_WIDTH,-BASE_THICK,0])   cube([BASE_TAB_WIDTH,BASE_THICK,SIDE_WALL_THICK]);
    translate([0,(SLOT_THICK+TAB_THICK)*SLOT_COUNT,0])   cube([BASE_TAB_WIDTH,BASE_THICK,SIDE_WALL_THICK]);
    translate([maxDepth-BASE_TAB_WIDTH,(SLOT_THICK+TAB_THICK)*SLOT_COUNT,0])   cube([BASE_TAB_WIDTH,BASE_THICK,SIDE_WALL_THICK]);

}module buildSideTabsMM()
{
    maxDepth = MAX_PAPER_HEIGHT;

    translate([0,-BASE_THICK,0])   cube([BASE_TAB_WIDTH,BASE_THICK,SIDE_WALL_THICK]);
    translate([maxDepth-BASE_TAB_WIDTH,-BASE_THICK,0])   cube([BASE_TAB_WIDTH,BASE_THICK,SIDE_WALL_THICK]);
    translate([0,(SLOT_THICK+TAB_THICK)*SLOT_COUNT,0])   cube([BASE_TAB_WIDTH,BASE_THICK,SIDE_WALL_THICK]);
    translate([maxDepth-BASE_TAB_WIDTH,(SLOT_THICK+TAB_THICK)*SLOT_COUNT,0])   cube([BASE_TAB_WIDTH,BASE_THICK,SIDE_WALL_THICK]);

}

module buildSideSlotInch()
{
        maxDepth = inchToMM(MAX_PAPER_HEIGHT);
        cube([maxDepth,SLOT_THICK+TAB_THICK,SIDE_WALL_THICK]);
        cube([maxDepth,TAB_THICK,SIDE_WALL_THICK+TAB_WIDTH]);
        translate([0,SLOT_THICK+TAB_THICK,0]) cube([maxDepth,TAB_THICK,SIDE_WALL_THICK+TAB_WIDTH]);

}

module buildSideSlotMM()
{
        maxDepth = MAX_PAPER_HEIGHT;
        cube([maxDepth,SLOT_THICK+TAB_THICK,SIDE_WALL_THICK]);
        cube([maxDepth,TAB_THICK,SIDE_WALL_THICK+TAB_WIDTH]);
        translate([0,SLOT_THICK+TAB_THICK,0]) cube([maxDepth,TAB_THICK,SIDE_WALL_THICK+TAB_WIDTH]);

}

module build()
{
    buildSide();
    
    if(BUILD_ALL_PARTS)
    {

        translate([0,(SLOT_THICK+TAB_THICK)*SLOT_COUNT+BASE_THICK*2+PART_OFFSET,0]) buildSide();
        translate([0,((SLOT_THICK+TAB_THICK)*SLOT_COUNT+BASE_THICK*2)*2+PART_OFFSET*2,0])buildBases();
    }
    else
    {
        translate([0,((SLOT_THICK+TAB_THICK)*SLOT_COUNT+BASE_THICK)+PART_OFFSET,0])buildBases();
    }
}

function inchToMM(inches) = inches*25.4;

build();