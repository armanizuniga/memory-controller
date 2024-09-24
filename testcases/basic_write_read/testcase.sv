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
  
   // Keep count of READ and WRITE opertaions for final block
   int write_count = 0;
   int read_count = 0;
   bit test_passed = 1; // Assuming the test passes unless an error is detected
  
   // Variables to monitor bus activities
   int idle_cycles = 0;
  
   // Monitor bus activity for ending Simulation
   task automatic check_bus_activity;
     forever begin
       @(posedge clk);
        if (cmd_valid_sys || ready_sys || we_sys || (data_sys !== 8'bz)) begin
                idle_cycles = 0;
            end else begin
                idle_cycles++;
                if (idle_cycles % 10 == 0) // Print every 10 idle cycles
                    $display("Bus idle for %0d cycles", idle_cycles);
            end

            if (idle_cycles >= 100) begin
                $display("Bus idle for 100 clock cycles. Ending simulation.");
                $finish;
                break;
            end
        end
    endtask
     
  
   initial begin
     reset = 			1;
     we_sys = 			0;
     cmd_valid_sys = 	0;
     addr_sys = 		0;
     data_sys = 		8'bz;
     #100 reset = 		0;
     
     // Start the bus activity monitoring
     fork
        check_bus_activity();
     join_none
     
     for (int i = 0; i < 4; i++) begin
       @(posedge clk);
       addr_sys = 		i;
       data_sys = 		$urandom_range(0,255);
       cmd_valid_sys = 	1;
       we_sys = 		1;
       write_count++;
       
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
       read_count++;
       
       @(posedge ready_sys);
       @(posedge clk);
       $display("%5dns: Reading: address=%0d, read data=8'h%2h", $time, i, data_sys);
       
       addr_sys = 0;
       cmd_valid_sys = 0;
     end
     
     repeat(150) @(posedge clk);
     
   end
  
   final begin
        $display("\n***** End Of Simulation Summary *****");
        $display("Number of WRITE operations performed: %0d", write_count);
        $display("Number of READ operations performed: %0d", read_count);
        $display("Test status: %s", test_passed ? "PASS" : "FAIL");
        $display("*************************************\n");
    end

endprogram
