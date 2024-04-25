`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2024 11:22:55 PM
// Design Name: 
// Module Name: byte_striper
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


module byte_striper
    import pcie_pkg::*;
    import striper_pkg::*;
    #(
        parameter num_lanes = 4
    )
    (
        i_striper_ifc.DUT in,
        o_striper_ifc.DUT out
    );
    
    always_ff @(posedge in.i_clk,posedge in.i_rst) 
    begin
        if (in.i_rst == 1) begin
            for(int i = 0; i < num_lanes/4; i++) begin
                out.o_stripe_lane[i + 0].striped_byte <= '0;
                out.o_stripe_lane[i + 1].striped_byte <= '0;
                out.o_stripe_lane[i + 2].striped_byte <= '0;
                out.o_stripe_lane[i + 3].striped_byte <= '0;
                
                out.o_stripe_lane[i + 0].d_k <= 0;
                out.o_stripe_lane[i + 1].d_k <= 0;
                out.o_stripe_lane[i + 2].d_k <= 0;
                out.o_stripe_lane[i + 3].d_k <= 0;
            end
        end else begin
            for(int i = 0; i < num_lanes/4; i++) begin
                out.o_stripe_lane[i + 0].striped_byte <= in.i_mu[i].mr1.byte1;
                out.o_stripe_lane[i + 1].striped_byte <= in.i_mu[i].mr1.byte2;
                out.o_stripe_lane[i + 2].striped_byte <= in.i_mu[i].mr1.byte3;
                out.o_stripe_lane[i + 3].striped_byte <= in.i_mu[i].mr1.byte4;
                
                out.o_stripe_lane[i + 0].d_k <= in.i_d_k_vals[i + 0];
                out.o_stripe_lane[i + 1].d_k <= in.i_d_k_vals[i + 1];
                out.o_stripe_lane[i + 2].d_k <= in.i_d_k_vals[i + 2];
                out.o_stripe_lane[i + 3].d_k <= in.i_d_k_vals[i + 3];
            end    
        end

    end
    
endmodule
