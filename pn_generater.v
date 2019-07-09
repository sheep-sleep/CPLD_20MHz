module pn_generater (clk,rst,number_select,code_out);//产生伪码
input clk;
input rst;
input [3:0] number_select;
output reg code_out;

reg code1_reg1,code1_reg2,code1_reg3,code1_reg4,code1_reg5,code1_reg6,code1_reg7,code1_reg8,code1_reg9,code1_reg10;
reg code2_reg1,code2_reg2,code2_reg3,code2_reg4,code2_reg5,code2_reg6,code2_reg7,code2_reg8,code2_reg9,code2_reg10;


always @ (posedge clk or negedge rst)
begin
	if (!rst)
		begin
			code1_reg1 <= 1'b1;//全部置1
			code1_reg2 <= 1'b1;
			code1_reg3 <= 1'b1;
			code1_reg4 <= 1'b1;
			code1_reg5 <= 1'b1;
			code1_reg6 <= 1'b1;
			code1_reg7 <= 1'b1;
			code1_reg8 <= 1'b1;
			code1_reg9 <= 1'b1;
			code1_reg10 <= 1'b1;
			code2_reg1 <= 1'b1;
			code2_reg2 <= 1'b1;
			code2_reg3 <= 1'b1;
			code2_reg4 <= 1'b1;
			code2_reg5 <= 1'b1;
			code2_reg6 <= 1'b1;
			code2_reg7 <= 1'b1;
			code2_reg8 <= 1'b1;
			code2_reg9 <= 1'b1;
			code2_reg10 <= 1'b1;
			code_out <= 1'b0;
		end
	else begin
		code1_reg2 <= code1_reg1;//G1的产生
		code1_reg3 <= code1_reg2;
		code1_reg4 <= code1_reg3;
		code1_reg5 <= code1_reg4;
		code1_reg6 <= code1_reg5;
		code1_reg7 <= code1_reg6;
		code1_reg8 <= code1_reg7;
		code1_reg9 <= code1_reg8;
		code1_reg10 <= code1_reg9;
		code1_reg1 <= code1_reg3^code1_reg10;
		
		code2_reg2 <= code2_reg1;//G2的产生
		code2_reg3 <= code2_reg2;
		code2_reg4 <= code2_reg3;
		code2_reg5 <= code2_reg4;
		code2_reg6 <= code2_reg5;
		code2_reg7 <= code2_reg6;
		code2_reg8 <= code2_reg7;
		code2_reg9 <= code2_reg8;
		code2_reg10 <= code2_reg9;
		code2_reg1 <= code2_reg2^code2_reg3^code2_reg6^code2_reg8^code2_reg9^code2_reg10;
		
		if (number_select == 4'b0001) // 4'b0001是2⊕8,PRN#1//相位选择
			begin
				code_out <= code2_reg2^code2_reg8^code1_reg10;
			end
		else if (number_select == 4'b0010) // 4'b0010是2⊕6,PRN#2
			begin
				code_out <= code2_reg2^code2_reg6^code1_reg10;
			end
		else if (number_select == 4'b0011) // 4'b0011是4⊕10,PRN#3
			begin
				code_out <= code2_reg4^code2_reg10^code1_reg10;
			end
		else if (number_select == 4'b0100) // 4'b0100是7⊕10,PRN#4
			begin
				code_out <= code2_reg7^code2_reg10^code1_reg10;
			end
		else if (number_select == 4'b0101) // 4'b0101是5⊕10,PRN#5
			begin
				code_out <= code2_reg5^code2_reg10^code1_reg10;
			end
		else if (number_select == 4'b0110) // 4'b0110是1⊕10,PRN#6
			begin
				code_out <= code2_reg1^code2_reg10^code1_reg10;
			end
		else begin
				code_out <= 1'b0;
		end
	
	
	end
end
endmodule








