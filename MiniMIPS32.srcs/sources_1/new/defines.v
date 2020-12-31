`timescale 1ns / 1ps

/*------------------- ȫ�ֲ��� -------------------*/
`define RST_ENABLE      1'b0                // ��λ�ź���Ч  RST_ENABLE
`define RST_DISABLE     1'b1                // ��λ�ź���Ч
`define ZERO_WORD       32'h00000000        // 32λ����ֵ0
`define ZERO_DWORD      64'b0               // 64λ����ֵ0
`define WRITE_ENABLE    1'b1                // ʹ��д
`define WRITE_DISABLE   1'b0                // ��ֹд
`define READ_ENABLE     1'b1                // ʹ�ܶ�
`define READ_DISABLE    1'b0                // ��ֹ��
`define ALUOP_BUS       7 : 0               // ����׶ε����aluop_o�Ŀ���
`define SHIFT_ENABLE    1'b1                // ��λָ��ʹ�� 
`define ALUTYPE_BUS     2 : 0               // ����׶ε����alutype_o�Ŀ���  
`define TRUE_V          1'b1                // �߼�"��"  
`define FALSE_V         1'b0                // �߼�"��"  
`define CHIP_ENABLE     1'b1                // оƬʹ��  
`define CHIP_DISABLE    1'b0                // оƬ��ֹ  
`define WORD_BUS        31: 0               // 32λ��
`define DOUBLE_REG_BUS  63: 0               // ������ͨ�üĴ����������߿���
`define RT_ENABLE       1'b1                // rtѡ��ʹ��
`define SIGNED_EXT      1'b1                // ������չʹ��
`define IMM_ENABLE      1'b1                // ������ѡ��ʹ��
`define UPPER_ENABLE    1'b1                // ��������λʹ��
`define MREG_ENABLE     1'b1                // д�ؽ׶δ洢�����ѡ���ź�
`define BSEL_BUS        3 : 0               // ���ݴ洢���ֽ�ѡ���źſ���
`define PC_INIT         32'h00000000        // PC��ʼֵ
`define JUMP_BUS        25:0                //J��ָ������instr_index�ֶεĳ���
`define JTSEL_BUS       1:0                 //ת�Ƶ�ַѡ���źŵĿ���

/*------------------- ָ���ֲ��� -------------------*/
`define INST_ADDR_BUS   31: 0               // ָ��ĵ�ַ����
`define INST_BUS        31: 0               // ָ������ݿ���

// ��������alutype
`define NOP             3'b000
`define ARITH           3'b001
`define LOGIC           3'b010
`define MOVE            3'b011
`define SHIFT           3'b100
`define JUMP            3'b101
`define PRIVILEGE       3'b110

// �ڲ�������aluop
`define MINIMIPS32_LUI             8'h05
`define MINIMIPS32_MFHI            8'h0C
`define MINIMIPS32_MFLO            8'h0D
`define MINIMIPS32_SLL             8'h11
`define MINIMIPS32_MULT            8'h14
`define MINIMIPS32_ADD             8'h18
`define MINIMIPS32_ADDIU           8'h19
`define MINIMIPS32_SUBU            8'h1B
`define MINIMIPS32_AND             8'h1C
`define MINIMIPS32_ORI             8'h1D
`define MINIMIPS32_SLT             8'h26
`define MINIMIPS32_SLTIU           8'h27
`define MINIMIPS32_LB              8'h90
`define MINIMIPS32_LW              8'h92
`define MINIMIPS32_SB              8'h98
`define MINIMIPS32_SW              8'h9A

//11.8 ����22��
`define MINIMIPS32_ADDU            8'h40
`define MINIMIPS32_SUB             8'h41
`define MINIMIPS32_SLTU            8'h42
`define MINIMIPS32_OR              8'h43
`define MINIMIPS32_NOR             8'h44
`define MINIMIPS32_XOR             8'h45
`define MINIMIPS32_SRL             8'h46
`define MINIMIPS32_SRA             8'h47
`define MINIMIPS32_SLLV            8'h48
`define MINIMIPS32_SRLV            8'h49
`define MINIMIPS32_SRAV            8'h4A
`define MINIMIPS32_MULTU           8'h4B
`define MINIMIPS32_MTHI            8'h4C
`define MINIMIPS32_MTLO            8'h4D
`define MINIMIPS32_ADDI            8'h4E
`define MINIMIPS32_SLTI            8'h4F
`define MINIMIPS32_ANDI            8'h50
`define MINIMIPS32_XORI            8'h51
`define MINIMIPS32_LBU             8'h52
`define MINIMIPS32_LH              8'h53
`define MINIMIPS32_LHU             8'h54 
`define MINIMIPS32_SH              8'h55

//11.12 ����5��
`define MINIMIPS32_J               8'h2C
`define MINIMIPS32_JR              8'h2D
`define MINIMIPS32_JAL             8'h2E
`define MINIMIPS32_BEQ             8'h30
`define MINIMIPS32_BNE             8'h31

//11.15 ����7��
`define MINIMIPS32_JALR            8'h32
`define MINIMIPS32_BGEZ            8'h33
`define MINIMIPS32_BGTZ            8'h34
`define MINIMIPS32_BLEZ            8'h35
`define MINIMIPS32_BLTZ            8'h36
`define MINIMIPS32_BGEZAL          8'h37
`define MINIMIPS32_BLTZAL          8'h38

//12.14 ���ӳ���
`define MINIMIPS32_DIV             8'h16
`define MINIMIPS32_DIVU            8'h17

//12.15 �����쳣����
`define MINIMIPS32_SYSCALL         8'h86
`define MINIMIPS32_ERET            8'h87
`define MINIMIPS32_MFC0            8'h8C
`define MINIMIPS32_MTC0            8'h8D

/*------------------- ͨ�üĴ����Ѳ��� -------------------*/
`define REG_BUS         31: 0               // �Ĵ������ݿ���
`define REG_ADDR_BUS    4 : 0               // �Ĵ����ĵ�ַ����
`define REG_NUM         32                  // �Ĵ�������32��
`define REG_NOP         5'b00000            // ��żĴ���
/************************��������ˮ����ͣ begin*********************************/
/*------------------- ��ˮ����ͣ -------------------*/
`define STALL_BUS       3 : 0               // ��ͣ�źſ���
`define STOP            1'b1                // ��ˮ����ͣ
`define NOSTOP          1'b0                // ��ˮ�߲���ͣ

/*------------------- ����ָ����� -------------------*/
`define DIV_FREE            2'b00           // ����׼��״̬
`define DIV_BY_ZERO         2'b01           // �ж��Ƿ����״̬
`define DIV_ON              2'b10           // ������ʼ״̬
`define DIV_END             2'b11           // ��������״̬
`define DIV_READY           1'b1            // ������������ź�
`define DIV_NOT_READY       1'b0            // ��������δ�����ź�
`define DIV_START           1'b1            // ������ʼ�ź�
`define DIV_STOP            1'b0            // ����δ��ʼ�ź�
/************************��������ˮ����ͣ begin*********************************/

/************************�쳣���� begin*******************************/
/*------------------- CP0���� -------------------*/
`define CP0_INT_BUS         7 : 0           // �ж��źŵĿ���
`define CP0_BADVADDR        8               // BadVAddr�Ĵ�����ַ����ţ�
`define CP0_STATUS          12              // Status�Ĵ�����ַ����ţ�
`define CP0_CAUSE           13              // Cause�Ĵ�����ַ����ţ�
`define CP0_EPC             14              // EPC�Ĵ�����ַ����ţ�

/*------------------- �쳣�������� -------------------*/
`define EXC_CODE_BUS        4 : 0           // �쳣���ͱ������
`define EXC_INT             5'b00           // �ж��쳣�ı���
`define EXC_ADEL            5'h04           // ���ػ�ȡָ��ַ���쳣�ı���
`define EXC_ADES            5'h05           // �洢��ַ���쳣�ı���
`define EXC_SYS             5'h08           // ϵͳ�����쳣�ı���
`define EXC_BREAK           5'h09           // Break�쳣�ı���
`define EXC_RI              5'h0a           // ����ָ���쳣�ı���
`define EXC_OV              5'h0c           // ��������쳣�ı���
`define EXC_NONE            5'h10           // ���쳣
`define EXC_ERET            5'h11           // ERET�쳣�ı���
`define EXC_ADDR            32'h00000100    // �쳣����������ڵ�ַ
`define EXC_INT_ADDR        32'h00000040    // �ж��쳣����������ڵ�ַ

`define NOFLUSH             1'b0            // �������ˮ��
`define FLUSH               1'b1            // �����쳣�������ˮ��
/************************�쳣���� end*********************************/

/************************SoC���� begin*******************************/
`define IO_ADDR_BASE        16'hbfd0        // �ⲿIO�豸��ַ
/************************SoC���� end*********************************/


