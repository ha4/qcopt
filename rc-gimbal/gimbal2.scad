
let(a=$t*360,r=30,
    m=r*sin(a*2)*sqrt(2)/2,
    x=cos(a)-sin(a),y=sin(a)+cos(a))
{
    rotate([x*m,0])ycap();
    rotate([0,y*m])xcov();
    rotate([0,0])rotate([x*m,y*m])
    { 
        color([.6,.6,.6])cylinder(d=3,h=40,$fn=23);
        cros();
    }
}

module cros() {
    for(j=[[90,0],[0,90]]) rotate(j)
    cylinder(d=7.5,h=20,center=true,$fn=30);
    rotate([90,0])
    cylinder(d=20,h=5,$fn=40,center=true);
}

module ycap() {
    wall=2;
    omnt=26/2;
    imnt=25/2-wall;
    di=7.5;
    dmnt=9;
    cut=2;
    module outer() intersection() {
        rotate([0,90,0])
            cylinder(d=25,h=30,center=true,$fn=50);
        translate([0,0,-cut])
            cube([30,25,25],center=true);
    }
    module inner() {
        intersection() {
            rotate([0,90,0])
               cylinder(d=25-wall*2,h=30-wall*2,
                    center=true,$fn=50);
        translate([0,0,-cut])
            cube([30,25,25-4],center=true);
        }
        translate([0,0,-25/2])cube([40,25,25],center=true);
        hull() for(x=[-7,7]) translate([x,0,0])
            cylinder(d=5.1,h=30,$fn=30);
    }
    difference() { outer(); inner(); }
    for(x=[90,270]) rotate([0,x,0]) translate([0,0,omnt]) 
        cylinder(d=dmnt,h=5,$fn=30);
    for(y=[90,270]) rotate([y,0,0]) translate([0,0,imnt]) 
        cylinder(d=di,h=2,$fn=30);
}

module xcov() {
    wall=2;
    omnt=26/2;
    imnt=25/2-wall;
    di=7.5;
    dmnt=9;
    module j1(th=wall)
        rotate([-90,0,0])
        translate([0,0,omnt]) 
            cylinder(d=dmnt,h=th,$fn=30);
    module j2()
        translate([0,omnt*2+wall,-dmnt/.8-wall/.8]/2)
        rotate([0,90,0])
            cylinder(d=wall,center=true,h=dmnt,$fn=30);
    module j1i()
        rotate([0,-90,0])
        translate([0,0,imnt]) 
            cylinder(d=di,h=wall,$fn=30);
    module j2i()
        translate([-imnt*2-wall,0,-di]/2)
        rotate([90,0,0])
            cylinder(d=wall,center=true,h=di,$fn=30);
    module j3(k=1)
        translate(k==1?-[0,-omnt,omnt+dmnt]/2:-[omnt,0,omnt+dmnt]/2)
        rotate(k==1?[0,90]:[90,0])
            cylinder(d=wall,center=true,h=dmnt,$fn=30);

    for (y=[0,180]) hull() rotate([0,0,y]){ j1(); j2(); }
    for (y=[0,180]) hull() rotate([0,0,y]){ j2(); j3(); }

    for (y=[0,180]) hull() rotate([0,0,y]){ j1i();j2i();}
    for (y=[0,180]) hull() rotate([0,0,y]){ j2i();j3(0); }
    hull()
        for (y=[0,180]) rotate([0,0,y]) {j3();j3(0);}
    for(y=[0,180]) rotate([0,0,y]) j1(5);
    for(y=[0,180]) rotate([0,0,y]) j1i();
    
}
