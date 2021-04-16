
*translate([0,-17,0])
scale(10.4)rotate([90,0,-90])translate([0,0,4.31])import(file="footstopredux.stl");

mt=1.625*25.4;
*for(m=[-2,2]) translate([mt/m,0]) cylinder(d=6,h=20,$fn=35);

width=90;
ewidth=2;
height=34.5;
bheight=15.5;
Dmain=137.3;
Dinner=169;
Hinner=13.13;
depth=26.415;
Mdepth=13.2;
Mrad=6;
Tdepth=1.321;
Tstep=4.648;
Tstart=49.53;
Tdia=4.6;

module innerform(dr=0)
   let(sz=Dinner,y=height,dy=Hinner)translate([0,sz/2-(y-dy)])
        rotate_extrude($fn=190) translate([sz/2-dr,0])
            square([dy,depth]);

module meinform()
    intersection() {
        let(x=width,e=ewidth,R1=4,y=height,y2=bheight) hull()
            for(x1=[-x/2+R1,x/2+e-R1],y1=[-y+R1+y2,-y+R1])
                translate([x1,y1]) cylinder(r=R1,h=27,$fn=30);
        let(y=height,sz=Dmain)translate([0,sz/2-y])cylinder(d=sz,h=depth,$fn=90);
        innerform();
        }

        
module teeth()
    let(sz=Dmain,y=height)translate([0,sz/2-y,Tdepth])
     for(n=[0:17]) rotate([0,0,-n*Tstep-Tstart]) translate([sz/2,0])
       cylinder(d=Tdia,h=depth,$fn=20);

module slot(sz,d,z) hull() 
    for(k=[0,-sz]) translate([0,k]) cylinder(d=d,h=z,$fn=30);

module mount1(dr=0)
    translate([mt/2,0])
    for(a=[0,25,-25]) rotate([0,0,a])
    slot(sz=24-(a>=0?5:0)-dr,d=(Mrad+dr)*2,z=Mdepth+dr*2);

module my()
        for(m=[0,1]) mirror([m,0,0]) children();

module slots()
     for(m=[-2,2]) translate([mt/m,-1]) {
        translate([0,0,-1])slot(sz=15,d=6,z=Mdepth+2);
        translate([0,0,Mdepth])slot(sz=15,d=14.5,z=16);
        }

module junc(w) let(R=5,a=R-R*cos(w),b=R-R*sin(w))
        intersection() { mount1(a); innerform(b); }

module bevel()
    for(i=[0:10:90-10]) 
        //hull() {
            junc(i); 
            //junc(i+15); }
    
module jhull() for(i=[0:$children-2])
    hull() { children(i); children(i+1); }

module stopper()
{    
  difference() {
    meinform();
    teeth();
    slots();
  }
  difference() {
    my() union() { mount1(); *bevel(); }
    my() slots();
  }
}
stopper();