class driver #(parameter data_width = 8);
  virtual fifo_if #(data_width).driver dif;
  mailbox #(fifo_item #(data_width)) gen2drv;
  fifo_item #(data_width) tr;

  function new(
    virtual fifo_if #(data_width).driver dif,
    mailbox #(fifo_item #(data_width)) gen2drv
  );
    this.dif = dif;
    this.gen2drv = gen2drv;
  endfunction

  //Reset task
  task reset();
    $display("[%0t] [DRV] Reset Asserted", $time);

    //Direct assignment to reset values
    dif.write_reset_n <= 1'b0;
    dif.read_reset_n <= 1'b0;

    dif.cb_write.write_enable <= 1'b0;
    dif.cb_write.write_data <= '0;
    dif.cb_read.read_enable <= 1'b0;

    //Hold reset avtive across multiple clock cycles
    repeat(3) @(dif.cb_write);
    repeat(3) @(dif.cb_read);

    //De-assert resets
    dif.write_reset_n <= 1'b1;
    dif.read_reset_n <= 1'b1;

    //Wait 1 cycle
    @(dif.cb_write);
    @(dif.cb_read);

    $display("[%0t] [DRV] Reset Released", $time);
  endtask

  //Main run task
  task main();
    forever begin
      //Fetch next randomized transaction from mailbox
      gen2drv.get(tr);
      tr.print("DRV_RECV");

      //Drive transaction according to op_type
      case(tr.op_type)
        tr.WRITE: drive_write(tr);
        tr.READ: drive_read(tr);
        tr.IDLE: drive_idle(tr);
      endcase
    end
  endtask

  //Write Channel task
  task drive_write (fifo_item #(data_width) tr);
    //Align to write clock domain
    @(dif.cb_write);
    
    //Wait for randomized idle cycles
    repeat(tr.delay) @(dif.cb_write);

    //Drive write data and write enable
    dif.cb_write.write_data <= tr.write_data;
    dif.cb_write.write_enable <= 1'b1;

    //Wait 1 rising edge of write clock
    @(dif.cb_write);

    //De-assert write enable
    dif.cb_write.write_enable <= 1'b0;
  endtask

  //Read channel task
  task drive_read (fifo_item #(data_width) tr);
    //Align to read clock domain
    @(dif.cb_read);

    //Wait for randomized idle cycles
    repeat(tr.delay) @(dif.cb_read);

    //Assert read enable
    dif.cb_read.read_enable <= 1'b1;

    //Wait 1 rising edge of read clock
    @(dif.cb_read);

    //De-assert read enable
    dif.cb_read.read_enable <= 1'b0;
  endtask

  //Idle task - no activity driven
  task drive_idle(fifo_item #(data_width) tr);
    dif.cb_write.write_enable <= 1'b0;
    dif.cb_read.read_enable <= 1'b0;
    repeat(tr.delay + 1) @(dif.cb_write);
  endtask
endclass