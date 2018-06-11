
base_inner_height = 10;
base_wall_thickness = 1;
base_total_height = base_inner_height + 2*base_wall_thickness;

hive_depth = 1;

main_hex();


// Insipired by https://github.com/openscad/MCAD
module hexagon(size, height) {
  boxWidth = size/1.75;
  for (r = [-60, 0, 60]) rotate([0,0,r]) cube([boxWidth, size, height], true);
}

module negative_connectors(width, height){
    position = -1;
    for (n = [-1, 0, 1]) translate([0.24*width*n*position,0.9*width*position,0]) hexagon(1, 2*height);
}

module positive_connectors(width, height){
    position = 1;
    for (n = [-1, 0, 1]) translate([0.24*width*n*position,0.9*width*position,0]) hexagon(1, height);
}

module cube_with_connectors(dimmensions, center) {
    width = dimmensions[0];
    size = dimmensions[1];
    height = dimmensions[2]; 
    union(){
        difference(){
            cube(dimmensions, center);
            negative_connectors(width, height);
        }
        positive_connectors(width, height);
    }

}

module hexagon_with_connectors(size, height) {
  boxWidth = size/1.75;
  for (r = [-60, 60, 180]) rotate([0,0,r]) cube_with_connectors([boxWidth, size, height], true);
}

module main_hex(){
    difference(){
        hexagon_with_connectors(base_total_height, hive_depth);
        hexagon(base_inner_height, hive_depth*2);
    }    
}
