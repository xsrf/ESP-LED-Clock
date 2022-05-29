/*
    All parts needed for a giant RGB LED Clock

    Sorry, this code is all over the place and not well commented...
    You shouldn't use it anyways, create your own modules using 7seg.lib.scad ;)
*/
use <7seg.lib.scad> // https://github.com/xsrf/7-seg-scad
include <7seg.parameters.scad>


// Main four 7 seg frames
translate([-$dx*1.1,0,0]) segFrame(1);
translate([+$dx*1.1,0,0]) segFrame(2);

// Colon / dot Frame
dotFrame();

// Lids
translate([-$dx*1.1,$dy*1.5,0]) segLid();
translate([0,$dy*1.5,0]) dotLid();

/*
    FRAMES
*/
module segFrame($side_cutouts = 2) {
    difference() {
        // outer body (with .5mm phase)
        frame($ox,$oy,$oz);
        // digits cutout
        translate([0,0,$oz/2-11]) digit_hull($dx,$dy,$dt,1+$lightguard_separation*2,$oz-4,$skew);
        // joiner cutouts
        if($side_cutouts >= 2) mirror([1,0,0]) translate([$ox/2,0,$oz]) joiner_cutouts();
        if($side_cutouts >= 1) mirror([0,0,0]) translate([$ox/2,0,$oz]) joiner_cutouts();
        // center holes to glue down segments
        translate([tan($skew)*($dy/4-$dt/4),$dy/4-$dt/4,-0.1]) cylinder(r=($dx-$dt*2)/2-5,h=4,$fn=16);
        translate([-tan($skew)*($dy/4-$dt/4),-($dy/4-$dt/4),-0.1]) cylinder(r=($dx-$dt*2)/2-5,h=4,$fn=16);
    }
    digit_outline($dx,$dy,$dt,1,$dh,$skew);
    pcb_standoffs_seg();
    %pcb_dummy();
}

module dotFrame() {
    M = [ [ 1  , 0  , 0    ],
       [ tan($skew)  , 1  , 0  ],  // The "0.7" is the skew value; pushed along the y axis
       [ 0  , 0  , 1    ] ] ;
    difference() {
        // outer body (with .5mm phase)
        frame($odx,$oy,$oz);
        // dot cutouts
        for(i=[-1,0,1]) translate([0,i*24.8,-$oz/2]*M) cylinder(r=7,h=$oz,$fn=32);
        mirror([1,0,0]) translate([$odx/2,0,$oz]) joiner_cutouts();
        mirror([0,0,0]) translate([$odx/2,0,$oz]) joiner_cutouts();
        hull() {
            translate([0,-$oy/2-1,$dh - 4.5]) rotate([-90,0,0]) cylinder(r=9/2, h=10, $fn=32);
            translate([0,-$oy/2-1,$dh - 3]) rotate([-90,0,0]) cylinder(r=9/2, h=10, $fn=6);
        }
    }
    // dot shells
    difference() {
        for(i=[-1,0,1]) translate([0,i*24.8,0]*M) cylinder(r=7+$ot,h=$dh,$fn=32);
        for(i=[-1,0,1]) translate([0,i*24.8,-0.1]*M) cylinder(r=7,h=$dh+1,$fn=32);
    }
    // hook
    translate([0,$oy/2-12/2,0]) difference() {
        translate([0,-$ot/2,$oz/2]) cube([$odx-$ot*2,12-$ot,$oz],center=true);
        hull() {
            translate([0,-12/2,0]) cylinder(r=3,h=$oz+1,$fn=16);
            translate([0,-12/2+2,0]) cylinder(r=2,h=$oz+1,$fn=16);
        }
        hull() {
            translate([0,-12/2,0]) cylinder(r=3,h=$oz-2,$fn=16);
            translate([0,-12/2+2,0]) cylinder(r=2,h=$oz-2,$fn=16);
            translate([0,-12/2,0]) cylinder(r=2,h=$oz-2,$fn=16);
            translate([0,-12/2,0]) cylinder(r=7,h=$oz-10,$fn=16);
            translate([0,12/2,0]) cylinder(r=2,h=$oz-10,$fn=16);
        }
    }
    // power cutout
    difference() {
        $ins = 16.5;
        translate([0,-$oy/2 + $ins/2,($dh-$of+2)/2+$of]) cube([15,$ins,($dh-$of+2)],center=true); // power cutout
        translate([0,-$oy/2,$dh - 4.5]) rotate([-90,0,0]) cylinder(r=4.5/2, h=$ins, $fn=6);
        hull() {
            translate([0,-$oy/2-1,$dh - 4.5]) rotate([-90,0,0]) cylinder(r=9/2, h=$ins, $fn=32);
            translate([0,-$oy/2-1,$dh - 3]) rotate([-90,0,0]) cylinder(r=9/2, h=$ins, $fn=6);
        }
    }
    pcb_standoffs_dots();    
    %pcb_dummy_dot();
}

/*
    LIDS
*/
module segLid() {
    $ra = $or;
    $iri = 2; // lip inner radius
    difference(){
        difference() {
            union() {
                hull() for(i=[-1,1]) for(j=[-1,1]) translate([($ox/2-$ra-0.25)*i,($oy/2-$ra)*j,0]) cylinder(r=$ra,h=$lt,$fn=32); // reduce x by 0.5 so lids fit next together
                hull() for(i=[-1,1]) for(j=[-1,1]) translate([($ox/2-$iri-1-$lid_lip_inset-$ot)*i,($oy/2-$iri-1-$lid_lip_inset-$ot)*j,0]) cylinder(r=$iri+1,h=$lt+1,$fn=32);
            }
            hull() for(i=[-1,1]) for(j=[-1,1]) translate([($ox/2-$iri-$lid_lip_inset-1-$ot)*i,($oy/2-$iri-$lid_lip_inset-1-$ot)*j,$lf]) cylinder(r=$iri,h=$lt+1,$fn=32);
        }
        for(i=[-1,1]) for(j=[-1,0,1]) translate([0,$oy/4*i + j*5,0]) cube([$ox/2,2,20],center=true);
        for(i=[1,-1]) for(j=[1,-1]) translate([i*$pcb_holes_x/2,j*$pcb_holes_y/2,0]) 
            rotate([0,0,45*j*i]) lid_standoff_cutout();
    }
    for(i=[1,-1]) for(j=[1,-1]) translate([i*$pcb_holes_x/2,j*$pcb_holes_y/2,0]) 
        rotate([0,0,45*j*i]) difference() {
            lid_standoff_support();
            lid_standoff_cutout();
        }
}


module dotLid() {
    $ra = $or;
    $iri = 2; // lip inner radius
    difference(){
        difference() {
            union() {
                hull() for(i=[-1,1]) for(j=[-1,1]) translate([($odx/2-$ra-0.25)*i,($oy/2-$ra)*j,0]) cylinder(r=$ra,h=$lt,$fn=32); // reduce x by 0.5 so lids fit next together
                hull() for(i=[-1,1]) for(j=[-1,1]) translate([($odx/2-$iri-1-$lid_lip_inset-$ot)*i,($oy/2-$iri-1-$lid_lip_inset-$ot)*j,0]) cylinder(r=$iri+1,h=$lt+1,$fn=32);
            }
            hull() for(i=[-1,1]) for(j=[-1,1]) translate([($odx/2-$iri-$lid_lip_inset-1-$ot)*i,($oy/2-$iri-$lid_lip_inset-1-$ot)*j,$lf]) cylinder(r=$iri,h=$lt+1,$fn=32);
            translate([0,$oy/2 - 12.5/2,$lt/2 + $lt]) cube([$odx,12.5,$lt],center=true); // remove lip on top where 12mm hook support is
        }
        for(i=[1,-1]) for(j=[1,-1]) translate([i*$pcb_holes_dots_x/2,j*$pcb_holes_dots_y/2,0]) 
            rotate([0,0,45*j*i]) lid_standoff_cutout();
        // hook entry
        hull() {
            translate([0,$oy/2-9,-1]) cylinder(r=2,h=20,$fn=16);
            translate([0,$oy/2-18,-1]) cylinder(r=6,h=20,$fn=16);
        }
    }
    for(i=[1,-1]) for(j=[1,-1]) translate([i*$pcb_holes_dots_x/2,j*$pcb_holes_dots_y/2,0]) 
        rotate([0,0,45*j*i]) difference() {
            lid_standoff_support();
            lid_standoff_cutout();
        }
}


/*
    Support Modules
*/

module joiner_cutouts() {
    for(i=[-1,0,1]) translate([-$ot/2,i*($dy/3),0]) joiner_cutout();
}

module joiner_cutout() {
    cube([$ot+4,4.2,$oz],center=true);
    difference() {
        cube([$ot+4,16,$oz],center=true);
        cube([$ot,16,$oz],center=true);
    }
}

module lid_standoff_cutout() translate([0,0,-0.1]) {
    $rr = $pcb_holes_d/2;
    $ch = $oz;
    cylinder(r=$rr,h=$ch,$fn=16);
    difference() {
        cylinder(r=$rr+2.5,h=$ch,$fn=16);
        cylinder(r=$rr+1,h=$ch,$fn=16);
        cube([3.5,20,2*$ch],center=true);
    }
    cube([1.5,8.5,2*$ch],center=true);
}

module lid_standoff_support() {
    $rr = $pcb_holes_d/2;
    $support_height = $oz - $dh - $pcb_t + $lt;
    cylinder(r=$rr+1,h=$support_height,$fn=16);
    translate([0,0,$support_height/2]) cube([3.5,10.5,$support_height],center=true);
}

module frame($dx,$dy,$h) {
    $ra = $or;
    $ri = $ra - $ot;
    difference() {
        hull() {
            for(i=[-1,1]) for(j=[-1,1]) translate([($dx/2-$ra)*i,($dy/2-$ra)*j,0.5]) cylinder(r=$ra,h=$h-0.5,$fn=32);
            for(i=[-1,1]) for(j=[-1,1]) translate([($dx/2-$ra)*i,($dy/2-$ra)*j,0]) cylinder(r1=$ra-0.5,r2=$ra,h=0.5,$fn=32);
        }
        hull() {
            for(i=[-1,1]) for(j=[-1,1]) translate([($dx/2-$ra)*i,($dy/2-$ra)*j,$of]) cylinder(r=$ri,h=$h,$fn=32);
        }
    }
}

// Dummy for my PCB
module pcb_dummy() {
    translate([0,0,$dh]) linear_extrude(height=$pcb_t) difference() {
        polygon(points=[[36,62],[40,58],[40,-58],[36,-62],[-36,-62],[-40,-58],[-40,58],[-36,62]]);
        for(i=[1,-1]) for(j=[1,-1]) translate([i*$pcb_holes_x/2,j*$pcb_holes_y/2,0]) circle(r=2, $fn=24);
    }
}

module pcb_dummy_dot() {
    translate([0,0,$dh]) linear_extrude(height=$pcb_t) difference() {
        polygon(points=[[-12,39],[12,39],[12,-43],[-12,-43]]);
        for(i=[1,-1]) for(j=[1,-1]) translate([i*$pcb_holes_dots_x/2,j*$pcb_holes_dots_y/2,0]) circle(r=2, $fn=24);
    }
    translate([-5/2,-43-5,$dh-8]) cube([5,12,8]); // barrel jack
    translate([-8/2,-43-2,$dh-3]) cube([8,6,3]); // micro usb
}

module pcb_standoff() {
    cylinder(r=$pcb_holes_d/2+1,h=$dh,$fn=16);
    cylinder(r=$pcb_holes_d/2,h=($oz+$lf)-0.5,$fn=16);
    translate([0,0,($oz+$lf)-0.5]) cylinder(r1=$pcb_holes_d/2,r2=$pcb_holes_d/2-0.5,h=0.5,$fn=16);
}

module pcb_standoffs_seg() {
    for(i=[1,-1]) for(j=[1,-1]) translate([i*$pcb_holes_x/2,j*$pcb_holes_y/2,0]) pcb_standoff();
}

module pcb_standoffs_dots() {
    for(i=[1,-1]) for(j=[1,-1]) translate([i*$pcb_holes_dots_x/2,j*$pcb_holes_dots_y/2,0]) pcb_standoff();
}