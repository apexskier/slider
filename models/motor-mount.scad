wallWidth = 2;

motorWidth = 42.3;
motorCircleDiameter = 22;
motorHeight = 34 + .5;
motorDistanceBetweenScrews = 31 + .2;
motorCornerInset = 4;
motorCornerInsetSide = sqrt(2 * pow(motorCornerInset, 2));
motorEdgeHeight = 4;
motorScrewThreadDiameter = 2;
motorScrewDiameter = 3;
motorCounterSinkDiameter = 1;
motorCounterSinkDepth = 1;

fourCorners = [0, 90, 180, 270];

module motorScrewHole() {
    translate([motorDistanceBetweenScrews / 2, motorDistanceBetweenScrews / 2, 0]) {
        translate([0, 0, -1]) {
            cylinder(h = 20, r = motorScrewThreadDiameter, $fn = 80);
            //cylinder(h = 1, r = motorScrewThreadDiameter + motorCounterSinkDiameter, $fn = 80);
        }
        cylinder(h = motorCounterSinkDepth, r1 = motorScrewThreadDiameter + motorCounterSinkDiameter, r2 = motorScrewThreadDiameter, $fn = 80);
    }
}

module motorScrew() {
    difference() {
        translate([motorDistanceBetweenScrews / 2, motorDistanceBetweenScrews / 2, 0]) {
            cylinder(h = 4, r = motorScrewDiameter, $fn = 80);
        }
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
            for (d = fourCorners) {
                rotate(d, [0, 0, 1]) motorScrew();
            }

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
            cylinder(h = 40, d = 22);
        }

        for (d = fourCorners) {
            rotate(d, [0, 0, 1]) motorScrewHole();
        }
    }
}

motorMount();

