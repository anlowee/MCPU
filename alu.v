`include "ctrl_encode_def.v"

module alu(A, B, ALUOp, C, work, Zero, Overflow, Gez);
   
   input work;  // EX_signal
   input  signed [31:0] A, B;
   input         [4:0]  ALUOp;
   output signed [31:0] C;
   output Overflow;
   output Gez;
   output Zero;
   
   reg [31:0] C_r;
   reg Overflow_r;
   reg [32:0] temp;
   integer    i;
       
   always @( * ) begin
      if (work) begin
         case ( ALUOp )
            `ALU_NOP:  C_r = A;  // NOP
            `ALU_ADD: begin
               temp = {1'b0, A} + {1'b0, B};
               C_r = A + B;  // ADD/ADDI
               Overflow_r = temp[32] ^ A[31] ^ B[31] ^ C[31]; 
            end
            `ALU_ADDU: C_r = A + B;  // ADDU/ADDIU
            `ALU_SUB: begin
               temp = {1'b0, A} - {1'b0, B};
               C_r = A - B;  // SUB/SUBI
               Overflow_r = temp[32] ^ A[31] ^ B[31] ^ C[31];
            end 
            `ALU_NOR:  C_r = ~(A | B);  // NOR
            `ALU_SLL:  C_r = A << B;  // SLL
            `ALU_SLLV: C_r = B << {27'b0, A[4:0]};  // SLLV
            `ALU_SRA:  C_r = ($signed(A)) >>> B;  // SRA
            `ALU_SRAV: C_r = ($signed(B)) >>> {27'b0, A[4:0]};  // SRAV
            `ALU_SRL:  C_r = A >> B;  // SRL
            `ALU_SRLV: C_r = B >> {27'b0, A[4:0]};  // SRLV
            `ALU_XOR:  C_r = A ^ B;  // XOR 
            `ALU_SUBU: C_r = A - B;  // SUBU
            `ALU_AND:  C_r = A & B;  // AND/ANDI
            `ALU_OR:   C_r = A | B;  // OR/ORI
            `ALU_LUI:  C_r = {B[15:0], 16'b0000_0000_0000_0000};  // LUI
            `ALU_SLT:  C_r = (A < B) ? 32'd1 : 32'd0;  // SLT/SLTI
            `ALU_SLTU: C_r = ({1'b0, A} < {1'b0, B}) ? 32'd1 : 32'd0;  // SLTU
            default:   C_r = A;  // Undefined
         endcase
      end
   end // end always
   
   assign Zero = (C == 32'b0);
   assign Gez = (~C[31]);
   assign C = C_r;
   assign Overflow = Overflow_r;

endmodule
    
