pullyInnerDiameter = 5;
pullyOuterDiameter = 17.8 + .4;
pullyWidth = 7.4;
pullyElevation = .5;
pullyBaseExtra = .8;
pullyVerticalPadding = 0.4;
pullyRadialPadding = 0.4;

wallWidth = 2;
wallExtraSpace = 1.5;

baseWidth = 1.5;
baseLengthExtra = 26;

mountHeight = 6;
mountRadius = 4;
mountWallWidth = 1;
mountPadding = 0.2;
mountGripHeight = 0.5;
mountGripPad = mountPadding;
mountPartSpacing = 1.5;

mountOtherOffset = 3 + mountRadius + 0.2;
mountOtherWidth = 14;
mountOtherDepth = 8 - 0.2 * 2;

outerRadius = pullyOuterDiameter / 2 + wallWidth + wallExtraSpace;

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

// base
difference() {
    union() {
        cylinder(h = baseWidth, r1 = outerRadius, r2 = outerRadius);
        translate([-outerRadius, 0, 0]) {
            cube([outerRadius * 2, outerRadius + baseLengthExtra, baseWidth]);
        }
    }

    translate([0, 0, -1]) {
        translate([0, 17, 0]) {
            cylinder(h = 20, d = 8, $fn = 60);

            translate([0, 13, 0]) {
                cylinder(h = 20, d = 8, $fn = 60);
            }
        }
    }
}

// above base
translate([0, 0, baseWidth]) {
    // central shaft
    cylinder(h = pullyVerticalPadding + pullyElevation, r1 = pullyInnerDiameter / 2 + pullyBaseExtra, r2 = pullyInnerDiameter / 2 + pullyBaseExtra, $fn = 60);
    cylinder(h = pullyWidth + pullyVerticalPadding + pullyElevation, r1 = pullyInnerDiameter / 2, r2 = pullyInnerDiameter / 2, $fn = 60);

    // outer guard
    guard(pullyWidth + pullyVerticalPadding + pullyElevation);
    translate([outerRadius - wallWidth, 0, 0]) {
        cube([wallWidth, outerRadius + baseLengthExtra, height]);
    }
    translate([-outerRadius, 0, 0]) {
        cube([wallWidth, outerRadius + baseLengthExtra, height]);
    }

    // top lip
    translate([0, 0, pullyWidth + pullyVerticalPadding + pullyElevation]) {
        guard(baseWidth, wallWidth + wallExtraSpace - pullyRadialPadding);
    }
}

module cutMountingCylinderOut() {
    translate([-(mountRadius + 4), -mountPartSpacing/2, 0]) {
        cube([(mountRadius + 4) * 2, mountPartSpacing, mountHeight]);
    }
}

// mounting parts
//translate([0, 0, -mountGripHeight]) {
//    difference() {
//        cylinder(h = mountGripHeight, r1 = mountRadius - mountPadding, r2 = mountRadius - mountPadding + mountGripPad);
//
//        cylinder(h = mountGripHeight, r1 = mountRadius - mountPadding - mountWallWidth, r2 = mountRadius - mountPadding - mountWallWidth);
//
//        cutMountingCylinderOut();
//        rotate(90, [0, 0, 1]) {
//            cutMountingCylinderOut();
//        }
//    }
//}
//
//translate([0, 0, -mountHeight]) {
//
//    difference() {
//        cylinder(h = mountHeight, r1 = mountRadius - mountPadding, r2 = mountRadius - mountPadding);
//
//        cylinder(h = mountHeight, r1 = mountRadius - mountPadding - mountWallWidth, r2 = mountRadius - mountPadding - mountWallWidth);
//
//        cutMountingCylinderOut();
//        rotate(90, [0, 0, 1]) {
//            cutMountingCylinderOut();
//        }
//    }
//
//    translate([-mountOtherWidth / 2, mountOtherOffset, 0]) {
//        cube([mountOtherWidth, mountOtherDepth, mountHeight]);
//    }
//
//    translate([0, 0, -mountGripHeight]) {
//        difference() {
//            cylinder(h = mountGripHeight, r1 = mountRadius - mountPadding + mountGripPad, r2 = mountRadius - mountPadding);
//
//            cylinder(h = mountGripHeight, r1 = mountRadius - mountPadding - mountWallWidth, r2 = mountRadius - mountPadding - mountWallWidth);
//
//            cutMountingCylinderOut();
//            rotate(90, [0, 0, 1]) {
//                cutMountingCylinderOut();
//            }
//        }
//
//        translate([0, 0, -mountGripHeight]) {
//            difference() {
//                cylinder(h = mountGripHeight, r1 = mountRadius - mountPadding, r2 = mountRadius - mountPadding + mountGripPad);
//
//                cylinder(h = mountGripHeight, r1 = mountRadius - mountPadding - mountWallWidth, r2 = mountRadius - mountPadding - mountWallWidth);
//
//                cutMountingCylinderOut();
//                rotate(90, [0, 0, 1]) {
//                    cutMountingCylinderOut();
//                }
//            }
//        }
//    }
//}
