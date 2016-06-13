// rule of thumb
// .2 mm space for friction fit
// .4 mm space for loose fit

wallWidth = 2;

fourCorners = [0, 90, 180, 270];

motorWidth = 42.3 + .2 * 2;
motorHeight = 34 + .5;
motorCornerInset = 4;
motorCornerInsetSide = sqrt(2 * pow(motorCornerInset, 2));
motorEdgeHeight = 6;
motorScrewThreadDiameter = 2.7 + .4 * 2;

mountNutDiameter = 12.8 + .2 * 2;
// ensure this is < timing belt diameter
mountDiameter = mountNutDiameter + 3;
// distance between middle of two mounting holes
mountSpaceBetween = 4 + 4.2 + 4;

baseThickness = 1.5;
baseLengthExtra = mountDiameter + mountSpaceBetween;
baseWidth = 30 - .2;

boxWidth = motorWidth + (wallWidth + wallWidth + 6.8 + 7) * 2;
boxDepth = motorWidth + wallWidth * 2 + baseLengthExtra + 20;
motorRise = 7.5;
boxHeight = 31.5 + motorRise + wallWidth * 2;

nutDiameter = 7.1 + .4 * 2;

switchHeadSide = 16 + .4 * 2;
dialDiameter = 7 + .4 * 2;
batteryPlugDiameter = 11 + .4;
switchCableWidth = 3.3;
switchCableHeight = 2.3;

module screwHole() {
    linear_extrude(height = boxHeight - wallWidth) {
        circle(d = motorScrewThreadDiameter, $fn = 80);
    }
}

module nut() {
    height = 3;
    translate([0, 0, boxHeight - wallWidth * 3 - height]) {
        cylinder(h = height, d = nutDiameter, $fn = 6);
    }
}

module nutHolder() {
    height = 10;
    translate([-7, -7, boxHeight - wallWidth * 3 - .2 - height]) {
        cube([14, 14, height]);
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
    union() {
        translate([0, 0, motorRise]) {
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
        }

        translate([-motorWidth / 2 - wallWidth, -motorWidth / 2 - wallWidth, 0]) {
            cube([motorWidth + wallWidth * 2, motorWidth + wallWidth * 2, motorRise]);
        }
    }
}

module switchCable() {
    rotate(90, [1, 0, 0])
        scale([1, switchCableHeight / switchCableWidth, 1])
            cylinder(h = 20, d = switchCableWidth, $fn = 30);
}

motorCtlWidth = 1.65;
motorCtlLength = 27;
translate([boxWidth / 2 - (motorCtlWidth + wallWidth * 2) - wallWidth * 3, -boxDepth + baseLengthExtra + wallWidth * 3, wallWidth]) {
    difference() {
        translate([0, 0, wallWidth]) {
            cube([motorCtlWidth + wallWidth * 2, motorCtlLength + wallWidth * 2, .6]);
            translate([0, 0, -wallWidth]) {
                cube([motorCtlWidth + wallWidth * 2, motorCtlLength + wallWidth * 2, wallWidth]);
            }
        }
        translate([wallWidth, wallWidth, wallWidth]) {
            cube([motorCtlWidth, motorCtlLength, 10]);
        }
    }
}

arduWidth = 1;
arduLength = 33.6;
mirror(v = [1, 0, 0])
translate([motorWidth / 2 + wallWidth * 2, -boxDepth + baseLengthExtra + wallWidth * 1, wallWidth]) {
    difference() {
        translate([0, 0, wallWidth]) {
            cube([arduWidth + wallWidth * 2, arduLength + wallWidth * 2, .6]);
            translate([0, 0, -wallWidth]) {
                cube([arduWidth + wallWidth * 2, arduLength + wallWidth * 2, wallWidth]);
            }
        }
        translate([wallWidth, wallWidth, wallWidth]) {
            cube([arduWidth, arduLength, 10]);
        }
    }
}

difference() {
    union() {
        translate([-boxWidth / 2, -(boxDepth - baseLengthExtra), 0]) {
            difference() {
                // remember to account for the floor and the ceiling!
                cube([boxWidth, boxDepth, boxHeight]);
                translate([wallWidth, wallWidth, wallWidth]) {
                    cube([boxWidth - wallWidth * 2, boxDepth - wallWidth * 2, 100]);
                }
                // lip where top attaches
                lipWidth = wallWidth - .4;
                translate([lipWidth, lipWidth, boxHeight - wallWidth * 2 - .2]) {
                    cube([boxWidth - lipWidth * 2, boxDepth - lipWidth * 2, 100]);
                }

                // hide walls
                // translate([-1, -1, wallWidth]) {
                //     cube([boxWidth + 2, boxDepth + 2, boxHeight + 2]);
                // }
            }

            // ftdi channel
            cube([6, 10, 24]);
        }

        // screwmounts
        translate([0, 0, wallWidth]) {
            translate([-boxWidth / 2 + 8, 0, 0]) {
                translate([0, baseLengthExtra - 8, 0]) {
                    nutHolder();
                }

                translate([0, -(boxDepth - baseLengthExtra - 8), 0]) {
                    nutHolder();
                }
            }

            translate([boxWidth / 2 - 8, 0, 0]) {
                translate([0, baseLengthExtra - 8, 0]) {
                    nutHolder();
                }

                translate([0, -(boxDepth - baseLengthExtra - 8), 0]) {
                    nutHolder();
                }
            }
        }
    }

    // screwmounts
    translate([0, 0, wallWidth]) {
        translate([-boxWidth / 2 + 8, 0, 0]) {
            translate([0, baseLengthExtra - 8, 0]) {
                screwHole();
                nut();
            }

            translate([0, -(boxDepth - baseLengthExtra - 8), 0]) {
                screwHole();
                nut();
            }
        }

        translate([boxWidth / 2 - 8, 0, 0]) {
            translate([0, baseLengthExtra - 8, 0]) {
                screwHole();
                nut();
            }

            translate([0, -(boxDepth - baseLengthExtra - 8), 0]) {
                screwHole();
                nut();
            }
        }
    }

    translate([boxWidth / 2, 0, boxHeight / 2]) {
        // button hole
        translate([-10, -motorWidth / 2 - wallWidth, 0]) {
            rotate(90, [0, 1, 0]) {
                cylinder(d = dialDiameter, h = 20, $fn = 40);
            }
        }

        // dial hole
        translate([-switchHeadSide / 2 - 20, 0, -switchHeadSide / 2]) cube([100, switchHeadSide, switchHeadSide]);
        sHInside = switchHeadSide + 4;
        translate([-sHInside - wallWidth + .8, -2, -sHInside / 2]) cube([20, sHInside, sHInside]);
    }

    // FTDI cable
    translate([-boxWidth / 2, -motorWidth - 20, wallWidth * 2]) {
        translate([-5, 0, 0]) {
            cube([20, 2.55 + .4 * 2, 15.2 + .4 * 2]);
        }
    }

    // battery plug
    translate([10 - boxWidth / 2, baseLengthExtra - batteryPlugDiameter / 2 - wallWidth, batteryPlugDiameter / 2 + wallWidth]) {
        rotate(-90, [0, 1, 0]) {
            cylinder(d = batteryPlugDiameter, h = 20, $fn = 40);
        }
    }

    // switch holes
    translate([0, baseLengthExtra + 10, boxHeight / 2]) {
        hull() {
            switchCable();
            translate([0, 0, switchCableHeight]) {
                switchCable();
            }
        }
    }

    translate([boxWidth / 2 - .2, -boxDepth + baseLengthExtra + wallWidth, wallWidth]) {
        rotate(90, [1, 0, 0]) {
            rotate(90, [0, 1, 0]) {
                text("https://github.com/apexskier/slider v1.0.0", size = 3);
            }
        }
    }
}

translate([0, -(motorWidth + wallWidth * 2) / 2, 0]) {
    motorMount();
}

