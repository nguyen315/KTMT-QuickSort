.data
array: .space 1024
n: .word 0 # SL phan tu
filename: .asciiz "input.txt"	
buffer: .space 20
strXuatArray: .asciiz "Array: "
strDauPhay: .asciiz ", "


.text
main:

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
li $a2, 100
syscall

#close file
li $v0, 16
move $a0, $s0
syscall

#xuat noi dung file
la $a0, buffer
jal readArr

# Load dia chi array[0] vao $a0
la $a0, array
jal XuatArray
j exit

# $a1 = do doi left, $a2 = do doi right
li $a1, 0
li $a2, 12

jal QuickSort
# Ket thuc chuong trinh
li $v0, 10
syscall	


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

		bge $t3, $t4, DeQuy
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

############# Ket thuc xuat phan tu

# -- end program
exit:
li $v0, 10
syscall