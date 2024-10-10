module memory_ctrl(interface ctrlif);

typedef enum {IDLE,
              WRITE,
              READ,
              DONE
             }mode_t;

mode_t state;

  always @ (posedge ctrlif.clk)
    if (ctrlif.reset) begin
    state     <= IDLE;
    ctrlif.ready_sys <= 0;
    ctrlif.we_mem    <= 0;
    ctrlif.ce_mem    <= 0;
    ctrlif.addr_mem  <= 0;
    ctrlif.datai_mem <= 0;
    ctrlif.data_sys  <= 8'bz;
  end else begin
    case(state)
       IDLE :  begin
         ctrlif.ready_sys <= 1'b0;
         if (ctrlif.cmd_valid_sys && ctrlif.we_sys) begin
           ctrlif.addr_mem   <= ctrlif.addr_sys;
           ctrlif.datai_mem  <= ctrlif.data_sys;
           ctrlif.we_mem     <= 1'b1;
           ctrlif.ce_mem     <= 1'b1;
           state      <= WRITE;
         end
         if (ctrlif.cmd_valid_sys && ~ctrlif.we_sys) begin
           ctrlif.addr_mem   <= ctrlif.addr_sys;
           ctrlif.datai_mem  <= ctrlif.data_sys;
           ctrlif.we_mem     <= 1'b0;
           ctrlif.ce_mem     <= 1'b1;
           state      <= READ;
         end
       end
       WRITE : begin
         ctrlif.ready_sys  <= 1'b1;
         if (~ctrlif.cmd_valid_sys) begin
           ctrlif.addr_mem   <= 8'b0;
           ctrlif.datai_mem  <= 8'b0;
           ctrlif.we_mem     <= 1'b0;
           ctrlif.ce_mem     <= 1'b0;
           state      <= IDLE;
         end
       end 
       READ : begin
         ctrlif.ready_sys  <= 1'b1;
         ctrlif.data_sys   <= ctrlif.datao_mem;
         if (~ctrlif.cmd_valid_sys) begin
           ctrlif.addr_mem   <= 8'b0;
           ctrlif.datai_mem  <= 8'b0;
           ctrlif.we_mem     <= 1'b0;
           ctrlif.ce_mem     <= 1'b0;
           ctrlif.ready_sys  <= 1'b1;
           state      <= IDLE;
           ctrlif.data_sys   <= 8'bz;
         end 
       end 
    endcase
  end

endmodule
