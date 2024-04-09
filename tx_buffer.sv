`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2024 07:58:10 PM
// Design Name: 
// Module Name: tx_buffer
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


module tx_buffer
    import pcie_pkg::*;
    #( parameter depth = 4,
       parameter num_lanes = 4
    )
    (
    
        input logic i_clk,
        input logic i_rst,
        input logic i_wren,
        input logic i_ren,
        input tx_buffer_record [0:num_lanes/4-1] i_tbr,
        output logic o_throttle,
        output logic o_empty,
        
        output tx_buffer_record [0:num_lanes/4-1] o_tbr
    );
    
    tx_buffer_record [depth - 1:0] [0: num_lanes/4 - 1] tx_buff; //this is the actual buffer that we will be adding to
    integer fifo_count = 0;
    integer write_index = 0;
    integer read_index = 0;
    
    always_ff @ (posedge i_clk) 
    begin 
        if (i_rst == 1) begin
            fifo_count <= 0;
            write_index <= 0;
            read_index <= 0;
            
            for (int i = 0; i < depth; i++) begin
                for (int j = 0; j < num_lanes/4; j++) begin
                    tx_buff[i][j] <= '0;
                end
            end
            
        end else begin
            if (i_wren == 1 && i_ren == 0) begin
                tx_buff[write_index] <= i_tbr;
                fifo_count <= fifo_count + 1;
                //fifo_count++;
            end else if (i_ren == 1 && i_wren == 0 && fifo_count > 0) begin
                o_tbr <= tx_buff[read_index];
                fifo_count <= fifo_count - 1;
                //fifo_count--;
            end else if (i_wren == 1 && i_ren == 1 && fifo_count > 0 && fifo_count < depth ) begin
                o_tbr <= tx_buff[read_index];
                tx_buff[write_index] <= i_tbr;
                //fifo_count stays the same
            end else begin
                //do nothing
                o_tbr = '0;
            end
            
            if (i_wren == 1 && fifo_count < depth ) begin
                if (write_index >= depth - 1) begin
                    write_index <= 0;
                end else begin
                    write_index <= write_index + 1;
                end 
            end else begin
            end
            
            if (i_ren ==1 && fifo_count > 0) begin
                if (read_index >= depth - 1) begin
                    read_index <= 0;
                end else begin
                    read_index <= read_index + 1;
                end
            end else begin
            end 
            
            if(fifo_count == depth)
                o_throttle <= 1;
            else
                o_throttle <= 0;
                
            if(fifo_count == 0)
                o_empty <= 1;
            else
                o_empty <= 0;        
        
        end

            
        
    end;
endmodule
