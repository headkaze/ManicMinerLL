@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"),  the rights to use, copy, modify, merge, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software both source and
@ the compiled code.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
@ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
@ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
@ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
@ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
@ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
@ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "mmll.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "sprite.h"

	.arm
	.align
	.text
	
	.global checkLeft
	.global checkRight
	.global checkFeet
	.global checkHead
	.global checkCollectDie
	.global checkHeadDie
	.global initDeath
	.global checkFall
	.global checkExit
	.global checkBlocked
	.global switchClear
	
@----------------------- We are moving LEFT, we need to check what we collide into in colMapStore	
@ detection functions should return a value in r9 and r10 to signal a result
@ also, are we going to need another check for killing things? or will these do? time will tell...
@--------------------- Check moving left

checkLeft:

	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0
	
	@ first, top portion
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkLeftTNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	@ This will now relate to top 8 pixel portion (head)
	subs r1,#384				@ our offset
	add r1,#4
	bmi checkLeftTNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	@ ok, r0,r1= actual screen pixels now.
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r9,r5					@ store value for return
	
	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie
	
	checkLeftTNot:				@ now bottom section	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkLeftBNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8		
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	add r1,#4
	bmi checkLeftBNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	add r1,#1					@ add 1 char down	
	@ ok, r0,r1= actual screen pixels now.
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r10,r5					@ store value for return

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie
	
	checkLeftBNot:
	
	ldmfd sp!, {r0-r8, pc}

@--------------------- Check moving right
	
checkRight:
	
	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0
	
	@ first, top portion
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkRightTNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	@ This will now relate to top 8 pixel portion (head)
	subs r1,#384				@ our offset
	add r1,#4 
	bmi checkRightTNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r9,r5					@ store value for return

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie
	
	checkRightTNot:				@ now bottom section
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkRightBNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	add r1,#4
	bmi checkRightBNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	add r1,#1					@ add 1 char down
	@ ok, r0,r1= actual screen pixels now.	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r10,r5					@ store value for return

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie

	checkRightBNot:

	ldmfd sp!, {r0-r8, pc}
	
@----------------------------- CHECK FEET

checkFeet:

	@	This returns r9 and r10 for what is under left and right portion
	@   and must also check for conveyers, crumbles, and whatever else we need
	@ 	do we need a platform matching check? ie, make sure we are on a platform first?

	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0					@ left Var
	mov r10,#0					@ right var

	ldr r0,=spriteY+256
	ldr r0,[r0]
	and r0,#7
	cmp r0,#2
	bgt checkFeetFail

	ldr r0,=minerAction
	ldr r1,[r0]
	cmp r1,#MINER_CONVEYOR
	moveq r1,#0
	streq r1,[r0]

	@ left side first
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkFeetLNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	


	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	bmi checkFeetLNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	add r1,#2					@ add 2 charaters (16 pixels)	

cmp r0,#32
subge r1,#1

	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value
	mov r8,r3					@ store r3 in r8 (this is our offset needed for crumblers)

	mov r9,r5	
	
	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDieFeet
	
	checkFeetLNot:

	@ now right side
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkFeetRNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	bmi checkFeetRNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	add r1,#2
	@ ok, r0,r1= actual screen pixels now.	

cmp r0,#32
subge r1,#1
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value ('remember' r3 is the offset)

	mov r10,r5
	
	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDieFeet
	checkFeetRNot:
	
	@ ok, r9 and r10 relate to what is under our feet!
	@ we need to check for a crumbler
	@ this is from 5 to 11 in our colmap
	@ so, check r9 first, if this is in this range, set r8 as the x offset and call crumbler
	@ then check r10, set r8 to x offset and call crumbler
	
	push {r3,r8}

	cmp r9,#5
	blt notCrumblerL
	cmp r9,#12
	bgt notCrumblerL
		@ r8 already contains the offset 	(r9 offset)
		bl crumbler
	notCrumblerL:
	cmp r10,#5
	blt notCrumblerR
	cmp r10,#12
	bgt notCrumblerR
		@ r3 contains the offset			(r10 offset)
		mov r8,r3
		bl crumbler
	notCrumblerR:
	
	pop {r3,r8}
	
	@ Now we need to check for conveyer and act on it
	@ if on one, set minerAction and also the conveyorDirection

	cmp r9,#2
	moveq r9,#13
	beq r9OnConveyor
	cmp r9,#3
	moveq r9,#17
	beq r9OnConveyor

	cmp r9,#13
	blt feetNotLConveyor
	cmp r9,#20
	bgt feetNotLConveyor
	
	r9OnConveyor:
	mov r4,r9
	b feetOnConveyor
	
	feetNotLConveyor:
	
	cmp r10,#2
	moveq r10,#13
	beq r10OnConveyor
	cmp r10,#3
	moveq r10,#17
	beq r10OnConveyor
	cmp r10,#13
	blt feetNotRConveyor
	cmp r10,#20
	bgt feetNotRConveyor
	
	r10OnConveyor:
	mov r4,r10
	b feetOnConveyor	
	
	feetNotRConveyor:
	
	checkFeetFinish:

	@ if either r9 or r10=4, set platFours to 1 (used for ice)
	mov r11,#0
	cmp r9,#4
	moveq r11,#1
	cmp r10,#4
	moveq r11,#1
	ldr r2,=platFours
	str r11,[r2]

	checkFeetFail:

	ldmfd sp!, {r0-r8, pc}
	
feetOnConveyor:

	ldr r0,=spriteY+256						@ make sure we are on the platform nice and firmly
	ldr r0,[r0]
	and r0,#7
	cmp r0,#1
	bgt checkFeetFinish

	ldr r0,=minerAction
	mov r1,#MINER_CONVEYOR
	str r1,[r0]

	cmp r4,#15
	movle r3,#MINER_LEFT
	movgt r3,#MINER_RIGHT					@ set conveyor direction
	cmp r4,#19
	moveq r3,#MINER_LEFT
	cmp r4,#20
	moveq r3,#MINER_RIGHT

	ldr r1,=conveyorDirection
	str r3,[r1]
	
	ldr r1,=gameType
	ldr r1,[r1]								@ if this is 1, we need to move instantly with conveyor
	cmp r1,#1
	bne checkFeetFinish
	ldr r1,=minerDirection
	str r3,[r1]
	sub r3,#1
	ldr r1,=spriteHFlip+256
	str r3,[r1]

	b checkFeetFinish
	
@----------------------------- CHECK HEAD

checkHead:

	@	This returns r9 and r10 for what is above left and right head portion

	stmfd sp!, {r0-r8, lr}
	
	mov r9,#0
	mov r10,#0

	@ left side first
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkHeadLNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	add r1,#1
	bmi checkHeadLNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r9,r5	

	checkHeadLNot:
	
	mov r10,#0
	
	@ now right side
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	subs r0,#64					@ our offset (8 chars to left)
	bmi checkHeadRNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3					@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384				@ our offset
	add r1,#1
	bmi checkHeadRNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5				@ multiply y by 32 and store in r3
	add r3,r3,r0				@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]				@ r5=value

	mov r10,r5

	checkHeadRNot:

	ldmfd sp!, {r0-r8, pc}

@-----------------------------------------------

checkHeadDie:

	stmfd sp!, {r0-r10, lr}
	
	mov r9,#0
	mov r10,#0

	@ left side first
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#LEFT_OFFSET
	add r0,#1
	subs r0,#64						@ our offset (8 chars to left)
	bmi checkHeadDieLNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3						@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384					@ our offset
	bmi checkHeadDieLNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5					@ multiply y by 32 and store in r3
	add r3,r3,r0					@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]					@ r5=value

	mov r9,r5	

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie

	checkHeadDieLNot:
	
	mov r10,#0
	
	@ now right side
	
	@ make r0=x and r1=y
	ldr r0,=spriteX+256
	ldr r0,[r0]
	add r0,#RIGHT_OFFSET
	sub r0,#1
	subs r0,#64						@ our offset (8 chars to left)
	bmi checkHeadDieRNot			@ if offscreen - dont check (will help later I hope)
	lsr r0, #3						@ divide by 8	
	
	ldr r1,=spriteY+256
	ldr r1,[r1]
	subs r1,#384					@ our offset
	bmi checkHeadDieRNot			@ incase we are jumping off the top of screen (may need work here)
	lsr r1, #3
	
	@ ok, r0,r1= actual screen pixels now.	
	
	lsl r3,r1, #5					@ multiply y by 32 and store in r3
	add r3,r3,r0					@ r3 should now be offset from colMapStore (bytes)
	
	ldr r4,=colMapStore
	ldrb r5,[r4,r3]					@ r5=value

	mov r10,r5

	@ check for other stuff
	mov r0,r5
	mov r1,r3
	bl checkCollectDie

	checkHeadDieRNot:
	
	ldmfd sp!, {r0-r10, pc}


@--------------------------------------------
	
checkCollectDie:
	@ we need to pass this 2 things for now - the r9,r10 from detect code and also
	@ the offset value for colmapstore
	@ r0 = collide value
	@ r1 = offset
	
	stmfd sp!, {r0-r10, lr}
	
	cmp r0,#64							@ check for DEATH first!
	blt notDieThing

		ldr r3,=spriteX+256
		ldr r3,[r3]
		and r3,#7
		cmp r3,#1
		bgt dieCheck2
		cmp r3,#6
		blt dieCheck2
		
		b notDieThing
		
		dieCheck2:
		
		bl initDeath

		b checkCollectDieDone

	notDieThing:

	@ if between 24 and 31, this is a key (collectable)

	cmp r0,#24
	blt notKeyThing
	cmp r0,#31
	bgt notKeyThing

		@ We have a key, so collect it!
		
		bl collectKey 
		b checkCollectDieDone

	notKeyThing:
	
	@ ok, is it a switch? (#switch=state 0=0ff 1=on)
	
	cmp r0,#32
	blt notSwitchThing
	cmp r0,#35
	bgt notSwitchThing
	SwitchThing:
		@ 32= switch 1, 33=switch 2
		@ ok, we need to change the state of the switch to on
	
		ldr r4,=switchOn			@ are we still over the switch?
		ldr r4,[r4]
		cmp r4,#0
		bne checkCollectDieDone
	
		@ now to redraw the switch
		mov r2,#1
		bl flipSwitch
		
		b checkCollectDieDone

	notSwitchThing:
	
	cmp r0,#38
	bne notBonusThing
		@ This is a bonus activator
		
		ldr r3,=gameMode
		ldr r3,[r3]
		cmp r3,#GAMEMODE_DIES_UPDATE
		beq checkCollectDieDone
		
		ldr r3,=levelSpecialFound
		ldr r4,=levelNum
		ldr r4,[r4]
		sub r4,#1
		ldr r5,[r3,r4,lsl#2]		@ r4=1 ok, 2=already activated
		cmp r5,#2
		beq notBonusThing
		
		mov r5,#2					@ set bonus as found
		str r5,[r3,r4,lsl#2]
		ldr r5,=unlockedBonuses
		ldr r6,[r5]
		cmp r6,#255
		moveq r6,#0
		beq unlockBonus
		
		cmp r6,#SECRET_MAX			@ no more to unlock
		bge notBonusThing
	
		unlockBonus:
		
		add r6,#1
		str r6,[r5]
		
		bl bonusLevelUnlocked
		b checkCollectDieDone
		
	notBonusThing:

	checkCollectDieDone:
	ldmfd sp!, {r0-r10, pc}

@--------------------------------------------
	
checkCollectDieFeet:
	@ we need to pass this 2 things for now - the r9,r10 from detect code and also
	@ the offset value for colmapstore
	@ r0 = collide value
	@ r1 = offset
	
	stmfd sp!, {r0-r10, lr}
	
	cmp r0,#64							@ check for DEATH first!
	blt notDieThingFeet
@-----------
		@ special mod for level 32
		ldr r3,=levelNum
		ldr r3,[r3]
		cmp r3,#32
		bne level32Die
		
		ldr r3,=keyCounter
		ldr r3,[r3]
		cmp r3,#0
		beq notDieThingFeet

		level32Die:
@-----------
		ldr r3,=spriteX+256
		ldr r3,[r3]
		and r3,#7
		cmp r3,#1
		bgt dieCheckFeet2
		cmp r3,#6
		blt dieCheckFeet2
		
		b notDieThingFeet
		
		dieCheckFeet2:
		
		bl initDeath

		b checkCollectDieDone

	notDieThingFeet:

	ldr r3,=minerAction
	ldr r3,[r3]
	cmp r3,#MINER_FALL
	beq notDieThing
	cmp r3,#MINER_JUMP
	beq notDieThing

	ldmfd sp!, {r0-r10, pc}

@--------------------------------------------

initDeath:
	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=minerDied
	ldr r1,[r1]
	cmp r1,#1
	beq initDeathFailed

	ldr r1,=cheatMode
	ldr r0,[r1]
	cmp r0,#1
	moveq r0,#0
	movne r0,#1

	mov r2,#1
	ldr r1,=minerDied
	str r2,[r1]
	
	ldr r1,=minerLives
	ldr r2,[r1]
	subs r2,r0
	movmi r2,#0
	str r2,[r1]

	bl drawLives
	
	initDeathFailed:

	ldmfd sp!, {r0-r10, pc}	

@--------------------------------------------

checkFall:
	stmfd sp!, {r0-r7,r9,r10, lr}	
	
	@ call this with r9 and r10 set from a collision check
	@ and it will return r8 with 0 if fall continues and 1 if fall is over

	@ if both r9,r10 >=24 or 0 fall is ok
	
	mov r8,#0
	
	cmp r9,#0
	beq checkFall2
	cmp r9,#24
	bge checkFall2

		ldr r7,=spriteY+256				@ this is perhaps not the best way???
		ldr r6,[r7]
		and r6,#7
		cmp r6,#2			
		bgt checkFall3

	mov r8,#1

	ldmfd sp!, {r0-r7,r9,r10, pc}		
	
	checkFall2:
	cmp r10,#0
	beq checkFall3
	cmp r10,#24
	bge checkFall3

		ldr r7,=spriteY+256				@ this is perhaps not the best way???
		ldr r6,[r7]
		and r6,#7
		cmp r6,#2				
		bgt checkFall3

	mov r8,#1

	ldmfd sp!, {r0-r7,r9,r10, pc}	
	
	checkFall3:

	ldmfd sp!, {r0-r7,r9,r10, pc}

@--------------------------------------------

checkExit:
	stmfd sp!, {r0-r10, lr}	

	ldr r1,=spriteActive
	mov r0,#63				@ use the 63rd sprite
	ldr r2,[r1,r0,lsl#2]
	cmp r2,#EXIT_OPEN
	bne checkExitFail

		ldr r0,=spriteX+256
		ldr r0,[r0]
		ldr r1,=spriteY+256
		ldr r1,[r1]
		ldr r2,=exitX
		ldr r2,[r2]
		ldr r3,=exitY
		ldr r3,[r3]
		ldr r4,=minerAction
		ldr r4,[r4]
		cmp r4,#MINER_NORMAL
		moveq r5,#3
		movne r5,#13
	
		mov r5,#6
		add r0,r5
		cmp r0,r2
		sub r0,r5
		blt checkExitFail
		add r2,r5
		cmp r0,r2
		sub r2,r5
		bgt checkExitFail
		add r1,r5
		cmp r1,r3
		sub r1,r5
		blt checkExitFail
		add r3,r5
		cmp r1,r3
		sub r3,r5
		bgt checkExitFail			

		ldr r0,=gameMode
		mov r1,#GAMEMODE_LEVEL_CLEAR_INIT
		str r1,[r0]

	checkExitFail:

	ldmfd sp!, {r0-r10, pc}	

@--------------------------------------------

checkBlocked:
	stmfd sp!, {r0-r10, lr}	
	@ pass r9,r10 as 2 to check 
	@ if r9=1-3 or r10=1-3 return 1, else 0 in r11
	
	mov r11,#0
	
	cmp r9,#0
	beq checkBlock2
	cmp r9,#3
	bgt checkBlock2

	mov r11,#1
	ldmfd sp!, {r0-r10, pc}		
	
	checkBlock2:
	cmp r10,#0
	beq checkBlock3
	cmp r10,#3
	bgt checkBlock3

	mov r11,#1
	
	checkBlock3:	

	ldmfd sp!, {r0-r10, pc}	

@--------------------------------------------

switchClear:

	stmfd sp!, {r0-r10, lr}	

	ldr r0,=switchOn
	ldr r1,[r0]
	cmp r1,#0
	beq switchClearDone
	
	ldr r2,=spriteX+256
	ldr r2,[r2]
	ldr r3,=switchX
	ldr r3,[r3]
	
	add r2,#16
	cmp r2,r3
	blt switchClearAllow
	sub r2,#16
	add r3,#8
	cmp r2,r3
	bgt switchClearAllow

	ldr r2,=spriteY+256
	ldr r2,[r2]
	ldr r3,=switchY
	ldr r3,[r3]
	
	add r2,#16
	cmp r2,r3
	blt switchClearAllow
	sub r2,#16
	add r3,#8
	cmp r2,r3
	bgt switchClearAllow

	switchClearDone:

	ldmfd sp!, {r0-r10, pc}	
	
	switchClearAllow:
	
	mov r1,#0
	str r1,[r0]
	
	ldmfd sp!, {r0-r10, pc}	
	
	crumbleWait:
		.word 0