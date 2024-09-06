// Stand-alone test inside program block
program testcase(//Inputs to Design, Outputs from Program <-- Signals are to be driven inside Progam Block
				 input wire clk,
  				 output logic reset,
  				 output logic we_sys,
  				 output logic cmd_valid_sys,
  				 output logic [7:0] addr_sys,
                 //Inout to/from Design, inout to/from Programa <-- Signals are to be driven inside Program
  				 ref    logic [7:0]	data_sys,
                 //Output from Design, Input to Program <-- Signals are to be monitored
				 input logic ready_sys
                );

   initial begin
     reset = 			1;
     we_sys = 			0;
     cmd_valid_sys = 	0;
     addr_sys = 		0;
     data_sys = 		8'bz;
     #100 reset = 		0;
     
     for (int i = 0; i < 4; i++) begin
       @(posedge clk);
       addr_sys = 		i;
       data_sys = 		$urandom_range(0,255);
       cmd_valid_sys = 	1;
       we_sys = 		1;
       
       @(posedge ready_sys);
       $display("%5dns: Writing: address=%0d, write data=8'h%2h", $time, i, data_sys);
       
       @(posedge clk);
       addr_sys = 		0;
       data_sys = 		8'bz;
       cmd_valid_sys = 	0;
       we_sys = 		0;
     end
     
     $display("\n");
     
     repeat(10) @(posedge clk);
     for (int i = 0; i < 4; i++) begin
       @(posedge clk);
       addr_sys = i;
       cmd_valid_sys = 1;
       we_sys = 0;
       
       @(posedge ready_sys);
       @(posedge clk);
       $display("%5dns: Reading: address=%0d, read data=8'h%2h", $time, i, data_sys);
       
       addr_sys = 0;
       cmd_valid_sys = 0;
     end
     
     #10 $finish;
   end

endprogram
