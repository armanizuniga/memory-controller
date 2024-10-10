interface memory_interface(input clk);
  //System Signal wire bundle
  logic reset;
  logic we_sys;
  logic cmd_valid_sys;
  logic [7:0] addr_sys;
  logic [7:0] data_sys;
  logic ready_sys;
  
  //Memory Signal wire bundle 
  logic we_mem;
  logic ce_mem;
  logic [7:0] addr_mem;
  logic [7:0] datai_mem;
  logic [7:0] datao_mem;
  
  // Modport for memory core
  modport core_port(input clk, reset, we_mem, ce_mem, addr_mem, datai_mem,
                    output datao_mem
                   );
  
  // Modport for the memory controller
  modport ctrl_port(input clk, reset, we_sys, cmd_valid_sys, addr_sys, datao_mem,
                    output we_mem, ce_mem, addr_mem, datai_mem, ready_sys,
                    inout data_sys
                   );
  
  // Modport for the testcase 
  modport testcase_port(input clk, ready_sys,
                       output we_sys, cmd_valid_sys, addr_sys, reset,
                       inout data_sys
                      );
  
endinterface