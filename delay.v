`timescale   1ns/1ns
module delay (clk_in,dealy_clk_in);
input   clk_in;

output  wire dealy_clk_in;

assign dealy_clk_in=clk_in;


endmodule