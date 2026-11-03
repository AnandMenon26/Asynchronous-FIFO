module async_fifo#(
  parameter data_width = 8,
  parameter addr_width = 4
  )(
  //Read interface
  output wire [data_width-1:0] read_data,
  output wire read_empty,
  input wire read_enable, read_reset_n, read_clk,
  //Write interface
  output wire write_full,
  input [data_width-1:0] write_data,
  input wire write_enable, write_reset_n, write_clk
  );
  //Internal fifo states
  //Write domain registers
  wire [addr_width:0] write_ptr_bin, write_ptr_gray, sync_read_ptr_gray;
  //Read domain registers
  wire [addr_width:0] read_ptr_bin, read_ptr_gray, sync_write_ptr_gray; 
  
  //To enable/stop write operation
  wire write_clk_enable;
  
  assign write_clk_enable = (write_enable && !write_full);
  
  //Instantiation of sub- modules
  //Dual port memory array
  fifo_mem #(.data_width(data_width),
             .addr_width(addr_width)
            )u_fifo_mem(
    .write_clk (write_clk), 
    .write_clk_enable (write_clk_enable),
    .write_addr (write_ptr_bin[addr_width-1:0]),
    .write_data (write_data),
    .read_addr (read_ptr_bin[addr_width-1:0]),
    .read_data (read_data)
	);
  
  //Synchroniser: write gray pointer to read clk domain
  synchroniser_2ff #(.width(addr_width+1))u_sync_w_to_r(
    .clk (read_clk), 
    .reset_n (read_reset_n),
    .data_in (write_ptr_gray),
    .data_out (sync_write_ptr_gray)
	);
  
  //Synchroniser: read gray pointer to write clk domain
  synchroniser_2ff #(.width(addr_width+1))u_sync_r_to_w(
    .clk (write_clk), 
    .reset_n (write_reset_n),
    .data_in (read_ptr_gray),
    .data_out (sync_read_ptr_gray)
	);
  
  //Write pointer, full flag generation
  write_full #(.addr_width (addr_width))u_write_full(
    .write_clk (write_clk), 
    .write_reset_n(write_reset_n), 
    .write_enable (write_enable),
    .sync_read_ptr_gray (sync_read_ptr_gray),
    .write_ptr_bin (write_ptr_bin), 
    .write_ptr_gray (write_ptr_gray),
    .write_full (write_full)
	);
  
  //Read pointer, empty flag generation
  read_empty #(.addr_width (addr_width))u_read_empty(
    .read_clk (read_clk), 
    .read_reset_n (read_reset_n), 
    .read_enable (read_enable),
    .sync_write_ptr_gray (sync_write_ptr_gray),
    .read_ptr_bin (read_ptr_bin), 
    .read_ptr_gray (read_ptr_gray),
    .read_empty (read_empty)
	);
endmodule