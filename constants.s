# Syscalls

.equ SYS_openat, 56
.equ SYS_close, 57
.equ SYS_read, 63
.equ SYS_write, 64
.equ SYS_fstat, 80
.equ SYS_exit, 93
.equ SYS_socket, 198
.equ SYS_bind, 200
.equ SYS_listen, 201
.equ SYS_accept, 202
.equ SYS_sendto, 206
.equ SYS_mmap, 222

# Socket constants

.equ AF_INET, 2
.equ SOCK_STREAM, 1

# Other constants

.equ ST_SIZE_OFFSET, 48

.equ AT_FDCWD, -100

