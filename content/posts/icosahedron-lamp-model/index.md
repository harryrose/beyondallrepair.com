+++
title = "3D-Printed Icosahedron Lamp :: The Model"
date  = "2020-02-08T20:00:00Z"
description = "A build article discussing a 3D-printed icosahedron lamp using an arduino pro mini and a string of WS2811/WS2812 LEDs."
cover = "posts/icosahedron-lamp-model/in-situ-shot-rect.jpg"
author = "Harry"
tags = [ "decoration", "3d-printing", "arduino", "led", "ws2812", "openscad" ]
+++

## Intro
In this article, I will discuss an icosahedron lamp I recently built.  Aside from the electronics,
it is 100% 3D-Printed, and designed in OpenSCAD, although I do admit to using epoxy in order to glue
segments of the icosahedron together.

The design and build will be split into two articles.  The first (this one) will discuss the OpenSCAD model, and
the mathematics behind it. I will cover the electronics and microcontroller code in an upcoming article.  However,
if you're just interested in the source code, both the OpenSCAD model and the arduino source code is available
on [GitHub](https://github.com/harryrose/icosahedron-lamp).

{{< toc >}}

## Tools and Hardware

{{<figure src="components.jpg" position="center" caption="Some of the components used within this project" style="border-radius:8px">}}
 * Design Software: OpenSCAD
 * Printer: Anycubic i3Mega
 * Filaments:
   * 3D Warhorse Silver PLA
   * 3D Warhorse White PLA
   * AMZ3D Black PLA
 * Arduino Pro Mini
 * 12v, 12mm WS2811 LED String (just from AliExpress)
 * 12v -> 5v Buck converter
 * 12v, 2A 2.5mm Centre Positive Power Supply
 * 2.5mm Power Jack
 * 16mm diameter toggle switch used for power
 * Epoxy (just used as a glue)
 * JST-SM (2.54mm) connectors + crimper (to build connections that connect to the LED strip)

### Why OpenSCAD?
This was my first venture into OpenSCAD, having exclusively used AutoDesk Fusion 360 before. I decided
to use OpenSCAD this time for a number of reasons:

 * I primarily use Linux, and boot Windows as a last resort if there's no support for Linux in the tool I'd like to use.  Fusion 360 is a good tool, but it was getting painful having to reboot all of the time.
 * I don't like the cloud-based nature of Fusion 360.  I'd prefer to have local files (although I'm aware you can export), over which I have full control.
 * Fusion 360's move towards limiting their hobbyist plan has scared me slightly.  Although the restrictions seem reasonable (for now), it made me more aware of how locked into the AutoDesk ecosystem I was.

## Icosahedron Model

### Mathematical Basis

#### Icosahedron Section

{{< image src="icosahedron-explode.gif" caption="Animation showing how an icosahedron can be thought of many triangular-based pyramids meeting at its centre" position="center" style="border-radius:8px" >}}

An Icosahedron is a polyhedron made of 20 identical equilateral triangular faces.  For this lamp, it helps to think of each of the faces as a triangular-base pyramid whose peak is at the centre of the icosahedron.  Given this, the lamp model simply models one "section" of an icosahedron, which is then printed 19 times (and then a similar model is used for the final, base section).  The animated gif above may help to visualise this (thanks to Adam Anderson, whose [model I modified](https://www.thingiverse.com/thing:1343285) to obtain the above animation).

To determine the dimensions of each section, we simply need to know how deep we'd like each pyramid to be, \\( r_i \\), and then to determine the length, \\( l_e \\), of one (and therefore all) of the edges of the equlateral triangle that makes its base.  The equation for this is specified on [Wikipedia](https://en.wikipedia.org/w/index.php?title=Regular_icosahedron&oldid=937738533). Using the equation for the inscribed radius of the icosahedron (i.e., the radius of the sphere that touches the centre of each face),
\\[
  r_i = {{\sqrt{3}\over{12}}} (3 + \sqrt{5}) l_e
\\]

it can be seen that the length of a side of the base of the pyramid, \\(l_e\\), given the depth of the pyramid, \\(r_i\\) is:

\\[
 l_e = {12 \over (3 + \sqrt{5})\sqrt{3}} r_i
\\]

Now, to model the pyramid in OpenSCAD, we need to determine the points that make up the vertices (corners) of the pyramid.  For the sake of simplicity, I'm stating that the base of the pyramid is on the \\(xy\\) plane at \\(z = 0\\).  We will also take the point \\((0,0,0)\\) to be the centre of the pyramid base.  Given that, we already know that the peak of the pyramid is at \\( (0,0,r) \\).  For the remaining three points that describe the base triangle, we know that they're all at \\(z = 0\\), so all that remains isto determine the x and y coordinates for the three points that make it.

{{< image src="eq_triangle.png" caption="Points of an equilateral triangle described as points on the circumference of a circle" position="center" style="border-radius:8px" >}}

An equilateral triangle centred around a point can be thought of as three points, 120&deg; apart on a circle whose centre is at that same point.  Given the radius, \\(r_b\\) of a circle, whose centre is at the origin, a point on its circumference at angle, \\(\theta\\), is given by \\((r_b \cdot \mathrm{sin}(\theta), r_b \cdot \mathrm{cos}(\theta))\\).  So now the radius of that circle must be determined given the edge length we calculated earlier, \\(l_e\\), which can be done using some simple trigonometry.  

{{<image src="circle_radius_calc.png" position="center" style="border-radius:8px" >}}

Given that we know the angle between the two corners via the centre of the circle is 120&deg;, we know that the angle at the corners must be 30&deg;. Drawing a line that bisects the angle between the two corners via the centre, we end up with a right-angled triangle, with a hypotenuse length of \\(r_b\\), and a side length adjacent to the 30&deg; angle of \\({1\over2} l_e\\)).  Using trigonometry, this eventually gives us the result that

\\[
  r_b = {l_e \over \sqrt{3}}
\\]

With this, we can now calculate points that make up a solid icosahedron section.  However, there are a few more steps before we have an section we can use in the lamp.

 * Truncate the top, such that there is a cavity in the centre of the icosahedron.
 * Hollow out the section to make a 'lens'.
 * Produce a lid.

#### Modelling the Central Cavity

The central cavity in the icosahedron is achieved by truncating the sections.  This is achieved by simply removing a pyramid from the top of the icosahedron section.  To model the pyramid to be removed from the top of each section, we can simply use the mathematics described for the larger icosahedron section above.  We'd simply substitute the icosahedron radius, \\(r_i\\), with the cavity radius, \\(r_c\\).

#### Hollowing Out the Section

{{<image src="wall_width.png" position="center" style="border-radius:8px">}}

The lens of the icosahedron section must be hollow to allow the LED to sit inside, and for the light to radiate around it.  The sections have a wall width, \\(w\\), and a lens thickness, \\(t_l\\), which denote the thickness of the sides protruding from the base of the pyramid, and the thickness of the base respectively.  Given these, hollowing out the lens is simply a case of subtracting the right sized pyramid from the original section.  Therefore, we must calculate the base radius parameter that must be used for the smaller pyramid, \\(p_b'\\).

This can be achieved fairly simply using similar triangles.  In the above diagram it can be seen we make a right-angled triangle through the origin of the pyramid base, one of the pyramid base's corners, and the midpoint of one of its sides.  We know that triangle has height, \\(h = \mathrm{cos}(120^\circ) \cdot r_b\\) or \\(h = 0.5 \cdot r_b\\).  From that we know that the new triangle will have height \\(h' = h - w \\) and further, from similar triangles, we know that
the ratios of the sides must remain the same.  That is,
\\[
{h'\over h} = {r'b \over r_b}
\\]
and so substituting \\(h' = h - w\\) and \\(h = 0.5 \cdot r_b\\) we eventually get the result:
\\[
 r_b' = r_b - 2w
\\]
or, in order to obtain a wall width of \\(w\\), the radius of the pyramid we subtract must be reduced by \\(2w\\) from the original base.

Of course, the maths above assumes the base of the original pyramid and the one we're subtracting are coplanar.  That's not the case here, as we want the lens to have a certain thickness, \\(t_l\\).  The same maths can still be followed but using the radius of the pyramid's base for an icosahedron of radius \\( r_b = r_i - t_l \\).

#### Modelling the Lens Lid

{{<image src="lid-model.png" position="center" style="border-radius:8px">}}
The lens lid can be thought of as a truncated icosahedron section whose base starts at radius \\(r_c\\) and whose top is at \\(r_c - w \\) (assuming you want the lid thickness to equal your wall width).  The lid is not hollowed, but
a circular hole is cut through the centre to allow the LED to be pushed through, and a triangular 'lip' is extruded in order to help the lid sit within the lens.

### OpenSCAD Model

```javascript
function icoRadiusToFaceEdgeLength(radius) = radius * 12 / (sqrt(3) * (3 + sqrt(5)));

function icoRadiusToFaceRadius(radius) = icoRadiusToFaceEdgeLength(radius) / sqrt(3);

function faceRadiusMinusWallWidth(radius, wallWidth) = radius - 2 * wallWidth;

module pyramid(r, h) {
  vertices = [[r,0,0], [r * cos(120),r * sin(120),0], [r * cos(240), r * sin(240),0],[0,0,h]];
  polyhedron(points=vertices,faces=[[0,1,2],[1,0,3],[0,2,3],[2,1,3]]);
}

module icoSection(innerDepth, outerDepth) {
  difference() {
    pyramid(icoRadiusToFaceRadius(outerDepth), outerDepth);
    translate([0,0,outerDepth - innerDepth])
      pyramid(icoRadiusToFaceRadius(innerDepth), outerDepth);
  }
}
```
