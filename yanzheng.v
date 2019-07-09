module yanzheng (clk_ca,code_out,ss_data,rst,tx_data);
input clk_ca;
input code_out;
input ss_data;
//input gps_clk;
input rst;
//reg code_out_reg,gps_data_reg,ss_en;

output reg tx_data;

//assign tx_data = (rst)?code_out^ss_data:0;
always @ (posedge clk_ca or negedge rst)
begin
	if (!rst)
		begin
			tx_data <= 1'b0;
		end
	else begin
		tx_data = code_out^ss_data;
	end
end


endmodule
