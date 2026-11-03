module fifo_mem #(parameter data_width = 8,
                  parameter addr_width = 4
                 )(
  //Write port
  input wire write_clk, write_clk_enable,
  input wire [addr_width-1:0] write_addr,
  input wire [data_width-1:0] write_data,
  //Read port
  input wire [addr_width-1:0] read_addr,
  output wire [data_width-1:0] read_data
  );
  
  localparam fifo_depth = 1<< addr_width;
  
  //Dual port storage array
  reg [data_width-1:0] mem [0:fifo_depth-1];
  
  //Write operation
  always @(posedge write_clk)
           begin
             if(write_clk_enable)
               begin
                 mem[write_addr] <= write_data;
               end
           end
  
  //Continuous read opreation
  assign read_data = mem[read_addr];
endmodule