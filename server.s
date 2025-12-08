.include "constants.s"

.section .data

sockaddr:
	.hword AF_INET
	.hword 0x5000
	.word 0x00000000
	.space 8

sockaddr_len = . - sockaddr 

http_fail:
         .ascii "HTTP/1.1 400 Bad Request\r\n"
	 .ascii "Content-Type: text/plain\r\n"
	 .ascii "Content-Length: 11\r\n\r\n"
	 .ascii "Bad Request"

fail_len = . - http_fail

file_path:
	.ascii "./index.html"

.section .bss

clientaddr:	
	.zero 16

clientaddr_len:
	.zero 8

statbuff:
	.zero 144

request_buff:
	.zero 4096

temp_byte: 
	.zero 1

.section .text
.global _start

_start:
	bl load_html
	mov x16, x22
	mov x15, x21

	//mov x0, #1
	//mov x1, x16
	//mov x2, x15
	//bl print

	bl create_server

	ret

print:
	mov x8, SYS_write
	svc #0
	ret

load_html:

	// open
	mov  x0, AT_FDCWD
	ldr x1, =file_path
	eor x2, x2, x2
	mov x3, #292

	mov x8, SYS_openat
	svc #0

	mov x20, x0
	
	// fstat
	mov x0, x20
	ldr x1, =statbuff

	mov x8, SYS_fstat
	svc #0
	
	// get size
	mov x9, #9
	ldr x0, =statbuff
	add x0, x0, ST_SIZE_OFFSET
	ldr x21, [x0]

	// mmap
	
	eor x0, x0, x0
	mov x1, x21
	mov x2, #1
	mov x3, #2
	mov x4, x20
	eor x5, x5, x5

	mov x8, SYS_mmap
	svc #0

	mov x22, x0

	//close

	mov x0, x20

	mov x8, SYS_close
	svc #0

	mov x0, x22
	mov x1, x21

	ret


create_server:
	
	bl create_socket

	bl bind
	
	bl listen

	bl loop
	
	mov x8, SYS_exit
	svc #0

	ret

create_socket:

	mov x0, AF_INET
	mov x1, SOCK_STREAM
	mov x2, #0

	mov x8, SYS_socket
	svc #0
	mov x19, x0
	
	ret
	
bind:	
	mov x0, x19
	ldr x1, =sockaddr
	mov x2, sockaddr_len

	mov x8, SYS_bind
	svc #0

	ret

listen:
	mov x0, x19
	mov x1, 1024
	mov x8, SYS_listen
	svc #0

	ret

accept:
	mov x0, x19
	ldr x1, =clientaddr
	ldr x2, =clientaddr_len

	mov x8, SYS_accept
	svc #0
	
	ret

send:
	
	mov x1, x16
	mov x2, x15

	eor x3, x3, x3
	eor x4, x4, x5
	eor x5, x5, x5

	mov x8, SYS_sendto
	svc #0

	ret

close:
	mov x8, SYS_close
	svc #0
	ret

is_get:
	eor x2, x2, x2
	ldr x1, =request_buff
        ldrb w2, [x1]
        cmp w2, #0x47
        b.ne fail

        ldrb w2, [x1, #1]
        cmp w2, #0x45
        b.ne fail

        ldrb w2, [x1, #2]
        cmp w2, #0x54
        b.ne fail

        ldrb w2, [x1, #3]
        cmp w2, #0x20
        b.ne fail

        mov x17, #1
        ret

fail:
        mov x17, #0
        ret

loop:

	bl accept

	mov x20, x0

	mov x0, x20
	ldr x1, =request_buff
	mov x2, #4096
	mov x8, SYS_read
	svc #0
	mov x21, x0

	mov x0, #1
	ldr x1, =request_buff
	mov x2, x21
	bl print
	
	bl is_get
	cmp x17, #1
	b.ne send_400

	mov x0, x20
   	bl send

	mov x0, x20
	bl close

   	b loop

send_400:
        mov x0,x20

        ldr x1, =http_fail
        mov x2, fail_len

        eor x3, x3, x3
        eor x4, x4, x4
        eor x5, x5, x5

        mov x8, SYS_sendto
        svc #0

	mov x0, x20
	bl close
	b loop
