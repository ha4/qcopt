gsz=125;
ri=12;
extra=14.5;
base=(15+7.5)/2;
rtst=98*2;//278.5;

lsz=gsz-ri-41;
ps=[ri,0];
pe=ps+[lsz,0];
p1=[0,ri];
p2=pe+[extra,base];

function center2pr(p1,p2,r) = let(c1=(p1+p2)/2, c=p2-p1, n=[c.y,-c.x], 
		nn=norm(n), h=nn/2, y=r<h?0:sqrt(r*r-h*h), ofs=nn==0?[0,0]:y/nn*n)
  c1-ofs;
function vangle(v) = atan2(v.y, v.x);
function rootof(p,q) = let(ph=p/2, D=ph*ph-q, s=sqrt(D)) [-ph+s,-ph-s];
function c4l_xcross(pc,r,ps)=let(r1=ps.y-ps.x, r3=pc.x-pc.y,
    p=r1-pc.x-pc.y, q=(r1*r1+r3*r3-r*r)/2-(r1-pc.x)*pc.y, z=rootof(p,q))
    z[1];

function crossbars(pc,r,ps,n=1)=let(x2=c4l_xcross(pc,r,ps),
    l=x2-ps.x, ps2=ps+[l*2,0])
    n==1?[l]:let(l2=crossbars(pc,r,ps2,n-1)) concat(l*2,l2);

function sumlst(lst,r=0,i=0) = i<len(lst)?sumlst(lst,r+lst[i],i+1):r;

function lbars(r,p1,p2,ps,n) = let(pc=center2pr(p1,p2,r),
    crbs=crossbars(pc,r,ps,n)) sumlst(crbs);

function search_r(rmin,rmax,p1,p2,ps,lopt,n=5,eps=.01) = let(lmin=lbars(rmin,p1,p2,ps,n), lmax=lbars(rmax,p1,p2,ps,n), rmid=(rmin+rmax)/2, lmid=lbars(rmid,p1,p2,ps,n))
    abs(lopt-lmid) < eps ? 
        rmid :
        let(lower = lopt < lmid) search_r(lower?rmin:rmid,lower?rmid:rmax,p1,p2,ps,lopt);

module drawarc(p1,p2,r,size=.5)
{
    pc=center2pr(p1,p2,r);
    a1=vangle(p1-pc);
    a2=vangle(p2-pc);
    translate(pc)
    rotate([0,0,a1])rotate_extrude(angle=a2-a1,convexity=4,$fn=140)
        translate([r,0])square([size,size],center=true);
}

module drawcrossbar(h2,full=true)
{
    hull() { cylinder(d=.5); translate([h2,h2]/2) cylinder(d=.5); }
    if (full)
    hull() { translate([h2,0])cylinder(d=.5); translate([h2,h2]/2) cylinder(d=.5); }
}

module drawcrossbars(crbs,ps,i=0) {
    end = i >= len(crbs)-1;
    h = end?crbs[i]*2:crbs[i];
    translate(ps) drawcrossbar(h,!end);
    if (!end) drawcrossbars(crbs,ps+[h,0],i+1);
}

module drawsketch()
{
    nnn=8;
    rtst=420;//278.5;
    ltst=lbars(rtst,p1,p2,ps,nnn);
//    rtst=search_r(50,500,p1,p2,ps,lsz,nnn);
    echo(rtst);
    echo("len", ltst);
    circle(r=ri);
    drawarc(p1,p2,rtst);
    curv=norm(p2-p1)/(p1.y+p2.y)/2;
    echo(norm(p2-p1));
    echo((p1.y+p2.y)/2);
    echo(curv);
/*
    pc=center2pr(p1,p2,rtst);
    crbs=crossbars(pc,rtst,ps,nnn);
    l1=sumlst(crbs);
    l2=crbs[len(crbs)-1];
    hull() {
    translate(ps+[l1,0]) cylinder(d=.5);
    translate(ps+[l1,l2]) cylinder(d=.5);
    }

    drawcrossbars(crbs,ps);
*/
    #translate(ps) cylinder(d=.5,h=2);
    #translate(pe) cylinder(d=.5,h=2);
    #translate(p1) cylinder(d=.5,h=2);
    #translate(p2) cylinder(d=.5,h=2);
    #translate(center2pr(p1,p2,rtst)) cylinder(d=5,h=2);
}

drawsketch();
