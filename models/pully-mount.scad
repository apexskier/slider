// rule of thumb
// .2 mm space for friction fit
// .4 mm space for loose fit

pullyInnerDiameter = 5 - .2 * 2;
pullyOuterDiameter = 17.97 + .4 * 2;
pullyWidth = 7.4;
pullyElevation = .5;
pullyBaseExtra = .8;
pullyVerticalPadding = .4;
pullyRadialPadding = .4;

wallWidth = 2;
wallExtraSpace = 1.5;

outerRadius = pullyOuterDiameter / 2 + wallWidth + wallExtraSpace;

mountNutDiameter = 12.8 + .2 * 2;
mountNutHeight = 4.6;
mountScrewDiameter = 6.2 + .4 * 2;
// ensure this is < timing belt diameter
mountDiameter = mountNutDiameter + 3;
// distance between middle of two mounting holes
mountSpaceBetween = 4 + 4.2 + 4;

baseThickness = 1.5;
baseLengthExtra = mountDiameter * 2;
baseWidth = 30 - .2;

module guardStraight(height, width) {
    translate([outerRadius - width, 0, 0]) {
        cube([width, outerRadius / 1.3, height]);
    }
}

module guard(height, width = wallWidth) {
    union() {
        difference() {
            cylinder(h = height, r1 = outerRadius, r2 = outerRadius);

            cylinder(h = height, r1 = outerRadius - width, r2 = outerRadius - width);

            translate([-outerRadius, 0, 0]) {
                cube([outerRadius * 2, outerRadius, height]);
            }
        }

        guardStraight(height, width);

        mirror([1, 0, 0]) {
            guardStraight(height, width);
        }
    }
}

module mountNutCutout() {
    linear_extrude(height = baseThickness + 2) {
        circle(d = mountScrewDiameter, $fn = 60);
    }
}

intersection() {
    union() {
        // base
        difference() {
            union() {
                cylinder(h = baseThickness, r1 = outerRadius, r2 = outerRadius);

                translate([-baseWidth / 2, 0, 0]) {
                    cube([baseWidth, outerRadius + baseLengthExtra, baseThickness]);
                }
            }

            translate([0, outerRadius + mountDiameter / 2, -1]) {
                mountNutCutout();

                translate([0, mountSpaceBetween, 0]) {
                    mountNutCutout();
                }
            }
        }

        // above base
        translate([0, 0, baseThickness]) {
            // central shaft
            cylinder(h = pullyVerticalPadding + pullyElevation, r1 = pullyInnerDiameter / 2 + pullyBaseExtra, r2 = pullyInnerDiameter / 2 + pullyBaseExtra, $fn = 60);
            cylinder(h = pullyWidth + pullyVerticalPadding + pullyElevation + baseThickness, r1 = pullyInnerDiameter / 2, r2 = pullyInnerDiameter / 2, $fn = 60);

            // outer guard
            guard(pullyWidth + pullyVerticalPadding + pullyElevation);

            // support rails
            translate([outerRadius - wallWidth, 0, 0]) {
                cube([wallWidth, outerRadius + baseLengthExtra, pullyVerticalPadding + pullyElevation]);
            }
            translate([-outerRadius, 0, 0]) {
                cube([wallWidth, outerRadius + baseLengthExtra, pullyVerticalPadding + pullyElevation]);
            }

            // top lip
            translate([0, 0, pullyWidth + pullyVerticalPadding + pullyElevation]) {
                guard(baseThickness, wallWidth + wallExtraSpace - pullyRadialPadding);
            }

            // nut holders
            translate([0, outerRadius + mountDiameter / 2, 0]) {
                intersection() {
                    difference() {
                        hull() {
                            linear_extrude(height = mountNutHeight) {
                                circle(d = mountDiameter, $fn = 30);
                            }

                            translate([0, mountSpaceBetween, 0]) {
                                linear_extrude(height = mountNutHeight) {
                                    circle(d = mountDiameter, $fn = 30);
                                }
                            }
                        }

                        translate([0, 0, -1]) {
                            linear_extrude(height = mountNutHeight + 2) {
                                circle(d = mountNutDiameter, $fn = 6);
                            }

                            translate([0, mountSpaceBetween, 0]) {
                                linear_extrude(height = mountNutHeight + 2) {
                                    circle(d = mountNutDiameter, $fn = 6);
                                }
                            }
                        }
                    }

                    cutWidth = mountNutDiameter - 3;
                    translate([-cutWidth / 2, -mountDiameter / 2, 0]) {
                        cube([cutWidth, mountSpaceBetween + mountDiameter, mountNutHeight + 2]);
                    }
                }
            }
        }
    }

    translate([0, 0, -50]) {
        linear_extrude(height = 100) {
            distanceToRounded = outerRadius + mountDiameter + mountSpaceBetween - (baseWidth / 2);
            translate([0, distanceToRounded, 0]) {
                circle(d = baseWidth, $fn = 300);
            }

            square(distanceToRounded * 2, center = true);
        }
    }
}

