`include "ctrl_encode_def.v"

module NPC(work_EX, work_IF, PC, NPCOp, Reg, IMM, NPC, Zero, Gez, PCPLUS4);  // next pc module
    
    input Zero;  // ALU output: is equal to zero 
    input Gez;   // ALU output: is greater/equal to zero
    input work_EX;  // EX_signal
    input work_IF;  // IF_signal, used to store PC
    input  [31:0] PC;        // pc
    input  [3:0]  NPCOp;     // next pc operation
    input  [25:0] IMM;       // immediate
    input  [31:0] Reg;       // data read from RF, used in jalr and jr
    output [31:0] NPC;   // next pc
    output [31:0] PCPLUS4;  // used to store PC + 4 into %ra
    
    reg [31:0] NPC_r;
    reg [31:0] PC_r;
    reg [31:0] PCPLUS4_r;

    assign NPC = NPC_r; 
    assign PCPLUS4 = PCPLUS4_r;
    
    always @(*) begin
      if (work_IF) begin
        PC_r <= PC;
        PCPLUS4_r <= PC + 4;
      end
      if (work_EX) begin 
        case (NPCOp)
            `NPC_PLUS4:  NPC_r = PCPLUS4_r;
            `NPC_BRANCH_BEQ:    begin
              NPC_r = (Zero) ? PCPLUS4_r + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4_r;
            end
            `NPC_BRANCH_BGEZ:   begin
              NPC_r = (Gez) ? PCPLUS4_r + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4_r;
            end
            `NPC_BRANCH_BGTZ:   begin
              NPC_r = (Gez & ~Zero) ? PCPLUS4_r + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4_r;
            end
            `NPC_BRANCH_BLEZ:   begin
              NPC_r = (Zero | ~Gez) ? PCPLUS4_r + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4_r;
            end
            `NPC_BRANCH_BLTZ:   begin
              NPC_r = (~Gez) ? PCPLUS4_r + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4_r;
            end
            `NPC_BRANCH_BNE:    begin
              NPC_r = (~Zero) ? PCPLUS4_r + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4_r;
            end
            `NPC_JUMP:   NPC_r = {PCPLUS4_r[31:28], IMM[25:0], 2'b00};
            `NPC_JUMPR:  NPC_r = Reg;
            `NPC_NOP:   NPC_r = PC_r;
            default:     NPC_r = PC_r;
        endcase
      end
    end // end always
   
endmodule
