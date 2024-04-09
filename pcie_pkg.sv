`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2024 07:58:10 PM
// Design Name: 
// Module Name: pcie_pkg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


package pcie_pkg;
    localparam PCIE_NUM_LANES = 1;
    typedef struct packed {
        logic valid;
        logic [1:0] start_byte; //00 - none, 01 - STP, 10 - SDP
        logic [1:0] end_byte; //00 -none, 01 - END, 10 - EDB
        logic [0:3] [1:0] byte_tag;   //00 - none, 01 - COM, 10 - FTS
        logic [31:0] packet_bytes;
    
    }tx_buffer_record;
    
    typedef struct packed {
        logic [7:0] byte1;
        logic [7:0] byte2;
        logic [7:0] byte3;
        logic [7:0] byte4;
    }mux_record1;
    
    typedef struct packed {
        logic [31:0] cont_bytes;
    }mux_record2;
    
    typedef union packed {
        mux_record1 mr1;
        mux_record2 mr2;
    }mux_union;
    
    typedef struct packed {
        logic d_k; //1 - D, 0 - K
        logic [7:0] striped_byte;
    } stripe_record;

    typedef enum logic [31:0]{
        idle,
        output_data
    }t_state;


    //Utility functions---------------------------------------------------------------------------
    `define SV_RAND_CHECK(r) \
        do begin \
            if(!(r)) begin \
                $display("%s:%0d: Randomization failed \"%s\"",\
                            `__FILE__, `__LINE__, `"r`"); \
                $finish; \
            end \
        end while(0)
        
    //end utility functions-----------------------------------------------------------------------

endpackage: pcie_pkg
