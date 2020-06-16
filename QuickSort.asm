.data
array: .word 1, 13, -4, 5
n: .word 0 # SL phan tu


.text
main:

# Load dia chi array[0] vao $a0
la $a0, array

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
