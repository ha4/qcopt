module csrc() translate([0,0,0])
scale(1)rotate([0,0,0])translate([-2.5,10+37.5,0])import(file="concave_footstop.stl",convexity=10);

mt=1.625*25.4;
//#for(m=[-2,2]) translate([mt/m,0]) cylinder(d=6,h=20,$fn=35);


deep1=20;
deep3=12;

H1=85;
Z1f=12.5;
Z1b1=3;
Z1b=13.5;

H2=28.5;
Z2f=7.5;
Z2b1=16.5;
Z2b=21.5;

len3=37.5;
R3=10;
module base() {
    translate([-H1/2,-Z1f,0]) cube([H1,Z1f+Z1b,deep1]);
    translate([-H2/2,-Z2f,0]) cube([H2,Z2f+Z2b,deep1]);
    for(k=[0,1])mirror([k,0])
    translate([-mt/2,0,0]) hull() {
        cylinder(r=R3,h=deep3);
        translate([0,len3,0])cylinder(r=R3,h=deep3);
    }
}

Rb1=10;
Rb2=8;
Db2=mt-R3*2;
Sb2=0.4;

module bevel() {
    for(k=[0,1])mirror([k,0]) translate([-mt/2,0]) {
        translate([-Rb1-R3,Rb1+Z1b1,-1]) // bevel xy
            cylinder(r=Rb1,h=deep1+2);
        translate([0,Rb1+Z1b1,Rb1+deep3]) // bevel z
            rotate([0,-90,0])cylinder(r=Rb1,h=H1/2-mt/2+1);
        translate([-R3,-Z1f-1,deep3]) // bolt path
            cube([R3*2,Z1f+Z2b+2,deep1-deep3+1]);
        hull() for(y=[0,len3])  // bolt slot
            translate([0,y,-1]) cylinder(d=6,h=deep3+2,$fn=30);
        for(y=[0:10:30]) translate([0,y+4,deep3]) cube([14,2,4],center=true);
    }
    translate([0,Z2b1+Rb2,Rb2+deep3]) // bevel z #2
        rotate([0,90,0])cylinder(r=Rb2,h=H2+1,center=true,$fn=30);
    translate([0,1+Z2b1+Db2/2*Sb2,-1]) // bevel xy #2
        scale([1,Sb2])cylinder(d=Db2,h=deep1+1,$fn=40);
}

Rc=64; Sc=0.8;
module concave() {
    for(k=[0,1])mirror([k,0])
    translate([-H2/2,-Z2f-Rc*Sc,-1])scale([1,Sc]) {
        cylinder(r=Rc,h=deep1+2,$fn=320);
        for(a=[0:6]) rotate([0,0,a*4.3+1])
            translate([0,Rc,2+1]) cylinder(d=3,h=deep1,$fn=20);
    }
    translate([-H2/2,-Z1f-1,-1])
        cube([H2,Z1f-Z2f+1,deep1+2]);
    for(a=[-2:2]) translate([a*5.1,-Z2f,2])
        cylinder(d=3,h=deep1,$fn=20);

}

difference() {
    base();
    bevel();
    concave();
}

//#csrc();
