`include "ctrl_encode_def.v"

module state_machine(
    input clk,
    input [5:0] op,
    input [5:0] funct,  // check JALR and JR
    output IF_signal,
    output ID_signal,
    output EX_signal,
    output MEM_signal,
    output WB_signal,
    output IorD_signal,
    output IRWr);

    // reg for output
    reg IF_signal_r;
    reg ID_signal_r;
    reg EX_signal_r;
    reg MEM_signal_r;
    reg WB_signal_r;

    // reg for storing the current state
    reg [3:0] cur_state;

    initial
    begin
        cur_state = `STATE_INI; 
        IF_signal_r = 1'b0;
        ID_signal_r = 1'b0;
        EX_signal_r = 1'b0;
        MEM_signal_r = 1'b0;
        WB_signal_r = 1'b0;
    end 

    assign IF_signal = IF_signal_r;
    assign ID_signal = ID_signal_r;
    assign EX_signal = EX_signal_r;
    assign MEM_signal = MEM_signal_r;
    assign WB_signal = WB_signal_r;
    assign IRWr = (cur_state == `STATE_IF);
    assign IorD_signal = (cur_state == `STATE_MEM_L || cur_state == `STATE_MEM_S);

    always @(posedge clk) begin
        IF_signal_r = 1'b0;
        ID_signal_r = 1'b0;
        EX_signal_r = 1'b0;
        MEM_signal_r = 1'b0;
        WB_signal_r = 1'b0;
        case (cur_state)
            `STATE_INI: begin
                cur_state = `STATE_IF;
                IF_signal_r = 1'b1;
            end
            `STATE_IF: begin
                cur_state = `STATE_ID;
                ID_signal_r = 1'b1;
            end
            `STATE_ID: begin
                EX_signal_r = 1'b1;
                case (op)
                    `R_TYPE: begin
                        case (funct)
                            `JALR: cur_state = `STATE_EX_JUMPA;
                            `JR: cur_state = `STATE_EX_JUMP;
                            default: cur_state = `STATE_EX_RI;
                        endcase
                    end
                    `ADDI, `ADDIU, `ANDI, `LUI, `ORI, `SLTI, `SLTIU, `XORI: cur_state = `STATE_EX_RI;
                    `BEQ, `BGTZ, `BLEZ, `BNE, `BLTZ_BGEZ: cur_state = `STATE_EX_BRANCH;
                    `LB, `LBU, `LH, `LHU, `LW, `SB, `SH, `SW: cur_state = `STATE_EX_LS;
                    `J: cur_state = `STATE_EX_JUMP;
                    `JAL: cur_state = `STATE_EX_JUMPA;
                    default: cur_state = `STATE_INI;
                endcase
            end
            `STATE_EX_LS: begin
                MEM_signal_r = 1'b1;
                case (op)
                    `LB, `LBU, `LH, `LHU, `LW: cur_state = `STATE_MEM_L;
                    `SB, `SH, `SW: cur_state = `STATE_MEM_S;
                    default: cur_state = `STATE_INI;
                endcase
            end
            `STATE_EX_RI: begin
                WB_signal_r = 1'b1;
                cur_state = `STATE_WB;
            end
            `STATE_EX_JUMPA: begin
                WB_signal_r = 1'b1;
                cur_state = `STATE_WB;
            end
            `STATE_MEM_L: begin
                WB_signal_r = 1'b1;
                cur_state = `STATE_WB;
            end
            `STATE_EX_BRANCH, `STATE_EX_JUMP, `STATE_WB, `STATE_MEM_S: begin
                IF_signal_r = 1'b1;
                cur_state = `STATE_IF;
            end
            default: cur_state = `STATE_INI;
        endcase
    end


endmodule