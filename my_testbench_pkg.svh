
package my_testbench_pkg;
	typedef enum bit [1:0] {reset_asserted = 0, random_baud = 1} oper_mode;

    `include "my_sequence.svh"
    `include "my_driver.svh"
    
    class mon extends uvm_monitor;
        `uvm_component_utils(mon)
        
        uvm_analysis_port#(transaction) send;
        transaction tr;
        virtual clk_if vif;
        real ton  = 0;
        real toff = 0;
    
        function new(input string inst = "mon", uvm_component parent = null);
            super.new(inst,parent);
        endfunction
    
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            send = new("send", this);
            
            tr = transaction::type_id::create("tr");
            
            if(!uvm_config_db#(virtual clk_if)::get(this,"","vif",vif)) 
                `uvm_error("mon","Unable to access Interface");
        endfunction
    
        
        virtual task run_phase(uvm_phase phase);
            forever begin
                @(posedge vif.clk);

                if(vif.rst) begin
                    tr.oper = reset_asserted;
                    ton    = 0;
                    toff   = 0;
                    `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
                    send.write(tr);
                end
                else begin
                    tr.baud = vif.baud;
                    tr.oper = random_baud; 
                    ton     = 0;
                    toff    = 0; 

                    @(posedge vif.tx_clk);
                    ton = $realtime;

                    @(posedge vif.tx_clk);
                    toff = $realtime;
                    tr.period = toff - ton;
                    
                    `uvm_info("MON",$sformatf("Baud : %0d Period:%0f",tr.baud,tr.period), UVM_NONE);
                    
                    send.write(tr);
            
                end
            end
        endtask: run_phase
    
    endclass: mon
    
    //////////////////////////////////////////////////////////////////////////////////
    class sco extends uvm_scoreboard;
        `uvm_component_utils(sco)
    
        real count = 0;
        real baudcount = 0;
        uvm_analysis_imp#(transaction,sco) recv;
    
        function new(input string inst = "sco", uvm_component parent = null);
            super.new(inst,parent);
        endfunction
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            recv = new("recv", this);
        endfunction
        
        
        virtual function void write(transaction tr);
            count =  tr.period / 20;
            baudcount = count;

            `uvm_info("SCO", $sformatf("BAUD:%0d count:%0f bcount:%0f", tr.baud,count, baudcount), UVM_NONE);
            
            case(tr.baud)
                4800: begin
                    if(baudcount == 10418)
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                    else
                    `uvm_error("SCO" , "TEST FAILED")
                end
                    
                    
                9600: begin
                    if(baudcount == 5210)
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                    else
                    `uvm_error("SCO" , "TEST FAILED") 
                    
                end
                    
                14400: begin
                    if(baudcount == 3474)
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                    else
                    `uvm_error("SCO" , "TEST FAILED")
                end
                    
                19200: begin
                    if(baudcount == 2606)
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                    else
                    `uvm_error("SCO" , "TEST FAILED")
                    
                end
                    
                38400: begin
                    if(baudcount == 1304)
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                    else
                    `uvm_error("SCO" , "TEST FAILED")
                    
                end
                    
                57600: begin
                    if(baudcount == 870)
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                    else
                    `uvm_error("SCO" , "TEST FAILED")
                end
                
            endcase     
        endfunction: write
    
    endclass: sco
    
    ///////////////////////////////////////////////////////////////////////////////
    
                    
                    
    class agent extends uvm_agent;
        `uvm_component_utils(agent)
        
        function new(input string inst = "agent", uvm_component parent = null);
            super.new(inst,parent);
        endfunction
        
        driver d;
        uvm_sequencer#(transaction) seqr;
        mon m;
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            m = mon::type_id::create("m",this);
            d = driver::type_id::create("d",this);
            seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
        
        endfunction: build_phase
        
        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            d.seq_item_port.connect(seqr.seq_item_export);
        endfunction: connect_phase
    
    endclass: agent
    
    //////////////////////////////////////////////////////////////////////////
    
    class env extends uvm_env;
        `uvm_component_utils(env)
        
        function new(input string inst = "env", uvm_component c);
            super.new(inst,c);
        endfunction
        
        agent a;
        sco s;
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            a = agent::type_id::create("a",this);
            s = sco::type_id::create("s", this);
        endfunction
        
        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            a.m.send.connect(s.recv);
        endfunction
    
    endclass: env
    
    
    /////////////////////////////////////////////////////////////
    
    class test extends uvm_test;
        `uvm_component_utils(test)
        
        env e;
        variable_baud vbar;
        reset_clk   rclk;
        
        
        function new(input string inst = "test", uvm_component c);
            super.new(inst,c);
        endfunction
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            e       = env::type_id::create("env",this);  
            vbar = variable_baud::type_id::create("vbar");
            rclk = reset_clk::type_id::create("rclk"); 
        endfunction: build_phase
        
        virtual task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            vbar.start(e.a.seqr);
            #20;
            phase.drop_objection(this);
        endtask: run_phase
    endclass: test
    
endpackage: my_testbench_pkg