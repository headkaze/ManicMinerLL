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
	.global initSprites
	.global initTitleSprites
	.global initTitlePointer
	.global initAudioSprites
	.global initBonusSprites
	.global clearOAM
	
initSprites:

	stmfd sp!, {r0-r10, lr}
	
	ldr r0, =SpritesPal
	ldr r2, =512
	ldr r1, =SPRITE_PALETTE_SUB
	bl dmaCopy

	@ Write the tile data to VRAM

	ldr r0, =SpritesTiles
	ldr r2, =SpritesTilesLen
	ldr r1, =SPRITE_GFX_SUB
	bl dmaCopy
	
	ldmfd sp!, {r0-r10, pc}
	
	@ --------------------------------------
	
initTitleSprites:

	stmfd sp!, {r0-r10, lr}
	
	bl clearOAM

	ldr r0, =ATTR0_DISABLED			@ Set OBJ_ATTRIBUTE0 to ATTR0_DISABLED
	ldr r1, =OAM
	ldr r2, =1024					@ 3 x 16bit attributes + 16 bit filler = 8 bytes x 128 entries in OAM
	bl dmaFillWords
	
	ldr r0, =TitleSpritesPal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =512
	bl dmaCopy
	ldr r0, =TitleSpritesTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =TitleSpritesTilesLen
	bl dmaCopy
	
	ldr r0,=OBJ_ATTRIBUTE0(0)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#160
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(0)
	ldr r2, =(ATTR1_SIZE_16)
	@mov r2,#0					@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(0)
	mov r2,#0
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE0(1)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#160					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(1)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#240					@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(1)
	mov r2,#1
	lsl r2,#3
	strh r2,[r0]
	
	@ seal pt1
	
	ldr r0,=OBJ_ATTRIBUTE0(3)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#76					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(3)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#168-26				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(3)
	mov r2,#11
	lsl r2,#3
	strh r2,[r0]
	
	@ seal pt2

	ldr r0,=OBJ_ATTRIBUTE0(5)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#92					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(5)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#100+26				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(5)
	mov r2,#11
	lsl r2,#3
	strh r2,[r0]	
	
	ldmfd sp!, {r0-r10, pc}
	
	@ --------------------------------------
	
initTitlePointer:

	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=gameMode
	ldr r1,[r1]
	cmp r1,#GAMEMODE_TITLE_SCREEN
	bne noPointerUpdate
	
	ldr r0,=OBJ_ATTRIBUTE0(2)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	ldr r1,=pointerY
	ldr r1,[r1]
	lsl r1,#4
	add r1,#41
	orr r2,r1					@y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(2)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#12					@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(2)
	ldr r2,=pointerFrame
	ldr r2,[r2]
	add r2,#2					@ object
	lsl r2,#3
	strh r2,[r0]
	
	noPointerUpdate:

	ldmfd sp!, {r0-r10, pc}
	
	@ --------------------------------------
	
clearOAM:

	stmfd sp!, {r0-r6, lr}
	
	@ Clear the OAM (disable all 128 sprites for both screens)
	
	ldr r1,=gameMode
	ldr r1,[r1]
	cmp r1,#GAMEMODE_TITLE_SCREEN

	ldr r0, =ATTR0_DISABLED			@ Set OBJ_ATTRIBUTE0 to ATTR0_DISABLED
	ldr r1, =OAM
	ldr r2, =1024					@ 3 x 16bit attributes + 16 bit filler = 8 bytes x 128 entries in OAM
	blne dmaFillWords
	ldr r1, =OAM_SUB
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}

	@ --------------------------------------
	
initAudioSprites:

	stmfd sp!, {r0-r10, lr}
	
	ldr r1,=gameMode
	ldr r1,[r1]
	cmp r1,#GAMEMODE_AUDIO
	bne noPointerAUpdate
	
	ldr r0,=OBJ_ATTRIBUTE0(0)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(0)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#14					@ x
	mov r3,#1
	lsl r3,#12
	orr r2,r3
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(0)
	ldr r2,=2					@ sprite Used + frame
	lsl r2,#3
	strh r2,[r0]
	
	ldr r0, =AudioSpritesPal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =512
	bl dmaCopy
	ldr r0, =AudioSpritesTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =AudioSpritesTilesLen
	bl dmaCopy	
	
	noPointerAUpdate:

	ldmfd sp!, {r0-r10, pc}
	
	@ --------------------------------------
	
initBonusSprites:

	stmfd sp!, {r0-r10, lr}
	
	ldr r0, =SpritesPal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =512
	bl dmaCopy
	ldr r0, =BonusSpriteTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =BonusSpriteTilesLen
	bl dmaCopy
	
	ldr r0,=OBJ_ATTRIBUTE0(0)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#8					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(0)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#224				@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(0)
	mov r2,#0
	strh r2,[r0]
	
	ldr r0,=OBJ_ATTRIBUTE0(1)
	ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
	orr r2,#8+16					@ y
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE1(1)
	ldr r2, =(ATTR1_SIZE_16)
	orr r2,#224			@ x
	strh r2,[r0]
	ldr r0,=OBJ_ATTRIBUTE2(1)
	mov r2,#1
	lsl r2,#3
	strh r2,[r0]

	ldmfd sp!, {r0-r10, pc}