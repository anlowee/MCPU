`include "ctrl_encode_def.v"

module ctrl_unit(  // p176
    output [1:0] RegDst,
    output [1:0] ToReg,  // What write into Reg
    output [1:0] ALUSrc,
    output RFWr,
    output [3:0] NPCOp,
    output EXTOp,
    output ALUSrc0,  // select for A
    input  [5:0] op,    //31:26
    input  [5:0] funct,  // 5:0
    input  [4:0] bgez_bltz,  // 20:16
    output [4:0] ALUOp,
    output [1:0] DMWr,
    output [2:0] DMRe);

    // reg for control signal
    reg [1:0] RegDst_r;
    reg [1:0] ToReg_r;  // What write into Reg
    reg [1:0] ALUSrc_r;
    reg RFWr_r;
    reg [3:0] NPCOp_r;
    reg EXTOp_r;
    reg ALUSrc0_r;
    reg [4:0] ALUOp_r;
    reg [1:0] DMWr_r;
    reg [2:0] DMRe_r;
    
    assign RegDst = RegDst_r;
    assign ToReg = ToReg_r;
    assign ALUSrc = ALUSrc_r;
    assign RFWr = RFWr_r;
    assign NPCOp = NPCOp_r;
    assign EXTOp = EXTOp_r;
    assign ALUSrc0 = ALUSrc0_r;
    assign ALUOp = ALUOp_r;
    assign DMWr = DMWr_r;
    assign DMRe = DMRe_r;

    always @(*) begin
        NPCOp_r = `NPC_PLUS4;  
        RegDst_r = `RD_RT;  // x
        ALUSrc_r = `ALUSRC_ZERO;  // x
        ToReg_r = `DM2REG;  // x
        RFWr_r = 1'b0;  
        DMRe_r = `DMRE_NOP; 
        DMWr_r = `DMWR_NOP; 
        ALUOp_r = `ALU_NOP; 
        ALUSrc0_r = 1'b0;
        EXTOp_r = 1'b1;
        case (op)
            `R_TYPE:  begin
                // R-type
                NPCOp_r = `NPC_PLUS4;
                RegDst_r = `RD_RD;  // write into rd
                ToReg_r = `ALU2REG;
                RFWr_r = 1'b1;
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                
                // ALU control unit
                case (funct)
                    `ADD:   begin   
                        ALUOp_r = `ALU_ADD;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `ADDU:  begin 
                        ALUOp_r = `ALU_ADDU;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `AND:   begin 
                        ALUOp_r = `ALU_AND;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `NOR:   begin 
                        ALUOp_r = `ALU_NOR;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `OR:    begin 
                        ALUOp_r = `ALU_OR;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `SLL:   begin 
                        ALUOp_r = `ALU_SLL;
                        ALUSrc_r = `ALUSRC_SHA;
                        ALUSrc0_r = 1'b1;
                        EXTOp_r = 1'b0;
                    end
                    `SLLV:  begin 
                        ALUOp_r = `ALU_SLLV;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `SLT:   begin 
                        ALUOp_r = `ALU_SLT;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `SLTU:  begin 
                        ALUOp_r = `ALU_SLTU;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `SRA:   begin 
                        ALUOp_r = `ALU_SRA;
                        ALUSrc_r = `ALUSRC_SHA;
                        ALUSrc0_r = 1'b1;
                        EXTOp_r = 1'b0;
                    end
                    `SRAV:  begin 
                        ALUOp_r = `ALU_SRAV;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `SRL:   begin 
                        ALUOp_r = `ALU_SRL;
                        ALUSrc_r = `ALUSRC_SHA;
                        ALUSrc0_r = 1'b1;
                        EXTOp_r = 1'b0;
                    end
                    `SRLV:  begin 
                        ALUOp_r = `ALU_SRLV;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `SUB:   begin 
                        ALUOp_r = `ALU_SUB;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `SUBU:  begin 
                        ALUOp_r = `ALU_SUBU;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `XOR:   begin 
                        ALUOp_r = `ALU_XOR;
                        ALUSrc_r = `ALUSRC_REG;
                    end
                    `JALR:  begin
                        NPCOp_r = `NPC_JUMPR; 
                        RegDst_r = `RD_RA;  // if JALR then write into rd
                        ALUSrc_r = `ALUSRC_ZERO; // x
                        ToReg_r = `NPC2REG;  // Next PC write into rd
                        RFWr_r = 1'b1; 
                        DMRe_r = `DMRE_NOP; 
                        DMWr_r = `DMWR_NOP; 
                        ALUOp_r = `ALU_NOP;
                    end
                    `JR:    begin
                        NPCOp_r = `NPC_JUMPR; 
                        RegDst_r = `RD_RA;  // if JALR then write into rd
                        ALUSrc_r = `ALUSRC_ZERO; // x
                        ToReg_r = `NPC2REG;  // Next PC write into rd
                        RFWr_r = 1'b0;  
                        DMRe_r = `DMRE_NOP; 
                        DMWr_r = `DMWR_NOP; 
                        ALUOp_r = `ALU_NOP;
                    end
                endcase
            end
            `ADDI:  begin
                // ADDI
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // imm
                ToReg_r = `ALU2REG;  
                RFWr_r = 1'b1;
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b1;
                ALUOp_r = `ALU_ADD;
            end
            `ADDIU:  begin
                // ADDIU
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM; // imm
                ToReg_r = `ALU2REG; 
                RFWr_r = 1'b1;
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b0;
                ALUOp_r = `ALU_ADDU;
            end
            `ANDI:  begin
                // ANDI
                NPCOp_r = `NPC_PLUS4;
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // imm
                ToReg_r = `ALU2REG; 
                RFWr_r = 1'b1;
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b0;
                ALUOp_r = `ALU_AND;
            end
            `LUI:  begin
                // LUI
                NPCOp_r = `NPC_PLUS4;  
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // imm
                ToReg_r = `ALU2REG;  
                RFWr_r = 1'b1;
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b0;
                ALUOp_r = `ALU_LUI;
            end
            `ORI:  begin
                // ORI
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // imm
                ToReg_r = `ALU2REG;  
                RFWr_r = 1'b1;
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b0;
                ALUOp_r = `ALU_OR;
            end
            `SLTI:  begin
                // SLTI
                NPCOp_r = `NPC_PLUS4;  
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // imm
                ToReg_r = `ALU2REG;  
                RFWr_r = 1'b1;
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b1;
                ALUOp_r = `ALU_SLT;
            end
            `SLTIU:  begin
                // SLTIU
                NPCOp_r = `NPC_PLUS4;  
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM; // imm
                ToReg_r = `ALU2REG;  
                RFWr_r = 1'b1;
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b0;
                ALUOp_r = `ALU_SLTU;
            end
            `XORI:  begin
                // XORI
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM; // imm
                ToReg_r = `ALU2REG; 
                RFWr_r = 1'b1;
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b0;
                ALUOp_r = `ALU_XOR;
            end
            `BEQ:  begin
                // BEQ
                NPCOp_r = `NPC_BRANCH_BEQ; 
                RegDst_r = `RD_RT; // x
                ALUSrc_r = `ALUSRC_REG;  // ALU do sub operation
                ToReg_r = `ALU2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b1;
                ALUOp_r = `ALU_SUB;
            end
            `BGTZ:  begin
                // BGTZ
                NPCOp_r = `NPC_BRANCH_BGTZ; 
                RegDst_r = `RD_RT;  // x
                ALUSrc_r = `ALUSRC_ZERO;  // zero
                ToReg_r = `ALU2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP;
                EXTOp_r = 1'b1; 
                ALUOp_r = `ALU_SUB;
            end
            `BLEZ:  begin
                // BLEZ
                NPCOp_r = `NPC_BRANCH_BLEZ;  
                RegDst_r = `RD_RT;  // x
                ALUSrc_r = `ALUSRC_ZERO;  // zero
                ToReg_r = `ALU2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b1;
                ALUOp_r = `ALU_SUB;
            end
            `BNE:  begin
                // BNE
                NPCOp_r = `NPC_BRANCH_BNE; 
                RegDst_r = `RD_RT;  // x
                ALUSrc_r = `ALUSRC_REG;  // reg
                ToReg_r = `ALU2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b1;
                ALUOp_r = `ALU_SUB;
            end
            `BLTZ_BGEZ:  begin
                // BLTZ and BGEZ
                RegDst_r = `RD_RT;  // x
                ALUSrc_r = `ALUSRC_ZERO;  // zero
                ToReg_r = `ALU2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                EXTOp_r = 1'b1;
                ALUOp_r = `ALU_SUB;
                if (bgez_bltz == 5'b00000) begin
                    NPCOp_r = `NPC_BRANCH_BLTZ; 
                end else begin
                    NPCOp_r = `NPC_BRANCH_BGEZ; 
                end
            end
            `J:  begin
                // J
                NPCOp_r = `NPC_JUMP; 
                RegDst_r = `RD_RT;  // x
                ALUSrc_r = `ALUSRC_ZERO;  // x
                ToReg_r = `ALU2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                ALUOp_r = `ALU_NOP;
            end
            `JAL:  begin
                // JAL
                NPCOp_r = `NPC_JUMP; 
                RegDst_r = `RD_RA;  // write into %ra
                ALUSrc_r = `ALUSRC_ZERO;  // x
                ToReg_r = `NPC2REG;  // Next PC write into %ra
                RFWr_r = 1'b1;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                ALUOp_r = `ALU_NOP;
            end
            `LB:  begin
                // LB
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // offset
                ToReg_r = `DM2REG;  // load data from DM into reg
                RFWr_r = 1'b1;  
                DMRe_r = `DMRE_LB; 
                DMWr_r = `DMWR_NOP; 
                ALUOp_r = `ALU_ADD;  // caculate address
            end
            `LBU:  begin
                // LBU
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // offset
                ToReg_r = `DM2REG;  // load data from DM into reg
                RFWr_r = 1'b1;  
                DMRe_r = `DMRE_LBU; 
                DMWr_r = `DMWR_NOP; 
                ALUOp_r = `ALU_ADD;  // caculate address
            end
            `LH:  begin
                // LH
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // offset
                ToReg_r = `DM2REG;  // load data from DM into reg
                RFWr_r = 1'b1;  
                DMRe_r = `DMRE_LH; 
                DMWr_r = `DMWR_NOP; 
                ALUOp_r = `ALU_ADD;  // caculate address
            end
            `LHU:  begin
                // LHU
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // offset
                ToReg_r = `DM2REG;  // load data from DM into reg
                RFWr_r = 1'b1;  
                DMRe_r = `DMRE_LHU; 
                DMWr_r = `DMWR_NOP; 
                ALUOp_r = `ALU_ADD;  // caculate address
            end
            `LW:  begin
                // LW
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // write into rt
                ALUSrc_r = `ALUSRC_IMM;  // offset
                ToReg_r = `DM2REG;  // load data from DM into reg
                RFWr_r = 1'b1;  
                DMRe_r = `DMRE_LW; 
                DMWr_r = `DMWR_NOP; 
                ALUOp_r = `ALU_ADD;  // caculate address
            end
            `SB:  begin
                // SB
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // x
                ALUSrc_r = `ALUSRC_IMM;  // offset
                ToReg_r = `DM2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_SB; 
                ALUOp_r = `ALU_ADD;  // caculate address
            end
            `SH:  begin
                // SH
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // x
                ALUSrc_r = `ALUSRC_IMM;  // offset
                ToReg_r = `DM2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_SH; 
                ALUOp_r = `ALU_ADD;  // caculate address
            end
            `SW:  begin
                // SW
                NPCOp_r = `NPC_PLUS4; 
                RegDst_r = `RD_RT;  // x
                ALUSrc_r = `ALUSRC_IMM;  // offset
                ToReg_r = `DM2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_SW; 
                ALUOp_r = `ALU_ADD;  // caculate address
            end
            default:    begin
                // NOP
                $display("over");
                NPCOp_r = `NPC_NOP;  
                RegDst_r = `RD_RT;  // x
                ALUSrc_r = `ALUSRC_ZERO;  // x
                ToReg_r = `DM2REG;  // x
                RFWr_r = 1'b0;  
                DMRe_r = `DMRE_NOP; 
                DMWr_r = `DMWR_NOP; 
                ALUOp_r = `ALU_NOP; 
                ALUSrc0_r = 1'b0;
            end
        endcase
    end

endmodule