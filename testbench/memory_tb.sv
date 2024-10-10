`include "memory_interface.sv"
module memory_tb();

   bit         clk;
   logic       reset;

   //Signals for Memory Core
   logic       we_mem;
   logic       ce_mem;
   logic [7:0] addr_mem;
   logic [7:0] datai_mem;
   logic [7:0] datao_mem;

   //Signals for Memory Controller
   logic       we_sys;
   logic       cmd_valid_sys;
   logic [7:0] addr_sys;
   logic       ready_sys;
   logic [7:0] data_sys;

   //Free running clock
   always #5 clk = !clk;
  
   // Instantiate memory_inerface 
   memory_interface miff (clk);


   //DUT is instantiated here
   memory_core 		memcore		(miff.core_port);

   memory_ctrl 		memctrl		(miff.ctrl_port);

   //testcase is instantiated here
   testcase   		itestcase	(miff.testcase_port);

endmodule
