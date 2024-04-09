`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2024 12:28:26 AM
// Design Name: 
// Module Name: top_stripe_test
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

import pcie_pkg::*;
import striper_pkg::*;
module top_stripe_test(

    );
    
    localparam lp_num_lanes = 4;
    logic rst, clk;
    initial begin
        rst = 0;
        clk = 0;
        #5ns rst = 1;
        #5ns clk = 1;
        #5ns rst = 0; clk = 0;
        forever
            #5ns clk = ~clk;
        
    end
    
    striper_ifc #(.num_lanes(lp_num_lanes)) rx(clk,rst);
    byte_striper #(.num_lanes(lp_num_lanes)) bs(rx);
    stripe_test #(.num_lanes(lp_num_lanes)) t1(rx,rst);
        

    
    
    
    
    
endmodule
