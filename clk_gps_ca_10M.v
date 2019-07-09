module clk_gps_ca_10M (clkin,clk_ca_1023,rst);

input clkin;
input rst;
output reg clk_ca_1023;

reg [32:0] gps_c_code_nco;

//parameter code_freqword = 32'd878750308;  

parameter code_freqword = 32'd439375154; 

////////////////////////产生1.023MHz的码频率//////////
always @ (posedge clkin or negedge rst)
	if(!rst)
		begin
//			gps_c_code_nco <= 32'b11111111111111111111111111111111;
			gps_c_code_nco <= 33'b100000000000000000000000000000000;
		end
	else
		begin
			gps_c_code_nco <= {1'b0,gps_c_code_nco[31:0]} + code_freqword;
		end
		
always @ (posedge clkin or negedge rst) 
begin
	if (!rst)
		begin
			clk_ca_1023 <= 0;
		end
	else begin
			if (gps_c_code_nco[32] == 1)
				begin
					clk_ca_1023 <= ~clk_ca_1023;
				end
			else begin
					clk_ca_1023 <= clk_ca_1023;
			end
		end
end
endmodule	