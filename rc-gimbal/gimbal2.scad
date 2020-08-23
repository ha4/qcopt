
wall=2;// thin elements wall
dstick=3; // outer dsitck diameter
daxle=2; // rotating pin diameter
tol=0.2; // movable elements tolarance luft
dmnt=9; // axis exit hub diameter
// general axis prarm
laxis=36;
// central hub param
dcros=7.5; // internal axis diameter
hcros=19; // internal axis length
wcros=5; // gimbal cross wheel
// yaxis and cover param
dcap=24; // cap diameter
lcap=30; // cap axial lenght
capcut=2; // ycap cur
wsize=12; // stick window size


let(a=$t*360,r=30,
    m=r*sin(a*2)*sqrt(2)/2,
    x=cos(a)-sin(a),y=sin(a)+cos(a))
{
    rotate([x*m,0])ycap();
    *rotate([0,y*m])xcov();
    *rotate([x*m,y*m])
    { 
        color([.6,.6,.6])cylinder(d=dstick,h=40,$fn=23);
        cros();
    }
}

module z(offs) translate([0,0,offs]) children();
module rx(angle) rotate([angle,0,0]) children();
module ry(angle) rotate([0,angle,0]) children();
module rz(angle) rotate([0,0,angle]) children();

module cros() {
    for(j=[[90,0],[0,90]]) rotate(j)
    cylinder(d=dcros,h=hcros,center=true,$fn=30);
    rotate([90,0]) intersection() {
      cylinder(d=hcros,h=wcros,$fn=40,center=true);
      sphere(d=hcros,$fn=66);
    }
}

module ycap() {
    omnt=lcap/2-wall;
    imnt=dcap/2-wall;
    idcap=dcap-wall*2;
    ilcap=lcap-wall*2;
    hub=laxis/2-omnt;
    module outer() intersection() {
        ry(90)cylinder(d=dcap,h=lcap,center=true,$fn=50);
        z(-capcut) cube([lcap,dcap,dcap],center=true);
    }
    module inner() {
      intersection() {
      ry(90)cylinder(d=idcap,h=ilcap,center=true,$fn=50);
      z(-capcut) cube([lcap,dcap,idcap],center=true);
      }
      z(-dcap/2)cube([lcap+1,dcap+1,dcap],center=true);
      hull() for(x=[-1,1]*wsize/2) translate([x,0,0])
            cylinder(d=wcros+tol,h=dcap,$fn=30);
      for(y=[90,270]) rx(y) z(imnt-wall) 
        cylinder(d=dcros+tol*4,h=wall,$fn=30);
    }

    difference() { outer(); inner(); }
    for(x=[0,180]) rz(x) ry(90)z(omnt) hull() { 
        cylinder(d=dmnt,h=hub,$fn=30);
        translate(-[dcap+dmnt,0,0]/4)cylinder(d1=wall,d2=0,h=wall);
    }
    intersection() { outer(); 
        for(y=[90,270]) rx(y) z(imnt) 
        cylinder(d=dcros,h=wall,$fn=30);
    }
}

module xcov() {
    omnt=lcap/2-wall;
    imnt=dcap/2-wall;
    hub=laxis/2-omnt;

    module j1(th=wall)
      rx(-90) z(omnt) cylinder(d=dmnt,h=th,$fn=30);
    module j2()
      translate([0,omnt*2+wall,-dmnt/.8-wall/.8]/2)
      ry(90) cylinder(d=wall,center=true,h=dmnt,$fn=30);
    module j1i()
      ry(-90) z(imnt)  cylinder(d=dcros,h=wall,$fn=30);
    module j2i()
      translate([-imnt*2-wall,0,-dcros]/2)
      rx(90) cylinder(d=wall,center=true,h=dcros,$fn=30);
    module j3(k=-90) rz(k) 
      translate(-[omnt,0,omnt+dmnt]/2)
      rx(90) cylinder(d=wall,center=true,h=dmnt,$fn=30);

    for (y=[0,180]) hull() rz(y){ j1(); j2(); }
    for (y=[0,180]) hull() rz(y){ j2(); j3(); }

    for (y=[0,180]) hull() rz(y){ j1i();j2i();}
    for (y=[0,180]) hull() rz(y){ j2i();j3(0);}
    hull() for (y=[0,180]) rz(y){ j3(); j3(0);}
    for(y=[0,180]) rz(y) j1(hub);    
}
