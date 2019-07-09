module test (pps,pps_out,transmit_en,transmit_en_out);
input   pps;
input   transmit_en;

output  wire transmit_en_out;
output  wire pps_out;

assign pps_out=pps;
assign transmit_en_out=transmit_en;


endmodule