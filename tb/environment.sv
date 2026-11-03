class environment #(parameter data_width = 8);
  //Objects for each class
  generator #(data_width) gen;
  driver #(data_width) drv;
  monitor #(data_width) mon;
  scoreboard #(data_width) scb;
  //Mailbox for sending data from generator-driver and monitor-scoreboard 
  mailbox #(fifo_item #(data_width)) gen2drv;
  mailbox #(fifo_item #(data_width)) mon2scb;

  //Events for generator and driver
  event gen_done;


  //Interface for driver and monitor
  virtual fifo_if #(data_width).driver dif;
  virtual fifo_if #(data_width).monitor mif;

  //Custom method for new
  function new(
    virtual fifo_if #(data_width).driver dif,
    virtual fifo_if #(data_width).monitor mif
  );
    this.dif = dif;
    this.mif = mif;

    gen2drv = new();
    mon2scb = new();

    gen = new(gen2drv, gen_done);
    drv = new(dif, gen2drv);
    mon = new(mif, mon2scb);
    scb = new(mon2scb);
  endfunction

  //Pre-test initializastion
  task pre_test();
    drv.reset();
  endtask
  
  //task for testing the DUT 
  task test();
    fork 
      gen.main();
      drv.main();
      mon.main();
      scb.main();
    join_any
  endtask

  //Post testing checks
  task post_test();
    //Waiting for generator to finish
    wait(gen_done.triggered);

    //Waiting until all items have been read out and processed by scoreboard
    wait(gen2drv.num() == 0);
    #200;
  endtask

  //Main run task
  task run();
    pre_test();
    test();
    post_test();

    //Print final report
    scb.report();
    $stop;
  endtask
endclass