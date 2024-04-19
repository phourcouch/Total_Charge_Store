.data

prompt: .asciiz "Please enter the number of items you are purchasing:\n"

tooManyItems: .asciiz "Sorry, too many items to purchase!!\n"

price: .asciiz "Please enter the price of item "

collon: .asciiz ":\t"

equalSigns: .asciiz "\n=====================================================================\n"

NumCoupons: .asciiz "Please enter the number of coupons that you want to use\n"

tooManyCoupons: .asciiz "Too many Coupons!!" 

tooLittleCoupons: .asciiz "Too little Coupons!!" 

enterCoupon: .asciiz "Please enter the amount of coupon "

errorCoupon: "This coupon is not acceptable\n" 

output: "Your total charge is:\t$"

output2: "\nThank you for shopping with us."

priceArray: .word 0

CouponArray: .word 0,0

.text

main:
la $s1,CouponArray
la $s0,priceArray

addi $t0, $0, 20 #max purchase num

priceUserInput: #input for prices

li $v0,4
la $a0,prompt #prompt user to input number of items purchasing
syscall 

li $v0,5
syscall

add $t1,$v0,$0 #user's input - n

bgt $t1,$t0,tooManyItemsError #if user's input is greater than 20, go to error message

li $v0,4
la $a0,equalSigns
syscall 


add $a1,$t1,$0 #passing user's input
add $a2,$s0,$0#passing price array pointer 
jal FillPriceArray

add $s2,$v1,$0 #returned sub total from FillPriceArray 

##########coupon stuff
numCouponInput:
li $v0,4
la $a0,NumCoupons #prompt user to enter number of coupons 
syscall 

li $v0,5 #collecting number of coupons
syscall

add $t3,$v0,$0 #user's input

bgt $t3,$t1,tooManyCouponsError #if user's input is greater than item number, go to greaterthan error message
blt $t3,$t1,tooLittleCouponsError #if user's input is less than item number, go to lessthan error message

li $v0,4
la $a0,equalSigns
syscall 

add $a1,$t3,$0 #passing user's input - n
add $a2,$s0,$0# price array pointer
add $a3,$s1,$0#coupon array pointer
jal FillCouponArray

add $t9,$v1,$0 #returned coupon total

li $v0,4
la $a0,equalSigns
syscall 

li $v0,4
la $a0,output
syscall 


sub $t8,$s2,$t9 #substract coupon total from sub total

li $v0,1
add $a0,$t8,$0 #print out total after applying coupons 
syscall

li $v0,4
la $a0,output2
syscall 


li $v0,10
syscall


########################################################################################################
#fillPRice

FillPriceArray:	
	
	addi $t2, $0, 0 #counter for loop
	addi $t5, $0, 1 #counter for item number
	addi $t4,$0, 0 #sub total

	add $t0,$a1,$0#n
	add $t3,$a2,$0#price array pointer
	
priceLoop:
	bge $t2,$t0,goMainPrice #if counter is greater than or equal to n ( num of coupons/items) return to main
		
	li $v0,4
	la $a0,price #prompt user to enter price of current item 
	syscall 
	
	li $v0,1
	add $a0,$t5,$0 #printing out current item number 
	syscall 
		
	li $v0,4
	la $a0,collon
	syscall 
	
	li $v0,5 #collecting price of current item
	syscall
	
	sw $v0,0($t3) #storing price  into  price array 
	
	add $t4,$v0,$t4 #adding user's inputs to sub total
	
	addi $t3,$t3,4
	addi $t5,$t5,1
	addi $t2,$t2,1
	j priceLoop
	
	
#return to Main
goMainPrice:
	add $v1,$t4,$0 #returning price total
	jr $ra

#################################################################################
#fillCoupon
FillCouponArray:
	addi $t2, $0, 0 #counter for loop
	addi $t5, $0, 1 #counter for item number
	addi $t4,$0, 0 #coupon sum 
	addi $t9, $0, 11 #max coupon amount is less than 11

	add $t0,$a1,$0#n
	add $t3,$a3,$0#pointer to coupon array
	add $t6,$a2,$0#pointer to price array
	

couponLoop:

	bge $t2,$t0,goMainCoupon #go to MainCoupon if counter is greater than or equal to n


	li $v0,4
	la $a0,enterCoupon #prompt user to enter the amount of the current coupon 
	syscall 
	
	li $v0,1
	add $a0,$t5,$0 #printing out current coupon number
	syscall 
		
	li $v0,4
	la $a0,collon
	syscall 
	
	li $v0,5 #collecting user's input
	syscall
	
	add $t7,$v0,$0 #storing coupon value
	
	lw $t1,0($t6) #loading  with  price array value
		
	bgt $t7,$t1, tooOver   #if coupon is greater than current item price than go to tooOver
	bge $t7,$t9, tooOver   #if coupon is greater than or equal to 11 than go to tooOver
	
	sw $t7,0($t3) #if coupon isnt over item's price or 10 then store coupon into coupon array
	
	add $t4,$t7,$t4 #adding user's input to coupon total
	
	j next
	
	tooOver: 
	
	sw $0,0($t3) #store 0 into coupon array 
	
	li $v0,4
	la $a0,errorCoupon
	syscall 
	
	j next
	
next:	
	addi $t6,$t6,4 
	addi $t3,$t3,4
	addi $t5,$t5,1
	addi $t2,$t2,1
	j couponLoop
	

goMainCoupon:
	add $v1,$t4,$0 #returning coupon total
	jr $ra


###############################################################################


#errorMessages
tooManyItemsError:

li $v0,4
la $a0,tooManyItems
syscall
j priceUserInput 


tooManyCouponsError:
li $v0,4
la $a0,tooManyCoupons
syscall
j numCouponInput 


tooLittleCouponsError:
li $v0,4
la $a0,tooLittleCoupons
syscall
j numCouponInput 



