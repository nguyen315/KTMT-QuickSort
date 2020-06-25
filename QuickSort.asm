.data
array: .space 5000
n: .word 0 # SL phan tu
filename: .asciiz "input_sort.txt"	
fileOut: .asciiz "output_sort.txt"	
buffer: .space 5000
strXuatArray: .asciiz "Array: "
strDauPhay: .asciiz ", "


.text
main:
######## Long input ###########
#open file for read-only
li $v0, 13
la $a0, filename
addi $a1, $0, 0
addi $a2, $0, 0
syscall
add $s0, $v0, $0

#read file
li $v0, 14
add $a0, $s0, $0
la $a1, buffer
li $a2, 5000
syscall

#close file
li $v0, 16
move $a0, $s0
syscall

#xuat noi dung file
la $a0, buffer
jal readArr


#j exit

######## End of Long Input ##########



######## Nguyen Quicksort ##########
# $a1 = do doi left, $a2 = do doi right

la $a0, array
li $a1, 0

lw $t0, n
addi $t0, $t0, -1
li $t1, 4
mult $t0, $t1

mflo $a2

jal QuickSort

# Load dia chi array[0] vao $a0
# la $a0, array
# jal XuatArray
j fout

# Ket thuc chuong trinh
j exit

###### End of Nguyen Quicksort #########



################# FUNCTION #################
# $a0 = dia chi array[0], $a1 = do doi left, $a2 = do doi right
QuickSort:
	bge $a1, $a2, Return
	
	# array[right] = $t2
	add $t0, $a0, $a2
	lw $t2, ($t0)


	# $t3=do doi left, $t4=do doi right
	# $t3 = i, $t4 = j
	move $t3, $a1
	move $t4, $a2


	LoopChinh:

		bgt $t3, $t4, DeQuy
		LoopI:
			add $t0, $a0, $t3
			lw $s0, ($t0)
			blt $s0, $t2, TangI
			j LoopJ
		TangI:
			addi $t3, $t3, 4
			j LoopI
		LoopJ:
			add $t0, $a0, $t4
			lw $s0, ($t0)
			bgt $s0, $t2, GiamJ
			j Task1
		GiamJ:
			addi $t4, $t4, -4
			j LoopJ
		
	
		Task1:
			ble $t3, $t4, Swap
			j LoopChinh

		Swap:
			# Gan array[i] o $t3 vao array[j] o $t4 va nguoc lai
			add $t0, $a0, $t3
			lw $s0, ($t0)

			add $t0, $a0, $t4
			lw $s1, ($t0)
			
			add $t0, $a0, $t4
			sw $s0, ($t0)

			add $t0, $a0, $t3
			sw $s1, ($t0)

			# Tang i va giam j
			addi $t3, $t3, 4
			addi $t4, $t4, -4
		
		# j lai vong lap
		j LoopChinh


	DeQuy:
		blt $a1, $t4, DeQuyTrai
		j BatDauDeQuyPhai
		DeQuyTrai:
			# Khai bao stack
			addi $sp, $sp, -12
			
			# Cat $ra vao stack
			sw $ra, 8($sp)
			
			# Cat right vao stack
			sw $a2, 4($sp)

			# Cat i vao stack
			sw $t3, 0($sp)

			# Gan right = j va jal vao QuickSort
			move $a2, $t4
			jal QuickSort

			# Sau khi quay ve thi lay nhung gia tri trong stack ra lai
			lw $ra, 8($sp)
			lw $a2, 4($sp)
			lw $t3, 0($sp)

			# Tang lai gia tri stack
			addi $sp, $sp, 12

		BatDauDeQuyPhai:
			bgt $a2, $t3, DeQuyPhai
			j Return
			DeQuyPhai:
				# Khai vao stack
				addi $sp, $sp, -4
			
				# Cat $ra vao stack
				sw $ra, 0($sp)

				# Gan left = i va jal vao QuickSort
				move $a1, $t3
				jal QuickSort

				# Sau khi quay ve thi lay nhung gia tri trong stack ra lai
				lw $ra, 0($sp)

				# Tang lai gia tri stack
				addi $sp, $sp, 4
	Return:
		jr $ra

# Read array from file
readArr:
	move $t6, $ra # luu $ra vao $t6
	jal atoi
	addi $a0, $a0, 1 # loai bo dau xuong hang
	li $t7, 0 # khoi tao bien dem o $t7
	la $t5, array	# luu dia chi array vao $t5
	sw $v0, n # $s2 ch?a s? ph?n t? n
	lw $s2, n
	
	Loop:
		jal atoi
		sw $v0, ($t5)

		SetUpNextLoop:
			# Tang bien dem
			addi $t7, $t7, 1
			addi $t5, $t5, 4 # $t5 luu gia tri dia chi phan tu array hien tai
			# So sanh dieu kien dung vong lap
			blt $t7, $s2, Loop

		# ket thuc ham
		move $ra, $t6
		jr $ra

#parse string to integer
atoi:
    or      $v0, $zero, $zero   # num = 0
    or      $t1, $zero, $zero   # isNegative = false
    lb      $t0, 0($a0)
    bne     $t0, '+', .isp      # consume a positive symbol
    addi    $a0, $a0, 1
.isp:
    lb      $t0, 0($a0)
    bne     $t0, '-', .num
    addi    $t1, $zero, 1       # isNegative = true
    addi    $a0, $a0, 1
.num:
    lb      $t0, 0($a0)
    slti    $t2, $t0, 58        # *str <= '9'
    slti    $t3, $t0, '0'       # *str < '0'
    beq     $t2, $zero, .done
    bne     $t3, $zero, .done
    sll     $t2, $v0, 1
    sll     $v0, $v0, 3
    add     $v0, $v0, $t2       # num *= 10, using: num = (num << 3) + (num << 1)
    addi    $t0, $t0, -48
    add     $v0, $v0, $t0       # num += (*str - '0')
    addi    $a0, $a0, 1         # ++num
    j   .num
.done:
    addi    $a0, $a0, 1         # ++num
    beq     $t1, $zero, .out    # if (isNegative) num = -num
    sub     $v0, $zero, $v0
.out:
    jr      $ra         # return



# xuat array
XuatArray:
	# $a1 luu n, $a2 luu dia chi array[0]
	lw $a1, n
	la $a2, array
	

	la $a0, strXuatArray
	li $v0, 4
	syscall	

	# a3 la bien dem
	li $a3, 0

	LoopXuatArray:
		# Dua so trong arr vao $a0 de xuat
		lw $a0, ($a2)
	
		li $v0, 1
		syscall

		# Thay doi gia tri bien dem va tang gia tri cua array
		addi $a2, $a2, 4
		addi $a3, $a3, 1 

		# Xuat dau phay cho de nhin
		# Neu la so cuoi thi khong xuat dau phay
		blt $a3, $a1, XuatDauPhay
		j TiepTucLoop
		XuatDauPhay:
			la $a0, strDauPhay
			li $v0, 4
			syscall

		
		TiepTucLoop:
			blt $a3, $a1, LoopXuatArray
	

	# Xong het thi return lai chuong trinh chinh
	jr $ra
fout:
	li $s4, 0
	li $t2, 10
	li $v0, 9
	li $a0, 10  # allocate 4 bytes for 4 chars
	syscall
	move $s0, $v0
	li $t6, 4000
	move $t7, $t6
	la $t4, array
	move $t6, $t4
	add $t4, $t4, $t7
	j getElement

getElement:
	lw $t3, 0($t4)
	j calc

calc:
	div $t3, $t2
	mflo $t3 # thuong
	mfhi $s1 # du
	addi $s1, $s1, 48
	sb $s1, 0($s0)
	addi $s0, $s0, -1
	bgt $t3, 0, increaseIndex
	j writeSpace

increaseIndex:
	addi $s4, $s4, 1
	j calc

writeSpace:
	li $t3, 32
	sb $t3, 0($s0)
	beq $t4, $t6, writeFile
	addi $s0, $s0, -1
	addi $t4, $t4, -4
	j getElement

writeFile:
	addi $s0, $s0, 1
	# Mo file de ghi
	li   $v0, 13       # system call for open file
	la   $a0, fileOut     # file output
	li   $a1, 1       # co ghi = 1
	li   $a2, 0      
	syscall            # mo file
	move $s6, $v0      # luu mo ta file va $s6

	# Ghi file
	li   $v0, 15       # ghi file
	move $a0, $s6     
	move $a1, $s0     
	la $s1, n
	lw $t1, 0($s1)
	add $t1, $t1, $t1
	subi $t1, $t1, 1
	add $t1, $t1, $s4
	move   $a2, $t1        # chieu dai array
	syscall            # ghi vao file

	# dong file
	li   $v0, 16       
	move $a0, $s6  
	syscall            


exit:
li $v0, 10
syscall

