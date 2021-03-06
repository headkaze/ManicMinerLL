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

#include "MMLL.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"

	#define burstFrameStart		40
	#define burstFrameEnd		47
	#define burstAnimDelay		4
	#define bloodAnimDelay		12	
	.arm
	.align
	.text

	.global fxStarburstInit
	.global fxMoveStarburst
	.global fxSplashburstInit
	.global fxMoveSplashburst
	.global fxBloodburstInit
	.global fxMoveBloodburst
	.global fxBonusburstInit
	.global fxBonusSpray
	.global fxSparkleInit
	.global fxSparkle
	
fxStarburstInit:

	stmfd sp!, {r0-r11, lr}

	ldr r1,=burstLength
	ldr r0,=220
	str r0,[r1]

	ldr r4, =spriteX
	ldr r5, =spriteY
	ldr r6, =spriteSpeed
	ldr r11, =spriteDir
	ldr r9,=spriteActive
	ldr r10,=spriteObj
	ldr r12,=spritePriority
	ldr r7,=0x1ff
	ldr r1,=0x8ff

	mov r3,#127							@ amount of stars
	starburstloopMulti:
	
		ldr r8,[r9, r3, lsl#2]
		cmp r8,#0
		bne starburstLoopSkip
	
		ldr r8,=exitX
		ldr r8,[r8]

		lsl r8,#12
		str r8, [r4, r3, lsl #2]						@ Store X
		ldr r8,=exitY
		ldr r8,[r8]
		lsl r8,#12
		str r8, [r5, r3, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction (we need from a range that only goes up)
		and r8, #127									
		add r8,#320
		str r8, [r11, r3, lsl #2]

		bl getRandom									@ generate speed
		ldr r1,=0x7ff
		and r8, r1	
		add r8,#2048
		str r8, [r6, r3, lsl #2] 						@ Store Speed
		
		mov r8,#FX_STARBURST_ACTIVE						@ sprite active
		str r8, [r9, r3, lsl #2]
		
		bl getRandom
		and r8,#0x7
		add r8,#burstFrameStart							@ obj
		str r8, [r10,r3, lsl #2]
		
		mov r8,#2										@ priority
		str r8, [r12,r3, lsl #2]
		
		ldr r1,=spriteMax+0								@ time to live!
		bl getRandom
		lsr r8,#12
		add r8,#0x20000
		str r8,[r1, r3, lsl #2]

		ldr r1,=spriteMin+0								@ time to live!
		bl getRandom
		and r8,#127
		str r8,[r1, r3, lsl #2]

		ldr r1,=spriteAnimDelay+0
		mov r8,#burstAnimDelay
		str r8,[r1, r3, lsl #2]
		
		starburstLoopSkip:

		subs r3, #1	
	bpl starburstloopMulti

	ldmfd sp!, {r0-r11, pc}
	
	@ ---------------------------------------

fxMoveStarburst:
	stmfd sp!, {r0-r12, lr}

	ldr r4, =spriteSpeed
	ldr r2, =spriteX
	ldr r3, =spriteY
	
	mov r10,#127
	
moveStarburstLoop:
	ldr r0,=spriteActive+0
	ldr r0,[r0, r10, lsl #2]
	cmp r0,#FX_STARBURST_ACTIVE
	bne burstSkip
	
	ldr r0,=spriteDir+0
	ldr r0,[r0, r10, lsl #2]
	lsl r0,#1
	ldr r7,=COS_bin
	ldrsh r7, [r7,r0]								@ r7= 16bit signed cos
	ldr r8,=SIN_bin
	ldrsh r8, [r8,r0]								@ r8= 16bit signed sin

	ldr r6, [r4, r10, lsl #2] 						@ R6 now holds the speed of the star

	ldr r0, [r2, r10, lsl #2]						@ r0 is now X coord value					MOVE X
	muls r9,r6,r7									@ mul cos by speed
	add r0,r9, asr #12								@ add to x

	cmp r0,#(32<<12)
	blt burstRegenerate
	cmp r0,#(320<<12)
	bge burstRegenerate
	
	str r0, [r2,r10, lsl #2]
			
	ldr r1, [r3, r10, lsl #2]						@ r1 now holds the Y coord of the star		MOVE Y
	muls r9,r6,r8
	add r1,r9, asr #12								@ add to Y coord (signed)
	
	@ now add gravity to y
	
	ldr r7,=spriteMin+0								@ add to gravity
	ldr r5,[r7, r10, lsl #2]
	add r5,#32

	str r5,[r7, r10, lsl #2]
	add r1,r5
	
	cmp r1,#(400<<12)
	blt burstRegenerate
	cmp r1,#(576<<12)
	movge r1,#(576<<12)

	str r1, [r3, r10, lsl #2]						@ store y 20.12
	
	ldr r7,=spriteMax+0
	ldr r1,[r7, r10, lsl #2]
	subs r1,r6
	subs r1,r5
	str r1,[r7, r10, lsl #2]
	bmi burstRegenerate
	
	burstOver:
	
	@ animate
	ldr r7,=spriteAnimDelay+0
	ldr r6,[r7, r10, lsl #2]
	subs r6,#1
	movmi r6,#burstAnimDelay
	str r6,[r7, r10, lsl #2]
	bpl burstSkip
	
		ldr r7,=spriteObj+0
		ldr r6,[r7,r10,lsl#2]
		add r6,#1
		cmp r6,#burstFrameEnd+1
		moveq r6,#burstFrameStart
		str r6,[r7,r10,lsl#2]
	
	burstSkip:

	subs r10, #1									@ count down the number of starSpeed
	bpl moveStarburstLoop
	
	ldr r1,=burstLength
	ldr r0,[r1]
	subs r0,#1
	movmi r0,#0
	str r0,[r1]

	ldmfd sp!, {r0-r12, pc}

burstRegenerate:

		ldr r8,=burstLength
		ldr r8,[r8]
		cmp r8,#0
		ldreq r8,=spriteActive+0
		moveq r7,#0
		streq r7,[r8,r10,lsl#2]
		beq burstOver

		ldr r8,=exitX
		ldr r8,[r8]
		lsl r8,#12
		str r8, [r2, r10, lsl #2]						@ Store X
		ldr r8,=exitY
		ldr r8,[r8]
		lsl r8,#12
		str r8, [r3, r10, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction
		and r8, #127
		add r8, #320
		ldr r0,=spriteDir+0
		str r8, [r0, r10, lsl #2]

		bl getRandom									@ generate speed
		ldr r6,=0x7ff
		and r8, r6	
		add r8,#2048
		ldr r0,=spriteSpeed+0
		str r8, [r0, r10, lsl #2] 						@ Store Speed

		ldr r0,=spriteMax+0							@ time to live!
		bl getRandom
		lsr r8,#12
		add r8,#0x60000
		str r8,[r0, r10, lsl #2]

		ldr r0,=spriteMin+0							@ gravity
		bl getRandom
		and r8,#127
		str r8,[r0, r10, lsl #2]
	
	b burstSkip

@----------------------------------------							WATER SPLASHES!!!

fxSplashburstInit:

	stmfd sp!, {r0-r11, lr}

	ldr r4, =spriteX
	ldr r5, =spriteY
	ldr r6, =spriteSpeed
	ldr r11,=spriteDir
	ldr r9, =spriteActive
	ldr r10,=spriteObj
	ldr r12,=spritePriority
	ldr r7,=0x1ff
	ldr r1,=0x8ff

	mov r3,#127							@ amount of stars
	splashburstloopMulti:
	
		ldr r8,[r9, r3, lsl#2]
		cmp r8,#0
		bne splashburstLoopSkip
	
		bl getRandom
		and r8,#0xff
		lsr r8,#3
		mov r7,#3
		mul r8,r7
		add r8,#80+64

		lsl r8,#12
		str r8, [r4, r3, lsl #2]						@ Store X

		mov r8,#384
		add r8,#166
		lsl r8,#12
		str r8, [r5, r3, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction (we need from a range that only goes up)
		and r8, #127										@ 0-511
		add r8,#320
		str r8, [r11, r3, lsl #2]

		bl getRandom									@ generate speed
		ldr r1,=0x7ff
		and r8, r1	
		add r8,#1024
		str r8, [r6, r3, lsl #2] 						@ Store Speed
		
		mov r8,#FX_STARBURST_ACTIVE						@ sprite active
		str r8, [r9, r3, lsl #2]
		
		bl getRandom
		and r8,#0x7
		add r8,#burstFrameStart							@ obj
		str r8, [r10,r3, lsl #2]
		
		mov r8,#2										@ priority
		str r8, [r12,r3, lsl #2]
		
		ldr r1,=spriteMax+0							@ time to live!
		bl getRandom
		lsr r8,#12
		add r8,#0x20000
		str r8,[r1, r3, lsl #2]

		ldr r1,=spriteMin+0							@ time to live!
		bl getRandom
		and r8,#127
		str r8,[r1, r3, lsl #2]

		ldr r1,=spriteAnimDelay+0
		add r8,#burstAnimDelay
		str r8,[r1, r3, lsl #2]
		
		splashburstLoopSkip:

		subs r3, #1	
	bpl splashburstloopMulti

	ldmfd sp!, {r0-r11, pc}
	
	@ ---------------------------------------

fxMoveSplashburst:
	stmfd sp!, {r0-r12, lr}

	ldr r4, =spriteSpeed
	ldr r2, =spriteX
	ldr r3, =spriteY
	
	mov r10,#127
	
moveSplashburstLoop:
	ldr r0,=spriteActive+0
	ldr r0,[r0, r10, lsl #2]
	cmp r0,#FX_STARBURST_ACTIVE
	bne splashSkip
	
	ldr r0,=spriteDir+0
	ldr r0,[r0, r10, lsl #2]
	lsl r0,#1
	ldr r7,=COS_bin
	ldrsh r7, [r7,r0]								@ r7= 16bit signed cos
	ldr r8,=SIN_bin
	ldrsh r8, [r8,r0]								@ r8= 16bit signed sin

	ldr r6, [r4, r10, lsl #2] 						@ R6 now holds the speed of the star

	ldr r0, [r2, r10, lsl #2]						@ r0 is now X coord value					MOVE X
	muls r9,r6,r7									@ mul cos by speed
	add r0,r9, asr #12								@ add to x

	cmp r0,#(32<<12)
	blt splashRegenerate
	cmp r0,#(320<<12)
	bge splashRegenerate
	
	str r0, [r2,r10, lsl #2]
			
	ldr r1, [r3, r10, lsl #2]						@ r1 now holds the Y coord of the star		MOVE Y
	muls r9,r6,r8
	add r1,r9, asr #12								@ add to Y coord (signed)
	
	@ now add gravity to y
	
	ldr r7,=spriteMin+0							@ add to gravity
	ldr r5,[r7, r10, lsl #2]
	add r5,#32

	str r5,[r7, r10, lsl #2]
	add r1,r5
	
	cmp r1,#(400<<12)
	blt splashRegenerate
	cmp r1,#(576<<12)
	movge r1,#(576<<12)

	str r1, [r3, r10, lsl #2]						@ store y 20.12
	
	ldr r7,=spriteMax+0
	ldr r1,[r7, r10, lsl #2]
	subs r1,r6
	subs r1,r5
	str r1,[r7, r10, lsl #2]
	bmi splashRegenerate
	
	splashOver:
	
	@ animate
	ldr r7,=spriteAnimDelay+0
	ldr r6,[r7, r10, lsl #2]
	subs r6,#1
	movmi r6,#burstAnimDelay
	str r6,[r7, r10, lsl #2]
	bpl splashSkip
	
		ldr r7,=spriteObj+0
		ldr r6,[r7,r10,lsl#2]
		add r6,#1
		cmp r6,#burstFrameEnd+1
		moveq r6,#burstFrameStart
		str r6,[r7,r10,lsl#2]
	
	splashSkip:

	subs r10, #1									@ count down the number of starSpeed
	bpl moveSplashburstLoop

	ldmfd sp!, {r0-r12, pc}

splashRegenerate:

		ldreq r8,=spriteActive+0
		mov r7,#0
		str r7,[r8,r10,lsl#2]
	b splashSkip
	
@------------------------------------------------------- blood splats	

fxBloodburstInit:

	stmfd sp!, {r0-r11, lr}

	ldr r1,=burstLength
	ldr r0,=220
	str r0,[r1]

	ldr r4, =spriteX
	ldr r5, =spriteY
	ldr r6, =spriteSpeed
	ldr r11, =spriteDir
	ldr r9,=spriteActive
	ldr r10,=spriteObj
	ldr r12,=spritePriority
	ldr r7,=0x1ff
	ldr r1,=0x8ff

	mov r3,#127							@ amount of splats
	bloodburstloopMulti:
	
		ldr r8,[r9, r3, lsl#2]
		cmp r8,#0
		bne bloodburstLoopSkip
	
		ldr r7,=exitX
		ldr r7,[r7]
		bl getRandom
		and r8,#7
		subs r8,#4
		adds r8,r7

		lsl r8,#12
		str r8, [r4, r3, lsl #2]						@ Store X
		ldr r8,=exitY
		ldr r8,[r8]
		lsl r8,#12
		str r8, [r5, r3, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction (we need from a range that only goes up)
		and r8, #127										@ 320-448 (
		add r8,#320
		str r8, [r11, r3, lsl #2]

		bl getRandom									@ generate speed
		ldr r1,=0xfff
		and r8, r1	
		add r8,#4096
		str r8, [r6, r3, lsl #2] 						@ Store Speed
		
		mov r8,#FX_STARBURST_ACTIVE						@ sprite active
		str r8, [r9, r3, lsl #2]
		
		mov r8,#burstFrameStart
		str r8, [r10,r3, lsl #2]
		
		mov r8,#2										@ priority
		str r8, [r12,r3, lsl #2]
		
		ldr r1,=spriteMax+0							@ time to live!
		bl getRandom
		and r8,#127
		add r8,#16
		str r8,[r1, r3, lsl #2]

		ldr r1,=spriteMin+0							@ gravity!
		bl getRandom
		and r8,#127
		str r8,[r1, r3, lsl #2]

		ldr r1,=spriteAnimDelay+0
		bl getRandom
		and r8,#15		
		add r8,#bloodAnimDelay
		str r8,[r1, r3, lsl #2]

		ldr r1,=spriteHFlip
		bl getRandom
		and r8,#1
		str r8,[r1, r3, lsl #2]

		ldr r1,=spritePriority
		mov r8,#1
		str r8,[r1, r3, lsl #2]
		
		bloodburstLoopSkip:

		subs r3, #1	
	bpl bloodburstloopMulti

	ldmfd sp!, {r0-r11, pc}
	
	@ ---------------------------------------

fxMoveBloodburst:
	stmfd sp!, {r0-r12, lr}

	ldr r4, =spriteSpeed
	ldr r2, =spriteX
	ldr r3, =spriteY
	
	mov r10,#127
	
moveBloodburstLoop:
	ldr r0,=spriteActive+0
	ldr r0,[r0, r10, lsl #2]
	cmp r0,#FX_STARBURST_ACTIVE
	bne bloodBurstSkip
	
	ldr r0,=spriteDir+0
	ldr r0,[r0, r10, lsl #2]
	lsl r0,#1
	ldr r7,=COS_bin
	ldrsh r7, [r7,r0]								@ r7= 16bit signed cos
	ldr r8,=SIN_bin
	ldrsh r8, [r8,r0]								@ r8= 16bit signed sin

	ldr r6, [r4, r10, lsl #2] 						@ R6 now holds the speed of the star

	ldr r0, [r2, r10, lsl #2]						@ r0 is now X coord value					MOVE X
	muls r9,r6,r7									@ mul cos by speed
	add r0,r9, asr #12								@ add to x

	cmp r0,#(32<<12)
	blt bloodBurstRegenerate
	cmp r0,#(320<<12)
	bge bloodBurstRegenerate
	
	str r0, [r2,r10, lsl #2]
			
	ldr r1, [r3, r10, lsl #2]						@ r1 now holds the Y coord of the star		MOVE Y
	muls r9,r6,r8
	add r1,r9, asr #12								@ add to Y coord (signed)
	
	@ now add gravity to y
	
	ldr r7,=spriteMin+0							@ add to gravity
	ldr r5,[r7, r10, lsl #2]
	add r5,#64

	str r5,[r7, r10, lsl #2]
	add r1,r5
	
	cmp r1,#(400<<12)
	blt bloodBurstRegenerate
	cmp r1,#(576<<12)
	movge r1,#(576<<12)

	str r1, [r3, r10, lsl #2]						@ store y 20.12
	
	ldr r7,=spriteMax+0
	ldr r1,[r7, r10, lsl #2]
	subs r1,#1
	str r1,[r7, r10, lsl #2]
	bmi bloodBurstRegenerate
	
	bloodBurstOver:
	
	@ animate
	ldr r7,=spriteAnimDelay+0
	ldr r6,[r7, r10, lsl #2]
	subs r6,#1
	movmi r6,#bloodAnimDelay
	str r6,[r7, r10, lsl #2]
	bpl bloodBurstSkip
	
		ldr r7,=spriteObj+0
		ldr r6,[r7,r10,lsl#2]
		add r6,#1
		str r6,[r7,r10,lsl#2]
		cmp r6,#burstFrameEnd+1
		moveq r6,#burstFrameEnd
		str r6,[r7,r10,lsl#2]
		beq  bloodBurstRegenerate
	
	bloodBurstSkip:
	
	ldr r0,=spriteActive+0
	ldr r0,[r0, r10, lsl #2]
	cmp r0,#255
	bne bloodBurstSkip2

		@ make drips fall
		
		ldr r0,=spriteY
		ldr r1,[r0,r10,lsl#2]
		ldr r5,=spriteMonster
		ldr r6,[r5,r10,lsl#2]
		add r1,r6
		str r1,[r0,r10,lsl#2]

	bloodBurstSkip2:

	subs r10, #1									@ count down the number of starSpeed
	bpl moveBloodburstLoop
	
	ldr r1,=burstLength
	ldr r0,[r1]
	subs r0,#1
	movmi r0,#0
	str r0,[r1]

	ldmfd sp!, {r0-r12, pc}

bloodBurstRegenerate:

ldr r8,=spriteActive
ldr r7,[r8,r10,lsl#2]
cmp r7,#255
beq bloodBurstSkip
mov r7,#255
str r7,[r8,r10,lsl#2]

ldr r7,=spriteMonster
bl getRandom
and r8,#0xff
add r8,#512
str r8,[r7,r10,lsl#2]
b bloodBurstSkip

@------------------------------------------------------- bonusSplay	

fxBonusburstInit:

	stmfd sp!, {r0-r12, lr}

	mov r3,r1
	lsr r3,#5			@ divide by 32, this is now the y area (0-23)
	
	mov r4,r1
	and r4,#31			@ r4 is now the x area (0-31)
	lsl r4,#3			@ r4=x
	lsl r3,#3			@ r3=y

	@ r4=x r3=y

	mov r1,r4
	mov r2,r3
	add r1,#64-4
	add r2,#384-4
	lsl r1,#12
	lsl r2,#12

	ldr r4, =spriteX
	ldr r5, =spriteY
	ldr r6, =spriteSpeed
	ldr r9,=spriteActive
	ldr r10,=spriteObj
	ldr r11, =spriteDir
	ldr r12,=spritePriority

	mov r3,#127											@ amount of sprays
	bonusburstloopMulti:
	
		ldr r8,[r9, r3, lsl#2]
		cmp r8,#0
		bne bonusburstLoopSkip
	
		str r1, [r4, r3, lsl #2]						@ Store X
		str r2, [r5, r3, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction
		ldr r7,=0x1ff
		and r8, r7									
		str r8, [r11, r3, lsl #2]

		bl getRandom									@ generate speed
		ldr r7,=0x7ff
		and r8, r7	
		add r8,#1024
		str r8, [r6, r3, lsl #2] 						@ Store Speed
		
		mov r8,#FX_BONUS								@ sprite active
		str r8, [r9, r3, lsl #2]
		
		mov r8,#burstFrameStart
		str r8, [r10,r3, lsl #2]
		
		mov r8,#2										@ priority
		str r8, [r12,r3, lsl #2]

		ldr r7,=spriteAnimDelay+0
		add r8,#BONUS_ANIM
		str r8,[r7, r3, lsl #2]

		ldr r7,=spriteHFlip
		bl getRandom
		and r8,#1
		str r8,[r7, r3, lsl #2]
		
		bonusburstLoopSkip:

		subs r3, #1	
	bpl bonusburstloopMulti

	ldmfd sp!, {r0-r12, pc}

@------------------------------------------------------- update bonusSplay	

fxBonusSpray:

	stmfd sp!, {r0-r12, lr}
	
	@ r10 = offset

	ldr r4, =spriteSpeed
	ldr r2, =spriteX
	ldr r3, =spriteY
		
	ldr r0,=spriteDir
	ldr r0,[r0, r10, lsl #2]
	lsl r0,#1
	ldr r7,=COS_bin
	ldrsh r7, [r7,r0]								@ r7= 16bit signed cos
	ldr r8,=SIN_bin
	ldrsh r8, [r8,r0]								@ r8= 16bit signed sin

	ldr r6, [r4, r10, lsl #2] 						@ R6 now holds the speed of the star

	ldr r0, [r2, r10, lsl #2]						@ r0 is now X coord value					MOVE X
	muls r9,r6,r7									@ mul cos by speed
	add r0,r9, asr #12								@ add to x

	cmp r0,#(32<<12)
	blt bonusBurstRegenerate
	cmp r0,#(320<<12)
	bge bonusBurstRegenerate
	
	str r0, [r2,r10, lsl #2]
			
	ldr r1, [r3, r10, lsl #2]						@ r1 now holds the Y coord of the star		MOVE Y
	muls r9,r6,r8
	add r1,r9, asr #12								@ add to Y coord (signed)
	
	cmp r1,#(400<<12)
	blt bonusBurstRegenerate
	cmp r1,#(576<<12)
	movge r1,#(576<<12)

	str r1, [r3, r10, lsl #2]						@ store y 20.12
	
	@ animate
	ldr r7,=spriteAnimDelay+0
	ldr r6,[r7, r10, lsl #2]
	subs r6,#1
	movmi r6,#BONUS_ANIM
	str r6,[r7, r10, lsl #2]
	bpl bonusBurstSkip
	
		ldr r7,=spriteObj+0
		ldr r6,[r7,r10,lsl#2]
		add r6,#1
		str r6,[r7,r10,lsl#2]
		cmp r6,#burstFrameEnd+1
		beq  bonusBurstRegenerate
	
	bonusBurstSkip:
	
	ldmfd sp!, {r0-r12, pc}

bonusBurstRegenerate:

ldr r8,=spriteActive
mov r7,#0
str r7,[r8,r10,lsl#2]

ldmfd sp!, {r0-r12, pc}

@------------------------------------------------------- bonusSplay	

fxSparkleInit:

	stmfd sp!, {r0-r12, lr}

	ldr r1,=spriteX
	ldr r1,[r1]
	bl getRandom
	and r8,#7
	subs r8,#3
	add r1,r8
	
	ldr r2,=spriteY
	ldr r2,[r2]
	add r2,#8

	lsl r1,#12
	lsl r2,#12

	ldr r4, =spriteX
	ldr r5, =spriteY
	ldr r6, =spriteSpeed
	ldr r9,=spriteActive
	ldr r3,=spriteObj
	ldr r11, =spriteDir
	ldr r12,=spritePriority

	bl anySpareSpriteFX
	cmp r10,#0
	beq sparkleGenerateDone
		
		str r1, [r4, r10, lsl #2]						@ Store X
		mov r8,#FX_SPARKLE								@ sprite active
		str r8, [r9, r10, lsl #2]
		mov r8,#0										@ priority
		str r8, [r12,r10, lsl #2]
		mov r8,#SPARKLE_FRAME
		str r8, [r3,r10, lsl #2]
		ldr r7,=spriteAnimDelay
		add r8,#SPARKLE_ANIM
		str r8,[r7, r10, lsl #2]
		ldr r7,=spriteMin								@ gravity
		mov r8,#0
		str r8,[r7, r10, lsl #2]
		
		ldr r8,=cursorAction
		ldr r0,[r8]
		cmp r0,#1
		beq sparkleUp
		cmp r0,#2
		beq sparkleDown

		sparkleUpQuit:

		str r2, [r5, r10, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction
		and r8,#255
		str r8, [r11, r10, lsl #2]

		bl getRandom									@ generate speed
		ldr r7,=0x7ff
		and r8, r7	
		add r8,#128
		str r8, [r6, r10, lsl #2] 						@ Store Speed

	sparkleGenerateDone:

	ldmfd sp!, {r0-r12, pc}
	
sparkleUp:
	bl getRandom
	and r8,#31
	cmp r8,#6
	ble sparkleUpQuit
	sub r2,#(16<<12)
	str r2, [r5, r10, lsl #2] 						@ Store Y
	
	bl getRandom
	and r8,#255
	add r8,#256
	str r8,[r11,r10,lsl#2]		@ direction
	mov r8,#-256
	subs r8,#256
	ldr r5,=spriteMin
	str r8,[r5,r10,lsl#2]		@ gravity
	bl getRandom
	ldr r1,=0xfff
	and r8,r1
	add r8,#1024
	str r8,[r6,r10,lsl#2]

b 	sparkleGenerateDone

sparkleDown:
	str r2, [r5, r10, lsl #2] 						@ Store Y
	bl getRandom
	and r8,#63
	add r8,#64+32
	str r8,[r11,r10,lsl#2]		@ direction
	mov r8,#64
	ldr r5,=spriteMin
	str r8,[r5,r10,lsl#2]		@ gravity
	bl getRandom
	ldr r1,=0x1ff
	and r8,r1
	add r8,#512
	str r8,[r6,r10,lsl#2]

b 	sparkleGenerateDone

@------------------------------------------------------- update bonusSplay	

fxSparkle:

	stmfd sp!, {r0-r12, lr}
	
	@ r10 = offset

	ldr r4, =spriteSpeed
	ldr r2, =spriteX
	ldr r3, =spriteY
		
	ldr r0,=spriteDir
	ldr r0,[r0, r10, lsl #2]
	lsl r0,#1
	ldr r7,=COS_bin
	ldrsh r7, [r7,r0]								@ r7= 16bit signed cos
	ldr r8,=SIN_bin
	ldrsh r8, [r8,r0]								@ r8= 16bit signed sin

	ldr r6, [r4, r10, lsl #2] 						@ R6 now holds the speed of the star

	ldr r0, [r2, r10, lsl #2]						@ r0 is now X coord value					MOVE X
	muls r9,r6,r7									@ mul cos by speed
	add r0,r9, asr #12								@ add to x

	cmp r0,#(32<<12)
	blt sparkleRegenerate
	cmp r0,#(320<<12)
	bge sparkleRegenerate
	
	str r0, [r2,r10, lsl #2]
			
	ldr r1, [r3, r10, lsl #2]						@ r1 now holds the Y coord of the star		MOVE Y
	muls r9,r6,r8
	add r1,r9, asr #12								@ add to Y coord (signed)

	@ now add gravity to y
	
	ldr r7,=spriteMin							@ add to gravity
	ldr r5,[r7, r10, lsl #2]
	bl getRandom
	and r8,#63
	add r8,#32
	add r5,r8
	str r5,[r7, r10, lsl #2]
	cmp r5,#0
	addpl r1,r5
	
	cmp r1,#(576<<12)
	bge sparkleRegenerate

	str r1, [r3, r10, lsl #2]						@ store y 20.12
	
	@ animate
	ldr r7,=spriteAnimDelay+0
	ldr r6,[r7, r10, lsl #2]
	subs r6,#1
	movmi r6,#SPARKLE_ANIM
	str r6,[r7, r10, lsl #2]
	bpl sparkleSkip
	
		ldr r7,=spriteObj+0
		ldr r6,[r7,r10,lsl#2]
		add r6,#1
		cmp r6,#SPARKLE_FRAME_END+1
		moveq r6,#SPARKLE_FRAME
		str r6,[r7,r10,lsl#2]
	
	sparkleSkip:
	
	ldmfd sp!, {r0-r12, pc}

sparkleRegenerate:

	ldr r8,=spriteActive
	mov r7,#0
	str r7,[r8,r10,lsl#2]

	ldmfd sp!, {r0-r12, pc}

	.data
	.align

	burstLength:
	.word 0