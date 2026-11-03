class generator #(parameter data_width = 8);
  fifo_item #(data_width) tr;
  mailbox #(fifo_item #(data_width)) gen2drv;
  
  event done;
  int repeat_count = 20;

  function new(mailbox #(fifo_item #(data_width)) gen2drv, event done);
    this.gen2drv = gen2drv;
    this.done = done;
  endfunction

  task main();
    int rand_val;
    int pending_items = 0;
    int rand_reads = 0;
    int rand_writes = 0;
    int rand_idles = 0;
    int forced_drain_reads = 0;

    for(int i=0; i<repeat_count; i++) begin
      tr = new();

      /* Bypassed .randomize() due to Questa Starter Edition licence limit
      if(!tr.randomize()) begin
        $error("[Gen] Randomization Failed");
      end
      */

      //Replicating Constraints
      rand_val = $urandom_range(1,100);

      if(rand_val <= 45) begin
        tr.op_type = tr.WRITE;
        rand_writes++;
        if(pending_items < 16) begin
          pending_items++;
        end
      end
      else if(rand_val <= 90) begin 
        tr.op_type = tr.READ;
        rand_reads++;
        if(pending_items > 0) begin
          pending_items--;
        end
      end
      else begin 
        tr.op_type = tr.IDLE;
        rand_idles++;
      end

      //Randomize write data
      tr.write_data = $urandom;

      //Replicating delay constraint
      tr.delay = $urandom_range(0,5);

      tr.print("Gen");
      gen2drv.put(tr); //push randomized data into mailbox for driver
    end

    //Drain phase to empty any items left behind
    if(pending_items > 0) begin
      $display("[%0t] [GEN] Entering drain phase: Forcing %0d reads", $time, pending_items);
      for(int i = 0; i < pending_items; i++) begin
        tr = new();
        tr.op_type = tr.READ;
        tr.delay = 1;
        forced_drain_reads++;

        tr.print("Gen_Drain");
        gen2drv.put(tr);
      end
    end
    
    //Generator final report
    $display("\n==============================================");
    $display("             GENERATOR REPORT                 ");
    $display("==============================================");
    $display("Total Randomized Writes: %0d", rand_writes);
    $display("Total Randomized Reads: %0d", rand_reads);
    $display("Total Randomized Idles: %0d", rand_idles);
    $display("----------------------------------------------");
    $display("Total Forced Drain Reads: %0d", forced_drain_reads);
    $display("==============================================\n");

    ->done;
  endtask
endclass