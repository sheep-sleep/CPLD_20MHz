module clk_gps_ca_10M_3 (clkin,clk_ca_1023,rst);

input clkin;
input rst;
output reg clk_ca_1023;

reg [65:0] gps_c_code_nco;


parameter code_freqword = 65'd7548407674961948521;


////////////////////////产生1.023MHz的码频率//////////
always @ (posedge clkin or negedge rst)
	if(!rst)
		begin
			gps_c_code_nco <= 66'b100000000000000000000000000000000000000000000000000000000000000000;
		end
	else
		begin
			gps_c_code_nco <= {1'b0,gps_c_code_nco[64:0]} + code_freqword;
		end
		
always @ (posedge clkin or negedge rst) 
begin
	if (!rst)
		begin
			clk_ca_1023 <= 0;
		end
	else begin
			if (gps_c_code_nco[65] == 1)
				begin
					clk_ca_1023 <= ~clk_ca_1023;
				end
			else begin
					clk_ca_1023 <= clk_ca_1023;
			end
		end
end
endmodule	