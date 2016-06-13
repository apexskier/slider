innerWidth = 21; // - .2 * 2;
outerWidth = innerWidth + 5;
innerLength = 41.7; // - .2 * 2;
outerLength = innerLength + 5;
innerHeight = 9.5;
channelDepth = .1;
channelWidth = 2; // - .2 * 2;
boltHeadDiameter = 11; // + .4 * 2;
boltShaftDiameter = 6.22; // + .4 * 2;
washerThickness = 1.64;
washerDiameter = 12.16; // + .4 * 2;

beltWidth = 6;
beltThickness = 1.4;
beltThicknessWithoutTeeth = .7;
beltToBeltThickness = beltThickness + beltThicknessWithoutTeeth;
toothThickness = 1;
toothSpacing = .8;

beltSpaceOuter = 13.5;

module baseCube() {
    cube([outerWidth, outerLength, innerHeight], center = true);
}

module baseCutout() {
    translate([innerWidth / 2 - .2, innerLength / 2 - .2, -50]) {
        cube([100, 100, 100]);
    }
}

module railCutout() {
    railspace = beltThickness * 3;
    railfromend = (outerLength + 2) / 4;

    translate([-railspace - beltToBeltThickness - outerWidth / 8, -(outerLength + 2) / 2, -innerHeight / 2 + 2]) {
        intersection() {
            union() {
                // outer (top)
                difference() {
                    cube([beltToBeltThickness + .4, outerLength + 2, innerHeight]);

                    // left
                    translate([railspace, outerLength + 2 - railfromend - beltToBeltThickness, 0]) {
                        rotate(-45, [0, 0, 1]) {
                            translate([-beltToBeltThickness - 100, -10, 0]) {
                                cube([beltToBeltThickness + 100, outerLength + 2, innerHeight]);
                            }
                        }
                    }

                    // right
                    translate([beltToBeltThickness + railspace, railfromend, 0]) {
                        rotate(180 + 45, [0, 0, 1]) {
                            translate([beltToBeltThickness, -10, 0]) {
                                cube([beltToBeltThickness + 100, outerLength + 2, innerHeight]);
                            }
                        }
                    }
                }

                // left
                translate([railspace, outerLength + 2 - railfromend - beltToBeltThickness, 0]) {
                    rotate(-45, [0, 0, 1]) {
                        translate([0, -10, 0]) {
                            cube([beltToBeltThickness + .4, outerLength + 2, innerHeight]);
                        }
                    }
                }

                // right
                translate([beltToBeltThickness + railspace, railfromend, 0]) {
                    rotate(180 + 45, [0, 0, 1]) {
                        translate([0, -10, 0]) {
                            cube([beltToBeltThickness + .4, outerLength + 2, innerHeight]);
                        }
                    }
                }

                // inner
                difference() {
                    translate([railspace, 0, 0]) {
                        cube([beltToBeltThickness + .4, outerLength + 2, innerHeight]);
                    }

                    // right
                    translate([beltToBeltThickness + railspace, railfromend, 0]) {
                        rotate(180 + 45, [0, 0, 1]) {
                            translate([-beltToBeltThickness - 4, -10, 0]) {
                                cube([beltToBeltThickness + 4, outerLength + 2, innerHeight]);
                            }
                        }
                    }

                    // left
                    translate([railspace, outerLength + 2 - railfromend - beltToBeltThickness, 0]) {
                        rotate(-45, [0, 0, 1]) {
                            translate([beltToBeltThickness, -10, 0]) {
                                cube([beltToBeltThickness + 10, outerLength + 2, innerHeight]);
                            }
                        }
                    }
                }
            }

            cube([beltThickness + railspace + .4, outerLength + 2, innerHeight]);
        }
    }
}

// this gives an idea of where the belt will slide
// cube(beltSpaceOuter, center = true);

difference() {
    baseCube();

    // corners
    baseCutout();
    scale([1, -1, 1]) baseCutout();
    scale([-1, 1, 1]) baseCutout();
    scale([-1, -1, 1]) baseCutout();

    translate([0, 0, -50]) {
        cylinder(h = 100, d = boltShaftDiameter + .4 * 2, $fn = 60);
    }
    translate([0, 0, -innerHeight / 2 + 1]) {
        cylinder(h = 100, d = boltHeadDiameter + .2 * 2, $fn = 60);
    }

    translate([0, 1.6, 0]) {
        railCutout();
    }

    beltSlidingWidth = beltThickness * 3;
    translate([(-beltSlidingWidth + beltSpaceOuter - beltThickness) / 2, -(outerLength + 2) / 2, -innerHeight / 2 + 2]) {
        cube([beltSlidingWidth, outerLength + 2, innerHeight]);
    }
}
