`timescale 1ns/1ps 

`include "fifo_item.sv"
`include "fifo_if.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "environment.sv"

module async_fifo_tb();
  localparam data_width = 8;
  localparam addr_width = 4;
  localparam fifo_depth = 1<<addr_width;
  
  reg read_clk, write_clk;

  fifo_if #(data_width) inf(write_clk, read_clk);
  
  async_fifo #(.data_width (data_width), 
             .addr_width (addr_width)
            ) dut (
    .read_data (inf.read_data),
    .read_empty (inf.read_empty),
    .read_enable (inf.read_enable),
    .read_reset_n (inf.read_reset_n),
    .read_clk (inf.read_clk),
    .write_full (inf.write_full),
    .write_data (inf.write_data),
    .write_enable (inf.write_enable),
    .write_reset_n (inf.write_reset_n),
    .write_clk (inf.write_clk)
  );
  
  initial
    begin
      write_clk=1'b0;
      forever  #10 write_clk=~write_clk;
    end
  
  initial
    begin
      read_clk=1'b0;
      forever  #25 read_clk=~read_clk;
    end 

    environment env;
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0,async_fifo_tb);
      
      env = new(inf.driver, inf.monitor);
      env.gen.repeat_count = 50;
      env.run();
      $stop;
    end
endmodule