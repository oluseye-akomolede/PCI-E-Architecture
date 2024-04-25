`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2024 07:25:44 PM
// Design Name: 
// Module Name: striper_pkg
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
import tb_base_pkg::*;
interface striper_ifc
#(
    parameter num_lanes = 4
)
(
    input logic i_clk,
    input logic i_rst
);

    mux_union [0:num_lanes/4 - 1] i_mu;
    logic [0:num_lanes - 1] i_d_k_vals;
    stripe_record [0:num_lanes - 1] o_stripe_lane;
    
    modport DUT
    (
        output o_stripe_lane,
        input i_mu, i_d_k_vals, i_clk, i_rst
        
    );
    
    clocking cbr @(posedge i_clk);
        input o_stripe_lane;
        output i_mu, i_d_k_vals;
    endclocking: cbr
    
    modport TB
    (
        clocking cbr
    );
    
endinterface: striper_ifc

package striper_pkg;
    import pcie_pkg::*;
    import tb_base_pkg::*;
    typedef virtual striper_ifc v_stripe_ifc;
    typedef virtual striper_ifc.TB v_stripe_ifct;
    
   
    
    typedef class stripe_output_cell;
    typedef stripe_output_cell soc [];
    
    class stripe_packer extends transaction_packer;
        `svm_object_utils(stripe_packer);
        mux_union to1;
        bit[3:0] d_k;
        
    endclass

    class stripe_cell extends BaseTr;
        `svm_object_utils(stripe_cell);
        rand bit [7:0] byte1;
        rand bit [7:0] byte2;
        rand bit [7:0] byte3;
        rand bit [7:0] byte4;
        rand bit [3:0] d_k;
        
        //virtual and default functions------------------------------
        extern function new();
        extern function void post_randomize();
        extern function bit compare(input BaseTr to);
        extern function void display(input string prefix = "");
        extern function stripe_cell copy(input BaseTr to = null);
        extern function void pack(output transaction_packer p);
        extern function void unpack(input transaction_packer p);
        //------------------------------------------------------------
        
        
        extern function soc to_stripe_output();
        
        
    endclass: stripe_cell
    
    class stripe_output_cell extends BaseTr;
        `svm_object_utils(stripe_output_cell);
        bit [7:0] striped_byte;
        bit d_k;
        
        //virtual and default functions------------------------------
        extern function new();
        extern function void post_randomize();
        extern function bit compare(input BaseTr to);
        extern function void display(input string prefix = "");
        extern function stripe_output_cell copy(input BaseTr to = null);
        function void pack(output transaction_packer p);
        endfunction
        
        function void unpack(input transaction_packer p);
        endfunction
        //------------------------------------------------------------
    endclass: stripe_output_cell
    //end transaction definitions----------------------------------------------------------------------------


    function stripe_cell::new();
        
    endfunction: new
    
    function void stripe_cell::post_randomize();

    endfunction: post_randomize
    
    function bit stripe_cell::compare(input BaseTr to);
        stripe_cell c;
        $cast(c,to);
        if (this.byte1 != c.byte1) return 0;
        if (this.byte2 != c.byte2) return 0;
        if (this.byte3 != c.byte3) return 0;
        if (this.byte4 != c.byte4) return 0;
        if (this.d_k != c.d_k) return 0;
        return 1;
    endfunction: compare
    
    function void stripe_cell::display(input string prefix = "");
        
        $display("%s byte1 = %x, byte2 = %x, byte3 = %x, byte4 = %x, d_k = %x",
                 prefix,
                 byte1,
                 byte2,
                 byte3,
                 byte4,
                 d_k);
                 
                 
    endfunction: display
    
    function stripe_cell stripe_cell::copy(input BaseTr to);
        if (to == null) copy = new();
        else $cast(copy,to);
        copy.byte1 = this. byte1;
        copy.byte2 = this. byte2;
        copy.byte3 = this. byte3;
        copy.byte4 = this. byte4;
        copy.d_k = this. d_k;
        
    endfunction: copy
    
    function void stripe_cell::pack(output transaction_packer p);
        stripe_packer outp = stripe_packer::type_ido::create("stripe_packer");
        outp.to1.mr1.byte1 = this.byte1;
        outp.to1.mr1.byte2 = this.byte2;
        outp.to1.mr1.byte3 = this.byte3;
        outp.to1.mr1.byte4 = this.byte4;
        
        outp.d_k = this.d_k;
        
        $cast(p,outp);
        
    
        
    endfunction: pack
    
    function void stripe_cell::unpack(input transaction_packer p);
        stripe_packer inp;
        $cast(inp,p);
        this.byte1 = inp.to1.mr1.byte1;
        this.byte2 = inp.to1.mr1.byte2;
        this.byte3 = inp.to1.mr1.byte3;
        this.byte4 = inp.to1.mr1.byte4;
        this.d_k = inp.d_k;
    endfunction: unpack
    
    function soc stripe_cell::to_stripe_output();
        stripe_output_cell outp[4];
        
        foreach(outp[i])
        begin
            outp[i] = new();
        end
        
        outp[0].striped_byte = this.byte1;
        outp[0].d_k = this.d_k[0];
        
        outp[1].striped_byte = this.byte2;
        outp[1].d_k = this.d_k[1];
        
        outp[2].striped_byte = this.byte3;
        outp[2].d_k = this.d_k[2];
        
        outp[3].striped_byte = this.byte4;
        outp[3].d_k = this.d_k[3];
        
        return outp; 
    endfunction: to_stripe_output
    
    
    function stripe_output_cell::new();
    
    endfunction: new
    
    function void stripe_output_cell::post_randomize();
    
    endfunction: post_randomize
    
    function bit stripe_output_cell::compare(input BaseTr to);
    
        stripe_output_cell c;
        $cast(c,to);
        if(this.striped_byte != c.striped_byte)return 0;
        if(this.d_k != c.d_k)return 0;
        
        return 1;
    
    endfunction:compare
    
    function void stripe_output_cell::display(input string prefix = "");
        $display("%s striped_byte = %x d_k value = %x",prefix,
                 striped_byte, d_k);
    endfunction: display
    
    function stripe_output_cell stripe_output_cell::copy(input BaseTr to = null);
        if (to == null) copy = new();
        else $cast(copy,to);
        copy.striped_byte = this.striped_byte;
        copy.d_k = this.d_k;
    endfunction: copy
    
    
    
    //--------------------------------------------------------------------------------------------------
    //Config Class and all definitions. Config sets up environment parameters are randomizes them.------
    class stripe_env_config extends svm_env_config;
        `svm_config_utils(stripe_env_config);
        static virtual striper_ifc.TB rx;
        static virtual striper_ifc.TB tx;
        
        extern function new();
        extern virtual function void display(input string prefix = "");
    endclass: stripe_env_config
    
    function stripe_env_config::new();
    endfunction: new
    
    function void stripe_env_config::display(input string prefix = "");
        $write("%sConfig: num_ops = %0d",prefix,num_ops);
        $display;
    endfunction: display
    //--------------------------------------------------------------------------------------------------
    
    typedef class stripe_scoreboard;
    
    //Generator class. Generates transactions based off of blueprints and uses mailboxes to pass to the driver class.
    class stripe_op_generator extends svm_generator;
        `svm_component_utils(stripe_op_generator);
        
        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction
        
        virtual function void set_override();
            BaseTr::type_ido::set_type_override(stripe_cell::get_type());
        endfunction: set_override
        
    endclass: stripe_op_generator
    //--------------------------------------------------------------------------------------------------    
    
 //Driver class and Driver callback class. Handles all driving of signals----------------------------
    //typedef class stripe_driver_cbs;
    
    class stripe_driver_config extends svm_driver_config;
       `svm_config_utils(stripe_driver_config);
       static v_stripe_ifct rx; //virtual ifc for transmitting operands
    endclass: stripe_driver_config
    
    class stripe_driver extends svm_driver;     
        `svm_component_utils(stripe_driver); 
        
        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction
          
        extern virtual function void set_override();
        extern virtual task initialize();
        extern virtual task send(input BaseTr c);
        extern virtual task run();
    endclass: stripe_driver
    

    task stripe_driver::run();
        BaseTr c;
//        rx.cbr.i_mu[drv_num].mr2 <= '0;
//        rx.cbr.i_d_k_vals[4*drv_num + 0] <= 0;
//        rx.cbr.i_d_k_vals[4*drv_num + 1] <= 0;
//        rx.cbr.i_d_k_vals[4*drv_num + 2] <= 0;
//        rx.cbr.i_d_k_vals[4*drv_num + 3] <= 0;
        initialize();
        
        
        forever 
        begin
            //read transaction at the front of the mailbox
            gen2drv.peek(c);
            begin: tx
                //pre-transmit callbacks
                foreach(cbsq[i]) 
                begin
                    cbsq[i].pre_tx(this, c);
                end
                c.display($sformatf("@%0t: Drv%0d: ", $time,0));
                send(c);
                //post-transmit callbacks
                foreach(cbsq[i])
                begin
                    cbsq[i].post_tx(this,c);
                end
            end: tx
            gen2drv.get(c); //remove cell from the mailbox
            ->drv2gen;
        end
    endtask: run
    
    function void stripe_driver::set_override();
        svm_driver_config::type_idc::set_type_override(stripe_driver_config::get_type());
    endfunction: set_override
    
    task stripe_driver::initialize();
        stripe_driver_config c_cfg;
        if(d_cfg == null) $display("driver config is null!");
        $cast(c_cfg,d_cfg);
        
        c_cfg.rx.cbr.i_mu[drv_num].mr2 <= '0;
        c_cfg.rx.cbr.i_d_k_vals[4*drv_num + 0] <= 0;
        c_cfg.rx.cbr.i_d_k_vals[4*drv_num + 1] <= 0;
        c_cfg.rx.cbr.i_d_k_vals[4*drv_num + 2] <= 0;
        c_cfg.rx.cbr.i_d_k_vals[4*drv_num + 3] <= 0;        
    endtask: initialize
    
    task stripe_driver::send(input BaseTr c);
        mux_union pkt;
        bit [3:0] d_ks;
        stripe_driver_config c_cfg;
        transaction_packer p;
        stripe_cell sc;
        stripe_packer s;
        
        $cast(sc,c);
        sc.pack(p);  
        $cast(s,p);

        
        $cast(c_cfg,d_cfg);

        c.display($sformatf("@%0tSending cell: ",$time));
        @(c_cfg.rx.cbr);
        c_cfg.rx.cbr.i_mu[drv_num] <= s.to1;
        c_cfg.rx.cbr.i_d_k_vals[4*drv_num + 0] <= s.d_k[0];
        c_cfg.rx.cbr.i_d_k_vals[4*drv_num + 1] <= s.d_k[1];
        c_cfg.rx.cbr.i_d_k_vals[4*drv_num + 2] <= s.d_k[2];
        c_cfg.rx.cbr.i_d_k_vals[4*drv_num + 3] <= s.d_k[3];
        @(c_cfg.rx.cbr);
    endtask: send
    

    
    class stripe_monitor_config extends svm_monitor_config;
        `svm_config_utils(stripe_monitor_config);
        static v_stripe_ifct tx;
    endclass: stripe_monitor_config
    
    class stripe_monitor extends svm_monitor;
        `svm_component_utils(stripe_monitor);
        
        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction
        
        extern task receive (output BaseTr c);
        extern function void set_override();
        extern virtual task run();
    endclass: stripe_monitor
    
    task stripe_monitor::run();
        BaseTr c;
        forever begin
            receive(c);
            foreach(cbsq[i])
                cbsq[i].post_rx(this,c); //post-receive callback
        end
    endtask: run
    
    
    task stripe_monitor::receive(output BaseTr c);
        stripe_output_cell s;
        stripe_monitor_config s_cfg;
        
        $cast(s_cfg,this.m_cfg);
        
        @(s_cfg.tx.cbr);        
        s = new();
        s.striped_byte = s_cfg.tx.cbr.o_stripe_lane[this.mon_num].striped_byte;
        s.d_k = s_cfg.tx.cbr.o_stripe_lane[this.mon_num].d_k;
        s.display($sformatf("@%0t: Mon%0d: ", $time,0));
        @(s_cfg.tx.cbr);
        $cast(c,s);
    endtask:receive
    
    function void stripe_monitor::set_override();
        svm_monitor_config::type_idc::set_type_override(stripe_monitor_config::get_type());
    endfunction: set_override
    

    
    class stripe_scoreboard extends svm_scoreboard;
        `svm_component_utils(stripe_scoreboard);
        
        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction

        extern virtual function void set_disabled(input int gen_num);
        extern virtual function void save_expected(input BaseTr m_cell, input int drv_num);
        
        virtual function void set_override();
        endfunction: set_override

    endclass: stripe_scoreboard
    

    
    function void stripe_scoreboard::set_disabled(input int gen_num);
        expect_cells[4*gen_num + 0].disabled = 1;
        expect_cells[4*gen_num + 1].disabled = 1;
        expect_cells[4*gen_num + 2].disabled = 1;
        expect_cells[4*gen_num + 3].disabled = 1;
    endfunction:set_disabled
    
    function void stripe_scoreboard::save_expected(input BaseTr m_cell, input int drv_num);
        stripe_cell s;
        stripe_output_cell o_cell[4]; 
        $cast(s,m_cell);
        o_cell = s.to_stripe_output();
        o_cell[0].display($sformatf("@%0t: Scb save:", $time ));
        o_cell[1].display($sformatf("@%0t: Scb save:", $time ));
        o_cell[2].display($sformatf("@%0t: Scb save:", $time ));
        o_cell[3].display($sformatf("@%0t: Scb save:", $time ));
        //o_cell.display();
        expect_cells[4*drv_num + 0].q.push_back(o_cell[0]);
        expect_cells[4*drv_num + 0].i_expect++;
        i_expect++;
        
        expect_cells[4*drv_num + 1].q.push_back(o_cell[1]);
        expect_cells[4*drv_num + 1].i_expect++;
        i_expect++;
        
        expect_cells[4*drv_num + 2].q.push_back(o_cell[2]);
        expect_cells[4*drv_num + 2].i_expect++;
        i_expect++;
        
        expect_cells[4*drv_num + 3].q.push_back(o_cell[3]);
        expect_cells[4*drv_num + 3].i_expect++;
        i_expect++;
    endfunction: save_expected
    

    
    class stripe_coverage extends svm_coverage;
        `svm_object_utils(stripe_coverage);
        covergroup cg_stripe;
            
        endgroup: cg_stripe
        
        function new();
            cg_stripe = new();
        endfunction: new 
        
        virtual function void sample();
            $display("@%0t: Coverage: None", $time);
            cg_stripe.sample();
        endfunction: sample
    endclass: stripe_coverage
    
    
    

    
    class stripe_environment extends svm_environment;
        `svm_component_utils(stripe_environment);
//        virtual striper_ifc.TB rx;
//        virtual striper_ifc.TB tx;

        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction
        
        extern virtual task run();
        extern virtual function void set_override();
        extern virtual function void set_configs();
    endclass: stripe_environment
    
    function void stripe_environment::set_override();
        svm_generator::type_id::set_type_override(stripe_op_generator::get_type());
        svm_driver::type_id::set_type_override(stripe_driver::get_type());
        svm_monitor::type_id::set_type_override(stripe_monitor::get_type());
        svm_scoreboard::type_id::set_type_override(stripe_scoreboard::get_type());
        svm_coverage::type_ido::set_type_override(stripe_coverage::get_type());
        svm_env_config::type_idc::set_type_override(stripe_env_config::get_type());
    endfunction: set_override
    
    function void stripe_environment::set_configs();
        stripe_env_config s_cfg;
        
        stripe_driver_config sdrv = stripe_driver_config::type_idc::create("stripe_driver_config");
        stripe_monitor_config smon = stripe_monitor_config::type_idc::create("stripe_monitor_config");
        
        $cast(s_cfg,cfg);
        
        sdrv.rx = s_cfg.rx;
        smon.tx = s_cfg.tx;
        
    endfunction: set_configs
    
    task stripe_environment::run();
        int num_gen_running;
        stripe_env_config s_cfg;
        num_gen_running = num_lanes/4;
        
        
        $cast(s_cfg,cfg);
        foreach(gen[i])
        begin
            int j = i;
            fork
                begin //statements inside a fork join block run concurrently. use begin..end statements to control this
                    
                    gen[j].run();
                    num_gen_running--;
                end
                drv[j].run();
            join_none
        end
        foreach(mon[i])
        begin
            int j = i;
            fork
                mon[j].run();
            join_none
        end
        
        fork: timeout_block //used to control with a disable statement
            wait (num_gen_running == 0);
            begin
                repeat(1_000_000) @(s_cfg.tx.cbr);
                $display("@%0t: %m ERROR: Generator timeout ", $time);
                s_cfg.num_errors++;
            end
        join_any
        
        disable timeout_block;
        
        //wait for data to flow through the device and into monitors and scoreboards
        repeat (1_000) @(s_cfg.tx.cbr);
    endtask:run
    
            
endpackage: striper_pkg