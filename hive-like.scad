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
DEPTH = 10;
BACK_WALL_TYPE = 2;
BACK_WALL_DEPTH = 2;
TOLERANCE = 0.1;

hive_hex(HEX_HEIGHT, WALL_THICKNESS, CONNECTOR_HEIGHT, DEPTH, 
        BACK_WALL_TYPE, BACK_WALL_DEPTH, TOLERANCE);



/*
    Generates the hive_hex.
    
    base_inner_height - this is important to define the inner height compatible with existing drawers
                    
    base_wall_thickness - this defines the thickness of the walls, will affect the total height
*/
module hive_hex(base_inner_height, base_wall_thickness, connector_height, hive_depth, 
                back_wall_type, back_wall_depth,
                tolerance){
    base_total_height = total_height(base_inner_height, base_wall_thickness);
    base_total_depth = hive_depth + back_wall_depth;
                    
    echo(str("Total base height:", base_total_height));                    
    echo(str("Total base depth:", base_total_depth));                    
    
    union(){
        back_wall(base_inner_height, back_wall_type, back_wall_depth);
        
        translate([0,0,base_total_depth/2]) 
        difference(){
            hexagon_with_connectors(base_total_height, connector_height, base_total_depth, tolerance);
            hexagon(base_inner_height, base_total_depth*2);
        };
    }
}

/*
    Generates hexagon of the given size (distance between its parallel edges)
    This version works with my brain a bit better than hexagon in shapes.scad from https://github.com/openscad/MCAD    
*/
module hexagon(size, height) {
  angle_step = 60;    // Every box

  // Iterate 3 times    
  for (n = [0:1:2]){
      rotate([0,0, n*angle_step]) 
      cube([edge_length(size), size, height], true);
  }
}


/*
    Generates the hive_hex's back wall.

    Back wall of the container - optional
    type:
    0 - none
    1 - solid
    2 - openwork (ajour-like)
    
*/
module back_wall(height, type, depth){
    if (type==0) {
        // no wall
    }
    
    if (type==1) {
        // solid wall
        translate([0,0,depth/2]) 
        hexagon(height, depth);          
    }
    
    if (type==2) {
        // ajour
        color("red");
        wall_thickness = 4;
        empty_hexagonagon_height = (height + wall_thickness) / 2;
        
        translate([0,0,depth/2])         
        intersection(){
            union(){
                
                empty_hexagon(empty_hexagonagon_height, wall_thickness, depth);
                for (r = [-150, -90, -30, 30, 90, 150]){
                    rotate([0,0,r]) 
                    translate([empty_hexagonagon_height - wall_thickness/2, 0, 0])
                    rotate([0,0,-r]) 
                    empty_hexagon(empty_hexagonagon_height, 4, depth);
                }            
            };
            hexagon(height+depth/2, depth*2);
        }

    }    
}



module row_of_connectors(cube_width, cube_height, cube_depth, connector_size, position, offset_ratio){
    /*
    This module draws a raw of connectors
    
    */
    x_translation = 0.22*cube_width;    
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


/*
    Modified version of the hexagon.
*/
module hexagon_with_connectors(size, connector_size, height, tolerance) {
  angle_step = 60*2;   // Every second box

  // Iterate 3 times
  for (n = [0:1:2]){
      rotate([0,0, n*angle_step]) 
      cube_with_connectors([edge_length(size), size, height], connector_size, tolerance);
  }
}

/*
    Calculates total height based on inner height and wall thickness
*/
function total_height(inner_height, wall_thickness) = inner_height + wall_thickness*2;

/*
    Calculates the hexagon edge length
*/
function edge_length(size) = size*0.5774; 


module empty_hexagon(height, wall_thickness, depth){
    difference(){
        hexagon(height, depth);
        hexagon(height-wall_thickness, depth*2);
    }       
}
