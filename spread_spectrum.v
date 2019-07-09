module spread_spectrum (code_out,gps_data,rst,ss_data);

input code_out;
input gps_data;
//input gps_clk;
input rst;
//reg code_out_reg,gps_data_reg,ss_en;

output wire ss_data;


assign ss_data = (rst)?code_out^gps_data:0;


//    assign dpsk = dpsk_buf ^ ss_data;


//assign ss_data = (ss_en)? code_out_reg^gps_data_reg:0;//扩频操作
endmodule
