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
#include "interrupts.h"
#include "sprite.h"

	.arm
	.align
	.text
	.global initLevelClear
	.global levelClear
		
initLevelClear:										@ set up the level clear data

	stmfd sp!, {r0-r10, lr}	

	bl stopTimer3
	
	mov r0,#0
	ldr r1,=isItARecord
	str r0,[r1]

	@ first, remove willy
	mov r1,#0
	ldr r2,=spriteActive+256
	str r1,[r2]

	ldr r0,=gameMode
	mov r1,#GAMEMODE_LEVEL_CLEAR
	str r1,[r0]
	
	ldr r0,=levelEndTimer
	ldr r1,=450		
	str r1,[r0]
	
	ldr r1,=spriteActive		@ Close the door
	mov r0,#63					@ use the 63rd sprite
	mov r2,#EXIT_CLOSED			@ Stop door anim
	str r2,[r1,r0,lsl#2]
	mov r3,#DOOR_FRAME
	ldr r1,=spriteObj
	str r3,[r1,r0,lsl#2]
	ldr r1,=spritePriority
	mov r3,#1
	str r3,[r1,r0,lsl#2]
	
	bl fxStarburstInit
	
	bl playLevelEnd
	
	@ if this is a bonus level, we need to check the timer and see if we have a record!
	
	ldr r0,=levelNum
	ldr r0,[r0]
	sub r0,#1
	ldr r1,=levelTypes
	ldr r1,[r1,r0,lsl#2]
	cmp r1,#2
	bne notABonusLevel
	
		@ ok, bonus level
		
		ldr r0,=cheat2Mode
		ldr r0,[r0]
		cmp r0,#1
		beq notABonusLevel		@ no records for cheaters! (turbo mode)
	
		bl checkBonusTimer
	
	notABonusLevel:
	
	@ ok, check if this is a completion level and add 1000pts per life left!
	
	cmp r1,#1
	beq gameComplete
	cmp r1,#3
	bne gameNotComplete
		
		gameComplete:
	
		ldr r1,=levelStartFrom
		ldr r1,[r1]
		cmp r1,#1
		beq completeBonus
		cmp r1,#23
		bne gameNotComplete
		
		completeBonus:
			
			ldr r1,=minerLives
			ldr r1,[r1]
			ldr r2,=adder+2
			strb r1,[r2]
			bl addScore
			bl playFanFare
			bl drawScore
	
	gameNotComplete:
	
	bl saveGame
	
	ldmfd sp!, {r0-r10, pc}	
@-----------------------------------------------

levelClear:											@ do the level clear stuff

	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=levelEndTimer
	ldr r10,[r0]
	
	levelClearLoop:
	
		bl swiWaitForVBlank	
		ldr r0,=cheat2Mode
		ldr r0,[r0]
		cmp r0,#1
		beq cheatClear
		ldr r0,=levelNum
		ldr r0,[r0]
		cmp r0,#21
		beq cheatClear
		ldr r0,=minerDelay
		ldr r1,[r0]
		add r1,#1
		cmp r1,#2
		moveq r1,#0
		str r1,[r0]
		bne skipFrameClear
			cheatClear:
			bl monsterMove
			bl scoreAir
		skipFrameClear:	
	
		bl drawSprite
		bl levelAnimate	
		bl drawScore
		bl updateSpecialFX	
		bl drawAir	
	
		bl fxMoveStarburst
		
		@ only if a bonus record
		
		ldr r1,=isItARecord
		ldr r1,[r1]
		cmp r1,#1
		bne notRecordFlash
		ldr r1,=lightningFlash
		ldr r0,[r1]
		subs r0,#1
		movmi r0,#0
		str r0,[r1]
		ldr r2,=BLEND_Y
		str r0,[r2]
		ldr r0, =BLEND_CR
		ldr r1, =(BLEND_FADE_WHITE | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3)
		strh r1, [r0]
		notRecordFlash:
		
	subs r10,#1
	bpl levelClearLoop

	@ if we are on the last level and going to completion, we need a full fade

	ldr r10,=levelTypes
	ldr r1,=levelNum
	ldr r1,[r1]
	sub r1,#1
	ldr r1,[r10,r1,lsl#2]
	cmp r1,#0
	bleq fxFadeBlackLevelInit
	blne fxFadeBlackInit

	bl fxFadeMin
	bl fxFadeOut

	justWait:

		bl swiWaitForVBlank	
		ldr r0,=cheat2Mode
		ldr r0,[r0]
		cmp r0,#1
		beq cheatClear1
		ldr r0,=levelNum
		ldr r0,[r0]
		cmp r0,#21
		beq cheatClear1
		ldr r0,=minerDelay
		ldr r1,[r0]
		add r1,#1
		cmp r1,#2
		moveq r1,#0
		str r1,[r0]
		bne skipFrameClear1
			cheatClear1:
			bl monsterMove
			bl scoreAir
		skipFrameClear1:	
	
		bl drawSprite
		bl levelAnimate	
		bl updateSpecialFX	

		ldr r1,=fxFadeBusy
		ldr r1,[r1]
		cmp r1,#0
	bne justWait
	
	bl levelNext
	
	ldmfd sp!, {r0-r10, pc}		
	
@-----------------------------------------------	
	
scoreAir:											@ reduce Air and score it

	stmfd sp!, {r0-r10, lr}		

	ldr r1,=air
	ldr r2,[r1]
	subs r2,#1
	movmi r2,#0
	str r2,[r1]
	bmi scoreAirDone
	
		ldr r4,=levelBank
		ldr r5,=levelNum
		ldr r5,[r5]
		sub r5,#1
		ldr r4,[r4,r5,lsl#2]
		cmp r4,#2
		movne r4,#3			
		moveq r4,#6
		ldr r5,=adder+5
		strb r4,[r5]
		bl addScore

	scoreAirDone:

	ldmfd sp!, {r0-r10, pc}

@-----------------------------------------------	
	
checkBonusTimer:

	stmfd sp!, {r0-r10, lr}	
	
	bl displayBonusTimer

	ldr r1,=gotRecord
	mov r0,#0
	str r0,[r1]

	ldr r1,=levelNum
	ldr r1,[r1]
	sub r1,#1
	ldr r2,=levelForTimer
	ldr r0,[r2,r1,lsl#2]
	mov r1,#12
	mul r0,r1				@ r0= offset from records (0-1-2-3-4-)
	ldr r8,=levelRecords
	add r8,r0				@ r8 points to mins
	mov r9,r8

	mov r5,#0
	ldr r1,=bMin
	ldr r1,[r1]
	ldr r3,=1000000
	mul r1,r3
	add r5,r1
	ldr r1,=bSec
	ldr r1,[r1]
	ldr r3,=10000
	mul r1,r3
	add r5,r1
	ldr r1,=bMil
	ldr r1,[r1]
	add r5,r1	@ r5=our time

	mov r6,#0
	ldr r1,[r8]
	ldr r3,=1000000
	mul r1,r3
	add r6,r1
	add r8,#4
	ldr r1,[r8]
	ldr r3,=10000
	mul r1,r3
	add r6,r1
	add r8,#4
	ldr r1,[r8]
	add r6,r1	@ r6=record

	cmp r5,r6
	bge notARecord

		@ ok, this is a record, copy to new record and display
	
		mov r3,r9
		ldr r1,=bMin
		ldr r1,[r1]
		str r1,[r3]
		mov r10,r1
		mov r7,#0
		mov r11,#14
		mov r9,#2
		mov r8,#1
		bl drawDigitsB
	
		add r3,#4
		ldr r1,=bSec
		ldr r1,[r1]
		str r1,[r3]	
		mov r10,r1
		mov r7,#0
		mov r11,#17
		mov r9,#2
		mov r8,#1
		bl drawDigitsB
	
		add r3,#4
		ldr r1,=bMil
		ldr r1,[r1]
		str r1,[r3]
		mov r10,r1
		mov r7,#0
		mov r11,#20
		mov r9,#3
		mov r8,#1
		bl drawDigitsB
	
		bl displayBonusTimer

		@ ok, now we need to do something to make a noise and signal success!!

		@ cLEAR TEXT

		ldr r1, =BG_MAP_RAM(BG0_MAP_BASE)
		add r1,#(32*2)*5
		mov r0,#0
		ldr r2,=(32*2)*12
		bl dmaFillWords
	
		@ DRAW RECORD TEXT (well done - a speed-run record)
	
		ldr r0,=BG_MAP_RAM(BG3_MAP_BASE)
		add r0,#(64*28)						@ r0=src
		ldr r1,=BG_MAP_RAM(BG3_MAP_BASE)
		add r1,#(64*7)
		add r1,#(6*2)						@ r1=dest
		mov r2,#20*2						@ len
		mov r3,#8
		recordTextLoop:
			bl dmaCopy
			add r1,#64
			add r0,#64
			subs r3,#1
		bpl recordTextLoop
	
		mov r8,#17
		ldr r1,=lightningFlash
		str r8,[r1]
	
		mov r0,#1
		ldr r1,=isItARecord
		str r0,[r1]

		ldr r1,=gotRecord
		mov r0,#1
		str r0,[r1]

		bl saveGame

	notARecord:

	ldmfd sp!, {r0-r10, pc}

	.pool
	.data
	
	levelEndTimer:
		.word 0
	lightningFlash:
		.word 0
	isItARecord:
		.word 0