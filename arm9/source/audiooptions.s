@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"), to deal in the Software without restriction, including
@ without limitation the rights to use, copy, modify, merge, publish,
@ distribute, sublicense, and/or sell copies of the Software, and to
@ permit persons to whom the Software is furnished to do so, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
@ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
@ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
@ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
@ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
@ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
@ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "mmll.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"
#include "audio.h"

	.global initAudio
	.global updateAudio
	
	.arm
	.align
	.text

@------------------------------------------------
	
initAudio:

	stmfd sp!, {r0-r10, lr}
	
	mov r1, #GAMEMODE_AUDIO
	ldr r2, =gameMode
	str r1,[r2]
	
	bl fxOff
	bl specialFXStop
	bl clearOAM	
	bl clearBG0									@ Clear bgs
	bl clearBG1
	bl clearBG2
	bl clearBG3

	bl initVideoTitle
	bl initSprites
	bl clearSpriteData
	
	bl stopMusic
	
	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn

	@ draw top and bottom screens
	
	ldr r0,=AudioTopTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	ldr r2,=AudioTopTilesLen
	bl decompressToVRAM	
	ldr r0, =AudioTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r2, =AudioTopMapLen
	bl dmaCopy
	ldr r0, =AudioTopPal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =AudioTopPalLen
	bl dmaCopy

	ldr r0,=AudioBottomTiles							@ copy the tiles used for title
	ldr r1,=BG_TILE_RAM(BG3_TILE_BASE)
	ldr r2,=AudioBottomTilesLen
	bl decompressToVRAM	
	ldr r0, =AudioBottomMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ destination
	ldr r2, =AudioBottomMapLen
	bl dmaCopy
	ldr r0, =AudioBottomPal
	ldr r1, =BG_PALETTE
	ldr r2, =AudioBottomPalLen
	bl dmaCopy

	ldr r0,=AudioBarsTiles							@ copy the tiles used for audio bars
	ldr r1,=BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2,=AudioBarsTilesLen
	bl decompressToVRAM	
	
	@ set vars first
	mov r0,#0
	ldr r1,=audioPointer
	str r0,[r1]
	ldr r1,=audioPlaying
	str r0,[r1]	
	ldr r1,=audioPointerDelay
	str r0,[r1]	
	ldr r1,=audioPointerFrame
	str r0,[r1]	

	mov r0,#1
	ldr r1,=moveTrap
	str r0,[r1]

	
	bl drawAudioText
	bl drawAudioBars
	bl initAudioSprites
	bl updateAudioPointer
	bl playSelectedAudio

	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------
	
updateAudio:

	stmfd sp!, {r0-r10, lr}
	
	bl swiWaitForVBlank
	
	@ er, do stuff here!
	
	
	bl moveAudioPointer
	bl drawAudioText
	bl drawSprite
	bl updateAudioPointer

	ldr r0,=REG_KEYINPUT						@ Read key input register
	ldr r10,[r0]								@ Read key value
	tst r10,#BUTTON_START
	beq audioStartPressed
	tst r10,#BUTTON_A
	beq audioStartPressed	
	
	audioStartReturn:
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------
audioStartPressed:

	ldr r0,=audioPointer
	ldr r0,[r0]
	cmp r0,#3
	bne audioStartReturn

	mov r0,#1
	ldr r1,=moveTrap
	str r0,[r1]
	ldr r1,=trapStart
	str r0,[r1]
	
	bl clearOAM	
	bl initVideoTitle
	bl initSprites
	bl clearSpriteData
	
	bl stopMusic
	
	bl fxFadeBlackLevelInit
	bl fxFadeMax
	bl fxFadeIn

	bl initTitleScreen

	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------

drawAudioText:

	stmfd sp!, {r0-r10, lr}
	
	ldr r0,=audioVT						@ game vol
	mov r1,#4
	mov r2,#10
	bl drawTextBigMain

	add r2,#2
	ldr r0,=audioMT						@ music on off
	mov r1,#7
	bl drawTextBigMain	

	add r2,#2
	ldr r0,=audioPT						@ now playing
	mov r1,#10
	bl drawTextBigMain	

	@ diplay name of tune, use audioPlaying for offset

	add r2,#2	
	ldr r4,=audioPlaying
	ldr r4,[r4]
	mov r5,#27
	mul r4,r5
	ldr r0,=audioNames
	add r0,r4
	mov r1,#3
	bl drawTextBigMain	
	
	add r2,#2
	ldr r0,=audioET						@ exit
	mov r1,#7
	bl drawTextBigMain	
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------

updateAudioPointer:
	@ draw pointer at correct position and animate
	stmfd sp!, {r0-r10, lr}
	
	ldr r3,=audioPointerFrame
	ldr r0,=audioPointerDelay
	ldr r1,[r0]
	subs r1,#1
	movmi r1,#4
	str r1,[r0]
	bpl updateAudioPointerDone
		ldr r4,[r3]
		add r4,#1
		cmp r4,#8
		moveq r4,#0
		str r4,[r3]
	updateAudioPointerDone:

	ldr r4,[r3]

	ldr r0,=audioPointer			@ 0-2
	ldr r0,[r0]
	ldr r1,=audioPointerY
	ldrb r2,[r1,r0]					@ r2=y coord
	ldr r0,=OBJ_ATTRIBUTE0(0)
	ldr r3, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r3,r2
	strh r3,[r0]	
	ldr r0,=OBJ_ATTRIBUTE2(0)
	mov r1,#0
	orr r1,r4, lsl #3				@ or r1 with sprite pointer *16 (for sprite data block)
	strh r1, [r0]					@ store it all back
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------
	
playSelectedAudio:

	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=audioPlaying
	ldr r1,[r1]
	ldr r2,=audioTuneList
	ldrb r0,[r2,r1]
	
	bl levelMusicPlayEasy
	
	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------
moveAudioPointer:

	stmfd sp!, {r0-r10, lr}

	ldr r0,=REG_KEYINPUT						@ Read key input register
	ldr r10,[r0]								@ Read key value
	tst r10,#BUTTON_UP
	beq movePointerUD
	tst r10,#BUTTON_DOWN
	beq movePointerUD	
	tst r10,#BUTTON_LEFT
	beq moveAlter
	tst r10,#BUTTON_RIGHT
	beq moveAlter

		ldr r1,=trapStart	
		mov r0,#0
		str r0,[r1]
		ldr r1,=moveTrap	
		mov r0,#0
		str r0,[r1]
		b moveAPointerDone1	
	
	moveAPointerDone:
	
	bl moveTimer
	
	moveAPointerDone1:
	
	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

movePointerUD:
	ldr r0,=moveTrap
	ldr r1,[r0]
	cmp r1,#0
	bne moveAPointerDone
	
	tst r10,#BUTTON_UP
	bne movePointerD
		@up
		ldr r1,=audioPointer
		ldr r2,[r1]
		subs r2,#1
		movmi r2,#0
		str r2,[r1]
		b moveAPointerDone
	
	movePointerD:
		@dn
		ldr r1,=audioPointer
		ldr r2,[r1]
		add r2,#1
		cmp r2,#4
		moveq r2,#3
		str r2,[r1]
		b moveAPointerDone

@-------------------------------------------------

moveTimer:

	stmfd sp!, {r0-r10, lr}

	ldr r1,=moveTrap	
	ldr r0,[r1]
	add r0,#1
	cmp r0,#POINTER_DELAY
	moveq r0,#0
	str r0,[r1]

	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

moveAlter:
	ldr r0,=moveTrap
	ldr r1,[r0]
	cmp r1,#0
	bne moveAPointerDone

	ldr r0,=audioPointer
	ldr r0,[r0]
	cmp r0,#2
	bne notTune
	
		@ alter Music playing
	
		tst r10,#BUTTON_RIGHT
		bne movePointerL
		
			@R
			ldr r0,=audioPlaying
			ldr r1,[r0]
			add r1,#1
			ldr r2,=audioTuneList
			ldrb r3,[r2,r1]
			cmp r3,#255
			beq moveAPointerDone
			str r1,[r0]
			mov r0,r3
			bl levelMusicPlayEasy
			b moveAPointerDone
	
		movePointerL:
			@L
			ldr r0,=audioPlaying
			ldr r1,[r0]
			subs r1,#1
			bmi moveAPointerDone
			ldr r2,=audioTuneList
			ldrb r3,[r2,r1]
			str r1,[r0]
			mov r0,r3
			bl levelMusicPlayEasy
			b moveAPointerDone	
	notTune:
	cmp r0,#0
	bne notVol
		@ alter SFX Volume
	
	
	b moveAPointerDone
	notVol:
	cmp r0,#1
	bne notMusicOn
		@ turn on/off ingame musc
	
	
	b moveAPointerDone	
	notMusicOn:
	
	
	b moveAPointerDone
@-------------------------------------------------

drawAudioBars:

	@ draw bars based on audioSFXVol 0-7

	stmfd sp!, {r0-r10, lr}
	
	ldr r4,=audioSFXVol
	ldr r4,[r4]							@ r4=volume
	mov r3,#14							@ 14 tiles per bar
	mul r4,r3
	lsl r4,#1							@ 2 bytes per char
	
	ldr r0, =BG_MAP_RAM(BG1_MAP_BASE)
	add r0,r4							@ r0 = source

	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)	@ r1 = destination

@	ldr r0, =AudioBarsMap
@	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)	@ destination
@	ldr r2, =AudioBottomMapLen
@	bl dmaCopy

	ldmfd sp!, {r0-r10, pc}

@-------------------------------------------------

.pool
.data
.align
moveTrap:
	.word 0
audioPointer:					@ pointer value 0-3
	.word 0
audioPointerFrame:
	.word 0
audioPointerDelay:
	.word 0
audioPlaying:					@ what tune?
	.word 0	
.align
audioPointerY:					@ pointer Y values
	.byte 81,97,113,145
audioTuneList:					@ values of the tunes for r0, 0-? (end with 255)
	.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,64,255
audioVT:
	.asciz	"SFX GAME VOLUME: ADDBARS"		@ 24
audioMT:
	.asciZ	"IN GAME MUSIC: ON "			@ 18
	.asciz	"IN GAME MUSIC: OFF"
audioPT:
	.asciz	"SELECT  TUNE"				@ 12
audioNames:					@ names of all the tunes in order of audioTuneList offset (0-?)
	.asciz	"MINER WILLY'S MINING SONG!"	@ 26+1
	.asciz	"  ON A DARK MINING NIGHT  "
	.asciz	"MINER WILLY, SPACE EXPORER"
	.asciz	" THE PHARAOH'S LITTLE JIG "
	.asciz	"    WILLY'S LITTLE RAG    "
	.asciz	"    SMITHS EAR BLEEDER    "
	.asciz	"     AS TIME GOES BY.     "
	.asciz	"      DOWN THE ALLEY      "
	.asciz	" THE MIGHTY JUNGLE BEASTS "
	.asciz	"PLAYING LIVE A THE CAVERN!"
	.asciz	"   THE ODDNESS OF BEING   "
	.asciz	"   REGGIE LIKE'S REGGAE   "
	.asciz	"    TIME TO TERMINATE!    "
	.asciz	" THE 80'S WILL NEVER DIE! "
	.asciz	"   SIT DOWN RAY PARKER!   "
	.asciz	"THERE'S A CHUNK IN MY EYE!"
	.asciz	" SCREAM AND SCREAM AGAIN! "
	.asciz	"HOBNAIL BOOTS, AND TOP HAT"
	.asciz	" THE MICROWAVE GOES 'POP' "
	.asciz	"   TOP OF THE WORLD MA!   "
	.asciz	"AND SOMEONE MENTIONED YES!"
	.asciz	"     A SOMBRE MOMENT.     "
	.asciz	"                          "
	.asciz	"                          "
	.asciz	"                          "
	.asciz	"                          "
	.asciz	"                          "
	.asciz	"                          "
	.asciz	"                          "
	.asciz	"                          "	

audioET:
	.asciz "EXIT AUDIO OPTIONS"				@ 18

@ call levelMusicPlayEasy with r0 to set to the tune to play	