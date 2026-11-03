module read_empty #(parameter addr_width = 4)(
  input wire read_clk, read_reset_n, read_enable,
  input wire [addr_width:0] sync_write_ptr_gray,
  output reg [addr_width:0] read_ptr_bin, read_ptr_gray,
  output reg read_empty
  );
  
  //Internal combinational wires
  wire [addr_width:0] read_ptr_bin_next, read_ptr_gray_next;
  wire read_empty_val;
  
  //Next read pointer in binary (only if read is enabled and FIFO is not empty)
  assign read_ptr_bin_next = read_ptr_bin + (read_enable && !read_empty);
  
  //Next read pointer in gray
  assign read_ptr_gray_next = read_ptr_bin_next^(read_ptr_bin_next >> 1);
  
  //Lookahead empty condition using the next gray read pointer
  assign read_empty_val = (read_ptr_gray_next == sync_write_ptr_gray);
  
  always @(posedge read_clk or negedge read_reset_n)
    begin
      if(!read_reset_n)
        begin
          read_ptr_bin <= {(addr_width+1){1'b0}};
          read_ptr_gray <= {(addr_width+1){1'b0}};
          read_empty <= 1'b1;
        end
      else
        begin
          read_ptr_bin <= read_ptr_bin_next;
          read_ptr_gray <= read_ptr_gray_next;
          read_empty <= read_empty_val;
        end
    end
endmodule