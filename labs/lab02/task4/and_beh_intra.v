module and_beh_intra(input a,b, output reg y);
    always@(*)begin
        y = #1 a&b;
    end
endmodule