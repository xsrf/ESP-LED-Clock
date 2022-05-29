$x = 10.5;
$y = 1.6;
$z = 13.6;

%translate([0,0,$z/2]) cube([$x,$y,$z],center=true);

difference() {
    translate([0,0,9-1]) cube([$x+2.5,$y+4,18],center=true);
    //translate([0,0,10]) cube([$x+1,$y+0.4,20],center=true);
    translate([0,0,10]) cube([$x-1.4,$y+2,20],center=true);
    hull() {
        translate([0,0,10]) cube([$x+0.5,$y-0.3,20],center=true);
        translate([0,0,10]) cube([$x-2,$y+1,20],center=true);
    }


    translate([0,0,10+$z-3]) cube([$x+0.5,$y+2,20],center=true);
    translate([-2.0,0,-5]) cylinder(r=2,h=10,$fn=6);
    translate([-2.0,0,3.5]) rotate([90,0,0]) cylinder(r=2,h=10,$fn=32);
}