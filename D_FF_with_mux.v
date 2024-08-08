module D_FF_with_mux (clk,rst,CEN,D,Q);
    parameter WIDTH = 18;  // default
    parameter RSTTYPE = "SYNC" ;  // default
    parameter REG = 1 ;  // default   (A0REG , B0REG , OPMODEREG,.....)
    input clk,rst,CEN;
    input [WIDTH-1:0] D;
    output reg [WIDTH-1:0] Q;

    // clk ==> clk for the register
    // rst ==> reset the register output to zero
    // EN ==> enable the register
    // CEN ==> Clock enable for the register
    generate 
        if (REG) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge clk or posedge rst) begin
                    if (rst) begin
                        Q <= 0;
                    end
                    else if(CEN) begin
                        Q <= D;
                    end
                end
            end

            else if (RSTTYPE == "SYNC") begin   // sync
            always @(posedge clk) begin
                if (rst) begin
                     Q <= 0;
                end
                else if(CEN) begin
                    Q <= D;
                end
            end
        end
        end

        else begin
            always @(*) begin   // if REG is not activated (A0reg , B0reg ,....)
                if(!REG) begin
                    Q = D;
                end
            end
        end
    endgenerate
    
endmodule