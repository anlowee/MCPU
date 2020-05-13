`include "ctrl_encode_def.v"

module mcpu(
    input clk,
    input rst);

    // PC
    wire [31:0] pc;
    wire [31:0] npc;
    wire [31:0] pcplus4;
    
    // Memory
    wire [31:0] InstructionOut;
    wire [31:0] DataOut;

    // IR_MDR
    wire [31:0] Instruction;
    wire [31:0] DMDataOut;

    // ctrl_unit
    wire [1:0] RegDst;
    wire [1:0] ToReg;
    wire [1:0] ALUSrc;
    wire ALUSrc0;
    wire RFWr;
    wire EXTOp;
    wire [3:0] NPCOp;
    wire [4:0] ALUOp;
    wire [1:0] DMWr;
    wire [2:0] DMRe;

    // RF
    wire [31:0] RFDataOut1;
    wire [31:0] RFDataOut2;
    
    //ALU
    wire [31:0] ALUResult;
    wire [31:0] num1;
    wire [31:0] num2;
    wire Zero;
    wire Gez;
    wire Overflow;

    // EXT
    wire [31:0] EXTOut;
    wire [31:0] EXTShamtOut;

    // mux
    wire [4:0] A3;  // write reg
    wire [31:0] A;  // alu num1
    wire [31:0] B;  // alu num2
    wire [31:0] RFWD; // RF' WD
    wire [31:0] addr;  // IorDMux

    // state_machine
    wire IF_signal;
    wire ID_signal;
    wire EX_signal;
    wire MEM_signal;
    wire WB_signal;
    wire IorD_signal;
    wire IRWr;


    // instants of each module
    PC PC(
        .clk(clk),
        .rst(rst),
        .NPC(npc),

        .PC(pc)
    );

    IorDMux IorDMux(
        .PC(pc),
        .DataAddr(ALUResult),
        .IorD(IorD_signal),

        .Addr(addr)
    );

    memory memory(
        .clk(clk),
        .Addr(addr),
        .work(MEM_signal),
        .DMWr(DMWr),
        .DMRe(DMRe),
        .DataIn(RFDataOut2),

        .DataOut(DataOut),
        .Instruction(InstructionOut)
    );
    
    state_machine state_machine(
        .clk(clk),
        .op(Instruction[31:26]),
        .funct(Instruction[5:0]),
        
        .IF_signal(IF_signal),
        .ID_signal(ID_signal),
        .EX_signal(EX_signal),
        .MEM_signal(MEM_signal),
        .WB_signal(WB_signal),
        .IorD_signal(IorD_signal),
        .IRWr(IRWr)
    );

    IR_MDR IR_MDR(
        .clk(clk),
        .IRWr(IRWr),
        .InsIn(InstructionOut),
        .DataIn(DataOut),
        
        .InsOut(Instruction),
        .DataOut(DMDataOut)
    );

    ctrl_unit ctrl_unit(
        .op(Instruction[31:26]),
        .funct(Instruction[5:0]),
        .bgez_bltz(Instruction[20:16]),

        .RegDst(RegDst),
        .ToReg(ToReg),
        .ALUSrc(ALUSrc),
        .ALUSrc0(ALUSrc0),
        .RFWr(RFWr),
        .NPCOp(NPCOp),
        .ALUOp(ALUOp),
        .DMWr(DMWr),
        .DMRe(DMRe),
        .EXTOp(EXTOp)
    );

    RegDstMux RegDstMux(
        .rt(Instruction[20:16]),
        .rd(Instruction[15:11]),
        .RegDst(RegDst),

        .A3(A3)
    );

    RF RF(
        .clk(clk),
        .rst(rst),
        .work(ID_signal),
        .RFWr(RFWr),
        .A1(Instruction[25:21]),
        .A2(Instruction[20:16]),
        .A3(A3),
        .WD(RFWD),

        .RD1(RFDataOut1),
        .RD2(RFDataOut2)
    );

    EXT EXTImm(
        .Imm16(Instruction[15:0]),
        .EXTOp(EXTOp),

        .Imm32(EXTOut)
    );

    EXT_Shamt EXTSha(
        .Imm5(Instruction[10:6]),
        .EXTOp(EXTOp),
        
        .Imm32(EXTShamtOut)
    );

    ALUSrcMux0 ALUSrcMux0(
        .RD1(RFDataOut1),
        .RD2(RFDataOut2),
        .ALUSrc0(ALUSrc0),

        .A(A)
    );

    ALUSrcMux ALUSrcMux(
        .RD2(RFDataOut2),
        .Imm32(EXTOut),
        .ShamtImm32(EXTShamtOut),
        .ALUSrc(ALUSrc),

        .B(B)
    );

    alu alu(
        .A(A),
        .B(B),
        .ALUOp(ALUOp),
        .work(EX_signal),

        .C(ALUResult),
        .Zero(Zero),
        .Overflow(Overflow),
        .Gez(Gez)
    );

    NPC NPC(
        .Zero(Zero),
        .Gez(Gez),
        .PC(pc),
        .NPCOp(NPCOp),
        .IMM(Instruction[25:0]),
        .Reg(RFDataOut1),
        .work(EX_signal),

        .NPC(npc),
        .PCPLUS4(pcplus4)
    );

    ToRegMux ToRegMux(
        .DataOut(DMDataOut),
        .PCPLUS4(pcplus4),
        .ALUResult(ALUResult),
        .ToReg(ToReg),

        .RFWD(RFWD)
    );



endmodule