.data
array: .space 1024
n: .word 0 # SL phan tu


.text
main:

	li $t7, 4



################# FUNCTION #################
# $a0 = dia chi array[0], $a1 = left, $a2 = right,  $t7 = 4



QuickSort:
	bge $a1, $a2, Return
	
	# right * 4 de co do doi cho array[right]
	mult $a2, $t7
	# $t0 chua do doi cua array[right]
	mflo $t0

	
	# $t2 chua dia chi cua array[right]
	# array[right] = ($t2)
	add $t2, $a0, $t0
	# array[right] = $t2
	lw $t2, ($t2)


	# $t3=do doi left, $t4=do doi right
	# $t3 = i, $t4 = j
	mult $a1, $t7
	mflo $t3


	move $t4, $t0

	LoopChinh:

		bge $t3, $t4, DeQuy
		LoopI:
			add $t5, $a0, $t3
			lw $s0, ($t5)
			blt $s0, $t2, TangI
			j LoopJ
		TangI:
			addi $t3, $t3, 4
			j LoopI
		LoopJ:
			add $t5, $a0, $t4
			lw $s0, ($t5)
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
			add $t5, $a0, $t3
			lw $s0, ($t5)

			add $t5, $a0, $t4
			lw $s1, ($t5)
			
			sw $s0, ($t4)
			sw $s1, ($t3)

			# Tang i va giam j
			addi $t3, $t3, 4
			addi $t4, $t4, -4
		
		# j lai vong lap
		j LoopChinh


	DeQuy:
		blt 
	Return:
		jr $ra