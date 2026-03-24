`timescale 1ns / 1ps

module ExceptionUnit(
    input clk, rst,
    input csr_rw_in,
    input[1:0] csr_wsc_mode_in,
    input csr_w_imm_mux,
    input[11:0] csr_rw_addr_in,
    input[31:0] csr_w_data_reg,
    input[4:0] csr_w_data_imm,
    output[31:0] csr_r_data_out,

    input interrupt,
    input illegal_inst,
    input l_access_fault,
    input s_access_fault,
    input ecall_m,

    input mret,

    input[31:0] epc_cur,
    input[31:0] epc_next,
    output[31:0] PC_redirect,
    output redirect_mux,

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel
);

    reg[11:0] csr_raddr, csr_waddr;
    reg[31:0] csr_wdata;
    reg csr_w;
    reg[1:0] csr_wsc;

    wire[31:0] mstatus;

    CSRRegs csr(.clk(clk),.rst(rst),.csr_w(csr_w),.raddr(csr_raddr),.waddr(csr_waddr),
        .wdata(csr_wdata),.rdata(csr_r_data_out),.mstatus(mstatus),.csr_wsc_mode(csr_wsc));

    localparam STATE_IDLE   = 2'b00;
    localparam STATE_MEPC   = 2'b01;
    localparam STATE_MCAUSE = 2'b10;

    reg[1:0] state, next_state;

    reg[31:0] saved_epc;
    reg[31:0] saved_cause;

    wire trap_in = interrupt | illegal_inst | l_access_fault | s_access_fault | ecall_m;

    wire mie = mstatus[3];
    wire mpie = mstatus[7];
    wire[1:0] mpp = mstatus[12:11];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDLE;
            saved_epc <= 32'b0;
            saved_cause <= 32'b0;
        end else begin
            state <= next_state;
            if (state == STATE_IDLE && trap_in) begin
                if (interrupt)
                    saved_epc <= epc_next;
                else
                    saved_epc <= epc_cur;
                if (ecall_m)
                    saved_cause <= 32'd11;
                else if (illegal_inst)
                    saved_cause <= 32'd2;
                else if (l_access_fault)
                    saved_cause <= 32'd5;
                else if (s_access_fault)
                    saved_cause <= 32'd7;
                else if (interrupt)
                    saved_cause <= 32'h80000000;
                else
                    saved_cause <= 32'd0;
            end
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            STATE_IDLE: begin
                if (trap_in)
                    next_state = STATE_MEPC;
                else
                    next_state = STATE_IDLE;
            end
            STATE_MEPC: begin
                next_state = STATE_MCAUSE;
            end
            STATE_MCAUSE: begin
                next_state = STATE_IDLE;
            end
            default: next_state = STATE_IDLE;
        endcase
    end

    always @(*) begin
        csr_w = 1'b0;
        csr_waddr = 12'b0;
        csr_wdata = 32'b0;
        csr_wsc = 2'b00;
        csr_raddr = 12'b0;
        case (state)
            STATE_IDLE: begin
                if (trap_in) begin
                    csr_w = 1'b1;
                    csr_waddr = 12'h300;
                    csr_wdata = {mstatus[31:13], 2'b11, mstatus[10:8], mie, mstatus[6:4], 1'b0, mstatus[2:0]};
                    csr_wsc = 2'b01;
                    csr_raddr = 12'h305;
                end else if (mret) begin
                    csr_w = 1'b1;
                    csr_waddr = 12'h300;
                    csr_wdata = {mstatus[31:13], mpp, mstatus[10:8], 1'b1, mstatus[6:4], mpie, mstatus[2:0]};
                    csr_wsc = 2'b01;
                    csr_raddr = 12'h341;
                end else if (csr_rw_in) begin
                    csr_w = 1'b1;
                    csr_waddr = csr_rw_addr_in;
                    csr_raddr = csr_rw_addr_in;
                    if (csr_w_imm_mux)
                        csr_wdata = {27'b0, csr_w_data_imm};
                    else
                        csr_wdata = csr_w_data_reg;
                    csr_wsc = {1'b0, csr_wsc_mode_in};
                end
            end
            STATE_MEPC: begin
                csr_w = 1'b1;
                csr_waddr = 12'h341;
                csr_wdata = saved_epc;
                csr_wsc = 2'b01;
                csr_raddr = 12'h305;
            end
            STATE_MCAUSE: begin
                csr_w = 1'b1;
                csr_waddr = 12'h342;
                csr_wdata = saved_cause;
                csr_wsc = 2'b01;
                csr_raddr = 12'h342;
            end
            default: begin
            end
        endcase
    end

    assign PC_redirect = csr_r_data_out;

    assign redirect_mux = (state == STATE_IDLE && mret) || (state == STATE_MEPC);

    assign reg_FD_flush = (state == STATE_IDLE && trap_in) ||
                          (state == STATE_IDLE && mret) ||
                          (state == STATE_MEPC);

    assign reg_DE_flush = (state == STATE_IDLE && trap_in) ||
                          (state == STATE_IDLE && mret);

    assign reg_EM_flush = (state == STATE_IDLE && trap_in) ||
                          (state == STATE_IDLE && mret);

    assign reg_MW_flush = (state == STATE_IDLE && trap_in);

    assign RegWrite_cancel = (state == STATE_IDLE && trap_in && !interrupt);

endmodule