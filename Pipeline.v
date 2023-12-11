module Pipeline (
	input wire clockCPU, clockMem,
	input wire reset,
	output reg [31:0] PC,
	output reg [31:0] Instr,
	input  wire[4:0] regin,
	output reg [31:0] regout
	);
	
	
	initial
		begin
			PC<=32'h0040_0000;
			Instr<=32'b0;
			regout<=32'b0;
		end
		
	
// Aqui vai o seu código do processador

wire [31:0] wID_Inst;

wire 		cBranch;
wire		cMemRead;
wire [1:0]  cMemtoReg;
wire [2:0]  cALUControl;
wire 		cMemWrite;
wire 		cALUSrc;
wire 		cRegWrite;
wire [1:0]  cOrigPC;

Controle CONTROL(
	.iInst(wID_Inst),
	.oBranch(cBranch),
    .oMemRead(cMemRead),
	.oMemtoReg(cMemtoReg),
	.oALUControl(cALUControl),
	.oMemWrite(cMemWrite),
	.oALUSrc(cALUSrc),
	.oRegWrite(cRegWrite),
	.oOrigPC(cOrigPC)
	);

Datapath DATAPATH(
	// FPGA
	.iClkCPU(clockCPU), 
	.iClkMem(clockMem),
	.iRST(reset),
	.iregin(iregin),

	.oInstView(Instr),
	.oPCView(PC),
	.oregout(regout),
	
	// CONTROLE
	.iBranch(cBranch),
	.iMemRead(cMemRead),
	.iMemtoReg(cMemtoReg),
	.iALUControl(cALUControl),
	.iMemWrite(cMemWrite),
	.iALUSrc(cALUSrc),
	.iRegWrite(cRegWrite),
	.iOrigPC(cOrigPC),

	.oInstruction(wID_Inst)
	);
			
endmodule
