module ULA (
	iControl,
	iA,
	iB,
	oResult,
	oZero
	);

	`include "parametros.v"

	input [2:0] iControl;
	input signed [31:0] iA;
	input signed [31:0] iB;
	output [31:0] oResult;
	output oZero;
	
	always @(*)
	begin
		case (iControl)
			OP_AND: oResult <= iA & iB;
			
			OP_OR: oResult <= iA | iB;
			
			OP_ADD: oResult <= iA + iB;
			
			OP_SUB: oResult <= iA - iB;
			
			OP_SLT: oResult <= iA < iB;
			
			OP_XOR: oResult <= iA ^ iB;

			default: oResult <= iA & iB;
		endcase

		oZero <= (oResult == 32'h0000_0000) ? 1'b1 : 1'b0;
	end

endmodule