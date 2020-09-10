
/*
  sz=frame size, bsz=baseplate mnt size,
  dmot=motot mount size, hm=motor mount thickness,
  r1,r2=motor mnt bolts, hole=for shaft,
  ha=arm thinkness htot=baseplate heught wall=thinkness,
  wmnt=mount wall, mntx,mnty=mount set sizes,
  dmnt=baseplate mount diameterm, drill=bolts diameter, 
  crossbar=number of crossbars
 */

module co_arm(sz=125, bsz=41,
    dmot=27, hm=4, r1=16/2, r2=19/2, hole=6.5,
    ha=6, htot=18, wall=2, wmnt=5, mntx=15, mnty=14.5,
    dmnt=7.5, drill=3.2, 
    crossbars=6)
{
    asz=sz-bsz; // mount position
    mxy=[[0,-asz,htot],[mntx/2,-asz-mnty,ha],[-mntx/2,-asz-mnty,ha]];
    lcrs=asz-dmot/2-dmnt/2-wall; // crossbar length
    p1=[-dmot/2,0]; p2=[-(mntx+dmnt)/2,-asz-mnty]; //curve ref. points
    rcrs=290; // crossbar curvature radius
    pc=center2pr(p2,p1,rcrs); // curve center
    // corssbar end point
    pE=let(py=-lcrs-dmot/2,d=py-pc.y)[pc.x+sqrt(rcrs*rcrs-d*d),py];
    // arc start point
    pS=let(py=-dmot/4,d=py-pc.y)[pc.x+sqrt(rcrs*rcrs-d*d),py];
    cbrs=[18,15,12.6,13.6,8];

    module rz(a) rotate([0,0,a])children();
    function rot(p)=[p.y,p.x];

    // get circle center by two points and radiius
    function center2pr(p1,p2,r) = let(c1=(p1+p2)/2, c=p2-p1,
        n=[c.y,-c.x], nn=norm(n), h=nn/2, y=r<h?0:sqrt(r*r-h*h),
        ofs=nn==0?[0,0]:y/nn*n) c1-ofs;

    module drawarc(p1,p2,r,sqr)
      let(pc=center2pr(p1,p2,rcrs),r1=p1-pc,r2=p2-pc,
          a1=atan2(r1.y, r1.x), a2=atan2(r2.y, r2.x))
        translate(pc)rz(a1)
         rotate_extrude(angle=a2-a1,convexity=4,$fn=340)
          translate([r,0])square(sqr);

    // Viett theorem solver
    function rootof(p,q) = let(ph=p/2, D=ph*ph-q)
        [-ph+sqrt(D),-ph-sqrt(D)];
    // intersection distance on X of 45 degree ray and circle
    function c4l_xcross(pc,r,ps)=let(r1=ps.y-ps.x, r3=pc.x-pc.y,
        p=r1-pc.x-pc.y, q=(r1*r1+r3*r3-r*r)/2-(r1-pc.x)*pc.y,
        z=rootof(p,q))
        z[1];
    // make all crossbars list with intersection with circle
    function crossbars(pc,r,ps,n=1)=let(x2=c4l_xcross(pc,r,ps),
        l=x2-ps.x, ps2=ps+[l*2,0])
        n==1?[l]:let(l2=crossbars(pc,r,ps2,n-1)) concat(l*2,l2);
    // list sum by recurse
    function sumlst(lst,r=0,i=0) = 
        i<len(lst)?sumlst(lst,r+lst[i],i+1):r;
    // length of crossbars
    function lbars(r,p1,p2,ps,n) = let(pc=center2pr(p1,p2,r),
        crbs=crossbars(pc,r,ps,n)) sumlst(crbs);
    // optimize function for circle radiius
    function search_r(rmin,rmax,p1,p2,ps,lopt,n=5,eps=.01) =
        let(lmin=lbars(rmin,p1,p2,ps,n), lmax=lbars(rmax,p1,p2,ps,n),
            rmid=(rmin+rmax)/2, lmid=lbars(rmid,p1,p2,ps,n))
        abs(lopt-lmid) < eps ?  rmid :
        let(lower = lopt < lmid)
          search_r(lower?rmin:rmid,lower?rmid:rmax,p1,p2,ps,lopt);

    // single crossbar step
    module drawcrossbar(h2,full=true) translate([-h2/2,-h2/2]) {
        d=sqrt(2)*h2/2;
        rz(-45) translate([-wall/2,0])cube([wall,d,ha]);
        if (full)
        rz(-135) translate([-wall/2,0])cube([wall,d,ha]);
    }
    // crossbars chain
    module drawcrossbars(crbs,ps,i=0) {
        end = i >= len(crbs)-1;
        h = crbs[i]*(end?2:1);
        translate(ps) drawcrossbar(h,!end);
        if (!end) drawcrossbars(crbs,ps-[0,h],i+1);
    }

    // motor mount drills
    module mot_mnt() {
        cylinder(d=hole,h=hm*3,center=true,$fn=30);
        for(a=[0:90:359])rz(a+45) hull()
            for(r=[r1,r2])translate([r,0,0])
                cylinder(d=drill,h=hm*3,center=true,$fn=24);
    }
    // arm end without drills
    module arm_mnt() {
        w1=asz+drill/2+pE.y;
        cw=p2-pE;
        // standings
        for(c=mxy) translate([c.x,c.y,-c.z+ha])
            cylinder(d=dmnt,h=c.z,$fn=34);
        // horiz bar
        translate(pE-[0,w1])cube([-pE.x*2,w1,ha]);
        // arm bar
        for(m=[0,1]) mirror([m,0,0])
            translate(pE)rz(atan2(cw.y,cw.x))
                 cube([norm(cw),wmnt,ha]);
        // crossbar center
        translate([-wall/2,-dmot/2-dmnt/2-lcrs-wall+.03])
            cube([wall,lcrs+wall+dmnt/2+.06,ha]);
    }
    module arm_drills() 
        for(c=mxy) translate([c.x,c.y])
            cylinder(d=drill,h=htot*3,center=true,$fn=34);
    module drawline(p1,p2,r=1) hull() {
        translate(p1)sphere(r=1);
        translate(p2)sphere(r=1);
    }
    module arm_frame() ///for(m=[0,1]) mirror([m,0,0])
        {
        p0=[0,-dmot/2+wall/2];
        pf=[
        //rtst=search_r(50,1500,-rot(p2),-rot(p2),-rot(p0),lcrs,crossbars);
        //pc=center2pr(p1,p2,rtst);
        //crbs=crossbars(pc,rtst,ps,nnn);
        
        crbx=crossbars(-rot(pc),rcrs+1.4,-rot(p0),crossbars-1);
        echo("crossbars",crbx);
        //echo("rtst",rtst);
        c1=-rot(pc);
        u1=-rot(p0);
        r1=290;
        m=c4l_xcross(c1,r1,u1);
        echo("pc",pc);
        #translate(c1)cylinder(r=r1,$fn=400);
        drawline(u1,p0+[m,m]);
        drawarc(pE,pS,rcrs,[wall,ha]);
        drawcrossbars(crbx,p0);
    }
    // motor plate
    difference() {
        cylinder(d=dmot,h=hm,$fn=60);
        mot_mnt();
    }
    // arm mounts
    difference() {
        arm_mnt();
        arm_drills();
    }
    arm_frame();
}

co_arm();
