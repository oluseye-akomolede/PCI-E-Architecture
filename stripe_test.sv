`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 04:27:14 AM
// Design Name: 
// Module Name: test
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
program automatic stripe_test
    #(
        parameter num_lanes = 4
    )
    (
        striper_ifc.TB rx,
        input logic i_rst
    );
    
    
    stripe_environment env;
    initial begin
        //env = new(rx,rx,num_lanes);
        stripe_env_config s_cfg;
        env = stripe_environment::type_id::create("stripe_environment",null);
        env.set_override();
        env.init(num_lanes);
        
        $cast(s_cfg,env.cfg);
        s_cfg.rx = rx;
        s_cfg.tx = rx;
        $cast(env.cfg,s_cfg);
        env.set_configs();
        env.gen_cfg();
        env.build_phase();
        env.run();
        env.wrap_up();
    end
    
endprogram //stripe_test
