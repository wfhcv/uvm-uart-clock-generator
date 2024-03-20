`include "uvm_macros.svh"
import uvm_pkg::*;

`include "my_testbench_pkg.svh"
import my_testbench_pkg::*;

module tb;
    clk_if vif();
    
    clk_gen dut (.clk(vif.clk),.rst(vif.rst), .baud(vif.baud), .tx_clk(vif.tx_clk));
    
    initial begin
        vif.clk <= 0;
    end
    
    always #10 vif.clk <= ~vif.clk; //1/50 20nsec 10nsec
    
    initial begin
        uvm_config_db#(virtual clk_if)::set(null, "*", "vif", vif);
        run_test("test");
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
 
endmodule: tb