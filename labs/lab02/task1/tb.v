// tb.v
module tb;

  reg   t_i0, t_i1, t_s;
  wire  t_y;

  // DUT instantiation
  DUT uut (.I0(t_i0), .I1(t_i1), .S(t_s), .Y(t_y));

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, tb);
    end
  end

  initial begin
    // All 8 combinations of {I0, I1, S}, 5 time units apart
                t_i0 = 0; t_i1 = 0; t_s = 0;
    #5          t_i0 = 0; t_i1 = 0; t_s = 1;
    #5          t_i0 = 0; t_i1 = 1; t_s = 0;
    #5          t_i0 = 0; t_i1 = 1; t_s = 1;
    #5          t_i0 = 1; t_i1 = 0; t_s = 0;
    #5          t_i0 = 1; t_i1 = 0; t_s = 1;
    #5          t_i0 = 1; t_i1 = 1; t_s = 0;
    #5          t_i0 = 1; t_i1 = 1; t_s = 1;
    #5 $finish;
  end

  initial
    $monitor($time, " I0=%b I1=%b S=%b | Y=%b", t_i0, t_i1, t_s, t_y);

endmodule