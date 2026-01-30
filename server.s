.include "constants.s"

.section .rodata

sockaddr:
	.hword AF_INET
	.hword 0x5000
	.word 0x00000000
	.space 8

sockaddr_len = . - sockaddr 

http_ok:
	.asciz "HTTP/1.1 200 OK"
http_ok_len = . - http_ok

html_cl:
	.ascii "Content-Length: "
html_cl_len = . - html_cl 

ct_html_text:
	.asciz "Content-Type: text/html"
ct_html_text_len = . - ct_html_text

http_fail:
         .ascii "HTTP/1.1 400 Bad Request\r\n"
	 .ascii "Content-Type: text/plain\r\n"
	 .ascii "Content-Length: 11\r\n\r\n"
	 .ascii "Bad Request"
fail_len = . - http_fail

overview_path:
	.asciz "./images.html"
overview_len = . - overview_path
overview_path_acc:
	.asciz "./sites/images.html"

file_path:
	.asciz "./index.html"
file_len = . - file_path
file_path_acc:
	.asciz "./sites/index.html"

wizard_path:
	.asciz "./wizard.html"
wizard_len = . - wizard_path
wizard_path_acc:
	.asciz "./sites/wizard.html"

books_path:
	.asciz "./books.html"
books_len = . - books_path
books_path_acc:
	.asciz "./sites/books.html"

music_path:
	.asciz "./music.html"
music_len = . - music_path
music_path_acc:
	.asciz "./sites/music.html"

slash:
	.asciz "/"
slash_len = . - slash

.section .bss

clientaddr:	
	.zero 16

clientaddr_len: 
	.zero 8

statbuff:
	.zero 144

request_buff:
	.zero 4096

img_path_buff:
	.zero 14

temp_byte: 
	.zero 1

.section .text
.global _start

_start: 
	bl create_server

	ret

print:
	mov x8, SYS_write
	svc #0
	ret


load_html:

	// open
	mov x0, AT_FDCWD
	eor x2, x2, x2
	mov x3, #292

	mov x8, SYS_openat
	svc #0

	mov x23, x0
	
	// fstat
	mov x0, x23
	ldr x1, =statbuff

	mov x8, SYS_fstat
	svc #0
	
	// get size
	mov x9, #9
	ldr x0, =statbuff
	add x0, x0, ST_SIZE_OFFSET
	ldr x24, [x0]

	// mmap
	
	eor x0, x0, x0
	mov x1, x24
	mov x2, #1
	mov x3, #2
	mov x4, x23
	eor x5, x5, x5

	mov x8, SYS_mmap
	svc #0

	mov x26, x0

	//close

	mov x0, x23

	mov x8, SYS_close
	svc #0

	mov x0, x26
	mov x1, x24

	ret

load_img:

	// open
	mov  x0, AT_FDCWD
	ldr x1, =img_path_buff
	eor x2, x2, x2
	mov x3, #292

	mov x8, SYS_openat
	svc #0

	mov x25, x0
	
	// fstat
	mov x0, x25
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
	mov x4, x25
	eor x5, x5, x5

	mov x8, SYS_mmap
	svc #0

	mov x22, x0

	//close

	mov x0, x25

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

str_len:
	eor x2, x2, x2
	ldrb w3, [x1]
len_loop:
	add x2, x2, #1
	cmp w3, 48
	b.ne len_loop
	mov x0, x2
	ret


create_header:
	
	ret

send_subpage:
	
	mov x1, x26
	mov x2, x24
	mov x0, x20

	eor x3, x3, x3
	eor x4, x4, x5
	eor x5, x5, x5

	mov x8, SYS_sendto
	svc #0

	b eol

send_img: 

	bl load_img

	mov x1, x22
	mov x2, x21
	mov x0, x20
	
	eor x3, x3, x3
	eor x4, x4, x5
	eor x5, x5, x5

	mov x8, SYS_sendto
	svc #0

	b eol

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

strcmp:
	// preset x1 to string and x2 to strlen1
	// preset x3 to comparing string
	
	eor x4, x4, x4
	eor x5, x5, x5
	eor x6, x6, x6
	sub x2, x2, #1

cmp_loop:
	ldrb w4, [x1]
	ldrb w5, [x3]
	cmp w4, w5
	b.ne fail
	add x1, x1, #1
	add x3, x3, #1
	add x6, x6, #1

	cmp x2, x6
	b.ne cmp_loop

	ldrb w4, [x3]
	cmp w4, #32
	b.ne fail

	mov x17, #1
	ret
fail:
        mov x17, #0
        ret

is_slash:
	ldr x1, =slash
	mov x2, slash_len
	ldr x3, =request_buff
	add x3, x3, #4
	b strcmp

	ret

is_index: 
	ldr x1, =file_path
	mov x2, file_len
	ldr x3, =request_buff
	add x1, x1, #1
	sub x2, x2, #1
	add x3, x3, #4
	b strcmp

	ret

is_wizard:
	ldr x1, =wizard_path
	mov x2, wizard_len
	ldr x3, =request_buff
	add x1, x1, #1
	sub x2, x2, #1
	add x3, x3, #4
	b strcmp

	ret

is_books:
	ldr x1, =books_path
	mov x2, books_len
	ldr x3, =request_buff
	add x1, x1, #1
	sub x2, x2, #1
	add x3, x3, #4
	b strcmp

	ret

is_overview:
	ldr x1, =overview_path
	mov x2, overview_len
	ldr x3, =request_buff
	add x1, x1, #1
	sub x2, x2, #1
	add x3, x3, #4
	b strcmp

	ret

is_img:
	eor x2, x2, x2
	ldr x1, =request_buff
	add x1, x1, #4
        ldrb w2, [x1]
        cmp w2, #0x2F
        b.ne fail

        ldrb w2, [x1, #1]
        cmp w2, #0x69
        b.ne fail

        ldrb w2, [x1, #2]
        cmp w2, #0x6d
        b.ne fail

        ldrb w2, [x1, #3]
        cmp w2, #0x61
        b.ne fail

        ldrb w2, [x1, #4]
        cmp w2, #0x67
        b.ne fail

        ldrb w2, [x1, #5]
        cmp w2, #0x65
        b.ne fail

        ldrb w2, [x1, #6]
        cmp w2, #0x73
        b.ne fail

        ldrb w2, [x1, #7]
        cmp w2, #0x2F
        b.ne fail

        ldrb w2, [x1, #8]
        cmp w2, #0x69
        b.ne fail

        ldrb w2, [x1, #9]
        cmp w2, #0x6d
        b.ne fail

        ldrb w2, [x1, #10]
        cmp w2, #0x67
        b.ne fail

        ldrb w2, [x1, #14]
        cmp w2, #0x2E
        b.ne fail

        ldrb w2, [x1, #18]
        cmp w2, #0x20
        b.ne fail

        ldr x1, =request_buff
	add x1, x1, #5         
     	ldr x2, =img_path_buff 
     	mov x3, #13            

copy_path:
        ldrb w4, [x1], #1  
        strb w4, [x2], #1  
        subs x3, x3, #1    
        b.ne copy_path

	mov x17, #1
        
	ret

overview:
	ldr x1, =overview_path_acc
	bl load_html
	mov x0, x20
	b send_subpage

index:
	ldr x1, =file_path_acc
	bl load_html
	mov x0, x20
	b send_subpage

wizard: 
	ldr x1, =wizard_path_acc
	bl load_html
	mov x0, x20
	b send_subpage

books: 
	ldr x1, =books_path_acc
	bl load_html
	mov x0, x20
	b send_subpage

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

	bl is_slash 
	cmp x17, #1
	mov x0, x20
	b.eq index

	bl is_index
	cmp x17, #1
	b.eq index

	bl is_overview
	cmp x17, #1
	b.eq overview 

	bl is_wizard
	cmp x17, #1
	b.eq wizard

	bl is_books	
	cmp x17, #1
	b.eq books
	
	bl is_img	
	cmp x17, #1
	b.eq send_img

	mov x0, x20
   	bl send_400


eol:
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
