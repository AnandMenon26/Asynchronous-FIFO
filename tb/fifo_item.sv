class fifo_item #(parameter data_width = 8);
  //Transaction control and data
  typedef enum bit [1:0] {WRITE = 2'b01, READ = 2'b10, IDLE = 2'b00} op_e;
  //"rand" is not used for Questa Starter Edition compatibility 
  //rand op_e op_type;
  //rand bit [data_width - 1:0] write_data;
  //rand int unsigned delay; 

  op_e op_type;
  bit [data_width - 1:0] write_data;
  int unsigned delay; 


  //Monitored Signals
  bit [data_width-1:0] read_data;
  bit write_full, read_empty;

  /*Constraints enforced procedurally using $urandom_range in generator
  constraint c_delay{
    delay inside{[0:5]};
  }

  constraint c_op_dist{
    op_type dist {WRITE := 45, READ := 45, IDLE := 10};
  }
  */

  //Display method
  function void print (string tag = "");
    $display("[%0t] [%s] OP = %s, Write Data = %h, Read Data = %h, full = %b, empty = %b", $time, tag, op_type.name(), write_data, read_data, write_full, read_empty );
  endfunction
endclass