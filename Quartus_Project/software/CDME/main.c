#include "sys/alt_stdio.h"
#include <stdint.h>
#include <unistd.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"

int write_program(void);
int read_program(void);

int main()
{ 


	volatile uint16_t t;
	volatile uint16_t buff[2] = {0,0};

	IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_SELOUT_BASE, 0x0);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0x7);
	//alt_putstr("Hello from Nios II!\n");
	/* Event loop never exits. */

	while (1) {
		t = alt_getchar();
		//alt_printf("%x",t);
		buff[1] = buff[0];
		buff[0] = t;

		if(buff[1] == 'W' && buff[0] == 'R'){
			//alt_putstr("write start\n");
			write_program();
		}
		else if(buff[1] == 'R' && buff[0] == 'D'){
			//alt_putstr("read start\n");
			read_program();
		}

	}
	return 0;
}
int write_program(){
	volatile unsigned char program[256]={};
	volatile int i;
	volatile uint16_t t;

	alt_printf("%x",0xFF); //受信準備完了したことを伝える
	for(i=0;i<256;i++){
		//一度すべてのコードを受け取る
		program[i] = alt_getchar();
	}

	//プログラムカウンタリセット、プログラム書き込みモードへ切り替え
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_SELOUT_BASE, 0x4);
	usleep(20000);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xF);
	usleep(20000);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xD);
	usleep(20000);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xF);
	usleep(20000);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_SELOUT_BASE, 0x7);
	usleep(20000);

	//書き込み
	for(i=0;i<256;i++){
		t=0x100 | program[i]; //先頭に1を付加してPIOを有効化する
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_IO_INOUT_BASE, t);
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xE);
		usleep(10000);
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xF);
		usleep(10000);
	}

	//復帰
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_IO_INOUT_BASE, 0x0);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_SELOUT_BASE, 0x0);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0x0);
	return 0;

}
int read_program(){
	volatile unsigned char memory[256]={};
	volatile int i;
	volatile uint16_t t;

	//プログラムカウンタリセット、プログラム読み出し動作へ切り替え
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_SELOUT_BASE, 0x4);
	usleep(20000);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xF);
	usleep(20000);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xD);
	usleep(20000);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xF);
	usleep(20000);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_SELOUT_BASE, 0x6);
	usleep(20000);
	for(i=0;i<256;i++){

		IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xE);
		usleep(10000);
		t=IORD_ALTERA_AVALON_PIO_DATA(PIO_DATAIN_BASE);
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0xF);
		usleep(10000);

		memory[i]=(t & 0x000F)|(t & 0x00F0);
		//alt_printf("%x ",i);
	}

	for(i=0;i<256;i++){
		alt_printf("%x,",memory[i]);
	}

	IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_SELOUT_BASE, 0x0);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_KEYOUT_BASE, 0x0);
	return 0;
}
