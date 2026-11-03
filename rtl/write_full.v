module write_full #(parameter addr_width = 4)(
  input wire write_clk, write_reset_n, write_enable,
  input wire [addr_width:0] sync_read_ptr_gray,
  output reg [addr_width:0] write_ptr_bin, write_ptr_gray,
  output reg write_full
  );
  
  //Internal combinational wires
  wire [addr_width:0] write_ptr_bin_next, write_ptr_gray_next;
  wire write_full_val;
  
  //Next write pointer in binary (only if write is enabled and FIFO is not full)
  assign write_ptr_bin_next = write_ptr_bin + (write_enable && !write_full);
  
  //Next write pointer in gray
  assign write_ptr_gray_next = write_ptr_bin_next^(write_ptr_bin_next >> 1);
  
  //Lookahead full condition using the next gray write pointer
  assign write_full_val = (write_ptr_gray_next[addr_width:addr_width-1] == ~sync_read_ptr_gray[addr_width:addr_width-1]) && (write_ptr_gray_next[addr_width-2:0] == sync_read_ptr_gray[addr_width-2:0]);
  
  
  always @(posedge write_clk or negedge write_reset_n)
    begin
      if(!write_reset_n)
        begin
          write_ptr_bin <= {(addr_width+1){1'b0}};
          write_ptr_gray <= {(addr_width+1){1'b0}};
          write_full <= 1'b0;
        end
      else
        begin
          write_ptr_bin <= write_ptr_bin_next;
          write_ptr_gray <= write_ptr_gray_next;
          write_full <= write_full_val;
        end
    end
endmodule