########################################################################
# COMP1521 22T1 -- Assignment 1 -- Mipstermind!
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# It is also suggested to indent with tabs only.
# Instructions to configure your text editor can be found here:
#   https://cgi.cse.unsw.edu.au/~cs1521/22T1/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by Stephen Lerantges (z5319858)
# on 19/03/2022
#
# Version 1.0 (28-02-22): Team COMP1521 <cs1521@cse.unsw.edu.au>
#
########################################################################

#![tabsize(8)]

# Constant definitions.
# DO NOT CHANGE THESE DEFINITIONS

TURN_NORMAL = 0
TURN_WIN    = 1
NULL_GUESS  = -1


########################################################################
# .DATA
# YOU DO NOT NEED TO CHANGE THE DATA SECTION
.data

# int correct_solution[GUESS_LEN];
.align 2
correct_solution:	.space GUESS_LEN * 4

# int current_guess[GUESS_LEN];
.align 2
current_guess:		.space GUESS_LEN * 4

# int solution_temp[GUESS_LEN];
.align 2
solution_temp:		.space GUESS_LEN * 4


guess_length_str:	.asciiz "Guess length:\t"
valid_guesses_str:	.asciiz "Valid guesses:\t1-"
number_turns_str:	.asciiz "How many turns:\t"
enter_seed_str:		.asciiz "Enter a random seed: "
you_lost_str:		.asciiz "You lost! The secret codeword was: "
turn_str_1:		.asciiz "---[ Turn "
turn_str_2:		.asciiz " ]---\n"
enter_guess_str:	.asciiz "Enter your guess: "
you_win_str:		.asciiz "You win, congratulations!\n"
correct_place_str:	.asciiz "Correct guesses in correct place:   "
incorrect_place_str:	.asciiz "Correct guesses in incorrect place: "

############################################################
####                                                    ####
####   Your journey begins here, intrepid adventurer!   ####
####                                                    ####
############################################################


########################################################################
#
# Implement the following 8 functions,
# and check these boxes as you finish implementing each function
#
#  - [X] main
#  - [X] play_game
#  - [X] generate_solution
#  - [X] play_turn
#  - [X] read_guess
#  - [X] copy_solution_into_temp
#  - [X] calculate_correct_place
#  - [X] calculate_incorrect_place
#  - [X] seed_rand  (provided for you)
#  - [X] rand       (provided for you)
#
########################################################################


########################################################################
# .TEXT <main>
.text
main:
	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    [$ra]
	# Uses:     [$v0, $a0]
	# Clobbers: [$v0, $a0]
	#
	# Locals:
	#   - N/A
	#
	# Structure:
	#   main
	#   -> [prologue]
	#   -> body
	#   -> [epilogue]

main__prologue:
	begin                   		# begin a new stack frame
	push	$ra             		# | $ra

main__body:
	# printf("Guess length: %d\n", GUESS_LEN);
	li	$v0, 4				# syscall 4: print_string
	la	$a0, guess_length_str		#
	syscall					# printf("Guess length: ");

	li	$v0, 1				# syscall 1: print_int
	li	$a0, GUESS_LEN			#
	syscall					# printf("%d", GUESS_LEN);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'			#
	syscall					# printf("\n");


	# printf("Valid guesses: 1-%d\n", GUESS_CHOICES);
	li	$v0, 4				# syscall 4: print_string
	la	$a0, valid_guesses_str
	syscall					# printf("Valid guesses: 1-");

	li	$v0, 1				# syscall 1: print_int
	li	$a0, GUESS_CHOICES
	syscall					# printf("%d", GUESS_CHOICES);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# printf("\n");


	# printf("How many turns: %d\n\n", MAX_TURNS);
	li	$v0, 4				# syscall 4: print_string
	la	$a0, number_turns_str		#
	syscall					# printf("How many turns: ");

	li	$v0, 1				# syscall 1: print_int
	li	$a0, MAX_TURNS			#
	syscall					# printf("%d", MAX_TURNS);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'			#
	syscall					# printf("\n");
	syscall					# printf("\n");

	# printf("Enter a random seed: ");
	li	$v0, 4				# syscall 4: print_string
	li	$a0, enter_seed_str		#
	syscall					# printf("Enter a random seed: ");

	li	$v0, 5				# syscall 5: read_int
	syscall					# scanf("%d", &random_seed);

	move	$a0, $v0			# 
	jal	seed_rand			# seed_rand(random_seed);

	jal	play_game			# play_game();

main__epilogue:
	pop	$ra             		# | $ra
	end                     		# ends the current stack frame

	li	$v0, 0
	jr	$ra             		# return 0;




########################################################################
# .TEXT <play_game>
.text
play_game:
	# Args:     void
	# Returns:  void
	#
	# Frame:    [$ra, $a0, $v0, $s2]
	# Uses:     [$a0, $v0, $s2, $t1, $t2, $t3, $t4]
	# Clobbers: [$t1, $t2, $t3, $t4]
	#
	# Locals:
	#   - $s2: int turn
	#   - $t1: int i (iterator)
	#   - $t2: int i * sizeof(int)
	#   - $t3: &correct_solution
	#   - $t4: &correct_solution[i]
	#
	# Structure:
	#   play_game
	#   -> [prologue]
	#   -> body
	#     -> loop0
	#       -> if0
	#       -> endif0
	#     -> end0
	#     -> loop1
	#     -> end1
	#   -> [epilogue]

play_game__prologue:
	begin						# move frame pointer
	push	$ra					# | $ra
	push	$a0					# | $a0 $ra
	push	$v0					# | $v0 $a0 $ra
	push	$s2					# | $s2 $v0 $a0 $ra
play_game__body:
	jal	generate_solution			# generate_solution();

	li	$s2, 0					# int turn = 0;
play_game__loop0:
	bge	$s2, MAX_TURNS, play_game__end0		# if ($t0 >= MAX_TURNS) goto play_game__end0:

	move	$a0, $s2				#
	jal	play_turn				#	int turn_status = play_turn(turn);

play_game__if0:
	bne	$v0, TURN_WIN, play_game__endif0	# 	if (turn_status != TURN_WIN) goto play_game__endif0;
	j	play_game__epilogue			#	goto play_game__epilogue; (return)

play_game__endif0:
	addi	$s2, $s2, 1				# 	turn++;
	j	play_game__loop0			# goto play_game_loop0;

play_game__end0:
	la	$a0, you_lost_str			# printf("You lost! The secret codeword was: ");
	li	$v0, 4					#
	syscall						#

	li	$t1, 0					# int i = 0;

play_game__loop1:
	bge	$t1, GUESS_LEN, play_game__end1		# if (i >= GUESS_LEN) goto play_game__end1;
	mul	$t2, $t1, 4				# 	$t2 = i * sizeof(int);
	la	$t3, correct_solution			#	$t3 = &correct_solution
	add	$t4, $t2, $t3				#	$t4 = &correct_solution[i]
	lw	$a0, ($t4)				#	printf("%d ", correct_solution[i]);
	li	$v0, 1					#
	syscall						#
							#
	li  	$a0, ' '				#
    	li  	$v0, 11					#
    	syscall						#

	addi	$t1, $t1, 1				#	i++;
	j	play_game__loop1			# goto play_game__loop1;

play_game__end1:
	li  	$a0, '\n'					# printf("\n");
    	li  	$v0, 11					#
    	syscall						#

play_game__epilogue:
	pop	$s2					# | $s2 $v0 $a0 $ra
	pop	$v0					# | $v0 $a0 $ra
	pop	$a0					# | $a0 $ra
	pop	$ra					# | $ra
	end						# move frame pointer
	jr	$ra             			# return;




########################################################################
# .TEXT <generate_solution>
.text
generate_solution:
	# Args:     void
	# Returns:  void
	#
	# Frame:    [$ra, $a0, $v0]
	# Uses:     [$ra, $a0, $v0, $t1, $t2, $t3, $t4, $t5]
	# Clobbers: [$t1, $t2, $t4, $t5]
	#
	# Locals:
	#   - $t0: iterator (i)
	#   - $t1: int $t0 * sizeof(int) ($t0 * 4)
	#   - $t2: &correct_solution
	#   - $t3: &correct_solution[i]
	#   - $t4: int correct_solution[i]
	#
	# Structure:
	#   generate_solution
	#   -> [prologue]
	#   -> body
	#     -> loop0
	#     -> end0
	#   -> [epilogue]

generate_solution__prologue:
	begin							# move frame pointer
	push	$ra						# | $ra
	push 	$a0						# | $a0 $ra
	push	$v0						# | $v0 $a0 $ra

generate_solution__body:
	li	$t5, 0						# int i = 0;

generate_solution__loop0:
	bge	$t5, GUESS_LEN, generate_solution__end0		# if (i >= GUESS_LEN) goto generate_solution__end0;

	li	$a0, GUESS_CHOICES				#
	jal	rand						# 	$t4 = rand(GUESS_CHOICES);

	move	$t4, $v0					#

	addi	$t4, $t4, 1					#	$t4++; (rand(GUESS_CHOICES) + 1;)

	mul	$t1, $t5, 4					# 	calculate &correct_solution[i]
	la	$t2, correct_solution				#
	add	$t3, $t2, $t1					#

	sw	$t4, ($t3)					# 	store $t4 into correction_solution[i]

	addi	$t5, $t5, 1					# 	i++;
	j	generate_solution__loop0			# 	jump to generate_solution__loop0

generate_solution__end0:
	pop	$v0				# | $v0 $a0 $ra
	pop	$a0				# | $a0 $ra
	pop	$ra				# | $ra

generate_solution__epilogue:
	end					# move frame pointer
	jr	$ra             		# return;




########################################################################
# .TEXT <play_turn>
.text
play_turn:
	# Args:
	#   - $a0: int
	# Returns:
	#   - $v0: int
	#
	# Frame:    [$ra, $a0, $s0, $s1]
	# Uses:     [$a0, $v0, $s0, $s1, $v0, $t2]
	# Clobbers: [$v0, $t2]
	#
	# Locals:
	#   - $t2: int turn
	#   - $s0: int correct_place
	#   - $s1: int incorrect_place
	#
	# Structure:
	#   play_turn
	#   -> [prologue]
	#   -> body
	#     -> if0
	#     -> endif0
	#   -> [epilogue]

play_turn__prologue:
	begin						# move frame pointer
	push	$ra					# | $ra
	push	$a0					# | $a0 $ra
	push	$s0					# | $s0 $a0 $ra
	push	$s1					# | $s1 $s0 $a0 $ra
play_turn__body:
	# printf("---[ Turn %d ]---\n", turn + 1);
	move	$t2, $a0				# store turn in $t2 register
	la	$a0, turn_str_1				#
	li	$v0, 4					#
	syscall						# printf(""---[ Turn ");
							#
	addi	$t2, $t2, 1				#
	move	$a0, $t2				#
	li	$v0, 1					#
	syscall						# printf("%d", turn + 1);
							#
	la	$a0, turn_str_2				# 
	li	$v0, 4					#
	syscall						# # printf(" ]---\n", turn + 1);

    	la	$a0, enter_guess_str			# printf("Enter your guess: ");
	li	$v0, 4					#
	syscall						#

	jal	read_guess				# read_guess();
	jal	copy_solution_into_temp			# copy_solution_into_temp();

	jal	calculate_correct_place			# int correct_place = calculate_correct_place();
	move	$s0, $v0				#
	
	jal	calculate_incorrect_place		# int incorrect_place = calculate_incorrect_place();
	move	$s1, $v0				#

play_turn__if0:
	bne	$s0, GUESS_LEN, play_turn__endif0	# if ($t0 != GUESS_LEN) goto play_turn__endif0;
	la	$a0, you_win_str			# printf("You win, congratulations!\n");
	li	$v0, 4					#
	syscall						#

	li	$v0, TURN_WIN				# return TURN_WIN;
	j	play_turn__epilogue			# goto play_turn__epilogue;

play_turn__endif0:
	la	$a0, correct_place_str			# printf("Correct guesses in correct place:   %d\n", correct_place);
	li	$v0, 4					#
	syscall						#
	move	$a0, $s0				#
	li	$v0, 1					#
	syscall						#
	la	$a0, '\n'				#
	li	$v0, 11					#
	syscall						#

	la	$a0, incorrect_place_str		# printf("Correct guesses in incorrect place: %d\n", incorrect_place);
	li	$v0, 4					#
	syscall						#
	move	$a0, $s1				#
	li	$v0, 1					#
	syscall						#
	la	$a0, '\n'				#
	li	$v0, 11					#
	syscall						#

	li	$v0, TURN_NORMAL			# return TURN_NORMAL;		
play_turn__epilogue:
	pop 	$s1					# | $s1 $s0 $a0 $ra
	pop	$s0					# | $s0 $a0 $ra
	pop	$a0					# | $a0 $ra
	pop	$ra					# | $ra
	end						# move frame pointer
	jr	$ra             			# return $v0;




########################################################################
# .TEXT <read_guess>
.text
read_guess:
	# Args:     void
	# Returns:  void
	#
	# Frame:    [$a0, $v0]
	# Uses:     [$v0, $t0, $t1, $t2, $t3]
	# Clobbers: [$t0, $t1, $t2, $t3]
	#
	# Locals:
	#   - $t0: iterator (i)
	#   - $t1: int $t0 * sizeof(int) ($t0 * 4)
	#   - $t2: &current_guess
	#   - $t3: &current_guess[i]
	#
	# Structure:
	#   read_guess
	#   -> [prologue]
	#   -> body
	#     -> loop0
	#     -> end0
	#   -> [epilogue]

read_guess__prologue:
	begin						# move frame pointer
	push	$a0					# | $a0
	push	$v0					# | $v0 $a0

read_guess__body:
	li	$t0, 0					# int i = 1;

read_guess__loop0:
	bge	$t0, GUESS_LEN, read_guess__end0  	# if ($t0 >= GUESS_LEN) goto read_guess__end0;

	li	$v0, 5					#	syscall 5: read_int
        syscall						#	scanf("%d", &current_guess[i]);

        mul	$t1, $t0, 4				#	calculate &current_guess[i]
        la	$t2, current_guess			#
        add	$t3, $t1, $t2				#
        sw	$v0, ($t3)				#	store entered number in array

        addi 	$t0, $t0, 1				#	i++;
        j    	read_guess__loop0			# goto read_guess__loop0;

read_guess__end0:
read_guess__epilogue:
	pop	$v0					# | $v0 $a0
	pop	$a0					# | $a0
	end						# move frame pointer
	jr	$ra             			# return;




########################################################################
# .TEXT <copy_solution_into_temp>
.text
copy_solution_into_temp:
	# Args:     void
	# Returns:  void
	#
	# Frame:    []
	# Uses:     [$t0, $t1, $t2, $t3, $t4, $t5, $t6]
	# Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5, $t6]
	#
	# Locals:
	#   - $t0: iterator (i)
	#   - $t1: $t0 * sizeof(int) = $t0 * 4
	#   - $t2: &solution_temp
	#   - $t3: &correct_solution
	#   - $t4: &solution_temp[i]
	#   - $t5: &correct_solution[i]
	#   - $t6: correct_solution[i]
	#
	# Structure:
	#   copy_solution_into_temp
	#   -> [prologue]
	#   -> body
	#     -> loop0
	#     -> end0
	#   -> [epilogue]

copy_solution_into_temp__prologue:
	begin					# move frame pointer

copy_solution_into_temp__body:
	li	$t0, 0				# int i = 0;

copy_solution_into_temp__loop0:
	bge	$t0, GUESS_LEN, copy_solution_into_temp__end0	# if (i >= GUESS_LEN) goto end_csit0;

	mul	$t1, $t0, 4					# 	$t1 = i * sizeof(int);
	la	$t2, solution_temp				#	$t2 = &solution_temp;
	la	$t3, correct_solution				#	$t3 = &correct_solution;
	add	$t4, $t1, $t2					#	$t4 = &solution_temp[i];
	add	$t5, $t1, $t3					#	$t5 = &correct_solution[i];

	lw	$t6, ($t5)					#	Load correct_solution[i] in $t6;
	sw	$t6, ($t4)					#	Store $t6 in solution_temp[i];

	addi	$t0, $t0, 1					#	i++;
	j	copy_solution_into_temp__loop0			# goto copy_solution_into_temp__loop0;

copy_solution_into_temp__end0:
copy_solution_into_temp__epilogue:
	end					# move frame pointer
	jr	$ra            			# return;




########################################################################
# .TEXT <calculate_correct_place>
.text
calculate_correct_place:
	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    [$s0]
	# Uses:     [$s0, $v0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8]
	# Clobbers: [$v0 $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8]
	#
	# Locals:
	#   - $s0: NULL_GUESS
	#   - $t0: int guess_index (iterator)
	#   - $t1: $t0 * sizeof(int) ($t0 * 4)
	#   - $t2: &solution_temp
	#   - $t3: &current_guess
	#   - $t4: &solution_temp[i]
	#   - $t5: &current_guess[i]
	#   - $t6: solution_temp[i]
	#   - $t7: int guess = current_guess[guess_index]
	#   - $t8: total
	#
	# Structure:
	#   calculate_correct_place
	#   -> [prologue]
	#   -> body
	#     -> loop0
	#       -> if0
	#       -> endif0
	#     -> end0
	#   -> [epilogue]

calculate_correct_place__prologue:
	begin							# move frame pointer
	push 	$s0						# | $s0

calculate_correct_place__body:
	li	$t8, 0						# int total = 0;	
	li	$t0, 0						# int guess_index = 0;

calculate_correct_place__loop0:
	bge	$t0, GUESS_LEN, calculate_correct_place__end0	# if (guess_index >= GUESS_LEN) goto calculate_correct_place__end0;
	
	mul	$t1, $t0, 4					# 	$t1 = guess_index * sizeof(int);
	la	$t2, solution_temp				#	$t2 = &solution_temp;
	la	$t3, current_guess				#	$t3 = &current_guess;
	add	$t4, $t1, $t2					#	$t4 = &solution_temp[guess_index];
	add	$t5, $t1, $t3					#	$t5 = &current_guess[guess_index];

	lw	$t6, ($t4)					#	$t6 = solution_temp[guess_index];
	lw	$t7, ($t5)					#	int guess = current_guess[guess_index];

calculate_correct_place__if0:
	bne	$t6, $t7, calculate_correct_place__endif0	# 	if (guess != solution_temp[guess_index]) goto calculate_correct_place__endif0;
	addi	$t8, $t8, 1					#		total++;
	li	$s0, NULL_GUESS					#
	sw	$s0, ($t4)					#		current_guess[guess_index] = NULL_GUESS;
	sw	$s0, ($t5)					#		solution_temp[guess_index] = NULL_GUESS;

calculate_correct_place__endif0:
	addi	$t0, $t0, 1					#	guess_index++;	
	j	calculate_correct_place__loop0			# jump to calculate_correct_place__loop0;

calculate_correct_place__end0:
	move	$v0, $t8					# copy total to $v0 to return

calculate_correct_place__epilogue:
	pop	$s0						# | $s0
	end							# move frame pointer
	jr	$ra            					# return;




########################################################################
# .TEXT <calculate_incorrect_place>
.text
calculate_incorrect_place:
	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    [$s0]
	# Uses:     [$v0, $s0, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9]
	# Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9]
	#
	# Locals:
	#   - $s0: NULL_GUESS
	#   - $t0: iterator (guess_index)
	#   - $t1: guess_index * sizeof(int);
	#   - $t2: &solution_temp;
	#   - $t3: &current_guess
	#   - $t4: &solution_temp[solution_index]
	#   - $t5: &current_guess[guess_index]
	#   - $t6: solution_temp[solution_index]
	#   - $t7: guess = current_guess[guess_index]
	#   - $t8: total
	#   - $t9: solution_index
	#
	# Structure:
	#   calculate_incorrect_place
	#   -> [prologue]
	#   -> body
	#     -> loop0
	#       -> if0
	#         -> loop1
	#           -> if1
	#           -> endif1
	#	  -> end1
	#       -> endif0
	#     -> end0
	#   -> [epilogue]

calculate_incorrect_place__prologue:
	begin								# move frame pointer
	push	$s0							# | $s0

calculate_incorrect_place__body:
	li	$t8, 0							# int total = 0;	
	li	$t0, 0							# int guess_index = 0;

calculate_incorrect_place__loop0:
	bge	$t0, GUESS_LEN, calculate_incorrect_place__end0		# if (guess_index >= GUESS_LEN) goto calculate_incorrect_place__end0;

	mul	$t1, $t0, 4						# 	$t1 = guess_index * sizeof(int);
	la	$t3, current_guess					#	$t3 = &current_guess;
	add	$t5, $t1, $t3						#	$t5 = &current_guess[guess_index];
	lw	$t7, ($t5)						#	int guess = current_guess[guess_index];

calculate_incorrect_place__if0:
	beq	$t7, NULL_GUESS, calculate_incorrect_place__endif0	# 	if ($t7 == NULL_GUESS) goto calculate_incorrect_place__endif0;
	li	$t9, 0							#		int solution_index = 0;

calculate_incorrect_place__loop1:
	bge 	$t9, GUESS_LEN, calculate_incorrect_place__end1		# 		if (guess_index >= GUESS_LEN) goto calculate_incorrect_place__end0;

calculate_incorrect_place__if1:
	la	$t2, solution_temp					#			$t2 = &solution_temp;
	mul	$t1, $t9, 4						#			$t1 = solution_index * sizeof(int)
	add	$t4, $t1, $t2						#			$t4 = &solution_temp[solution_index];
	lw	$t6, ($t4)						#			$t6 = solution_temp[solution_index];
	
	bne	$t6, $t7, calculate_incorrect_place__endif1		# 			if $t0 != $t1 then target

	addi	$t8, $t8, 1						#				solution_index++;
	li	$s0, NULL_GUESS						#
	sw	$s0, ($t4)						#				current_guess[solution_index] = NULL_GUESS;
	j	calculate_incorrect_place__end1				# 				goto calculate_incorrect_place__end1;

calculate_incorrect_place__endif1:
	addi	$t9, $t9, 1						# 				total++;

	j	calculate_incorrect_place__loop1			# 	jump to calculate_incorrect_place__loop1

calculate_incorrect_place__end1:
calculate_incorrect_place__endif0:
	addi	$t0, $t0, 1						#	guess_index++;
	j	calculate_incorrect_place__loop0			# jump to calculate_incorrect_place__loop0

calculate_incorrect_place__end0:
	move	$v0, $t8						# store $t0 in return register ($v0)

calculate_incorrect_place__epilogue:
	pop	$s0							# | $s0
	end								# move frame pointer
	jr	$ra             					# return;




########################################################################
####                                                                ####
####        STOP HERE ... YOU HAVE COMPLETED THE ASSIGNMENT!        ####
####                                                                ####
########################################################################

##
## The following are two utility functions, provided for you.
##
## You don't need to modify any of the following.
## But you may find it useful to read through.
## You'll be calling these functions from your code.
##


########################################################################
# .DATA
# DO NOT CHANGE THIS DATA SECTION
.data

# int random_seed;
.align 2
random_seed:		.space 4


########################################################################
# .TEXT <seed_rand>
# DO NOT CHANGE THIS FUNCTION
.text
seed_rand:
	# Args:
	#   - $a0: unsigned int seed
	# Returns: void
	#
	# Frame:    []
	# Uses:     [$a0, $t0]
	# Clobbers: [$t0]
	#
	# Locals:
	# - $t0: offline_seed
	#
	# Structure:
	#   seed_rand

	li	$t0, OFFLINE_SEED # const unsigned int offline_seed = OFFLINE_SEED;
	xor	$t0, $a0          # random_seed = seed ^ offline_seed;
	sw	$t0, random_seed

	jr	$ra               # return;




########################################################################
# .TEXT <rand>
# DO NOT CHANGE THIS FUNCTION
.text
rand:
	# Args:
	#   - $a0: unsigned int n
	# Returns:
	#   - $v0: int
	#
	# Frame:    []
	# Uses:     [$a0, $v0, $t0]
	# Clobbers: [$v0, $t0]
	#
	# Locals:
	# - $t0: random_seed
	#
	# Structure:
	#   rand

	lw	$t0, random_seed  # unsigned int rand = random_seed;
	multu	$t0, 0x5bd1e995   # rand *= 0x5bd1e995;
	mflo	$t0
	addiu	$t0, 12345        # rand += 12345;
	sw	$t0, random_seed  # random_seed = rand;

	remu	$v0, $t0, $a0     # rand % n
	jr	$ra               # return;
