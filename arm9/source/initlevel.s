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

	.arm
	.align
	.text

	.global initLevel

initLevel:
	
	@ This will be used to set level specifics, ie. colmap, initial x/y, facing etc...

	stmfd sp!, {r0-r10, lr}
	
	bl clearOAM
	bl clearSpriteData
	bl specialFXStop

	mov r0,#1
	ldr r1,=spriteActive+256
	str r0,[r1]

	mov r0,#0
	ldr r1,=spriteObj+256
	str r0,[r1]

	mov r0,#1
	ldr r1,=spritePriority+256
	str r0,[r1]
	
	mov r0,#0
	ldr r1,=spriteAnimDelay+256
	str r0,[r1]
	ldr r1,=minerAction
	str r0,[r1]
	ldr r1,=minerDied
	str r0,[r1]

	bl generateColMap
	
	ldr r1,=levelData
	ldr r2,=levelNum
	ldr r2,[r2]
	sub r2,#1
	add r1,r2, lsl #6				@ add r1, level number *64, r1 is now the base for the level
	
	ldrb r0,[r1],#1
	add r0,#64
	ldr r2,=exitX
	str r0,[r2]

	ldrb r0,[r1],#1
	add r0,#384
	ldr r2,=exitY
	str r0,[r2]	

	ldrb r0,[r1],#1
	mov r3,r0
	and r3,#7
	ldr r2,=keyCounter
	str r3,[r2]
	ldr r2,=musicPlay
	lsr r0,#4
	str r0,[r2]

	ldrb r0,[r1],#1
	add r0,#64
	ldr r2,=spriteX+256
	str r0,[r2]	

	ldrb r0,[r1],#1
	add r0,#384
	ldr r2,=spriteY+256
	str r0,[r2]	

	ldrb r0,[r1],#1
	mov r3,r0
	and r3,#7
	ldr r2,=spriteHFlip+256
	str r3,[r2]	
	ldr r2,=minerDirection
	str r3,[r2]
	lsr r0,#4
	ldr r2,=specialEffect
	str r0,[r2]
	
	ldrb r0,[r1],#1			@ Background number
	bl getLevelBackground

	ldrb r0,[r1],#1			@ Door number
	bl getDoorSprite
	
	bl generateMonsters		@ r1 is the pointer to the first monsters data
	
	bl drawLevel			@ Display the level graphics
	
	bl levelStory			@ Display the games story in the bottom screen
	
	bl levelMusic			@ start the music
	
	ldr r0,=specialEffect
	ldr r0,[r0]
	cmp r0,#FX_RAIN
		bleq rainInit
	cmp r0,#FX_STARS
		bleq starsInit
	cmp r0,#FX_LEAVES
		bleq leafInit
	@ etc
	
	ldmfd sp!, {r0-r10, pc}

	@ ------------------------------------

clearSpriteData:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =spriteDataStart
	ldr r1, =spriteDataEnd								@ Get the sprite data end
	ldr r2, =spriteDataStart							@ Get the sprite data start
	sub r1, r2											@ sprite end - start = size
	bl DC_FlushRange
	
	mov r0, #0
	ldr r1, =spriteDataStart
	ldr r2, =spriteDataEnd								@ Get the sprite data end
	ldr r3, =spriteDataStart							@ Get the sprite data start
	sub r2, r3											@ sprite end - start = size
	bl dmaFillWords	

	ldmfd sp!, {r0-r3, pc}
	
	@ ------------------------------------

generateColMap:

	stmfd sp!, {r0-r10, lr}
	
	@ generate the colmapstore based on the levelNum
	
	ldr r0,=levelNum
	ldr r5,[r0]
	@ colmap is 768*level -1
	sub r5,#1
	mov r2,#768
	mul r5,r2
	ldr r0,=colMapLevels
	add r0,r5
	ldr r1,=colMapStore
	mov r2,#768
	@ r0,=src, r1=dst, r2=len
	bl dmaCopy
	
	ldmfd sp!, {r0-r10, pc}

	@ ------------------------------------

getDoorSprite:

	stmfd sp!, {r0-r10, lr}
	cmp r0,#0
	ldreq r0, =Exit01Tiles
	ldreq r2, =Exit01TilesLen
	cmp r0,#1
	ldreq r0, =Exit02Tiles
	ldreq r2, =Exit02TilesLen
	cmp r0,#2
	ldreq r0, =Exit03Tiles
	ldreq r2, =Exit03TilesLen	
	
	@ sprite images 16-23 are for the door and its animation (door is 9th sprite)
	ldr r1, =SPRITE_GFX
	add r1, #(16*256)
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	add r1, #(16*256)
	bl dmaCopy

	@ now we need to add it to the screen
	ldr r1,=spriteActive
	mov r0,#63				@ use the 63rd sprite
	mov r2,#EXIT_CLOSED
	str r2,[r1,r0,lsl#2]
	ldr r3,=exitX
	ldr r3,[r3]
	ldr r1,=spriteX
	str r3,[r1,r0,lsl#2]
	ldr r3,=exitY
	ldr r3,[r3]
	ldr r1,=spriteY
	str r3,[r1,r0,lsl#2]
	mov r3,#DOOR_FRAME
	ldr r1,=spriteObj
	str r3,[r1,r0,lsl#2]
	mov r3,#0
	ldr r1,=spriteHFlip
	str r3,[r1,r0,lsl#2]
	mov r3,#4
	ldr r1,=spriteAnimDelay
	str r3,[r1,r0,lsl#2]
	
	
	ldmfd sp!, {r0-r10, pc}

	@ ------------------------------------

getLevelBackground:

	stmfd sp!, {r0-r10, lr}
	cmp r0,#0
	ldreq r4,=Background01Tiles
	ldreq r5,=Background01TilesLen
	ldreq r6,=Background01Map
	ldreq r7,=Background01MapLen
	cmp r0,#1
	ldreq r4,=Background02Tiles
	ldreq r5,=Background02TilesLen
	ldreq r6,=Background02Map
	ldreq r7,=Background02MapLen
	cmp r0,#2
	ldreq r4,=Background03Tiles
	ldreq r5,=Background03TilesLen
	ldreq r6,=Background03Map
	ldreq r7,=Background03MapLen
	cmp r0,#3
	ldreq r4,=Background04Tiles
	ldreq r5,=Background04TilesLen
	ldreq r6,=Background04Map
	ldreq r7,=Background04MapLen
	cmp r0,#4
	ldreq r4,=Background05Tiles
	ldreq r5,=Background05TilesLen
	ldreq r6,=Background05Map
	ldreq r7,=Background05MapLen
	cmp r0,#5
	ldreq r4,=Background06Tiles
	ldreq r5,=Background06TilesLen
	ldreq r6,=Background06Map
	ldreq r7,=Background06MapLen
	cmp r0,#6
	bgt noLevelBackground
@	ldreq r4,=Background07Tiles
@	ldreq r5,=Background07TilesLen
@	ldreq r6,=Background07Map
@	ldreq r7,=Background07MapLen
	@ Draw main game map!
	mov r0,r4
	ldr r1, =BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	mov r2,r5
	bl dmaCopy
	mov r0,r6
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	add r1,#384
	mov r2,r7
	bl dmaCopy
	
	noLevelBackground:

	ldmfd sp!, {r0-r10, pc}

	@ ------------------------------------
generateMonsters:

	stmfd sp!, {r0-r10, lr}
	
	@ just set up a dummy monster for now!
	
	@ r9 = loop for the 7 monsters that can be used per level
	@ using sprites 65-71
	
	mov r9,#65
	
	gmLoop:
		mov r0,#0
		ldr r2,=monsterDelay
		str r0,[r2,r9,lsl#2]
		ldrb r0,[r1],#1			@ monster x, if 0, no more monsters
		cmp r0,#0
		beq generateMonstersDone
		ldr r2,=spriteActive
		mov r3,#1
		str r3,[r2,r9,lsl#2]	@ activate sprite
		add r0,#64
		ldr r2,=spriteX
		str r0,[r2,r9,lsl#2]	@ store x coord	
		ldrb r0,[r1],#1	
		add r0,#384
		ldr r2,=spriteY
		str r0,[r2,r9,lsl#2]	@ store y coord		
		ldrb r0,[r1],#1			@ dirs... HHHHLLLL h=initial dir l=facing (hflip)
		mov r3,r0
		and r3,#7				@ r3=facing (keep lowest 4 bits)
		ldr r2,=spriteHFlip
		str r3,[r2,r9,lsl#2]
		lsr r0,#4				@ r0=init dir (highest 4 bits)
		ldr r2,=spriteDir
		str r0,[r2,r9,lsl#2]

		ldrb r5,[r1],#1			@ r0=monster movement direction (lowest 4 bits)
		mov r3,r5				@ use r5 later for min/max
		and r5,#7
		ldr r2,=spriteMonsterMove
		str r5,[r2,r9,lsl#2]
		lsr r3,#4
		ldr r2,=spriteMonsterFlips
		str r3,[r2,r9,lsl#2]
		
		ldrb r0,[r1],#1			@ r0=speed
		ldr r2,=spriteSpeed
		str r0,[r2,r9,lsl#2]

		ldrb r0,[r1],#1			@ r0=monster to use from spriteBank (0-?)
		ldr r2,=spriteObjBase	@ objbase tells us what sprite to dma (+anim stage)	
		str r0,[r2,r9,lsl#2]

		ldr r2,=spriteObj
		mov r3,r9				@ r3=number of the alien 1-8
		add r3,#7
		str r3,[r2,r9,lsl#2]	@ store monster number for the sprite Object (8+)

		cmp r5,#0
		movne r5,#64			@ offset for l/r movement
		moveq r5,#384			@ offset for u/d movement
		ldrb r0,[r1],#1			@ r0=min coord
		add r0,r5
		ldr r2,=spriteMin
		str r0,[r2,r9,lsl#2]
		ldrb r0,[r1],#1			@ r0=max coord
		add r0,r5
		ldr r2,=spriteMax
		str r0,[r2,r9,lsl#2]

	add r9,#1
	cmp r9,#72
	bne gmLoop
	
	generateMonstersDone:

	ldmfd sp!, {r0-r10, pc}

@-----------------

	levelMusic:
	stmfd sp!, {r0-r10, lr}	
	
	ldr r0,=musicPlay
	ldr r0,[r0]
	
	cmp r0,#0
	ldreq r1, =Miner_xm
	cmp r0,#1
	ldreq r1, =Dark_xm


	
	bl initMusic
	
	ldmfd sp!, {r0-r10, pc}
	.pool
	.end
