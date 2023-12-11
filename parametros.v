parameter
    STACK_ADDRESS = 32'h1001_03FC,
	GLOBAL_POINTER = 32'h1001_0000,

    OP_R = 7'b0110011,
    OP_B = 7'b1100011,
    OP_LOAD = 7'b0000011,
    OP_STORE = 7'b0100011,
    OP_JAL = 7'b1101111,
    OP_R_IMM = 7'b0010011,
        
    FUNCT3_ADD	= 3'b000,
    FUNCT3_SUB	= 3'b000,
    FUNCT3_SLT	= 3'b010,
    FUNCT3_OR	= 3'b110,
    FUNCT3_AND	= 3'b111,
    FUNCT3_ADDI = 3'b001,
    FUNCT3_ANDI = 3'b111,
    FUNCT3_ORI = 3'b100,
    FUNCT3_XORI = 3'b010,
        
    FUNCT7_ADD	= 7'b0000000,
    FUNCT7_SUB = 7'b0100000,

    OP_AND = 3'b000,
    OP_OR = 3'b001,
    OP_ADD = 3'b010,
    OP_SUB = 3'b011,
    OP_SLT = 3'b100,
    OP_XOR = 3'b101;
