// tb.v
// Testbench for the buggy ALU. Sweeps normal cases, boundary cases,
// and cases specifically chosen to expose the sensitivity-list bug
// and the blocking/non-blocking bug.

module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [4:0] t_result;
 
  alu uut (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  // Waveform dump
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, tb);
    end
  end

  initial begin
    // ---------------- ADD cases ----------------
    t_a=4'd0;  t_b=4'd0;  t_op=1'b0;         // 1)  0 + 0  = 0
    #5 t_a=4'd5;  t_b=4'd3;  t_op=1'b0;      // 2)  5 + 3  = 8
    #5 t_a=4'd15; t_b=4'd1;  t_op=1'b0;      // 3)  15+1   = 0  (overflow, wraps)
    #5 t_a=4'd15; t_b=4'd15; t_op=1'b0;      // 4)  15+15  = 14
    #5 t_a=4'd8;  t_b=4'd8;  t_op=1'b0;      // 5)  8 + 8  = 0  (MSB overflow)

    // ---------------- SUB cases ----------------
    #5 t_a=4'd0;  t_b=4'd0;  t_op=1'b1;      // 6)  0 - 0  = 0
    #5 t_a=4'd5;  t_b=4'd3;  t_op=1'b1;      // 7)  5 - 3  = 2
    #5 t_a=4'd3;  t_b=4'd5;  t_op=1'b1;      // 8)  3 - 5  = 14 (=-2, wraps)
    #5 t_a=4'd0;  t_b=4'd1;  t_op=1'b1;      // 9)  0 - 1  = 15 (=-1, underflow)
    #5 t_a=4'd15; t_b=4'd15; t_op=1'b1;      // 10) 15-15  = 0
    #5 t_a=4'd7;  t_b=4'd15; t_op=1'b1;      // 11) 7 -15  = 8  (=-8)

    // ---- Bug 1 probe: change ONLY op, keep a,b fixed ----
    #5 t_a=4'd6;  t_b=4'd2;  t_op=1'b0;      // 12) 6 + 2  = 8
    #5 t_a=4'd6;  t_b=4'd2;  t_op=1'b1;      // 13) 6 - 2  = 4
                                              //     if result stays 8, op isn't
                                              //     in the sensitivity list

    // ---- Bug 2 probe: consecutive subs with different b ----
    #5 t_a=4'd5;  t_b=4'd3;  t_op=1'b1;      // 14) 5 - 3  = 2
    #5 t_a=4'd5;  t_b=4'd7;  t_op=1'b1;      // 15) 5 - 7  = 14 (=-2)
    #5 t_a=4'd5;  t_b=4'd1;  t_op=1'b1;      // 16) 5 - 1  = 4
                                              //     if any of these are off,
                                              //     the sub chain is using stale
                                              //     b_inv/b_twos from NBAs

    #10 $finish;
  end

  initial
    $monitor("t=%0t  a=%b (%0d)  b=%b (%0d)  op=%b | result=%b (%0d)",
             $time, t_a, t_a, t_b, t_b, t_op, t_result, t_result);

endmodule