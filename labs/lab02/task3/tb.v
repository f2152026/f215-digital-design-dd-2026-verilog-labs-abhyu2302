// tb.v
// Self-checking testbench for the 2-bit magnitude comparator.
// Sweeps all 16 input combinations, computes the expected GT/LT/EQ
// in the tb itself, and flags any mismatch.

module tb;

  // Inputs / outputs
  reg  [1:0] t_a, t_b;
  wire       t_gt, t_lt, t_eq; 

  // DUT instantiation
  comp2 uut (
    .A  (t_a),
    .B  (t_b),
    .GT (t_gt),
    .LT (t_lt),
    .EQ (t_eq)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, tb);
    end
  end

  // Expected values, computed independently from the DUT
  reg exp_gt, exp_lt, exp_eq;
  integer errors;

  // Task: apply a vector, wait for propagation, check, report
  task check_case(input [1:0] a_in, input [1:0] b_in);
    begin
      t_a = a_in;
      t_b = b_in;
      #1;  // let combinational outputs settle

      exp_gt = (a_in >  b_in);
      exp_lt = (a_in <  b_in);
      exp_eq = (a_in == b_in);

      if (t_gt !== exp_gt || t_lt !== exp_lt || t_eq !== exp_eq) begin
        $display("MISMATCH at t=%0t  A=%0d B=%0d | GT=%b LT=%b EQ=%b  (expected GT=%b LT=%b EQ=%b)",
                 $time, a_in, b_in, t_gt, t_lt, t_eq, exp_gt, exp_lt, exp_eq);
        errors = errors + 1;
      end

      // One-hot sanity: exactly one of GT/LT/EQ must be 1
      if ((t_gt + t_lt + t_eq) !== 1) begin
        $display("ONE-HOT VIOLATION at t=%0t  A=%0d B=%0d | GT=%b LT=%b EQ=%b",
                 $time, a_in, b_in, t_gt, t_lt, t_eq);
        errors = errors + 1;
      end
    end
  endtask

  integer i, j;
  initial begin
    errors = 0;

    // Exhaustive: all 4x4 = 16 combinations, 5 units apart
    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        check_case(i[1:0], j[1:0]);
        #4;   // total 5 units between vectors (1 in task + 4 here)
      end
    end

    if (errors == 0)
      $display("ALL 16 CASES PASSED");
    else
      $display("FAILED: %0d mismatches found", errors);

    $finish;
  end

  initial
    $monitor("t=%0t  A=%0d B=%0d | GT=%b LT=%b EQ=%b",
             $time, t_a, t_b, t_gt, t_lt, t_eq);

endmodule