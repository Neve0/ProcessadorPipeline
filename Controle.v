module Controle (
	input [31:0] iInst,

	output reg 		 oBranch,
    output reg		 oMemRead,
	output reg [1:0] oMemtoReg,
	output reg [2:0] oALUControl,
	output reg 		 oMemWrite,
	output reg 		 oALUSrc,
	output reg 		 oRegWrite,
	output reg [1:0] oOrigPC;
	);

	`include "parametros.v"

	wire [6:0] Opcode = iInst[6:0];
	wire [2:0] funct3 = iInst[14:12];
	wire [6:0] funct7 = iInst[31:25];
	
	always @(*) 
	begin
		case (Opcode)	
			OP_B:
			begin
					oALUSrc <= 1'b0;
					oMemtoReg <= 2'b00;
					oRegWrite <= 1'b0;
					oMemRead <= 1'b0;
					oMemWrite <= 1'b0;
					oBranch <= 1'b1;
					oALUControl <= OP_SUB;
					oOrigPC <= 2'b01;
		  end
			OP_LOAD:
			begin
					oALUSrc <= 1'b1;
					oMemtoReg <= 2'b01;
					oRegWrite <= 1'b1;
					oMemRead <= 1'b1;
					oMemWrite <= 1'b0;
					oBranch <= 1'b0;
					oALUControl <= OP_ADD;
					oOrigPC <= 2'b00;
			end
			OP_STORE:
			begin
					oALUSrc <= 1'b1;
					oMemtoReg <= 2'b00;
					oRegWrite <= 1'b0;
					oMemRead <= 1'b0;
					oMemWrite <= 1'b1;
					oBranch <= 1'b0;
					oALUControl <= OP_ADD;
					oOrigPC <= 2'b00;
			end
			OP_JAL:
			begin
					oALUSrc <= 1'b0;
					oMemtoReg <= 2'b10;
					oRegWrite <= 1'b1;
					oMemRead <= 1'b0;
					oMemWrite <= 1'b0;
					oBranch <= 1'b0;
					oALUControl <= OP_ADD;
					oOrigPC <= 2'b10;
			end	
			OP_R:
				begin
					oALUSrc <= 1'b0;
					oMemtoReg <= 2'b00;
					oRegWrite <= 1'b1;
					oMemRead <= 1'b0;
					oMemWrite <= 1'b0;
					oBranch <= 1'b0;
					
					case (funct3)
						FUNCT3_ADD:
								if (funct7 == FUNCT7_ADD) oALUControl <= OP_ADD;
								else oALUControl <= OP_SUB;
						FUNCT3_AND: oALUControl <= OP_AND;
						FUNCT3_OR: oALUControl <= OP_OR;
						FUNCT3_SLT: oALUControl <= OP_SLT;	
						default: oALUControl <= OP_ADD;
					endcase
					oOrigPC <= 2'b00;
				end
			OP_R_IMM:
				begin
					oALUSrc <= 1'b1;
					oMemtoReg <= 2'b00;
					oRegWrite <= 1'b1;
					oMemRead <= 1'b0;
					oMemWrite <= 1'b0;
					oBranch <= 1'b0;
					
					case (funct3)
						FUNCT3_ADDI: oALUControl <= OP_ADD;
						FUNCT3_ANDI: oALUControl <= OP_AND;
						FUNCT3_ORI: oALUControl <= OP_OR;
						FUNCT3_XORI: oALUControl <= OP_XOR;
						default: oALUControl <= OP_ADD;
					endcase
					oOrigPC <= 2'b00;
				end
			default:
				begin
					oALUSrc <= 1'b0;
					oMemtoReg <= 2'b00;
					oRegWrite <= 1'b0;
					oMemRead <= 1'b0;
					oMemWrite <= 1'b0;
					oBranch <= 1'b0;
					oALUControl <= OP_ADD;
					oOrigPC <= 2'b00;
				end
		endcase

		// TESTE
		$display("Opcode=%b", Opcode);
		$display("ALUSrc=%b", oALUSrc);
		$display("MemtoReg=%b", oMemtoReg);
		$display("RegWrite=%b", oRegWrite);
		$display("MemRead=%b", oMemRead);
		$display("MemWrite=%b", oMemWrite);
		$display("Branch=%b", oBranch);
		$display("ALUControl=%b", oALUControl);
		$display("OrigPC=%b", oOrigPC);
	2///1////////////////////////////////////
	end
		
endmodule