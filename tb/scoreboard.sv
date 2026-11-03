class scoreboard #(parameter data_width = 8);
  //Mailbox receiving data from monitor
  mailbox #(fifo_item #(data_width)) mon2scb;

  //Storage for expected results
  bit [data_width - 1:0] ref_queue[$];

  //Statistics
  int match_count;
  int error_count;
  int total_writes;
  int total_reads;

  //Custom constructor
  function new(mailbox #(fifo_item #(data_width)) mon2scb);
    this.mon2scb = mon2scb;
    this.match_count = 0;
    this.error_count = 0;
    this.total_writes = 0;
    this.total_reads = 0;
  endfunction

  //Main processing task
  task main();
    fifo_item #(data_width) tr;

    forever begin
      //Pull the next transaction from monitor
      mon2scb.get(tr);

      case(tr.op_type)
        tr.WRITE: process_write(tr);
        tr.READ: process_read(tr);
        default: begin end
      endcase
    end
  endtask

  //Processing write operations
  task process_write(fifo_item #(data_width) tr);
    ref_queue.push_back(tr.write_data);
    total_writes++;
    $display("[%0t] [SCB_WR] Stored Expected Data: 0x%0h, Queue Depth: %0d:", $time, tr.write_data, ref_queue.size());
  endtask

  //Processing read operations
  task process_read(fifo_item #(data_width) tr);
    bit [data_width - 1:0] expected_data;
    total_reads++;

    //Check for underflow, if read occured when fifo was empty
    if(ref_queue.size() == 0) begin
      $error("[%0t] [SCB_ERROR] Read occured when reference queue is empty: Underflow", $time);
      error_count++;
      return;
    end

    //Pop earliest written item
    expected_data = ref_queue.pop_front();

    //Compare actual read data against expected data 
    if(tr.read_data === expected_data) begin
      $display("[%0t] [SCB_pass] Data match - Data: 0x%0h, Remaining items: %0d:", $time, tr.read_data, ref_queue.size());
      match_count++;
    end
    else begin
      $error("[%0t] [SCB_FAIL] Data Mismatch - Expected 0x%0h, Got 0x%0h", $time, expected_data, tr.read_data);
      error_count++;
    end
  endtask

  //Final report function
  function void report();
    $display("\n==============================================");
    $display("             SCOREBOARD REPORT                ");
    $display("==============================================");
    $display("Total Writes Monitored: %0d", total_writes);
    $display("Total Reads Monitored: %0d", total_reads);
    $display("Passed Matches: %0d", match_count);
    $display("Failed Mismatches: %0d", error_count);
    $display("Items Left In Queue: %0d", ref_queue.size());

    if(error_count == 0 && total_reads > 0 && ref_queue.size() == 0) begin
      $display("STATUS: ALL TESTS PASSED");
    end
    else begin
      $display("STATUS: TEST FAILED/INCOMPLETE");
    end
    $display("==============================================\n");
  endfunction
endclass