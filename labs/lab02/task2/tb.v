// tb.v
// Testbench for the parameterized LUT ROM.
// Sweeps sel through all DEPTH addresses and prints dout.

module tb;

  // Match the DUT's defaults; change here if you re-parameterize.
  localparam WIDTH = 8;
  localparam DEPTH = 4;

  // Inputs / outputs
  reg  [$clog2(DEPTH)-1:0] t_sel;
  wire [WIDTH-1:0]         t_dout;

  // DUT instantiation
  lut #(.WIDTH(WIDTH), .DEPTH(DEPTH)) uut (
    .sel  (t_sel),
    .dout (t_dout)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, tb);
    end
  end

  integer k;
  initial begin
    t_sel = 0;
    for (k = 0; k < DEPTH; k = k + 1) begin
      t_sel = k[$clog2(DEPTH)-1:0];
      #5;
    end
    $finish;
  end

  initial
    $monitor("t=%0t  sel=%0d | dout=%0d (0x%0h)",
             $time, t_sel, t_dout, t_dout);

endmodule