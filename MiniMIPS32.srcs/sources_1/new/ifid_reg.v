`include "defines.v"

module ifid_reg (
	input  wire 						cpu_clk_50M,
	input  wire 						cpu_rst_n,
    
    input   wire                       flush, //��ˮ������ź�
    //�յ�����ͣ�ź�
    input wire [`STALL_BUS ]           stall,
    
	// ����ȡָ�׶ε���Ϣ  
	input  wire [`INST_ADDR_BUS]       if_pc,
	
	// ��������׶ε���Ϣ  
	output reg  [`INST_ADDR_BUS]       id_pc,
	
	//ת��ָ��
	input  wire [`INST_ADDR_BUS]       if_pc_plus_4,
	output reg  [`INST_ADDR_BUS]       id_pc_plus_4,
	
	//�쳣����
    input wire [`EXC_CODE_BUS]     if_exccode,
    output reg [`EXC_CODE_BUS]     id_exccode
	);

	always @(posedge cpu_clk_50M) begin
	    // ��λ��ʱ����������׶ε���Ϣ��0
		if (cpu_rst_n == `RST_ENABLE || flush) begin
			id_pc 	<= `PC_INIT;
			id_pc_plus_4 <= `ZERO_WORD;
			id_exccode  <= `EXC_NONE;
		end
		else if(stall[1]==`STOP && stall[2]==`NOSTOP) begin
            id_pc    <= `ZERO_WORD;        
            id_pc_plus_4 <= `ZERO_WORD;
            id_exccode  <= `EXC_NONE;
        end		
		// ������ȡָ�׶ε���Ϣ�Ĵ沢��������׶�
		else if(stall[1]==`NOSTOP) begin
			id_pc	<= if_pc;		
			id_pc_plus_4 <= if_pc_plus_4;
			id_exccode  <= if_exccode;
		end
	end

endmodule