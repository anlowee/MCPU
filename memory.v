`include "ctrl_encode_def.v"

module memory(
    input clk,
    input work,  // MEM signal
    input [1:0] DMWr,
    input [2:0] DMRe,
    input [9:0] Addr,  // PC or Data address
    input [31:0] DataIn,
    output [31:0] DataOut,
    output [31:0] Instruction
);

    // reg for output
    reg [31:0] DataOut_r;

    // reg for Data Memory(size = 1024B)
    reg [7:0] DataMem[1023:0];

    // reg for Instruction Memory(size = 1024B)
    reg [7:0] InstrctionMem[1023:0];
    reg [31:0] InstrctionMemReadTemp[253:0];
    reg [31:0] curIns;

    // load instruction
    integer i, addr;
    initial begin
        addr = 32'b0;
        $readmemh("D:\\GitHub\\MCPU\\test.dat", InstrctionMemReadTemp);
        for (i = 0; i < 254; i = i + 1) begin
            curIns = InstrctionMemReadTemp[i];
            InstrctionMem[addr] = curIns[31:24];
            InstrctionMem[addr + 1] = curIns[23:16];
            InstrctionMem[addr + 2] = curIns[15:8];
            InstrctionMem[addr + 3] = curIns[7:0];
            addr = addr + 4;
        end
    end

    // IM
    assign Instruction = {InstrctionMem[Addr], InstrctionMem[Addr + 1], InstrctionMem[Addr + 2], InstrctionMem[Addr + 3]};

    // DM
    always @(posedge clk) begin
        if (work == 1'b1) begin
            case (DMWr)
                `DMWR_SW:   begin
                    DataMem[Addr] <= DataIn[7:0];
                    DataMem[Addr + 1] <= DataIn[15:8];
                    DataMem[Addr + 2] <= DataIn[23:16];
                    DataMem[Addr + 3] <= DataIn[31:24];
                end
                `DMWR_SH:   begin
                    DataMem[Addr] <= DataIn[7:0];
                    DataMem[Addr + 1] <= DataIn[15:8];
                end
                `DMWR_SB:   begin
                    DataMem[Addr] <= DataIn[7:0];
                end
                `DMWR_NOP:  begin
                    DataMem[Addr] <= DataMem[Addr];
                end
                default:    begin
                    DataMem[Addr] <= DataMem[Addr];
                end
            endcase
        end
   end

    always @(DMRe, Addr) begin
        if (work == 1'b1) begin
            case (DMRe) 
                `DMRE_LW:   begin
                    DataOut_r <= {DataMem[Addr + 3], DataMem[Addr + 2], DataMem[Addr + 1], DataMem[Addr]};
                end
                `DMRE_LH:   begin
                    DataOut_r <= {{16{DataMem[Addr + 1][7]}}, DataMem[Addr + 1], DataMem[Addr]};
                end
                `DMRE_LHU:  begin
                    DataOut_r <= {16'b0, DataMem[Addr + 1], DataMem[Addr]};
                end
                `DMRE_LB:   begin
                    DataOut_r <= {{24{DataMem[Addr][7]}}, DataMem[Addr]};
                end
                `DMRE_LBU:  begin
                    DataOut_r <= {24'b0, DataMem[Addr]};
                end
                `DMRE_NOP:  begin
                    DataOut_r <= 32'b0;
                end
                default:    begin
                    DataOut_r <= 32'b0;
                end
            endcase
        end
    end

    assign DataOut = DataOut_r;

endmodule