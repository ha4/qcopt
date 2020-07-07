//import(file="vtx_antenna_mount_universal_27mm.stl");
dis=23; // 27 23
wid=20; // 23 20
dep=6.1;
indeph=3.4;
hig=13;
ang=45;
htot=20;

r=7;
rc=2.7;
corr=1.3;

difference() {
    union() {
       for(c=[0,1]) mirror([c,0,0])
           { stand(); bevel(); }
       bridge();
    }
    smtdrill();
    mnthole();
    translate([-dis/2,-dis/2,htot])cube([dis,dis,dis]);
}

module j4(i) let(a=r-r*cos(i), b=r-r*sin(i)) intersection()
    { stand(b);  bridge(a); }
module bevel() 
    for(i=[0:5:90]) hull() {j4(i); j4(i+5); }

module smtdrill(hp=10,hm=10,do=5.5,w=12.5,w2=16,h=5.5)
    translate([0,0,htot+corr])
    rotate([ang,0,0])
    translate([0,-indeph,-hig/2]) rotate([-90,0,0]) {
    translate([0,0,-.1])cylinder(d=do,h=hp+.1,$fn=60);
    dh=w2-w;
    hull() {
        translate(-[w/2,h/2,hm]) cube([w,h,hm]);
        translate(-[w2/2,(h-dh)/2,hm]) cube([w2,h-dh,hm]);
    }
    translate(-[0,0,hm]) linear_extrude(height=hm,convexity=6)
        minkowski() {
            rotate([0,0,30])circle(d=6.91,$fn=6);
            circle(r=1,$fn=40);
    }
}

module stand(dx=0) 
 translate([-dis/2,0,0]) {
    hull(){
    translate([-1,0,0]) cylinder(d=8+dx,h=htot,$fn=60);
    translate([1.5,-1.5,0]) cylinder(d=5+dx,h=htot,$fn=40);
    translate([1.5,+1.5,0]) cylinder(d=5+dx,h=htot,$fn=40);
    }
 }

//cuber([wid,dep,hig],$fn=40);
//#cube([wid,dep,hig]);

module cuber(c,r=2.5)
hull() {
    translate([r,r,r]) sphere(r=r);
    translate([r,c.y-r,r]) sphere(r=r);
    translate([r,r,c.z-r]) sphere(r=r);
    translate([r,c.y-r,c.z-r]) sphere(r=r);
    translate([c.x-r,r,r]) sphere(r=r);
    translate([c.x-r,c.y-r,r]) sphere(r=r);
    translate([c.x-r,r,c.z-r]) sphere(r=r);
    translate([c.x-r,c.y-r,c.z-r]) sphere(r=r);
}

module bridge(dx=0)
 translate([0,0,htot+corr])
 rotate([ang,0,0])
 translate(-[wid/2+dx/2,dep+dx/2,hig+dx/2]) 
  cuber([wid+dx,dep+dx,hig+dx],r=rc,$fn=40);
    
module mnthole(diam=5.1){
for(c=[-dis,dis]/2) translate([c,0,-.5])
    cylinder(d=diam,h=htot+1,$fn=90);
}

