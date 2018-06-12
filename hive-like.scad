/* [Global] */

// What is the desired distance between two parallel edges of the main hex, so that the drawer would fit ?
hexagon_height = 65.4;

// What is depth of the main hex, so that the drawer would fit? (distance from the front edge to the beginning of the back wall)
hexagon_depth = 20; //

// What is the type of the back wall?
back_wall_type = 2; // [0:None,1:Solid,2:Openwork]

// What is the depth of the back wall? (it will be added to the total depth)
back_wall_depth = 2; // [0:10];

// What is the desired thickness of the main hex, so that it is sturdy enough?
wall_thickness = 4.82;

// What is the desired distance of two parallel edges of the connector hex? 
connector_heigth = 4.82;

// Tolerance reduces the positive connector size, so it is more likely it fits.
connector_tolerance = 0.0;    // [0.0:0.01:4.0]

// What fraction of the connector should be "hidden" within the main hex body.
connector_offset  = 0.8; // [0.1:0.1:0.99]


/* 
    This is the hex that is most likely compatibile with the Hive system 
*/

/*
    Print the part !
    With the defaults, it is most likely compatibile with the Hive system 
*/
hive_hex(hexagon_height, wall_thickness, connector_heigth, connector_offset, connector_tolerance, hexagon_depth, back_wall_type, back_wall_depth);


/*
    Generates the hive_hex.
    
    base_inner_height - this is important to define the inner height compatible with existing drawers
                    
    base_wall_thickness - this defines the thickness of the walls, will affect the total height
*/
module hive_hex(base_inner_height, base_wall_thickness, connector_height, connector_offset, connector_tolerance, hive_depth, back_wall_type, back_wall_depth){
    base_total_height = total_height(base_inner_height, base_wall_thickness);
    base_total_depth = hive_depth + back_wall_depth;
                    
//    echo(str("Total base height:", base_total_height));                    
//    echo(str("Total base depth:", base_total_depth));                    
    
    union(){
        back_wall(base_inner_height, back_wall_type, back_wall_depth);
        
        translate([0,0,base_total_depth/2]) 
        difference(){
            hexagon_with_connectors(base_total_height, connector_height, connector_offset, connector_tolerance, base_total_depth);
            hexagon(base_inner_height, base_total_depth*2);
        };
    }
}

/*
    Generates hexagon of the given size (distance between its parallel edges)
    This version works with my brain a bit better than hexagon in shapes.scad from https://github.com/openscad/MCAD    
*/
module hexagon(size, height) {
  angle_step = 60;
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
    2 - openwork (ajour)
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
        hollow_hexagon_height = (height + wall_thickness) / 2;
        
        translate([0,0,depth/2])         
        intersection(){
            union(){
                
                hollow_hexagon(hollow_hexagon_height, wall_thickness, depth);
                for (r = [-150, -90, -30, 30, 90, 150]){
                    rotate([0,0,r]) 
                    translate([hollow_hexagon_height - wall_thickness/2, 0, 0])
                    rotate([0,0,-r]) 
                    hollow_hexagon(hollow_hexagon_height, 4, depth);
                }            
            };
            hexagon(height+depth/2, depth*2);
        }
    }    
}


module connectors_set(cube_width, cube_height, cube_depth, connector_size, position, offset_ratio){
    /*
    This module draws a set of connectors (a row of connectors)
    */
    x_translation = 0.22*cube_width;    
    y_translation = position*(cube_height/2 + connector_size/2 - connector_size*offset_ratio);      

    for (n = [-1, 0, 1]) {
        translate([x_translation*n,y_translation,0]) 
        hexagon(connector_size, cube_depth*1.0);
    }        
}

module cube_with_connectors(dimmensions, connector_size, connector_offset, connector_tolerance) {
    hex_side_width = dimmensions[0];
    hex_height = dimmensions[1];
    hive_depth = dimmensions[2]; 
    
    negative_position = -1; 
    positive_position = 1;  
    
//    echo (str("Connector tolerance: ",connector_tolerance, "resulted in connector sizes", "\nNEGATIVE: ", connector_size, "\nPOSITIVE:", connector_size-connector_tolerance,"\n"));
        
    union(){
        difference(){
            cube(dimmensions, true);
            connectors_set(hex_side_width, hex_height, hive_depth*2, connector_size, 
            negative_position, connector_offset);
        }

        connectors_set(hex_side_width, hex_height, hive_depth, connector_size-connector_tolerance, positive_position, 
        1 - connector_offset);
    }
}


/*
    Modified version of the hexagon.
*/
module hexagon_with_connectors(size, connector_size, connector_offset, connector_tolerance, height) {
  angle_step = 60*2;   // Every second box

  // Iterate 3 times
  for (n = [0:1:2]){
      rotate([0,0, n*angle_step]) 
      cube_with_connectors([edge_length(size), size, height], connector_size, connector_offset, connector_tolerance);
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


module hollow_hexagon(height, wall_thickness, depth){
    difference(){
        hexagon(height, depth);
        hexagon(height-wall_thickness, depth*2);
    }       
}
