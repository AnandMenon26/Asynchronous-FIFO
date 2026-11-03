class monitor #(parameter data_width = 8);
  //Interface bound to monitor modport
  virtual fifo_if #(data_width).monitor mif;
  //Mailbox to send transactions to scoreboard
  mailbox #(fifo_item #(data_width)) mon2scb;

  function new(
    virtual fifo_if #(data_width).monitor mif,
    mailbox #(fifo_item #(data_width)) mon2scb
  );
    this.mif = mif;
    this.mon2scb = mon2scb;
  endfunction
  
  //Main task for sampling data
  task main();
    fork
      monitor_write();
      monitor_read();
    join
  endtask

  //Monitor write domain
  task monitor_write();
    forever begin
      //Synchronise to write clocking block
      @(mif.cb_mon_write);

      //Ignore activity while in reset
      if(!mif.write_reset_n) continue;

      //Valid write: write enabled and FIFO not full
      if(mif.cb_mon_write.write_enable && !mif.cb_mon_write.write_full) begin
        fifo_item #(data_width) tr_wr = new();

        tr_wr.op_type = tr_wr.WRITE;
        tr_wr.write_data = mif.cb_mon_write.write_data;
        tr_wr.write_full = mif.cb_mon_write.write_full;

        tr_wr.print("MON_WRITE");
        //Send data to scoreboard
        mon2scb.put(tr_wr);
      end
    end
  endtask

  //Monitor read domain
  task monitor_read();
    forever begin
      //Synchronise to read clocking domain
      @(mif.cb_mon_read);

      //Ignore activity while in reset
      if(!mif.read_reset_n) continue;

      //Valid read: read enabled and FIFO not empty
      if(mif.cb_mon_read.read_enable && !mif.cb_mon_read.read_empty) begin
        fifo_item #(data_width) tr_rd = new();

        tr_rd.op_type = tr_rd.READ;
        tr_rd.read_data = mif.cb_mon_read.read_data;
        tr_rd.read_empty = mif.cb_mon_read.read_empty;

        tr_rd.print("MON_READ");
        //Send data to scoreboard
        mon2scb.put(tr_rd);
      end
    end
  endtask
endclass