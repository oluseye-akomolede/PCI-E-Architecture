`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2024 10:48:58 AM
// Design Name: 
// Module Name: tb_base_pkg
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



package tb_base_pkg;
    //Utility functions---------------------------------------------------------------------------
    `define SV_RAND_CHECK(r) \
        do begin \
            if(!(r)) begin \
                $display("%s:%0d: Randomization failed \"%s\"",\
                            `__FILE__, `__LINE__, `"r`"); \
                $finish; \
            end \
        end while(0)
    
    `define svm_component_utils(T) \
        typedef svm_component_registry #(T,`"T`") type_id; \
        static function type_id get_type(); \
            return type_id::get(); \
        endfunction \
        virtual function string get_type_name(); \
            return `"T`"; \
        endfunction
        
    `define svm_object_utils(T) \
        typedef svm_object_registry #(T,`"T`") type_ido; \
        static function type_ido get_type(); \
            return type_ido::get(); \
        endfunction \
        virtual function string get_type_name(); \
            return `"T`"; \
        endfunction
        
    `define svm_config_utils(T) \
        typedef svm_config_registry #(T,`"T`") type_idc; \
        static function type_idc get_type(); \
            return type_idc::get(); \
        endfunction \
        virtual function string get_type_name(); \
            return `"T`"; \
        endfunction
    
    //end utility functions-----------------------------------------------------------------------
    
    virtual class svm_object;
    
    endclass
    
    typedef class svm_component_registry;
    
    virtual class svm_component extends svm_object;
        string name;
        svm_component parent;
               
        function new(input string name, input svm_component parent);
            this.name = name;
            this.parent = parent;
        endfunction
        
        pure virtual function void build_phase();
        pure virtual function void set_override();
        
    endclass

    virtual class svm_object_wrapper;
        pure virtual function string get_type_name();
        pure virtual function svm_object create_object(input string name, input svm_object parent);
        pure virtual function svm_object create_tr_object();
    endclass
    
    typedef class svm_factory;
    
    class svm_component_registry #(type T=svm_component, string Tname = "<unknown>") extends svm_object_wrapper;
        typedef svm_component_registry #(T,Tname) this_type;
        typedef T class_type;
        
        virtual function string get_type_name();
            return Tname;
        endfunction
        
        local static this_type me = get();
        
        static function this_type get();
            if(me == null)
            begin
                svm_factory f = svm_factory::get();
                me = new();
                f.register(me);
            end
            return me;
        endfunction
        
        virtual function T create_object(input string name = "", input svm_component parent);
            T obj;
            obj = new(name,parent);
            return obj;
        endfunction
        
        static function T create(input string name, input svm_component parent);
            T obj;
            svm_factory f = svm_factory::get();
            $cast(obj,f.get_object(name,parent));
            return obj;
        endfunction
        
        virtual function svm_object create_tr_object();
        endfunction: create_tr_object
        
        static function set_type_override(input svm_object_wrapper c);
            
            svm_factory::set_override(Tname,c);
            
        endfunction
        
    endclass
    
    class svm_factory;
        static svm_object_wrapper m_type_names[string];
        static svm_factory m_inst;
        
        static function svm_factory get();
            if(m_inst == null) m_inst = new();
            return m_inst;
        endfunction
        
        static function void register(svm_object_wrapper c);
            m_type_names[c.get_type_name()] = c;
        endfunction
        
        static function svm_component get_object(input string name, input svm_component parent);
            svm_component test_comp;
            svm_object_wrapper test_wrapper;
            
            test_wrapper = svm_factory::m_type_names[name];
            $cast(test_comp,test_wrapper.create_object(name,parent));
            return test_comp;
        endfunction
        
        static function void set_override(input string name, input svm_object_wrapper c);
            m_type_names[name] = c;
        endfunction
        
    endclass
    
    typedef class svm_object_factory;
    
    class svm_object_registry #(type T=svm_object, string Tname = "<unknown>") extends svm_object_wrapper;
        typedef svm_object_registry #(T,Tname) this_type;
        typedef T class_type;
        
        virtual function string get_type_name();
            return Tname;
        endfunction
        
        local static this_type me = get();
        
        static function this_type get();
            if(me == null)
            begin
                svm_object_factory f = svm_object_factory::get();
                me = new();
                f.register(me);
            end
            return me;
        endfunction
        
        virtual function T create_tr_object();
            T obj;
            obj = new();
            return obj;
        endfunction
        
        virtual function T create_object(input string name, input svm_component parent);
        endfunction
        
        static function T create(input string name);
            T obj;
            svm_object_factory f = svm_object_factory::get();
            $cast(obj,f.get_object(name));
            return obj;
        endfunction
        
        static function set_type_override(input svm_object_wrapper c);
            
            svm_object_factory::set_override(Tname,c);
            
        endfunction
        
    endclass
    
    class svm_object_factory;
        static svm_object_wrapper m_type_names[string];
        static svm_object_factory m_inst;
        
        static function svm_object_factory get();
            if(m_inst == null) m_inst = new();
            return m_inst;
        endfunction
        
        static function void register(svm_object_wrapper c);
            m_type_names[c.get_type_name()] = c;
        endfunction
        
        static function svm_object get_object(input string name);
            svm_object test_comp;
            svm_object_wrapper test_wrapper;
            
            test_wrapper = svm_object_factory::m_type_names[name];
            $cast(test_comp,test_wrapper.create_tr_object());
            return test_comp;
        endfunction
        
        static function void set_override(input string name, input svm_object_wrapper c);
            m_type_names[name] = c;
        endfunction
        
    endclass
    
    
    typedef class svm_config_factory;
    
    class svm_config_registry #(type T=svm_object, string Tname = "<unknown>") extends svm_object_wrapper;
        typedef svm_config_registry #(T,Tname) this_type;
        typedef T class_type;
        
        virtual function string get_type_name();
            return Tname;
        endfunction
        
        local static this_type me = get();
        
        static T classobj;
        
        static function this_type get();
            if(me == null)
            begin
                svm_config_factory f = svm_config_factory::get();
                me = new();
                f.register(me);
            end
            return me;
        endfunction
        
        virtual function T create_tr_object();
            if(classobj == null) classobj = new();
            return classobj;
        endfunction
        
        virtual function T create_object(input string name, input svm_component parent);
        endfunction
        
        static function T create(input string name);
            T obj;
            svm_config_factory f = svm_config_factory::get();
            $cast(obj,f.get_config(name));
            return obj;
        endfunction
        
        static function set_type_override(input svm_object_wrapper c);
            
            svm_config_factory::set_override(Tname,c);
            
        endfunction
        
    endclass
    
    class svm_config_factory;
        static svm_object_wrapper m_type_names[string];
        static svm_config_factory m_inst;
        
        static function svm_config_factory get();
            if(m_inst == null) m_inst = new();
            return m_inst;
        endfunction
        
        static function void register(svm_object_wrapper c);
            m_type_names[c.get_type_name()] = c;
        endfunction
        
        static function svm_object get_config(input string name);
            svm_object test_comp;
            svm_object_wrapper test_wrapper;
            
            test_wrapper = svm_config_factory::m_type_names[name];
            $cast(test_comp,test_wrapper.create_tr_object());
            return test_comp;
        endfunction
        
        static function void set_override(input string name, input svm_object_wrapper c);
            m_type_names[name] = c;
        endfunction
        
    endclass
    
    virtual class transaction_packer extends svm_object; //wrapper class to support pack and unpack methods
        `svm_object_utils(transaction_packer);
    endclass
    
    virtual class BaseTr extends svm_object;
        `svm_object_utils(BaseTr);
        static int count;
        int id;
        
        function new();
            id = count++;
        endfunction
        
        pure virtual function bit compare(input BaseTr to);
        pure virtual function BaseTr copy(input BaseTr to = null);
        pure virtual function void display(input string prefix = "");  
        pure virtual function void pack(output transaction_packer p);
        pure virtual function void unpack(input transaction_packer p);
           
    endclass: BaseTr 
    //--------------------------------------------------------------------------------------------------
    //Config Class and all definitions. Config sets up environment parameters are randomizes them.------
    class svm_env_config extends svm_object;
        `svm_config_utils(svm_env_config);
        int num_errors;
        int num_warnings;
        rand bit [31:0] num_ops; //total number of operations
        
        constraint c_num_ops_valid {num_ops > 0;}
        constraint c_num_ops_reasonable {num_ops < 1000;}
        
        extern function new();
        extern virtual function void display(input string prefix = "");
    endclass: svm_env_config
    
    function svm_env_config::new();
    endfunction: new
    
    function void svm_env_config::display(input string prefix = "");
        $write("%sConfig: num_ops = %0d",prefix,num_ops);
        $display;
    endfunction: display
    //--------------------------------------------------------------------------------------------------
        
    typedef class svm_scoreboard;
    
    //Generator class. Generates transactions based off of blueprints and uses mailboxes to pass to the driver class.
    class svm_generator extends svm_component;
        `svm_component_utils(svm_generator);
        BaseTr blueprint; //blueprint for generator
        svm_scoreboard scb;
        mailbox gen2drv; //mailbox to driver for transactions
        event drv2gen; //event from our driver for once it's done
        int num_ops; //number of operations
        int gen_num; //the generator number that we are. The number of lanes is a multiple of four. This generates for 4 lanes at a time.
        
        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction
        
        virtual function void set_override();
        endfunction: set_override
        
        virtual function void build_phase();
            $cast(blueprint,BaseTr::type_ido::create("BaseTr")); 
        endfunction: build_phase
        
        function connect(input mailbox gen2drv,
                     input event drv2gen,
                     input svm_scoreboard scb,
                     input int num_ops,
                     input int gen_num
                     );
                     
            this.gen2drv = gen2drv;
            this.drv2gen = drv2gen;
            this.scb = scb;
            this.num_ops = num_ops;
            this.gen_num = gen_num;
                        
        endfunction: connect     
        
        task run();
            BaseTr c;
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
        
    endclass: svm_generator
    
    class svm_driver_config extends svm_object;
        `svm_config_utils(svm_driver_config);
    endclass: svm_driver_config
    
    typedef class svm_driver_cbs;
    
    class svm_driver extends svm_component;
        `svm_component_utils(svm_driver);
        mailbox#(BaseTr) gen2drv; //for cells sent from generator
        event drv2gen; //tell generator when I am done with cell
        svm_driver_config d_cfg;
        //v_stripe_ifct rx; //virtual ifc for transmitting operands
        svm_driver_cbs cbsq[$]; //Queue of callback objects 
        int drv_num;
        
        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction
        
        virtual function void set_override();
        endfunction: set_override
        
        virtual task initialize();
        endtask: initialize
        
        extern function connect(
                            input mailbox gen2drv,
                            input event drv2gen,
                            input int drv_num
                           );
        extern virtual task run();
        extern virtual task send(input BaseTr c);
        extern virtual function void build_phase();
        
    endclass: svm_driver
    
    function svm_driver::connect(
                         input mailbox gen2drv,
                         input event drv2gen,
                         input int drv_num
                        );
        this.gen2drv = gen2drv;
        this.drv2gen = drv2gen;
        this.drv_num = drv_num;
    endfunction: connect
    
    
    
    task svm_driver::run();

    endtask: run
    
    task svm_driver::send(input BaseTr c);

    endtask: send
    
    function void svm_driver::build_phase();
        this.d_cfg = svm_driver_config::type_idc::create("svm_driver_config");
    endfunction: build_phase
    
    
    class svm_monitor_config extends svm_object;
        `svm_config_utils(svm_monitor_config);
    endclass: svm_monitor_config
    
    typedef class svm_coverage;
    
    class svm_driver_cbs extends svm_object;
        `svm_object_utils(svm_driver_cbs);
        
        virtual function void connect(input svm_scoreboard scb);
        endfunction
        
        virtual function void cov_connect(input svm_coverage cov);
        endfunction
        
        virtual task pre_tx(input svm_driver drv, input BaseTr c);
        endtask: pre_tx
        
        virtual task post_tx(input svm_driver drv, input BaseTr c);
        endtask: post_tx
    endclass: svm_driver_cbs
    
    typedef class svm_monitor_cbs;
    
    class svm_monitor extends svm_component;
        `svm_component_utils(svm_monitor);
        //v_stripe_ifct tx; //virtual interface with output of dut
        svm_monitor_config m_cfg;
        svm_monitor_cbs cbsq[$]; //callback queue
        int mon_num;
        
        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction
        
        extern function connect(input int mon_num);
        extern virtual task run();
        extern virtual function void build_phase();
        
        virtual task receive (output BaseTr c);
        endtask
        virtual function void set_override();
        endfunction
    endclass: svm_monitor
    
    function void svm_monitor::build_phase();
        this.m_cfg = svm_monitor_config::type_idc::create("svm_monitor_config");
    endfunction: build_phase
    
    function svm_monitor::connect(input int mon_num);
        this.mon_num = mon_num;
    endfunction: connect
    
    task svm_monitor::run();

    endtask: run
    
//    task svm_monitor::receive(output stripe_output_cell c);
//        @(tx.cbr);        
//        c = new();
//        c.striped_byte = tx.cbr.o_stripe_lane[mon_num].striped_byte;
//        c.d_k = tx.cbr.o_stripe_lane[mon_num].d_k;
//        c.display($sformatf("@%0t: Mon%0d: ", $time,0));
//        @(tx.cbr);
//    endtask:receive
    
    class svm_monitor_cbs extends svm_object;
        `svm_object_utils(svm_monitor_cbs);
        virtual task post_rx(input svm_monitor mon, input BaseTr c);
        endtask: post_rx
    endclass:svm_monitor_cbs
    
    
    class svm_expect_cells extends svm_object;
        `svm_object_utils(svm_expect_cells);
        BaseTr q[$];
        bit active;
        bit disabled;
        int i_expect, i_actual;
    endclass: svm_expect_cells
    
    class svm_scoreboard extends svm_component;
        `svm_component_utils(svm_scoreboard);
        svm_env_config cfg;
        svm_expect_cells expect_cells[];
        BaseTr cellq[$];
        int i_expect, i_actual;
        int num_lanes;
        
        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction
        
        extern function void connect(input int num_lanes);
        extern virtual function void wrap_up();
        virtual function void set_disabled(input int gen_num);
        endfunction
        virtual function void save_expected(input BaseTr m_cell, input int drv_num);
        endfunction
        extern virtual function void check_actual(input BaseTr c, input int mon_num);
        extern virtual function void display(input string prefix = "");
        extern virtual function void build_phase();
        virtual function void set_override();
        endfunction
    endclass: svm_scoreboard
    
    function void svm_scoreboard::connect(input int num_lanes);
        this.num_lanes = num_lanes;
        expect_cells = new[num_lanes];
        foreach(expect_cells[i])
            begin
                expect_cells[i] = svm_expect_cells::type_ido::create("svm_expect_cells");
                expect_cells[i].active = 1;
                expect_cells[i].disabled = 0;
            end
    endfunction: connect
    
    function void svm_scoreboard::build_phase();
        this.cfg = svm_env_config::type_idc::create("svm_env_config");
    endfunction: build_phase
    
    function void svm_scoreboard::wrap_up();
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
    
    function void svm_scoreboard::check_actual(input BaseTr c, input int mon_num);
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
    
    function void svm_scoreboard::display(input string prefix = "");
        $display("@%0t: %m so far %0d expected outputs, %0d actual rcvd", $time, i_expect, i_actual);
        foreach(expect_cells[i])
        begin
            foreach(expect_cells[i].q[j])
            expect_cells[i].q[j].display($sformatf("%sScoreboard: ",prefix));
        end
    endfunction: display
    
    class svm_coverage extends svm_object;
        `svm_object_utils(svm_coverage);
        
        covergroup cg_svm;
            
        endgroup: cg_svm
        
        function new();
            cg_svm = new();
        endfunction: new 
        
        virtual function void sample();
            $display("@%0t: Coverage: None", $time);
            cg_svm.sample();
        endfunction: sample
        
        virtual function void cov_connect(svm_coverage cov);
        endfunction
    endclass: svm_coverage
    
    class svm_scb_driver_cbs extends svm_driver_cbs;
        `svm_object_utils(svm_scb_driver_cbs);
        svm_scoreboard scb;
        
        virtual function void connect(input svm_scoreboard scb);
            this.scb = scb;
        endfunction: connect
        
        virtual task post_tx(input svm_driver drv, input BaseTr c);
            scb.save_expected(c,drv.drv_num);
        endtask: post_tx
    endclass: svm_scb_driver_cbs   
    
    class svm_cov_driver_cbs extends svm_driver_cbs;
        `svm_object_utils(svm_cov_driver_cbs);
        svm_coverage cov;
        
        virtual function void cov_connect(input svm_coverage cov);
            this.cov = cov;
        endfunction: cov_connect
        
        virtual function void connect(input svm_scoreboard scb);
        endfunction
        
        virtual task post_tx(input svm_driver drv, input BaseTr c);
            cov.sample();
        endtask: post_tx
    endclass: svm_cov_driver_cbs 
    
    class svm_scb_monitor_cbs extends svm_monitor_cbs;
        `svm_object_utils(svm_scb_monitor_cbs);
        svm_scoreboard scb;
        
        function connect(input svm_scoreboard scb);
            this.scb = scb;
        endfunction: connect
        
        virtual task post_rx(input svm_monitor mon, input BaseTr c);
            scb.check_actual(c,mon.mon_num);
        endtask: post_rx
    endclass: svm_scb_monitor_cbs
    
    class svm_environment extends svm_component;
        `svm_component_utils(svm_environment);
        int num_lanes;
        svm_generator gen[];
        mailbox gen2drv[];
        event drv2gen[24];
        svm_driver drv[];
        svm_monitor mon[];
        svm_env_config cfg;
        svm_scoreboard scb;
        svm_coverage cov;
        //virtual striper_ifc.TB rx;
        //virtual striper_ifc.TB tx;
        
        function new(input string name, input svm_component parent);
            super.new(name,parent);
        endfunction
        
        extern function init(input int num_lanes);
        extern virtual function void gen_cfg();
        extern virtual function void build_phase();
        extern virtual function void wrap_up();
        virtual task run();
        endtask
        virtual function void set_override();
        endfunction
        virtual function void set_configs();
        endfunction
    endclass: svm_environment
    
    function svm_environment::init(input int num_lanes);
        //construct our environment instance
//        this.rx = rx;
//        this.tx = tx;
        this.num_lanes = num_lanes;
        cfg = svm_env_config::type_idc::create("svm_env_config");
        if($test$plusargs("ntb_random_seed"))
        begin
            int seed;
            $value$plusargs("ntb_random_seed=%d", seed);
            $display("Simulation run with random seed=%0d", seed);
        end else 
        begin
            $display("Simulation run with default random seed");
        end
    endfunction: init

    function void svm_environment::gen_cfg();
        `SV_RAND_CHECK(cfg.randomize());
        cfg.display();
    endfunction: gen_cfg
    
    //build the environment objects for this test
    function void svm_environment::build_phase();
        scb = svm_scoreboard::type_id::create("svm_scoreboard",this);
        scb.set_override();
        scb.build_phase();
        scb.connect(num_lanes);
        cov = svm_coverage::type_ido::create("svm_coverage");
        gen = new[num_lanes/4];
        gen2drv = new[num_lanes/4];
        //drv2gen = new[24];
        drv = new[num_lanes/4];
        
        foreach(gen[i])
        begin
            gen2drv[i] = new();
            gen[i] = svm_generator::type_id::create("svm_generator",this);
            gen[i].set_override();
            gen[i].connect(gen2drv[i],drv2gen[i],scb,cfg.num_ops,i);
            gen[i].build_phase();
            drv[i] = svm_driver::type_id::create("svm_driver",this);
            drv[i].set_override();
            drv[i].connect(gen2drv[i],drv2gen[i],i);
            drv[i].build_phase();
        end
        
        mon = new[num_lanes];
        foreach(mon[i])
        begin
            mon[i] = svm_monitor::type_id::create("svm_monitor",this);
            mon[i].set_override();
            mon[i].connect(i);
            mon[i].build_phase();
        end
        
        
        //connect scoreboard to drivers and monitors with callbacks
        begin
            svm_scb_driver_cbs sdc;
            svm_scb_monitor_cbs smc;
            
            sdc = svm_scb_driver_cbs::type_ido::create("svm_scb_driver_cbs");
            sdc.connect(scb);
            
            smc = svm_scb_monitor_cbs::type_ido::create("svm_scb_monitor_cbs");
            smc.connect(scb);

            foreach(drv[i])
                drv[i].cbsq.push_back(sdc);
            foreach(mon[i])
                mon[i].cbsq.push_back(smc);
        end
        
        //connect coverage to driver. ATYPICAL. COVERAGE CAN ALSO BE CONNECTED TO MONITOR
        begin
            svm_cov_driver_cbs cdc;
            cdc = svm_cov_driver_cbs::type_ido::create("svm_cov_driver_cbs");
            cdc.cov_connect(cov);
            foreach(drv[i])
                drv[i].cbsq.push_back(cdc);
        end
    endfunction: build_phase
    

    
    //post-run cleanup/reporting
    function void svm_environment::wrap_up();
        $display("@%0t: End of sim, %0d errors, %0d warnings", $time, cfg.num_errors, cfg.num_warnings);
        scb.wrap_up();
    endfunction: wrap_up
    
endpackage: tb_base_pkg
