`include "ctrl_encode_def.v"

module NPC(work, PC, NPCOp, Reg, IMM, NPC, Zero, Gez, PCPLUS4);  // next pc module
    
    input Zero;  // ALU output: is equal to zero 
    input Gez;   // ALU output: is greater/equal to zero
    input work;  // EX_signal
    input  [31:0] PC;        // pc
    input  [3:0]  NPCOp;     // next pc operation
    input  [25:0] IMM;       // immediate
    input  [31:0] Reg;       // data read from RF, used in jalr and jr
    output [31:0] NPC;   // next pc
    output [31:0] PCPLUS4;  // used to store PC + 4 into %ra
    
    reg [31:0] NPC_r;

    assign NPC = NPC_r; 
    assign PCPLUS4 = PC + 4; // pc + 4
    
    always @(*) begin
      if (work) begin 
        case (NPCOp)
            `NPC_PLUS4:  NPC_r = PCPLUS4;
            `NPC_BRANCH_BEQ:    begin
              NPC_r = (Zero) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
            end
            `NPC_BRANCH_BGEZ:   begin
              NPC_r = (Gez) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
            end
            `NPC_BRANCH_BGTZ:   begin
              NPC_r = (Gez & ~Zero) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
            end
            `NPC_BRANCH_BLEZ:   begin
              NPC_r = (Zero | ~Gez) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
            end
            `NPC_BRANCH_BLTZ:   begin
              NPC_r = (~Gez) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
            end
            `NPC_BRANCH_BNE:    begin
              NPC_r = (~Zero) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
            end
            `NPC_JUMP:   NPC_r = {PCPLUS4[31:28], IMM[25:0], 2'b00};
            `NPC_JUMPR:  NPC_r = Reg;
            `NPC_NOP:   NPC_r = PC;
            default:     NPC_r = PC;
        endcase
      end
    end // end always
   
endmodule
