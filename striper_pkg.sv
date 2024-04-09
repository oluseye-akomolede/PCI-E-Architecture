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
    typedef virtual striper_ifc v_stripe_ifc;
    typedef virtual striper_ifc.TB v_stripe_ifct;
    
    virtual class BaseTr;
        static int count;
        int id;
        
        function new();
            id = count++;
        endfunction
        
        pure virtual function bit compare(input BaseTr to);
        pure virtual function BaseTr copy(input BaseTr to = null);
        pure virtual function void display(input string prefix = "");     
    endclass: BaseTr    
    
    typedef class stripe_output_cell;
    typedef stripe_output_cell soc [];

    class stripe_cell extends BaseTr;
        rand bit [7:0] byte1;
        rand bit [7:0] byte2;
        rand bit [7:0] byte3;
        rand bit [7:0] byte4;
        rand bit [3:0] d_k;
        
        
        extern function new();
        extern function void post_randomize();
        extern function bit compare(input BaseTr to);
        extern function void display(input string prefix = "");
        extern function stripe_cell copy(input BaseTr to = null);
        extern function void pack(output mux_union to1, output bit[3:0] d_k);
        extern function void unpack(input mux_union from, input bit [3:0] d_k);
        extern function soc to_stripe_output();
        
        
    endclass: stripe_cell
    
    class stripe_output_cell extends BaseTr;
        bit [7:0] striped_byte;
        bit d_k;
        extern function new();
        extern function void post_randomize();
        extern function bit compare(input BaseTr to);
        extern function void display(input string prefix = "");
        extern function stripe_output_cell copy(input BaseTr to = null);
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
    
    function void stripe_cell::pack(output mux_union to1, output bit[3:0] d_k);
        
        to1.mr1.byte1 = this.byte1;
        to1.mr1.byte2 = this.byte2;
        to1.mr1.byte3 = this.byte3;
        to1.mr1.byte4 = this.byte4;
        
        d_k = this.d_k;
        
    
        
    endfunction: pack
    
    function void stripe_cell::unpack(input mux_union from, input bit [3:0] d_k);
        this.byte1 = from.mr1.byte1;
        this.byte2 = from.mr1.byte2;
        this.byte3 = from.mr1.byte3;
        this.byte4 = from.mr1.byte4;
        this.d_k = d_k;
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
    class stripe_env_config;
        int num_errors;
        int num_warnings;
        rand bit [31:0] num_ops; //total number of addition operations
        
        constraint c_num_ops_valid {num_ops > 0;}
        constraint c_num_ops_reasonable {num_ops < 1000;}
        
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
    class stripe_op_generator;
        stripe_cell blueprint; //blueprint for generator
        stripe_scoreboard scb;
        mailbox gen2drv; //mailbox to driver for transactions
        event drv2gen; //event from our driver for once it's done
        int num_ops; //number of operations
        int gen_num; //the generator number that we are. The number of lanes is a multiple of four. This generates for 4 lanes at a time.
        
        function new(input mailbox gen2drv,
                     input event drv2gen,
                     input stripe_scoreboard scb,
                     input int num_ops,
                     input int gen_num
                     );
                     
            this.gen2drv = gen2drv;
            this.drv2gen = drv2gen;
            this.scb = scb;
            this.num_ops = num_ops;
            this.gen_num = gen_num;
            blueprint = new();             
        endfunction: new     
        
        task run();
            stripe_cell c;
            repeat(num_ops)
            begin
                `SV_RAND_CHECK(blueprint.randomize());
                $cast(c,blueprint.copy());
                c.display($sformatf("@%0t: Gen%0d: ", $time, 0));
                gen2drv.put(c);
                @drv2gen; //wait for the driver to finish with it
            end 
            scb.set_disabled(this.gen_num);        
        endtask: run
        
    endclass: stripe_op_generator
    //--------------------------------------------------------------------------------------------------    
    
 //Driver class and Driver callback class. Handles all driving of signals----------------------------
    typedef class stripe_driver_cbs;
    
    class stripe_driver;
        mailbox#(stripe_cell) gen2drv; //for cells sent from generator
        event drv2gen; //tell generator when I am done with cell
        v_stripe_ifct rx; //virtual ifc for transmitting operands
        stripe_driver_cbs cbsq[$]; //Queue of callback objects 
        int drv_num;
        extern function new(input mailbox gen2drv,
                            input event drv2gen,
                            input v_stripe_ifct rx,
                            input int drv_num
                           );
        extern task run();
        extern task send(input stripe_cell c);
    endclass: stripe_driver
    
    function stripe_driver::new(input mailbox gen2drv,
                         input event drv2gen,
                         input v_stripe_ifct rx,
                         input int drv_num
                        );
        this.gen2drv = gen2drv;
        this.drv2gen = drv2gen;
        this.rx = rx;
        this.drv_num = drv_num;
    endfunction: new
    
    task stripe_driver::run();
        stripe_cell c;
        rx.cbr.i_mu[drv_num].mr2 <= '0;
        rx.cbr.i_d_k_vals[4*drv_num + 0] <= 0;
        rx.cbr.i_d_k_vals[4*drv_num + 1] <= 0;
        rx.cbr.i_d_k_vals[4*drv_num + 2] <= 0;
        rx.cbr.i_d_k_vals[4*drv_num + 3] <= 0;
        
        
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
    
    task stripe_driver::send(input stripe_cell c);
        mux_union pkt;
        bit [3:0] d_ks;
        c.pack(pkt,d_ks);

        c.display($sformatf("@%0tSending cell: ",$time));
        @(rx.cbr);
        rx.cbr.i_mu[drv_num] <= pkt;
        rx.cbr.i_d_k_vals[4*drv_num + 0] <= d_ks[0];
        rx.cbr.i_d_k_vals[4*drv_num + 1] <= d_ks[1];
        rx.cbr.i_d_k_vals[4*drv_num + 2] <= d_ks[2];
        rx.cbr.i_d_k_vals[4*drv_num + 3] <= d_ks[3];
        @(rx.cbr);
    endtask: send
    
    class stripe_driver_cbs;
        virtual task pre_tx(input stripe_driver drv, input stripe_cell c);
        endtask: pre_tx
        
        virtual task post_tx(input stripe_driver drv, input stripe_cell c);
        endtask: post_tx
    endclass: stripe_driver_cbs
    
    typedef class stripe_monitor_cbs;
    
    class stripe_monitor;
        v_stripe_ifct tx; //virtual interface with output of dut
        stripe_monitor_cbs cbsq[$]; //callback queue
        int mon_num;
        
        extern function new(input v_stripe_ifct tx, input int mon_num);
        extern task run();
        extern task receive (output stripe_output_cell c);
    endclass: stripe_monitor
    
    function stripe_monitor::new(input v_stripe_ifct tx, input int mon_num);
        this.tx = tx;
        this.mon_num = mon_num;
    endfunction: new
    
    task stripe_monitor::run();
        stripe_output_cell c;
        forever begin
            receive(c);
            foreach(cbsq[i])
                cbsq[i].post_rx(this,c); //post-receive callback
        end
    endtask: run
    
    task stripe_monitor::receive(output stripe_output_cell c);
        @(tx.cbr);        
        c = new();
        c.striped_byte = tx.cbr.o_stripe_lane[mon_num].striped_byte;
        c.d_k = tx.cbr.o_stripe_lane[mon_num].d_k;
        c.display($sformatf("@%0t: Mon%0d: ", $time,0));
        @(tx.cbr);
    endtask:receive
    
    class stripe_monitor_cbs;
        virtual task post_rx(input stripe_monitor mon, input stripe_output_cell c);
        endtask: post_rx
    endclass:stripe_monitor_cbs
    
    class stripe_expect_cells;
        stripe_output_cell q[$];
        bit active;
        bit disabled;
        int i_expect, i_actual;
    endclass: stripe_expect_cells
    
    class stripe_scoreboard;
        stripe_env_config cfg;
        stripe_expect_cells expect_cells[];
        stripe_cell cellq[$];
        int i_expect, i_actual;
        int num_lanes;
        
        extern function new(input stripe_env_config cfg, input int num_lanes);
        extern virtual function void wrap_up();
        extern function void set_disabled(input int gen_num);
        extern function void save_expected(input stripe_cell m_cell, input int drv_num);
        extern function void check_actual(input stripe_output_cell c, input int mon_num);
        extern function void display(input string prefix = "");
        
    endclass: stripe_scoreboard
    
    function stripe_scoreboard::new(input stripe_env_config cfg, input int num_lanes);
        this.cfg = cfg;
        this.num_lanes = num_lanes;
        expect_cells = new[num_lanes];
        foreach(expect_cells[i])
            begin
                expect_cells[i] = new();
                expect_cells[i].active = 1;
                expect_cells[i].disabled = 0;
            end
    endfunction: new
    
    function void stripe_scoreboard::wrap_up();
        $display("@%0t: %m %0d expected outputs, %0d actual outputs rcvd",$time,i_expect,i_actual);
        foreach(expect_cells[i])
        begin
            if(expect_cells[i].q.size()) 
            begin
                $display("@%0t: %0d outputs in SCB at end of test",$time,expect_cells[i].q.size());
                this.display("Unclaimed: ");
                cfg.num_errors++;
            end
        end
    endfunction: wrap_up
    
    function void stripe_scoreboard::set_disabled(input int gen_num);
        expect_cells[4*gen_num + 0].disabled = 1;
        expect_cells[4*gen_num + 1].disabled = 1;
        expect_cells[4*gen_num + 2].disabled = 1;
        expect_cells[4*gen_num + 3].disabled = 1;
    endfunction:set_disabled
    
    function void stripe_scoreboard::save_expected(input stripe_cell m_cell, input int drv_num);
        stripe_output_cell o_cell[4] = m_cell.to_stripe_output();
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
    
    function void stripe_scoreboard::check_actual(input stripe_output_cell c, input int mon_num);
        if(expect_cells[mon_num].active == 0)
        begin
            return;
        end
        
        if(expect_cells[mon_num].disabled == 1)
        begin
            expect_cells[mon_num].active = 0;
        end
        
        c.display($sformatf("@%0t: Scb check: ", $time));
        if(expect_cells[mon_num].q.size() == 0 )
        begin
            $display("@%0t: ERROR: expected output not found. Scoreboard empty",$time);
            c.display("Not Found: ");
            cfg.num_errors++;
            return;
        end
        
        expect_cells[mon_num].i_actual++;
        i_actual++;
        
        foreach(expect_cells[mon_num].q[i])
        begin
            if(expect_cells[mon_num].q[i].compare(c))
            begin
                $display("@%0t: Match found for output", $time);
                expect_cells[mon_num].q.delete(i);
                

                
                return;
            end
        end
        
        $display("@%0t: ERROR output not found", $time);
        c.display("Not Found: ");
        cfg.num_errors++;
        
        
        
    endfunction: check_actual
    
    function void stripe_scoreboard::display(input string prefix = "");
        $display("@%0t: %m so far %0d expected outputs, %0d actual rcvd", $time, i_expect, i_actual);
        foreach(expect_cells[i])
        begin
            foreach(expect_cells[i].q[j])
            expect_cells[i].q[j].display($sformatf("%sScoreboard: ",prefix));
        end
    endfunction: display
    
    class stripe_coverage;
        //bit [15:0] a;
        //bit [15:0] b;
        
        covergroup cg_stripe;
            
        endgroup: cg_stripe
        
        function new();
            cg_stripe = new();
        endfunction: new 
        
        function void sample();
            $display("@%0t: Coverage: None", $time);
            cg_stripe.sample();
        endfunction: sample
    endclass: stripe_coverage
    
    class stripe_scb_driver_cbs extends stripe_driver_cbs;
        stripe_scoreboard scb;
        
        function new(input stripe_scoreboard scb);
            this.scb = scb;
        endfunction: new
        
        virtual task post_tx(input stripe_driver drv, input stripe_cell c);
            scb.save_expected(c,drv.drv_num);
        endtask: post_tx
    endclass: stripe_scb_driver_cbs
    
    class stripe_cov_driver_cbs extends stripe_driver_cbs;
        stripe_coverage cov;
        
        function new(input stripe_coverage cov);
            this.cov = cov;
        endfunction: new
        
        virtual task post_tx(input stripe_driver drv, input stripe_cell c);
            cov.sample();
        endtask: post_tx
    endclass: stripe_cov_driver_cbs
    
    class stripe_scb_monitor_cbs extends stripe_monitor_cbs;
        stripe_scoreboard scb;
        
        function new(input stripe_scoreboard scb);
            this.scb = scb;
        endfunction: new
        
        virtual task post_rx(input stripe_monitor mon, input stripe_output_cell c);
            scb.check_actual(c,mon.mon_num);
        endtask: post_rx
    endclass: stripe_scb_monitor_cbs
    
    class stripe_environment;
        int num_lanes;
        stripe_op_generator gen[];
        mailbox gen2drv[];
        event drv2gen[24];
        stripe_driver drv[];
        stripe_monitor mon[];
        stripe_env_config cfg;
        stripe_scoreboard scb;
        stripe_coverage cov;
        virtual striper_ifc.TB rx;
        virtual striper_ifc.TB tx;
        
        extern function new(input v_stripe_ifct rx, v_stripe_ifct tx, input int num_lanes);
        extern virtual function void gen_cfg();
        extern virtual function void build();
        extern virtual task run();
        extern virtual function void wrap_up();
    endclass: stripe_environment
    
    function stripe_environment::new(input v_stripe_ifct rx, v_stripe_ifct tx, input int num_lanes);
        //construct our environment instance
        this.rx = rx;
        this.tx = tx;
        this.num_lanes = num_lanes;
        cfg = new();
        if($test$plusargs("ntb_random_seed"))
        begin
            int seed;
            $value$plusargs("ntb_random_seed=%d", seed);
            $display("Simulation run with random seed=%0d", seed);
        end else 
        begin
            $display("Simulation run with default random seed");
        end
    endfunction: new

    function void stripe_environment::gen_cfg();
        `SV_RAND_CHECK(cfg.randomize());
        cfg.display();
    endfunction: gen_cfg
    
    //build the environment objects for this test
    function void stripe_environment::build();
        scb = new(cfg,this.num_lanes);
        cov = new();
        gen = new[num_lanes/4];
        gen2drv = new[num_lanes/4];
        //drv2gen = new[24];
        drv = new[num_lanes/4];
        
        foreach(gen[i])
        begin
            gen2drv[i] = new();
            gen[i] = new(gen2drv[i],drv2gen[i],scb,cfg.num_ops,i);
            drv[i] = new(gen2drv[i],drv2gen[i],rx,i);
        end
        
        mon = new[num_lanes];
        foreach(mon[i])
        begin
            mon[i] = new(this.tx,i);
        end
        
        
        //connect scoreboard to drivers and monitors with callbacks
        begin
            stripe_scb_driver_cbs sdc = new(scb);
            stripe_scb_monitor_cbs smc = new(scb);
            foreach(drv[i])
                drv[i].cbsq.push_back(sdc);
            foreach(mon[i])
                mon[i].cbsq.push_back(smc);
        end
        
        //connect coverage to driver. ATYPICAL. COVERAGE CAN ALSO BE CONNECTED TO MONITOR
        begin
            stripe_cov_driver_cbs cdc = new(cov);
            foreach(drv[i])
                drv[i].cbsq.push_back(cdc);
        end
    endfunction: build
    
    task stripe_environment::run();
        int num_gen_running;
        num_gen_running = num_lanes/4;
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
                repeat(1_000_000) @(tx.cbr);
                $display("@%0t: %m ERROR: Generator timeout ", $time);
                cfg.num_errors++;
            end
        join_any
        
        disable timeout_block;
        
        //wait for data to flow through the device and into monitors and scoreboards
        repeat (1_000) @(tx.cbr);
    endtask:run
    
    //post-run cleanup/reporting
    function void stripe_environment::wrap_up();
        $display("@%0t: End of sim, %0d errors, %0d warnings", $time, cfg.num_errors, cfg.num_warnings);
        scb.wrap_up();
    endfunction: wrap_up
            
endpackage: striper_pkg