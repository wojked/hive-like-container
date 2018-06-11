/* 
    This is the hex that is most likely compatibile with the Hive system 
    HEX_HEIGHT = 65.4;
    WALL_THICKNESS = 4.72;
    DEPTH = 4;
    BACK_WALL_TYPE = 0;
    TOLERANCE = 0.1;
*/

HEX_HEIGHT = 65.4;
WALL_THICKNESS = 4.82;
CONNECTOR_HEIGHT = 4.82;
DEPTH = 4;
BACK_WALL_TYPE = 0;
TOLERANCE = 0.1;

hive_hex(HEX_HEIGHT, WALL_THICKNESS, CONNECTOR_HEIGHT, DEPTH, BACK_WALL_TYPE, TOLERANCE);



module row_of_connectors(cube_width, cube_height, cube_depth, connector_size, position, offset_ratio){
    /*
    This module draws a raw of connectors
    
    */
    x_translation = 0.25*cube_width;    
    y_translation = position*(cube_height/2 + connector_size/2 - connector_size*offset_ratio);      

    for (n = [-1, 0, 1]) {
        translate([x_translation*n,y_translation,0]) 
        hexagon(connector_size, cube_depth*1.0);
        //cube([connector_size, connector_size, connector_size], true);
    }        
}

module cube_with_connectors(dimmensions, connector_size, tolerance) {
    hex_side_width = dimmensions[0];
    hex_height = dimmensions[1];
    hive_depth = dimmensions[2]; 
    
    offset_ratio = 0.8;
    negative_position = -1; 
    positive_position = 1;  
    
    echo (str("Tolerance: ",tolerance, "resulted in connector sizes",
    "\nNEGATIVE: ", connector_size, "\nPOSITIVE:", connector_size-tolerance,"\n"));
        
    union(){
        difference(){
            cube(dimmensions, true);
            row_of_connectors(hex_side_width, hex_height, hive_depth*2, connector_size, 
            negative_position, offset_ratio);
        }

        row_of_connectors(hex_side_width, hex_height, hive_depth, connector_size-tolerance, positive_position, 
        1 - offset_ratio);
    }
}

// Insipired by https://github.com/openscad/MCAD
module hexagon_with_connectors(size, connector_size, height, tolerance) {
  width = size/1.75;
  for (r = [-60, 60, 180]) {
      rotate([0,0,r]) 
      cube_with_connectors([width, size, height], connector_size, tolerance);
  }
}

// Taken from https://github.com/openscad/MCAD
module hexagon(size, height) {
  width = size/1.75;
  for (r = [-60, 0, 60]){
      rotate([0,0,r]) 
      cube([width, size, height], true);
  }
}

function total_height(inner_height, wall_thickness) = 
    /*
    Calculates total height based on inner height and wall thickness
    */
    inner_height + wall_thickness*2;

module back_wall(height, thickness, type){
    /*
    Back wall of the container - optional
    type:
    0 - none
    1 - solid
    2 - openwork (ajour-like), to be done
    */
    
    if (type==0) {
        // no wall
    }
    
    if (type==1) {
        // solid wall
        translate([0,0,thickness/2])
        hexagon(height, thickness);          
    }
}

module hive_hex(base_inner_height, base_wall_thickness, connector_height,
                hive_depth, back_wall_type, 
                tolerance){
    /*
    base_inner_height - this is important to define the inner height compatible with existing drawers
    base_wall_thickness - this defines the 
    */
    base_total_height = total_height(base_inner_height, base_wall_thickness);
    
    union(){
        back_wall(base_total_height, 2, back_wall_type);
        translate([0,0,hive_depth/2]) 
        difference(){
            hexagon_with_connectors(base_total_height, connector_height, hive_depth, tolerance);
            hexagon(base_inner_height, hive_depth*2);
        };
    }
}
