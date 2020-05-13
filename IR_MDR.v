module IR_MDR(
    input clk,
    input IRWr,
    input [31:0] InsIn,
    input [31:0] DataIn,
    output [31:0] InsOut,
    output [31:0] DataOut);

    reg [31:0] Ins, Data;

    assign InsOut = Ins;
    assign DataOut = DataIn;

    always @(posedge clk) begin
        if (IRWr)
            Ins <= InsIn;
    end

endmodule