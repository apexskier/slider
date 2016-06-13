// rule of thumb
// .2 mm space for friction fit
// .4 mm space for loose fit

wallWidth = 2;

fourCorners = [0, 90, 180, 270];

motorWidth = 42.3 + .2 * 2;
motorCircleDiameter = 22 + .4 * 2;
motorHeight = 34 + .5;
motorDistanceBetweenScrews = 31 + .2;
motorCornerInset = 4;
motorCornerInsetSide = sqrt(2 * pow(motorCornerInset, 2));
motorEdgeHeight = 6;
motorScrewThreadDiameter = 2.7 + .4 * 2;
motorScrewDiameter = 5 + .2 * 2;
motorCounterSinkDepth = 1.8;

module screwHole() {
    translate([0, 0, -1]) {
        cylinder(h = 20, d = motorScrewThreadDiameter, $fn = 80);
    }
    cylinder(h = motorCounterSinkDepth, d1 = motorScrewDiameter, d2 = motorScrewThreadDiameter, $fn = 80);
}

module motorScrewHole() {
    translate([motorDistanceBetweenScrews / 2, motorDistanceBetweenScrews / 2, -0.001]) {
        screwHole();
    }
}

module edgeCutOff() {
    translate([motorWidth / 2, motorWidth / 2, 0]) {
        rotate(45, [0, 0, 1]) {
            translate([-motorCornerInsetSide / 2, -motorCornerInsetSide / 2, 0]) {
                cube([motorCornerInsetSide, motorCornerInsetSide, motorEdgeHeight]);
            }
        }
    }
}

module motorMount() {
    difference() {
        union() {
            difference() {
                translate([-motorWidth / 2 - wallWidth, -motorWidth / 2 - wallWidth, 0]) {
                    cube([motorWidth + wallWidth * 2, motorWidth + wallWidth * 2, motorEdgeHeight]);
                }

                difference() {
                    translate([-motorWidth / 2, -motorWidth / 2, 0]) {
                        cube([motorWidth, motorWidth, motorEdgeHeight + 1]);
                    }

                    for (d = fourCorners) {
                        rotate(d, [0, 0, 1]) edgeCutOff();
                    }
                }
            }

            translate([-motorWidth / 2, -motorWidth / 2, 0]) {
                cube([motorWidth, motorWidth, 2]);
            }
        }

        translate([0, 0, -1]) {
            cylinder(h = 40, d = motorCircleDiameter);
        }

        for (d = fourCorners) {
            rotate(d, [0, 0, 1]) motorScrewHole();
        }
    }
}

translate([0, -(motorWidth + wallWidth * 2) / 2, 0]) {
    rotate(180, [0, 1, 0]) {
        motorMount();
    }
}

mountNutDiameter = 12.8 + .2 * 2;
mountNutHeight = 4.6;
mountScrewDiameter = 6.2 + .4 * 2;
// ensure this is < timing belt diameter
mountDiameter = mountNutDiameter + 3;
mountHoleBetween = 4.2;
mountDistanceToLegs = 4;
mountHoleDiameter = 8;
// distance between middle of two mounting holes
mountSpaceBetween = 4 + 4.2 + 4;

baseThickness = 1.5;
baseLengthExtra = mountDiameter + mountSpaceBetween;
baseWidth = 30 - .2;

module mountNutCutout() {
    translate([0, 0, -50]) {
        linear_extrude(height = 100) {
            circle(d = mountScrewDiameter, $fn = 60);
        }
    }
}

rotate(180, [0, 1, 0]) {
    // above base
    translate([0, 0, baseThickness]) {
        // nut holders
        translate([0, mountDiameter / 2, 0]) {
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

                translate([-mountDiameter, mountSpaceBetween + mountDiameter / 2 - wallWidth * 2, -20]) {
                    cube([mountDiameter * 2, 20, 30]);
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
        }
    }
}

boxWidth = motorWidth + (wallWidth + wallWidth + 6.8 + 7) * 2;
echo("boxWidth - walls: ", boxWidth - wallWidth * 4);
boxDepth = motorWidth + wallWidth * 2 + baseLengthExtra + 20;
difference() {
    translate([-boxWidth / 2, -(boxDepth - baseLengthExtra), -wallWidth * 2]) {
        translate([0, 0, wallWidth]) {
            cube([boxWidth, boxDepth, wallWidth]);
        }
        difference() {
            translate([wallWidth, wallWidth, -wallWidth]) {
                cube([boxWidth - wallWidth * 2, boxDepth - wallWidth * 2, wallWidth * 2]);
            }
            translate([wallWidth * 2, wallWidth * 2, -wallWidth * 2]) {
                cube([boxWidth - wallWidth * 4, boxDepth - wallWidth * 4, wallWidth * 4]);
            }
        }
    }

    translate([0, mountDiameter / 2, -1]) {
        mountNutCutout();

        translate([0, mountSpaceBetween, 0]) {
            mountNutCutout();
        }
    }

    translate([0, -(motorWidth + wallWidth * 2) / 2, 0]) {
        rotate(180, [0, 1, 0]) {
            translate([0, 0, -1]) {
                cylinder(h = 40, d = motorCircleDiameter);
            }

            for (d = fourCorners) {
                rotate(d, [0, 0, 1]) motorScrewHole();
            }
        }
    }

    translate([-boxWidth / 2 + 8, 0, 0.01]) {
        translate([0, baseLengthExtra - 8, 0]) {
            rotate(180, [0, 1, 0]) {
                screwHole();
            }
        }

        translate([0, -(boxDepth - baseLengthExtra - 8), 0]) {
            rotate(180, [0, 1, 0]) {
                screwHole();
            }
        }
    }

    translate([boxWidth / 2 - 8, 0,  0.01]) {
        translate([0, baseLengthExtra - 8, 0]) {
            rotate(180, [0, 1, 0]) {
                screwHole();
            }
        }

        translate([0, -(boxDepth - baseLengthExtra - 8), 0]) {
            rotate(180, [0, 1, 0]) {
                screwHole();
            }
        }
    }
}

