//module clk_gps_ca_10M_2 (clkin,clk_ca_1023,rst);
//
//input clkin;
//input rst;
//output reg clk_ca_1023;
//
//reg [45:0] gps_c_code_nco;
//reg clk_ca_1023_reg;
//
//
//parameter code_freqword = 45'd7198722529375;
//
//
//////////////////////////产生1.023MHz的码频率//////////
//always @ (posedge clkin or negedge rst)
//	if(!rst)
//		begin
//			gps_c_code_nco <= 45'd0;
//		end
//	else
//		begin
//			gps_c_code_nco <= {1'b0,gps_c_code_nco[44:0]} + code_freqword;
//		end
//		
//always @ (posedge clkin or negedge rst) 
//begin
//	if (!rst)
//		begin
//			clk_ca_1023_reg <= 0;
//		end
//	else begin
//			if (gps_c_code_nco[45] == 1)
//				begin
//					clk_ca_1023_reg <= ~clk_ca_1023_reg;
//				end
//			else begin
//					clk_ca_1023_reg <= clk_ca_1023_reg;
//			     end
//		  end
//	clk_ca_1023 <= ~clk_ca_1023_reg;
//end
//endmodule








module clk_gps_ca_10M_2 (clkin,clk_ca_1023,rst);

input clkin;
input rst;
output reg clk_ca_1023;

reg [64:0] gps_c_code_nco;


parameter code_freqword = 64'd754840767496194852;


////////////////////////产生1.023MHz的码频率//////////
always @ (posedge clkin or negedge rst)
	if(!rst)
		begin
			gps_c_code_nco <= 65'b10000000000000000000000000000000000000000000000000000000000000000;
		end
	else
		begin
			gps_c_code_nco <= {1'b0,gps_c_code_nco[63:0]} + code_freqword;
		end
		
always @ (posedge clkin or negedge rst) 
begin
	if (!rst)
		begin
			clk_ca_1023 <= 0;
		end
	else begin
			if (gps_c_code_nco[64] == 1)
				begin
					clk_ca_1023 <= ~clk_ca_1023;
				end
			else begin
					clk_ca_1023 <= clk_ca_1023;
			end
		end
end
endmodule	