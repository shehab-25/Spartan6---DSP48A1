module DSP #(
    parameter A0REG = 0,   // no register
    parameter A1REG = 1,   // registered
    parameter B0REG = 0,   // no register
    parameter B1REG = 1,   // registered
    parameter CREG = 1,   // registered
    parameter DREG = 1,    // registered
    parameter MREG = 1,    // registered
    parameter PREG = 1,    // registered
    parameter CARRYINREG = 1,  // registered
    parameter CARRYOUTREG = 1, // registered
    parameter OPMODEREG = 1,   // registered
    parameter CARRYINSEL = "OPMODE5",   // to select between carryin input or opmode[5] 
    parameter B_INPUT = "DIRECT",       // sel between B or BCIN to be the output on the mux after the final B port.
    parameter RSTTYPE = "SYNC" 
) (
    input CLK,
    input [7:0] OPMODE,
    input CEA , CEB , CEC , CECARRYIN , CED , CEM , CEP , CEOPMODE,          // clock enable signals
    input RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTP , RSTOPMODE,  // reset signals
    input [17:0] A , B , D,
    input [47:0] C,
    input [47:0] PCIN,
    input CARRYIN,
    input [17:0] BCIN,
    output [35:0] M,
    output [47:0] P , PCOUT,
    output  CARRYOUT , CARRYOUTF,
    output [17:0] BCOUT
);

    wire [7:0] OPMODE_reg_out;
    wire [17:0] B0_reg_out , B1_reg_out , A0_reg_out , A1_reg_out , D_reg_out;
    wire CIN;
    wire [47:0] C_reg_out , D_A_B_concat;
    reg [17:0] B0;
    reg [17:0] pre_adder_out , MUX_TO_B1REG;
    reg [35:0] multiplier_out;
    reg carry_cascade_out , cout_post_adder;
    reg [47:0] out_x , out_z;
    reg [47:0] post_adder_out;


    //direct or casecade input on port B 
    always @(*) begin
        if(B_INPUT == "DIRECT") begin
            B0 = B;
        end
        else if(B_INPUT == "CASCADE") begin
            B0 = BCIN;
        end
        else begin
            B0 = 0;
        end
    end

    D_FF_with_mux #(8,RSTTYPE,OPMODEREG) OPMODE_reg(CLK,RSTOPMODE,CEOPMODE,OPMODE,OPMODE_reg_out);
    D_FF_with_mux #(18,RSTTYPE,A0REG) A0_reg(CLK,RSTA,CEA,A,A0_reg_out);
    D_FF_with_mux #(18,RSTTYPE,B0REG) B0_reg(CLK,RSTB,CEB,B0,B0_reg_out);
    D_FF_with_mux #(48,RSTTYPE,CREG) C_reg(CLK,RSTC,CEC,C,C_reg_out);
    D_FF_with_mux #(18,RSTTYPE,DREG) D_reg(CLK,RSTD,CED,D,D_reg_out);

    // pre adder/subtractor
    always @(*) begin
        case (OPMODE_reg_out[6])
            0: pre_adder_out = B0_reg_out + D_reg_out;
            1: pre_adder_out = D_reg_out - B0_reg_out;
        endcase
    end

    // MUX after pre adder/subtractor
    always @(*) begin
        case (OPMODE_reg_out[4])
            0: MUX_TO_B1REG = B0_reg_out;
            1: MUX_TO_B1REG = pre_adder_out;
        endcase
    end

    D_FF_with_mux #(18,RSTTYPE,B1REG) B1_reg(CLK,RSTB,CEB,MUX_TO_B1REG,B1_reg_out);
    D_FF_with_mux #(18,RSTTYPE,A1REG) A1_reg(CLK,RSTA,CEA,A0_reg_out,A1_reg_out);

    // Multiplier
    always @(*) begin
        multiplier_out = B1_reg_out * A1_reg_out;
    end

    D_FF_with_mux #(36,RSTTYPE,MREG) M_reg(CLK,RSTM,CEM,multiplier_out,M);

    // MUX carry cascade ==> to select between carryin input or opmode[5] 
    always @(*) begin
        if (CARRYINSEL == "OPMODE5") begin
            carry_cascade_out = OPMODE_reg_out[5];
        end
        else if (CARRYINSEL == "CARRYIN") begin
            carry_cascade_out = CARRYIN;
        end
        else begin
            carry_cascade_out = 'b0;
        end
    end

    D_FF_with_mux #(1,RSTTYPE,CARRYINREG) CYI_reg(CLK,RSTCARRYIN,CECARRYIN,carry_cascade_out,CIN);

    assign D_A_B_concat = {D_reg_out[11:0] , A0_reg_out[17:0] , B0_reg_out[17:0]};

    // MUX X
    always @(*) begin
        case (OPMODE_reg_out[1:0])
            2'b00: out_x = 48'b0;
            2'b01: out_x = M;
            2'b10: out_x = P;
            2'b11: out_x = D_A_B_concat;
        endcase
    end

    // MUX Z
    always @(*) begin
        case (OPMODE_reg_out[3:2])
            2'b00: out_z = 48'b0;
            2'b01: out_z = PCIN;
            2'b10: out_z = P;
            2'b11: out_z = C_reg_out; 
        endcase
    end

    // post adder/subtractor
    always @(*) begin
        case (OPMODE_reg_out[7])
            0: {cout_post_adder,post_adder_out} = out_x + out_z + CIN;
            1: {cout_post_adder,post_adder_out} = out_z - (out_x + CIN);
        endcase
    end

     D_FF_with_mux #(1,RSTTYPE,CARRYOUTREG) CYO_reg(CLK,RSTCARRYIN,CECARRYIN,cout_post_adder,CARRYOUT);
     D_FF_with_mux #(48,RSTTYPE,PREG) P_reg(CLK,RSTP,CEP,post_adder_out,P);
     assign PCOUT = P;
     assign CARRYOUTF = CARRYOUT;
     assign BCOUT = B1_reg_out;

    
endmodule