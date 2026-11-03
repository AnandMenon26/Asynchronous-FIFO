interface fifo_if #(parameter data_width = 8)(
  input bit write_clk,
  input bit read_clk
  );
  //Read domain
  logic [data_width-1:0] read_data;
  logic read_empty;
  logic read_enable, read_reset_n;

  //Write domain
  logic write_full;
  logic [data_width-1:0] write_data;
  logic write_enable, write_reset_n;

  //Clocking Blocks:
  clocking cb_write @(posedge write_clk);
    default input #1step output #1ns;
    output write_enable;
    output write_data;
    input write_full;
  endclocking

  clocking cb_read @(posedge read_clk);
    default input #1step output #1ns;
    output read_enable;
    input read_data;
    input read_empty;
  endclocking

  clocking cb_mon_write @(posedge write_clk);
    default input #1step output #1ns;
    input write_enable;
    input write_data;
    input write_full;
  endclocking

  clocking cb_mon_read @(posedge read_clk);
    default input #1step output #1ns;
    input read_enable;
    input read_data;
    input read_empty;
  endclocking

  //Modports
  modport driver(
    clocking cb_write,
    clocking cb_read,
    output write_reset_n,
    output read_reset_n
  );

  modport monitor(
    clocking cb_mon_write,
    clocking cb_mon_read,
    input write_reset_n,
    input read_reset_n
  );

  // SYSTEMVERILOG ASSERTIONS (SVA)
  //Ensure flags are never unknown(X) after reset is released 
  property p_no_x_flags;
    @(posedge write_clk) disable iff (!write_reset_n)
    (!$isunknown(write_full) && !$isunknown(read_empty));
  endproperty
  assert_no_x_flags: assert property(p_no_x_flags)
  else $error("[SVA FAIL] Flags became unknown(X)");

  //Never attempt write when FIFO is full
  property p_no_overflow;
    @(posedge write_clk) disable iff (!write_reset_n)
    write_enable |-> !write_full;
  endproperty
  assert_no_overflow: assert property (p_no_overflow)
  else $warning("[SVA WARNING] Write attempted while FIFO is full");

  //Never attempt a read when FIFO is empty
  property p_no_underflow;
    @(posedge read_clk) disable iff (!read_reset_n)
    read_enable |-> !read_empty;
  endproperty
  assert_no_underflow: assert property (p_no_underflow)
  else $warning("[SVA WARNING] Read attempted when FIFO is empty");

endinterface