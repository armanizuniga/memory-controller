module memory_core (interface coreif);


   // Memory array
   logic [7:0] mem [0:255];

   //=================================================
   // Write Logic
   //=================================================
  always @ (posedge coreif.clk)
     if (coreif.ce_mem && coreif.we_mem) begin
       mem[coreif.addr_mem] <= coreif.datai_mem;
    end

   //=================================================
   // Read Logic
   //=================================================
  always @ (posedge coreif.clk)
     if (coreif.ce_mem && ~coreif.we_mem)  begin
       coreif.datao_mem <= mem[coreif.addr_mem];
    end

endmodule

