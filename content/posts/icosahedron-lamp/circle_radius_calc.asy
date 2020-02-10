size(500);
int rad = 200;

defaultpen(1.5 + fontsize(18));

pair origin = (0,0);

pair p1 = (0, rad);
pair p2 = (rad * Sin(120), rad * Cos(120));
pair p1p2mid = (p1 + p2)/2;

pair angleLabelPosition = (rad * Sin(60) / 5, rad * Cos(60) / 5);

draw((-1,0)--(1,0));
draw((0,-1)--(0,1));

draw(origin -- p1,dashed);
draw(origin -- p2,solid);
draw(origin -- p1p2mid, dashed);

draw(p1--p2,blue);
void angleMarker(pair around, real diam, pair dir1, pair dir2, int cnt=1, real sep=3) {
  for(int i = 0; i < cnt; ++i) {
    draw(arc(around, around + unit(dir1 - around) * (diam + i * sep), around + unit(dir2 - around) * (diam + i * sep)));
  }
}

void rightAngleMarker(pair around, real size, pair dir1, pair dir2) {
  pair top =  around + unit(dir1 - around) * size;
  pair sideBottom = around + unit(dir2 - around) * size;
  pair sideTop = top + unit(dir2 - around) * size;

  draw(top -- sideTop);
  draw(sideTop -- sideBottom);
}

angleMarker(p1, 20, origin, p2,2);
angleMarker(p2, 20, p1, origin, 2);


rightAngleMarker(p1p2mid,10,origin,p2);

label("$l_e$", p1--p2,NE);
label("$r_b$", p2--origin, SW);
label("$30^\circ$",p2 + unit((p1-p2) + (origin-p2)) / 2 * 50,NW);
pen p = currentpen + red;

dot(p1,p);
dot(p2,p);

shipout(bbox(white, Fill));

