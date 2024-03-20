class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    oper_mode   oper;
    rand logic [16:0] baud;
    logic tx_clk;
    real period;
    
  constraint baud_c { baud inside {4800,9600,14400,19200,38400,57600}; }
  
 
  function new(string name = "transaction");
    super.new(name);
  endfunction
 
endclass: transaction
//////////////////////////////////////////////////////
 
class reset_clk extends uvm_sequence#(transaction);
  `uvm_object_utils(reset_clk)
  
    transaction tr;
    
    function new(string name = "reset_clk");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(5)
        begin
            tr = transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize);
            tr.oper = reset_asserted;
            finish_item(tr);
        end
    endtask
  
 
endclass: reset_clk
 
 
///////////////////////////////////////////////////////////////////////
class variable_baud extends uvm_sequence#(transaction);
    `uvm_object_utils(variable_baud)
    
    transaction tr;
    
    function new(string name = "variable_baud");
        super.new(name);
    endfunction
  
    virtual task body();
        repeat(5)
        begin
            tr = transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize);
            tr.oper = random_baud;
            finish_item(tr);
        end
    endtask
    
 
endclass: variable_baud