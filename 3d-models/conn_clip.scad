mirror([0,0,0]) quad();
mirror([1,0,0]) quad();
mirror([0,1,0]) quad();
mirror([0,1,0]) mirror([1,0,0]) quad();

%cube([2,20,10],center=true);

module quad() {
    cube([2.5,1.9,4]);
    hull() {
        translate([2.5,0,0]) cylinder(r=1.5/2,h=10,$fn=12);
        translate([2.5,3,0]) cylinder(r=1.5/2,h=10,$fn=12);
    }
    hull() {
        translate([2.5,3,0]) cylinder(r=1.5/2,h=10,$fn=12);
        translate([1.5,6,0]) cylinder(r=1.5/2,h=9,$fn=12);
    }
}