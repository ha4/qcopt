
module src() translate([0,0,0])
scale(1)rotate([0,0,0])translate([-2243.325,699.886,-19.15])import(file="footstop.stl",convexity=10);

Hz=25-11.86+10;
module form1(main=true)
{
    H1=11.86; // from mount to top
    H=25; // overall height
    R1=25;
    R2=2.5;
    R3=.6;
    S=4.04;
    hh=H-R2; // lower circle midline position
    s=sqrt(hh*(2*R1-hh))-R2; // 22.375
    if (main)hull() {
        intersection() {
            translate([0,-R1+H1])circle(r=R1,$fn=60);
            translate([-R1,H1-H+R2])square([2*R1,H-R2]);
        }
        for(j=[0,1])mirror([j,0])
            translate([-s,H1-H+R2])circle(r=R2,$fn=30);
    }
    if(!main)for(n=[-5:5]) translate([S*n,H1-H]) circle(r=R3,$fn=20);
}


module base1()
{
    H=17;
    H1=12.36;
    amain=31.86;
    SZx=44.75;
    SZy=25;
    ax=2*H/SZx*tan(24.3);
    ay=2*H/SZy*tan(2.24);
    top=19;
    ofs=13.5;
    w=30.5;
    R5=2.0;

    module extruse() 
        translate([0,-Hz])
        linear_extrude(height=H,scale=[1,1]-[ax,ay],convexity=10) 
            translate([0,Hz]) children();
    hull() 
    {
    intersection() {
      extruse() form1();
      translate([0,0,H1]) rotate([-amain,0,0])
        translate([0,0,-25])cube([50,50,50],center=true);
      }
    translate([0,-ofs+R5,top-R5])
        rotate([0,90,0])cylinder(r=R5,h=w,center=true,$fn=30);
    }
    extruse() form1(false);
}

module cutz()
{
    sz=40;
    H1=12.36;
    amain=31.86;
    Z6=H1-5;
    Y6=7.5;
    Yw=8;
    R6=10.9;
    
    intersection() {
        translate([0,-R6+Yw])cylinder(r=R6,h=sz,$fn=40);
        translate([0,0,Z6]) rotate([-amain,0,0])
            translate([0,0,sz/2])cube([sz,sz,sz],center=true);
        translate([0,sz/2-Y6,0])cube(sz,center=true);
    }
}

module bolt() {
    translate([0,0,-.1])cylinder(d=6,h=3,$fn=40);
    translate([0,0,2.4])cylinder(d=12,h=20,$fn=40);
}

//projection(cut=true) translate([0,0,-.01])
difference() {
    base1();
    bolt();
    cutz();
}
//#src();
