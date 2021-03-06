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
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "sprite.h"

#define BUF_ATTRIBUTE0		(0x07000000)	@ WE CAN move these back to REAL registers!!
#define BUF_ATTRIBUTE1		(0x07000002)
#define BUF_ATTRIBUTE2		(0x07000004)
#define BUF_ATTRIBUTE0_SUB	(0x07000400)
#define BUF_ATTRIBUTE1_SUB	(0x07000402)
#define BUF_ATTRIBUTE2_SUB	(0x07000404)

	.arm
	.align
	.text
	.global drawSprite
	.global drawSpriteSub
	.global spareSprite
	.global spareSpriteSub
	.global spareSpriteFX
	.global anySpareSpriteFX
	.global anySpareSpriteMonster
	
offsetMiner:
	ldr r0,=spriteHFlip				@ compensate for left sprite pos.
	ldr r0,[r0,r10,lsl #2]
	cmp r0,#0
	moveq r11,#1	
	b sprites_Draw

drawSprite:
	stmfd sp!, {r0-r12, lr}
	
	ldr r1,=spriteScreen				@ 0=draw top / 1=draw bottom
	ldr r1,[r1]
	cmp r1,#0
	ldreq r5,=BUF_ATTRIBUTE0_SUB
	ldreq r6,=BUF_ATTRIBUTE1_SUB
	ldreq r9,=BUF_ATTRIBUTE2_SUB
	ldrne r5,=BUF_ATTRIBUTE0
	ldrne r6,=BUF_ATTRIBUTE1
	ldrne r9,=BUF_ATTRIBUTE2
	
	mov r10,#127 			@ our counter for 128 sprites, do not think we need them all though	
	SLoop:

		ldr r0,=spriteActive				@ r2 is pointer to the sprite active setting
		ldr r1,[r0,r10, lsl #2]				@ add sprite number * 4
		cmp r1,#MINER_SPRITE
		beq offsetMiner						@ set offset it miner!
		mov r11,#0							@ r11=-offset for sprite
		cmp r1,#0							@ Is sprite active? (anything other than 0)
		bne sprites_Draw					@ if so, draw it!

			@ If not - kill it
			
			mov r1, #ATTR0_DISABLED			@ this should destroy the sprite
			mov r0,r5
			add r0,r10, lsl #3
			strh r1,[r0]

		b sprites_Done
	
	sprites_Draw:
	
		ldr r0,=spriteY					@ Load Y coord
		ldr r1,[r0,r10,lsl #2]			@ add ,rX for offsets
		cmp r1,#4096					@ account for floating point
		lsrge r1,#12

		@ Draw sprite to SUB screen ONLY (r1 holds Y)	
		mov r0,r5
		add r0,r10, lsl #3
		ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
		ldr r3,=SCREEN_SUB_TOP
		cmp r1,r3
		addmi r1,#256
		sub r1,r3
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1
		strh r2,[r0]
		@ Draw X
		ldr r0,=spriteX					@ get X coord mem space
		ldr r1,[r0,r10,lsl #2]			@ add ,rX for offsets
		cmp r1,#4096					@ account for floating point
		lsrge r1,#12
		cmp r1,#SCREEN_LEFT				@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#SCREEN_LEFT				@ Take 64 off our X
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		mov r0,r6
		add r0,r10, lsl #3
		ldr r2, =(ATTR1_SIZE_16)
		sub r1,r11						@ subtract offset	
		and r1,r3
		orr r2,r1
		ldr r3,=spriteHFlip
		ldr r3,[r3,r10, lsl #2]			@ load flip H
		orr r2, r3, lsl #12
		strh r2,[r0]
			@ Draw Attributes
		mov r0,r9
		add r0,r10, lsl #3
		ldr r2,=spriteObj
		ldr r3,[r2,r10, lsl #2]
		ldr r1,=spritePriority
		ldr r1,[r1,r10, lsl #2]
		lsl r1,#10						@ set priority

		orr r1,r3, lsl #3				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back

	sprites_Done:
	
		@----
		@ now we need to animate any shards/effects/bits
		@----
		ldr r8,=spriteActive
		ldr r0,[r8, r10, lsl #2]
		cmp r0,#DUST_ACTIVE						@ first, our little dust thing when you land
		bne drawnNotDust
					
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#DUST_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawnNotDust
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#DUST_FRAME_END-3
				str r2,[r1,r10,lsl #2]
				bne drawnNotDust
					ldr r1,=spriteActive
					mov r2,#0
					str r2,[r1,r10,lsl #2]
		drawnNotDust:
		cmp r0,#KEY_ACTIVE						@ now, our little key glisten
		bne drawnNotKey
						
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#KEY_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawnNotKey
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#KEY_FRAME_END+1
				str r2,[r1,r10,lsl #2]
				bne drawnNotKey
					ldr r1,=spriteActive
					mov r2,#0
					str r2,[r1,r10,lsl #2]	
		drawnNotKey:
		cmp r0,#EXIT_OPEN						@ our door anim
		bne drawNotExitOpen
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#6
			str r2,[r1,r10,lsl #2]
			bne drawNotExitOpen
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#DOOR_FRAME_END+1
				moveq r2,#DOOR_FRAME
				str r2,[r1,r10,lsl #2]
		drawNotExitOpen:
		cmp r0,#FX_RAIN_SPLASH					@ little rain splashes
		bne drawNotRainSplash
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#RAIN_SPLASH_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotRainSplash			
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#RAIN_SPLASH_FRAME_END+1
				str r2,[r1,r10,lsl #2]				
				bne drawNotRainSplash
				@ generate new rain
					bl getRandom				@ r8 returned
					ldr r7,=0x1FF
					and r8,r7
					add r8,#64
					ldr r1,=spriteX
					str r8,[r1,r10,lsl#2]		@ store X	0-255
					mov r8,#384+32
					ldr r1,=spriteY
					str r8,[r1,r10,lsl#2]		@ store y	0-191
					bl getRandom
					and r8,#3
					cmp r8,#0
					moveq r8,#1
					ldr r1,=spriteSpeed
					str r8,[r1,r10,lsl#2]
					mov r8,#FX_RAIN_ACTIVE
					ldr r1,=spriteActive
					str r8,[r1,r10,lsl#2]
					mov r8,#RAIN_FRAME
					ldr r1,=spriteObj
					str r8,[r1,r10,lsl#2]	
		drawNotRainSplash:
		cmp r0,#FX_GLINT_ACTIVE					@ sparkly glints
		bne drawNotGlint
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#GLINT_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotGlint
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#GLINT_FRAME_END+1
				str r2,[r1,r10,lsl #2]
				bne drawNotGlint
					ldr r1,=spriteActive
					mov r2,#0
					str r2,[r1,r10,lsl #2]		
		drawNotGlint:
		cmp r0,#FX_DRIP_ACTIVE					@ little drips
		bne drawNotDrip
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#DRIP_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotDrip
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#DRIP_FRAME_END+1
				str r2,[r1,r10,lsl #2]
				bne drawNotDrip
					@ Convert drip to a dripfall
					ldr r1,=spriteActive
					mov r2,#FX_DRIPFALL_ACTIVE
					str r2,[r1,r10,lsl #2]	
					mov r0,#DRIPFALL_ANIM
					ldr r2,=spriteAnimDelay
					str r0,[r2,r10,lsl#2]
					ldr r1,=spriteObj
					mov r0,#DRIPFALL_FRAME
					str r0,[r1,r10,lsl #2]
				@	b endDrawSprite
		drawNotDrip:		
		cmp r0,#FX_DRIPFALL_ACTIVE
		bne drawNotDripFall
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#DRIPFALL_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotDripFall
				ldr r1,=spriteY
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				str r2,[r1,r10,lsl #2]
				@ now check for a platform (not 0, and <24) r2=y
				ldr r1,=spriteX
				ldr r1,[r1,r10,lsl #2]
				sub r1,#64
				lsr r1,#3
				sub r2,#384
				lsr r2,#3
				lsl r2,#5
				add r2,r1				@ r2=offset
				add r2,#32
				ldr r1,=colMapStore
				ldrb r0,[r1,r2]
				cmp r0,#0
				beq drawNotDripFall
				cmp r0,#64
				bge dripHitFloor
				cmp r0,#24
				bge drawNotDripFall
				
				dripHitFloor:
				@	ok, we have hit a platform
				ldr r1,=spriteY
				ldr r2,[r1,r10,lsl#2]
				lsr r2,#3
				lsl r2,#3
				str r2,[r1,r10,lsl#2]
				
				ldr r1,=spriteActive
				mov r0,#FX_DRIPSPLASH_ACTIVE
				str r0,[r1,r10,lsl #2]
				
				ldr r1,=spriteObj
				mov r0,#DRIPSPLASH_FRAME
				str r0,[r1,r10,lsl #2]
				
				ldr r1,=spriteAnimDelay
				mov r0,#DRIPSPLASH_ANIM
				str r0,[r1,r10,lsl #2]

		drawNotDripFall:	
		cmp r0,#FX_DRIPSPLASH_ACTIVE				@ little drip splashes
		bne drawNotDripSplash
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#DRIPSPLASH_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotDripSplash
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#DRIPSPLASH_FRAME_END+1
				str r2,[r1,r10,lsl #2]
				bne drawNotDripSplash
					ldr r1,=spriteActive
					mov r2,#0
					str r2,[r1,r10,lsl #2]	
		drawNotDripSplash:			
					
		cmp r0,#FX_EYES_ACTIVE						@ blinking eyes
		bne drawNotEye
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#EYE_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotEye
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#EYE_FRAME_END+1
				moveq r2,#EYE_FRAME
				str r2,[r1,r10,lsl #2]
		drawNotEye:
		cmp r0,#FX_FLIES_ACTIVE
		bne drawNotFly
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#FLY_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotFly
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#FLY_FRAME_END+1
				moveq r2,#FLY_FRAME
				str r2,[r1,r10,lsl #2]	
		drawNotFly:
		cmp r0,#FX_CSTARS_ACTIVE
		bne drawNotcStars
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			ldreq r3,=spriteSpeed
			ldreq r2,[r3,r10,lsl#2]
			str r2,[r1,r10,lsl #2]
			bne drawNotcStars
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#CSTARS_FRAME_END+1
				moveq r2,#CSTARS_FRAME
				str r2,[r1,r10,lsl #2]	
		drawNotcStars:
		cmp r0,#FX_CFLAG_ACTIVE
		bne drawNotcFlag
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#CFLAG_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotcFlag
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#CFLAG_FRAME_END+1
				moveq r2,#CFLAG_FRAME
				str r2,[r1,r10,lsl #2]	
		drawNotcFlag:
		cmp r0,#FX_BLINKS_ACTIVE
		bne drawNotBlinks
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#BLINKS_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotBlinks
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				str r2,[r1,r10,lsl #2]
				cmp r2,#BLINKS_FRAME_END+1
				bne drawNotBlinks
				mov r2,#0
				ldr r1,=spriteActive
				str r2,[r1,r10,lsl#2]
		drawNotBlinks:
		cmp r0,#FX_SPARK_ACTIVE
		bne drawNotSpark
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#SPARK_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotSpark
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				str r2,[r1,r10,lsl #2]
				cmp r2,#SPARK_FRAME_END+1
				bne drawNotSpark
				mov r2,#0
				ldr r1,=spriteActive
				str r2,[r1,r10,lsl#2]
		drawNotSpark:
		cmp r0,#FX_EXPLODE_ACTIVE
		bne drawNotExplode
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			str r2,[r1,r10,lsl #2]
			bne drawNotExplode
				ldr r2,=spriteSpeed
				ldr r2,[r2,r10,lsl#2]
				str r2,[r1,r10,lsl#2]
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				str r2,[r1,r10,lsl #2]
				cmp r2,#EXPLODE_FRAME_END+1
				bne drawNotExplode
				mov r2,#0
				ldr r1,=spriteActive
				str r2,[r1,r10,lsl#2]
		drawNotExplode:
		cmp r0,#FX_SCRATCH_ACTIVE
		bne drawNotScratch
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			str r2,[r1,r10,lsl #2]
			cmp r2,#0
				@ kill it
				moveq r2,#0
				ldreq r1,=spriteActive
				streq r2,[r1,r10,lsl#2]
		drawNotScratch:
		cmp r0,#FX_METEOR_ACTIVE
		bne drawNotMeteor
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			subs r2,#1
			movmi r2,#METEOR_ANIM
			str r2,[r1,r10,lsl #2]
			bpl drawNotMeteorAnim
			
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#METEOR_FRAME_END+1
				moveq r2,#METEOR_FRAME
				str r2,[r1,r10,lsl #2]
			
			drawNotMeteorAnim:
			
			ldr r1,=spriteY					@ update Y coord
			ldr r2,[r1,r10,lsl #2]
			add r2,#2
			str r2,[r1,r10,lsl #2]
			
			@check colmap
			@ now check for a platform (not 0, and <24) r2=y
			ldr r1,=spriteX
			ldr r1,[r1,r10,lsl #2]
			sub r1,#64
			add r1,#4
			lsr r1,#3
			
			sub r2,#384
			lsr r2,#3
			lsl r2,#5
			add r2,r1				@ r2=offset
			add r2,#64
			ldr r1,=colMapStore
			ldrb r0,[r1,r2]
			cmp r0,#0
			beq drawNotMeteor
			cmp r0,#64
			bge meteorHitFloor
			cmp r0,#24
			bge drawNotMeteor
				
				meteorHitFloor:
				@	ok, we have hit a platform, convert to explosion
				ldr r1,=spriteY
				ldr r2,[r1,r10,lsl#2]
				lsr r2,#3
				lsl r2,#3
				str r2,[r1,r10,lsl#2]
				
				ldr r1,=spriteObj
				mov r2,#METEOREXP_FRAME
				str r2,[r1,r10,lsl#2]
				ldr r1,=spriteActive
				mov r2,#FX_METEORCRASH_ACTIVE
				str r2,[r1,r10,lsl#2]
				ldr r1,=spriteAnimDelay
				mov r2,#METEOREXP_ANIM
				str r2,[r1,r10,lsl#2]
				
				bl playMeteor
		drawNotMeteor:
		cmp r0,#FX_METEORCRASH_ACTIVE
		bne drawNotMCrash
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			subs r2,#1
			movmi r2,#METEOREXP_ANIM
			str r2,[r1,r10,lsl #2]
			bpl drawNotMCrash
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				str r2,[r1,r10,lsl #2]
				cmp r2,#METEOREXP_FRAME_END+1
				bne drawNotMCrash
				
					@ get next pos and init another meteor
					
					mov r2,#METEOR_FRAME				@ reset image
					str r2,[r1,r10,lsl#2]
					ldr r1,=spriteActive
					mov r0,#FX_METEOR_ACTIVE
					str r0,[r1,r10,lsl#2]
					ldr r1,=meteorPhase
					ldr r0,[r1]
					add r0,#1
					cmp r0,#16
					moveq r0,#0
					str r0,[r1]
					ldr r1,=meteorDrops
					ldr r2,[r1,r0, lsl #2]
					lsl r2,#3
					add r2,#60
					ldr r1,=spriteX
					str r2,[r1,r10,lsl#2]
		
					ldr r1,=spriteY
					mov r0,#28+384
					str r0,[r1,r10,lsl#2]
		
					ldr r1,=spriteAnimDelay
					mov r0,#METEOR_ANIM
					str r0,[r1,r10,lsl#2]
		drawNotMCrash:
		cmp r0,#FX_BLOOD_ACTIVE
		bne drawNotBlood
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			subs r2,#1
			movmi r2,#BLOOD_ANIM
			str r2,[r1,r10,lsl #2]
			bpl drawNotBlood
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				str r2,[r1,r10,lsl #2]
				cmp r2,#BLOOD_FRAME_END+1
				bne drawNotBlood
				mov r2,#0
				ldr r1,=spriteActive
				str r2,[r1,r10,lsl#2]
		drawNotBlood:
		cmp r0,#FX_BONUS
		bne notBonusSpray
		
			bl fxBonusSpray;	b endDrawSprite
		
		notBonusSpray:
		cmp r0,#FX_SPARKLE
		bne notSparkle
		
			bl fxSparkle;		b endDrawSprite
		
		notSparkle:
		cmp r0,#FX_GGLINT_ACTIVE
		bne drawNotGGlint
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			sub r2,#1
			cmp r2,#0
			moveq r2,#GGLINT_ANIM
			str r2,[r1,r10,lsl #2]
			bne drawNotGGlint
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#GGLINT_FRAME_END+1
				str r2,[r1,r10,lsl #2]
				bne drawNotGGlint
					ldr r1,=spriteActive
					mov r2,#0
					str r2,[r1,r10,lsl #2]		
		drawNotGGlint:
		cmp r0,#FX_CAUSEWAY_ACTIVE
		bne endDrawSprite
			ldr r1,=spriteAnimDelay
			ldr r2,[r1,r10,lsl #2]
			subs r2,#1
			movmi r2,#CAUSE_ANIM
			str r2,[r1,r10,lsl #2]
			bpl endDrawSprite
				ldr r1,=spriteObj
				ldr r2,[r1,r10,lsl #2]
				add r2,#1
				cmp r2,#CAUSE_FRAME_END+1
				moveq r2,#CAUSE_FRAME
				str r2,[r1,r10,lsl #2]
			drawCause:
			ldr r1,=spriteX
			ldr r2,[r1,r10,lsl#2]
			ldr r0,=spriteSpeed
			ldr r0,[r0,r10,lsl#2]
			sub r2,r0
			str r2,[r1,r10,lsl#2]
			cmp r2,#47
			bpl endDrawSprite
			mov r2,#0
			ldr r1,=spriteActive
			str r2,[r1,r10,lsl#2]

		endDrawSprite:
	subs r10,#1
	bpl SLoop
	
	ldr r8,=bonusDelay
	ldr r9,[r8]
	subs r9,#1
	movmi r9,#0
	str r9,[r8]
	cmp r9,#1
	bne noBonusRefresh
	
		ldr r0,=BonusNormalTiles
		ldr r1,=SPRITE_GFX_SUB
		add r1,#40*256				@ dump at 40th sprite onwards
		ldr r2,=8*256
		bl dmaCopy

	noBonusRefresh:

	ldmfd sp!, {r0-r12,pc}
	
@--------------------------------------------

spareSprite:
	stmfd sp!, {r0-r9, lr}

	mov r0,#85
	ldr r1,=spriteActive
	spareSpriteFind:
	
		ldr r2,[r1, r0, lsl #2]
		cmp r2,#0
		beq spareSpriteFound
		add r0,#1
		cmp r0,#128
		bne spareSpriteFind
	mov r10,#0
	ldmfd sp!, {r0-r9, pc}
	
	spareSpriteFound:
	
	mov r10,r0

	ldmfd sp!, {r0-r9, pc}
	
@--------------------------------------------

spareSpriteSub:
	stmfd sp!, {r0-r9, lr}

	mov r0,#127
	ldr r1,=spriteActiveSub
	spareSpriteFindSub:
	
		ldr r2,[r1, r0, lsl #2]
		cmp r2,#0
		beq spareSpriteFoundSub
		subs r0,#1
		bpl spareSpriteFindSub
	mov r10,#0
	ldmfd sp!, {r0-r9, pc}
	
	spareSpriteFoundSub:
	
	mov r10,r0

	ldmfd sp!, {r0-r9, pc}
	
@--------------------------------------------

spareSpriteFX:
	stmfd sp!, {r0-r9, lr}

	mov r0,#62
	ldr r1,=spriteActive
	spareSpriteFindFX:
	
		ldr r2,[r1, r0, lsl #2]
		cmp r2,#0
		beq spareSpriteFoundFX
		subs r0,#1
		bpl spareSpriteFindFX
	mov r10,#0
	ldmfd sp!, {r0-r9, pc}
	
	spareSpriteFoundFX:
	
	mov r10,r0

	ldmfd sp!, {r0-r9, pc}

.pool
.align

@--------------------------------------------

anySpareSpriteFX:
	stmfd sp!, {r0-r9, lr}

	mov r0,#127
	ldr r1,=spriteActive
	anySpareSpriteFindFX:
	
		ldr r2,[r1, r0, lsl #2]
		cmp r2,#0
		beq anySpareSpriteFoundFX
		subs r0,#1
		bpl anySpareSpriteFindFX
	mov r10,#0
	ldmfd sp!, {r0-r9, pc}
	
	anySpareSpriteFoundFX:
	
	mov r10,r0

	ldmfd sp!, {r0-r9, pc}

@--------------------------------------------

anySpareSpriteMonster:
	stmfd sp!, {r0-r9, lr}

	mov r0,#84
	ldr r1,=spriteActive
	anySpareSpriteMFind:
	
		ldr r2,[r1, r0, lsl #2]
		cmp r2,#0
		beq anySpareSpriteMFound
		subs r0,#1
		cmp r0,#64
		bne anySpareSpriteMFind
	mov r10,#255
	ldmfd sp!, {r0-r9, pc}
	
	anySpareSpriteMFound:
	
	mov r10,r0
	ldmfd sp!, {r0-r9, pc}
	
@---------------------------------------------

drawSpriteSub:
	stmfd sp!, {r0-r12, lr}

	ldr r5,=BUF_ATTRIBUTE0_SUB
	ldr r6,=BUF_ATTRIBUTE1_SUB
	ldr r9,=BUF_ATTRIBUTE2_SUB
	
	mov r10,#127 			@ our counter for 128 sprites, do not think we need them all though	
	SLoopSub:

		ldr r0,=spriteActiveSub				@ r2 is pointer to the sprite active setting
		ldr r1,[r0,r10, lsl #2]				@ add sprite number * 4
		cmp r1,#0							@ Is sprite active? (anything other than 0)
		bne sprites_Draw_Sub				@ if so, draw it!

			@ If not - kill it
			
			mov r1, #ATTR0_DISABLED			@ this should destroy the sprite
			mov r0,r5
			add r0,r10, lsl #3
			strh r1,[r0]

		b sprites_Done_Sub
	
	sprites_Draw_Sub:
	
		ldr r0,=spriteYSub				@ Load Y coord
		ldr r1,[r0,r10,lsl #2]			@ add ,rX for offsets
		cmp r1,#4096					@ account for floating point
		lsrge r1,#12

		@ Draw sprite to SUB screen ONLY (r1 holds Y)	
		mov r0,r5
		add r0,r10, lsl #3
		ldr r2, =(ATTR0_COLOR_256 | ATTR0_SQUARE)
		ldr r3,=SCREEN_SUB_TOP
		cmp r1,r3
		addmi r1,#256
		sub r1,r3
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1
		strh r2,[r0]
		@ Draw X
		ldr r0,=spriteXSub				@ get X coord mem space
		ldr r1,[r0,r10,lsl #2]			@ add ,rX for offsets
		cmp r1,#4096					@ account for floating point
		lsrge r1,#12
		cmp r1,#SCREEN_LEFT				@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#SCREEN_LEFT				@ Take 64 off our X
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		mov r0,r6
		add r0,r10, lsl #3
		ldr r2, =(ATTR1_SIZE_16)	
		and r1,r3
		orr r2,r1
		strh r2,[r0]
			@ Draw Attributes
		mov r0,r9
		add r0,r10, lsl #3
		ldr r2,=spriteObjSub
		ldr r3,[r2,r10, lsl #2]
		ldr r1,=spritePrioritySub
		ldr r1,[r1,r10, lsl #2]
		lsl r1,#10						@ set priority
		orr r1,r3, lsl #3				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back

	sprites_Done_Sub:
		ldr r1,=spriteActiveSub
		ldr r1,[r1,r10,lsl#2]
		cmp r1,#1
		bne notSprinkle
			ldr r1,=spriteYSub
			ldr r2,[r1,r10,lsl#2]
			ldr r3,=spriteMinSub
			ldr r3,[r3,r10,lsl#2]
			add r2,r3
			cmp r2,#((384+192)<<12)
			bge killSprinkle
			str r2,[r1,r10,lsl#2]
			ldr r1,=spriteAnimDelaySub
			ldr r2,[r1,r10,lsl#2]
			subs r2,#1
			ldrmi r3,=spriteMaxSub
			ldrmi r3,[r3,r10,lsl#2]
			movmi r2,r3
			str r2,[r1,r10,lsl#2]
			bpl doneThing
				killSprinkle:
				ldr r1,=spriteObjSub
				ldr r2,[r1,r10,lsl#2]
				add r2,#1
				cmp r2,#8
				str r2,[r1,r10,lsl#2]
				bne doneThing
					ldr r1,=spriteActiveSub
					mov r2,#0
					str r2,[r1,r10,lsl#2]
					b doneThing
		notSprinkle:
		cmp r1,#2
		bne doneThing
			ldr r1,=spriteXSub
			ldr r2,[r1,r10,lsl#2]
			ldr r3,=spriteMinSub
			ldr r4,[r3,r10,lsl#2]
			adds r2,r4
			cmp r2,#((288+64)<<12)
			movpl r2,#(16<<12)
			str r2,[r1,r10,lsl#2]
			lsr r2,#12
			and r2,#15
			lsr r2,#2
			ldr r1,=spriteObjSub
			str r2,[r1,r10,lsl#2]
		
			ldr r1,=spriteYSub
			ldr r2,[r1,r10,lsl#2]
			ldr r3,=spriteMaxSub
			ldr r4,[r3,r10,lsl#2]
			adds r2,r4
			str r2,[r1,r10,lsl#2]

		doneThing:
	
	subs r10,#1
	bpl SLoopSub
	
	ldmfd sp!, {r0-r12, pc}	