// Dependencies from https://github.com/openscad/MCAD

include <shapes.scad>

base_inner_height = 10;
base_wall_thickness = 1;
base_total_height = base_inner_height + 2*base_wall_thickness;

hive_depth = 2;

main_hex();



module special_cube(dimensions, center) {
    cube(dimensions, center);
    width = dimensions[0];
    size = dimensions[1];
    height = dimensions[2];
}

module hexagon_sides(size, height, positive) {
  boxWidth = size/1.75;
  for (r = [-60, 0, 60]) rotate([0,0,r]) connectors(boxWidth, height, positive);  
}

module connectors(width, height, position) {        
    for (n = [-1, 0, 1]) translate([0.9*height*n*position,0.9*width*position,0]) hexagon(1, height*2);
}


module open_hex() {
    difference(){
        hexagon(base_total_height, hive_depth);
        hexagon(base_inner_height, hive_depth*2);
    }    
}

module main_hex(){
    difference(){

        union(){
            open_hex();  
            hexagon_sides(base_total_height, hive_depth, 1);
        };
        hexagon_sides(base_total_height, hive_depth, -1);
    }
}