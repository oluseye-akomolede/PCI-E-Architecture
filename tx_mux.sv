`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2024 12:54:12 PM
// Design Name: 
// Module Name: tx_mux
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


module tx_mux
    import pcie_pkg::*;
    #(
        parameter num_lanes = 4
    )
    (
        input logic i_clk,
        input logic i_rst,
        input logic i_empty,
        input tx_buffer_record [0:num_lanes/4-1] i_tbr,
        output logic o_ren, //to tx buffer to continuously read bytes
        output mux_union [0:num_lanes/4 - 1] o_mu,
        output logic [0:num_lanes - 1] o_dk_vals
    );
    
    
    const logic [7:0] com_byte = 8'hBC;
    const logic [7:0] pad_byte = 8'hF7;
    const logic [7:0] skp_byte = 8'h1C;
    const logic [7:0] stp_byte = 8'hFB;
    const logic [7:0] sdp_byte = 8'h5C;
    const logic [7:0] end_byte = 8'hFD;
    const logic [7:0] edb_byte = 8'hFE;
    const logic [7:0] fts_byte = 8'h3C;
    const logic [7:0] idl_byte = 8'h7C;
    always_ff @(posedge i_clk) 
    begin
        if (i_rst == 1) begin
            for (int i = 0; i < num_lanes/4; i++) begin
                o_mu[i].mr1.byte1 <= '0;
                o_mu[i].mr1.byte2 <= '0;
                o_mu[i].mr1.byte3 <= '0;
                o_mu[i].mr1.byte4 <= '0;
                
                o_dk_vals[i*4 + 0] <= 0;
                o_dk_vals[i*4 + 1] <= 0;
                o_dk_vals[i*4 + 2] <= 0;
                o_dk_vals[i*4 + 3] <= 0;
            end
        
        end else begin       
            if (i_empty == 0) begin
                for(int i = 0; i < num_lanes/4; i++) begin
                    o_mu[i] <= {idl_byte,idl_byte,idl_byte,idl_byte};  
                    o_dk_vals[i] <= 0;
                    o_dk_vals[i + 1] <= 0;
                    o_dk_vals[i + 2] <= 0;
                    o_dk_vals[i + 3] <= 0;                   
                end
            
            end else begin                
                for(int i = 0; i < num_lanes/4; i++) begin
                    //test for validity here o_mu[i] <= {pad_byte};
                    if (i_tbr[i].valid == 1) begin
                        case (i_tbr[i].byte_tag[0]) 
                            2'b00: begin //no byte tag
                                case (i_tbr[i].start_byte)
                                    2'b00: begin //no start byte
                                        o_mu[i].mr1.byte1 <= i_tbr[i].packet_bytes[7:0];
                                        o_dk_vals[i*4 + 0] <= 1; //D =1 K = 0
                                    end
                                    
                                    2'b01: begin //stp byte
                                        o_mu[i].mr1.byte1 <= stp_byte;
                                        o_dk_vals[i*4 + 0] <= 0;
                                    end
                                    
                                    2'b10: begin //sdp byte
                                        o_mu[i].mr1.byte1 <= sdp_byte;
                                        o_dk_vals[i*4 + 0] <= 0;
                                    end 
                                    
                                    default: begin
                                        o_mu[i].mr1.byte1 <= '0;
                                        o_dk_vals[i*4 + 0] <= 0;
                                    end
                                    
                                endcase
                            end
                            
                            2'b01: begin //COM byte
                                o_mu[i].mr1.byte1 <= com_byte;
                                o_dk_vals[i*4 + 0] <= 0;
                            end
                            
                            2'b10: begin //FTS byte
                                o_mu[i].mr1.byte1 <= fts_byte;
                                o_dk_vals[i*4 + 0] <= 0;
                            end
                            
                            default: begin
                                o_mu[i].mr1.byte1 <= '0;
                                o_dk_vals[i*4 + 0] <= 0;
                            end         
                                                 
                        endcase
                                
                        case (i_tbr[i].byte_tag[1]) 
                            2'b00: begin //no byte tag                         
                                o_mu[i].mr1.byte2 <= i_tbr[i].packet_bytes[15:8];
                                o_dk_vals[i*4 + 1] <= 1; //D =1 K = 0      
                            end
                            
                            2'b01: begin //COM byte
                                o_mu[i].mr1.byte2 <= com_byte;
                                o_dk_vals[i*4 + 1] <= 0;
                            end
                            
                            2'b10: begin //FTS byte
                                o_mu[i].mr1.byte2 <= fts_byte;
                                o_dk_vals[i*4 + 1] <= 0;
                            end
                            
                            default: begin
                                o_mu[i].mr1.byte2 <= '0;
                                o_dk_vals[i*4 + 1] <= 0;
                            end
                                
                        endcase
                        
                        case (i_tbr[i].byte_tag[2]) 
                            2'b00: begin //no byte tag                         
                                o_mu[i].mr1.byte3 <= i_tbr[i].packet_bytes[23:16];
                                o_dk_vals[i*4 + 2] <= 1; //D =1 K = 0      
                            end
                            
                            2'b01: begin //COM byte
                                o_mu[i].mr1.byte3 <= com_byte;
                                o_dk_vals[i*4 + 2] <= 0;
                            end
                            
                            2'b10: begin //FTS byte
                                o_mu[i].mr1.byte3 <= fts_byte;
                                o_dk_vals[i*4 + 2] <= 0;
                            end
                            
                            default: begin
                                o_mu[i].mr1.byte3 <= '0;
                                o_dk_vals[i*4 + 2] <= 0;
                            end
                                
                        endcase
                                  
                        case (i_tbr[i].byte_tag[3]) 
                            2'b00: begin //no byte tag
                                case (i_tbr[i].end_byte)
                                    2'b00: begin //no end byte
                                        o_mu[i].mr1.byte4 <= i_tbr[i].packet_bytes[31:24];
                                        o_dk_vals[i*4 + 3] <= 1; //D =1 K = 0
                                    end
                                    
                                    2'b01: begin //end byte
                                        o_mu[i].mr1.byte4 <= end_byte;
                                        o_dk_vals[i*4 + 3] <= 0;
                                    end
                                    
                                    2'b10: begin //enb byte
                                        o_mu[i].mr1.byte4 <= edb_byte;
                                        o_dk_vals[i*4 + 3] <= 0;
                                    end 
                                    
                                    default: begin
                                        o_mu[i].mr1.byte4 <= '0;
                                        o_dk_vals[i*4 + 3] <= 0;
                                    end
                                    
                                endcase
                            end
                            
                            2'b01: begin //COM byte
                                o_mu[i].mr1.byte4 <= com_byte;
                                o_dk_vals[i*4 + 3] <= 0;
                            end
                            
                            2'b10: begin //FTS byte
                                o_mu[i].mr1.byte4 <= fts_byte;
                                o_dk_vals[i*4 + 3] <= 0;
                            end
                            
                            default: begin
                                o_mu[i].mr1.byte4 <= '0;
                                o_dk_vals[i*4 + 3] <= 0;
                            end
                                
                        endcase
                        
                        
                    end else begin
                        o_mu[i].mr1.byte1 <= pad_byte;
                        o_mu[i].mr1.byte2 <= pad_byte;
                        o_mu[i].mr1.byte3 <= pad_byte;
                        o_mu[i].mr1.byte4 <= pad_byte;
                        
                        o_dk_vals[i*4 + 0] <= 0;
                        o_dk_vals[i*4 + 1] <= 0;
                        o_dk_vals[i*4 + 2] <= 0;
                        o_dk_vals[i*4 + 3] <= 0;
                    end
                   
                end
            
            end
        
        end
        

        
    end
    
endmodule
