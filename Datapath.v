module Datapath (
	// FPGA
	input wire 		iClkCPU, iClkMem,
	input wire 		iRST,
	input 	[31:0]	initialPC,
	input 	[ 4:0] 	iregin,

	output [31:0] oInstView,
	output [31:0] oPCView,
	output [31:0] oregout,
	///////////////////////////////////////

	// CONTROLE
	input	 		iBranch,
	input	 		iMemRead,
	input	[1:0] 	iMemtoReg,
	input	[2:0] 	iALUControl,
	input	 		iMemWrite,
	input  			iALUSrc,
	input  			iRegWrite,
	input 	[1:0]	iOrigPC,

	output  [31:0] oInstruction
	///////////////////////////////////////
	);

reg	[ 95:0] RegIFID;
//PC 32
//PC+4 32
//Inst 32

reg [176:0] RegIDEX;
//PC+4 32
//PC 32
//Rs1Result 32
//Rs2Result 32
//RdID 5
//Imm 32
//Controle 12

reg [105:0]	RegEXMEM;
//ALUResult 32
//PC+4 32
//Rs2Result 32
//RdID 5
//Controle 8

reg [ 67:0] RegMEMWB
//PC+4 32
//RdID 5
//AluResult 32
//Controle 3

initial
begin
	RegIFID  <= {96  {1'b0}};
	RegIDEX  <= {177 {1'b0}};
	RegEXMEM <= {106 {1'b0}};
	RegMEMWB <= {100  {1'b0}};
end

//=====================================================================//
//======================== Estagio IF =================================//
//=====================================================================//

reg [ 31:0] PC;

initial
	begin
		PC <= 32'h0040_0000;
	end

//Memoria de instrucoes

wire [31:0] IwReadData;

rom INSTRUCTMEM (
	.address(PC[9:0]/4),
	.clock(iClkMem),
	.q(IwReadData)
	);

///////////////////////////////////////

// FPGA 
assign oInstruction = IwReadData;
assign oPCView = PC;
assign oInstView = IwReadData;
///////////////////////////////////////

wire [31:0] wPC4       	= PC + 32'h00000004;

//Multiplexadores
wire [31:0] wIF_iPC;

always @(*)
begin
	case (iOrigPC)
		2'b00: 	 	wIF_iPC <= wPC4;
		2'b01: 	 	wIF_iPC <= (oZero & iBranch) ? wEX_BranchPC : wPC4;
		2'b10: 	 	wIF_iPC <= wID_BranchPC; 
		default: 	wIF_iPC <= wPC4;
	endcase	
end
///////////////////////////////////////

//A cada ciclo de clock
always @(posedge iClkCPU or posedge iRST)
begin
	if(iRST)
		begin
			PC 		 <= 32'h0040_0000;
			RegIFID  <= {96  {1'b0}};
		end
	else
		begin
			PC <= wIF_iPC;
			RegIFID[31: 0]  <=  PC;
			RegIFID[63:32]  <=  wPC4;
			RegIFID[95:64]  <=  IwReadData;
		end
end
///////////////////////////////////////


//=====================================================================//
//======================== Estagio ID =================================//
//=====================================================================//

wire [31:0] wID_Inst = RegIFID[95:64];

wire [ 4:0] wID_Rs1  = wID_Inst[19:15];
wire [ 4:0] wID_Rs2  = wID_Inst[24:20];
wire [ 4:0] wID_Rd 	 = wID_Inst[11: 7];


	
//Banco de registradores
wire [31:0] wID_Read1, wID_Read2;

BancoReg REGISTRADORES (
	.iCLK(iClkCPU),
	.iRST(iRST),
	.iRegWrite(wWB_RegWrite),
	.iReadReg1(wID_Rs1),
	.iReadReg2(wID_Rs2),
	.iWriteReg(wWB_RdID),
	.iWriteData(wWB_RegWrite),
	.iRegDispSelect(iregin),
	.oReadData1(wID_Read1),
	.oReadData2(wID_Read2),
	.oRegDisp(oregout)
	);
///////////////////////////////////////

//Gerador de imediato
wire [31:0] wID_Immediate;

ImmGen IMMGEN (
	.iInstrucao(IwReadData),
	.oImm(wID_Immediate)
	);
///////////////////////////////////////

always @(posedge iClkCPU or posedge iRST)
begin
	if(iRST)
		RegIDEX <= {177 {1'b0}};
	else
		begin
			RegIDEX[31:   0] 	<= RegIFID[31: 0];  //PC
			RegIDEX[63:  32] 	<= RegIFID[63:32];  //PC+4
			RegIDEX[95:  64] 	<= wID_Read1; 		//Rs1
			RegIDEX[127: 96] 	<= wID_Read2; 		//Rs2
			RegIDEX[132:128] 	<= wID_Rd; 			//Rd
			RegIDEX[164:133] 	<= wID_Immediate; 	//Imm
			RegIDEX[165    ]	<= iBranch; 		//cBranch
			RegIDEX[166    ] 	<= iMemRead; 		//cMemRead
 			RegIDEX[168:167]	<= iMemtoReg; 		//cMemtoReg
			RegIDEX[171:169]	<= iALUControl; 	//cALUControl
		 	RegIDEX[172    ]	<= iMemWrite; 		//cMemWrite
			RegIDEX[173    ]	<= iALUSrc; 		//cALUSrc
			RegIDEX[174    ]	<= iRegWrite; 		//cRegWrite
			RegIDEX[176:175]	<= iOrigPC; 		//cOrigPC
		end
end


//=====================================================================//
//======================== Estagio EX =================================//
//=====================================================================//

wire [31:0] wEX_PC    	   = RegIDEX[31:   0];
wire [31:0] wEX_Imm   	   = RegIDEX[164:133];
wire [31:0] wEX_BranchPC   = wEX_PC + wEX_Imm;
wire [31:0] wEX_Read1 	   = RegIDEX[ 95: 64];
wire [31:0] wEX_Read2 	   = RegIDEX[127: 96];
wire        wEX_ALUSrc 	   = RegIDEX[173    ];
wire [2:0 ] wEX_AluControl = RegIDEX[171:169];

//ALU
wire [31:0] wEX_ALUResult;
wire 		wEX_Zero;

ULA ULA0 (
	.iControl(wEX_AluControl),
	.iA(wEX_Read1),
	.iB(wEX_OrigBULA),
	.oResult(wEX_ALUResult),
	.oZero(wEX_Zero)
	);
///////////////////////////////////////

wire [31:0] wEX_OrigBULA;

always @(*)
begin
	case(ALUSrc)
		1'b0: 	 wEX_OrigBULA <= wEX_Read2;
		1'b1: 	 wEX_OrigBULA <= wEX_Imm; 
		default: wEX_OrigBULA <= wEX_Read2;
	endcase
end

always @(posedge iClkCPU or posedge iRST)
begin
	if(iRST)
		RegEXMEM <= {106 {1'b0}};
	else
		begin
			RegEXMEM[31:0   ] <= wEX_ALUResult; 	//ALUResult 32
			RegEXMEM[63:32  ] <= RegIDEX[63:32  ];  //PC+4 32
			RegEXMEM[95:64  ] <= wEX_Read2; 		//Rs2Result 32
			RegEXMEM[100:96 ] <= RegIDEX[132:128];  //RdID 5
			RegEXMEM[101    ] <= RegIDEX[166    ]; 	//cMemRead
 			RegEXMEM[103:102] <= RegIDEX[168:167]; 	//cMemtoReg
		 	RegEXMEM[104    ] <= RegIDEX[172    ]; 	//cMemWrite
			RegEXMEM[105    ] <= RegIDEX[174    ]; 	//cRegWrite
		end
end

//=====================================================================//
//======================== Estagio MEM ================================//
//=====================================================================//

wire [31:0] wMEM_AluResult = RegEXMEM[31:0];
wire [31:0] wMEM_Rd2Result = RegEXMEM[95:64];
wire 		wMEM_MemRead   = RegEXMEM[101]; 	
wire 		wMEM_MemWrite  = RegEXMEM[104]; 	


//Memoria de dados
wire [31:0] wMEM_DataMemOutput;

ram DATAMEM (
	.address(wMEM_ALUResult[9:0]/4),
	.clock(iClkMem),
	.data(wMEM_Rd2Result),
	.wren(iMemWrite),
	.q(wMEM_DataMemOutput)
	);
///////////////////////////////////////

// A cada ciclo de clock
always @(posedge iClkCPU or posedge iRST)
begin
	if (iRST)
			RegMEMWB <= {100 {1'b0}};
	else
		begin
			RegMEMWB[31:0 ] <= wMEM_AluResult; 
			RegMEMWB[63:32] <= RegEXMEM[63:32  ]; //PC+4
			RegMEMWB[68:64] <= RegEXMEM[100:96 ]; //RdID
			RegMEMWB[66:65] <= RegEXMEM[103:102]; //MemtoReg
			RegMEMWB[67   ] <= RegEXMEM[105    ]; //RegWrite
			RegMEMWB[99:68]	<= wMEM_DataMemOutput;
		end
end
///////////////////////////////////////

//=====================================================================//
//======================== Estagio WB =================================//
//=====================================================================//

wire [31:0] wWB_ReadData  = RegMEMWB[99:68];
wire [31:0] wWB_ALUResult = RegMEMWB[31:0 ];
wire [31:0] wWB_PC4 	  = RegMEMWB[63:32];
wire [31:0] wWB_RdID 	  = RegMEMWB[68:64];
wire [1:0 ] wWB_MemtoReg  = RegMEMWB[66:65];
wire 		wWB_RegWrite  = RegMEMWB[67   ];

//Multiplexadores 
wire[31:0] wWB_RegWrite ;

always @(*)
begin
	case (wWB_MemtoReg)
		2'b00: wWB_RegWrite <= wWB_ALUResult;
		2'b01: wWB_RegWrite <= wWB_ReadData;
		2'b10: wWB_RegWrite <= wWB_PC4;
	endcase
end
///////////////////////////////////////
 
endmodule