// Stand-alone test inside program block
program testcase(interface tcif);
  
   // Keep count of READ and WRITE opertaions for final block
   int write_count = 0;
   int read_count = 0;
   bit test_passed = 1; // Assuming the test passes unless an error is detected
  
   // Variables to monitor bus activities
   int idle_cycles = 0;
  
   // Monitor bus activity for ending Simulation
   task automatic check_bus_activity;
     forever begin
       @(posedge tcif.clk);
       if (tcif.cmd_valid_sys || tcif.ready_sys || tcif.we_sys || (tcif.data_sys !== 8'bz)) begin
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
     tcif.reset = 			1;
     tcif.we_sys = 			0;
     tcif.cmd_valid_sys = 	0;
     tcif.addr_sys = 		0;
     tcif.data_sys = 		8'bz;
     #100 tcif.reset = 		0;
     
     // Start the bus activity monitoring
     fork
        check_bus_activity();
     join_none
     
     for (int i = 0; i < 4; i++) begin
       @(posedge tcif.clk);
       tcif.addr_sys = 		i;
       tcif.data_sys = 		$urandom_range(0,255);
       tcif.cmd_valid_sys = 	1;
       tcif.we_sys = 		1;
       write_count++;
       
       @(posedge tcif.ready_sys);
       $display("%5dns: Writing: address=%0d, write data=8'h%2h", $time, i, tcif.data_sys);
       
       @(posedge tcif.clk);
       tcif.addr_sys = 		0;
       tcif.data_sys = 		8'bz;
       tcif.cmd_valid_sys = 	0;
       tcif.we_sys = 		0;
     end
     
     $display("\n");
     
     repeat(10) @(posedge tcif.clk);
     for (int i = 0; i < 4; i++) begin
       @(posedge tcif.clk);
       tcif.addr_sys = i;
       tcif.cmd_valid_sys = 1;
       tcif.we_sys = 0;
       read_count++;
       
       @(posedge tcif.ready_sys);
       @(posedge tcif.clk);
       $display("%5dns: Reading: address=%0d, read data=8'h%2h", $time, i, tcif.data_sys);
       
       tcif.addr_sys = 0;
       tcif.cmd_valid_sys = 0;
     end
     
     repeat(150) @(posedge tcif.clk);
     
   end
  
   final begin
        $display("\n***** End Of Simulation Summary *****");
        $display("Number of WRITE operations performed: %0d", write_count);
        $display("Number of READ operations performed: %0d", read_count);
        $display("Test status: %s", test_passed ? "PASS" : "FAIL");
        $display("*************************************\n");
    end

endprogram
