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

	.global drawLevel

drawLevel:
	@ levelNum holds the number of the level needed

	stmfd sp!, {r0-r10, lr}

	ldr r0, =Background01Pal
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =Background01PalLen
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	
	@ Write the tile data

	ldr r3,=levelNum
	ldr r3,[r3]
	
	cmp r3,#1
	ldreq r4,=Level01Tiles
	ldreq r5,=Level01TilesLen
	ldreq r6,=Level01Map
	ldreq r7,=Level01MapLen
	cmp r3,#2
	ldreq r4,=Level02Tiles
	ldreq r5,=Level02TilesLen
	ldreq r6,=Level02Map
	ldreq r7,=Level02MapLen
	cmp r3,#3
	ldreq r4,=Level03Tiles
	ldreq r5,=Level03TilesLen
	ldreq r6,=Level03Map
	ldreq r7,=Level03MapLen	
	cmp r3,#4
	ldreq r4,=Level04Tiles
	ldreq r5,=Level04TilesLen
	ldreq r6,=Level04Map
	ldreq r7,=Level04MapLen	
	cmp r3,#5
	ldreq r4,=Level05Tiles
	ldreq r5,=Level05TilesLen
	ldreq r6,=Level05Map
	ldreq r7,=Level05MapLen		
	cmp r3,#6
	ldreq r4,=Level06Tiles
	ldreq r5,=Level06TilesLen
	ldreq r6,=Level06Map
	ldreq r7,=Level06MapLen	
	cmp r3,#7
	ldreq r4,=Level07Tiles
	ldreq r5,=Level07TilesLen
	ldreq r6,=Level07Map
	ldreq r7,=Level07MapLen	
	cmp r3,#8
	ldreq r4,=Level08Tiles
	ldreq r5,=Level08TilesLen
	ldreq r6,=Level08Map
	ldreq r7,=Level08MapLen	
	cmp r3,#9
	ldreq r4,=Level09Tiles
	ldreq r5,=Level09TilesLen
	ldreq r6,=Level09Map
	ldreq r7,=Level09MapLen	
	cmp r3,#10
	ldreq r4,=Level10Tiles
	ldreq r5,=Level10TilesLen
	ldreq r6,=Level10Map
	ldreq r7,=Level10MapLen	
	cmp r3,#11
	ldreq r4,=Level11Tiles
	ldreq r5,=Level11TilesLen
	ldreq r6,=Level11Map
	ldreq r7,=Level11MapLen	
	cmp r3,#12
	ldreq r4,=Level12Tiles
	ldreq r5,=Level12TilesLen
	ldreq r6,=Level12Map
	ldreq r7,=Level12MapLen	
	cmp r3,#13
	ldreq r4,=Level13Tiles
	ldreq r5,=Level13TilesLen
	ldreq r6,=Level13Map
	ldreq r7,=Level13MapLen	
	cmp r3,#14
	ldreq r4,=Level14Tiles
	ldreq r5,=Level14TilesLen
	ldreq r6,=Level14Map
	ldreq r7,=Level14MapLen	
	cmp r3,#15
	ldreq r4,=Level15Tiles
	ldreq r5,=Level15TilesLen
	ldreq r6,=Level15Map
	ldreq r7,=Level15MapLen	
	cmp r3,#16
	ldreq r4,=Level16Tiles
	ldreq r5,=Level16TilesLen
	ldreq r6,=Level16Map
	ldreq r7,=Level16MapLen	
	cmp r3,#17
	ldreq r4,=Level17Tiles
	ldreq r5,=Level17TilesLen
	ldreq r6,=Level17Map
	ldreq r7,=Level17MapLen	
	cmp r3,#18
	ldreq r4,=Level18Tiles
	ldreq r5,=Level18TilesLen
	ldreq r6,=Level18Map
	ldreq r7,=Level18MapLen	
	cmp r3,#19
	ldreq r4,=Level19Tiles
	ldreq r5,=Level19TilesLen
	ldreq r6,=Level19Map
	ldreq r7,=Level19MapLen	
	cmp r3,#20
	ldreq r4,=Level20Tiles
	ldreq r5,=Level20TilesLen
	ldreq r6,=Level20Map
	ldreq r7,=Level20MapLen	
	cmp r3,#21
	ldreq r4,=Level21Tiles
	ldreq r5,=Level21TilesLen
	ldreq r6,=Level21Map
	ldreq r7,=Level21MapLen	
	cmp r3,#22
	ldreq r4,=Level22Tiles
	ldreq r5,=Level22TilesLen
	ldreq r6,=Level22Map
	ldreq r7,=Level22MapLen
	cmp r3,#23
	ldreq r4,=Level23Tiles
	ldreq r5,=Level23TilesLen
	ldreq r6,=Level23Map
	ldreq r7,=Level23MapLen	
	cmp r3,#24
	ldreq r4,=Level24Tiles
	ldreq r5,=Level24TilesLen
	ldreq r6,=Level24Map
	ldreq r7,=Level24MapLen	
	cmp r3,#25
	ldreq r4,=Level25Tiles
	ldreq r5,=Level25TilesLen
	ldreq r6,=Level25Map
	ldreq r7,=Level25MapLen	
	cmp r3,#26
	ldreq r4,=Level26Tiles
	ldreq r5,=Level26TilesLen
	ldreq r6,=Level26Map
	ldreq r7,=Level26MapLen	
	cmp r3,#27
	ldreq r4,=Level27Tiles
	ldreq r5,=Level27TilesLen
	ldreq r6,=Level27Map
	ldreq r7,=Level27MapLen	
	cmp r3,#28
	ldreq r4,=Level28Tiles
	ldreq r5,=Level28TilesLen
	ldreq r6,=Level28Map
	ldreq r7,=Level28MapLen
	cmp r3,#29
	ldreq r4,=Level29Tiles
	ldreq r5,=Level29TilesLen
	ldreq r6,=Level29Map
	ldreq r7,=Level29MapLen		
	cmp r3,#30
	ldreq r4,=Level30Tiles
	ldreq r5,=Level30TilesLen
	ldreq r6,=Level30Map
	ldreq r7,=Level30MapLen
	cmp r3,#31
	ldreq r4,=Level31Tiles
	ldreq r5,=Level31TilesLen
	ldreq r6,=Level31Map
	ldreq r7,=Level31MapLen
	cmp r3,#32
	ldreq r4,=Level32Tiles
	ldreq r5,=Level32TilesLen
	ldreq r6,=Level32Map
	ldreq r7,=Level32MapLen
	cmp r3,#33
	ldreq r4,=Level33Tiles
	ldreq r5,=Level33TilesLen
	ldreq r6,=Level33Map
	ldreq r7,=Level33MapLen
	cmp r3,#34
	ldreq r4,=Level34Tiles
	ldreq r5,=Level34TilesLen
	ldreq r6,=Level34Map
	ldreq r7,=Level34MapLen
	cmp r3,#35
	ldreq r4,=Level35Tiles
	ldreq r5,=Level35TilesLen
	ldreq r6,=Level35Map
	ldreq r7,=Level35MapLen
	cmp r3,#36
	ldreq r4,=Level36Tiles
	ldreq r5,=Level36TilesLen
	ldreq r6,=Level36Map
	ldreq r7,=Level36MapLen
	cmp r3,#37
	ldreq r4,=Level37Tiles
	ldreq r5,=Level37TilesLen
	ldreq r6,=Level37Map
	ldreq r7,=Level37MapLen
	cmp r3,#38
	ldreq r4,=Level38Tiles
	ldreq r5,=Level38TilesLen
	ldreq r6,=Level38Map
	ldreq r7,=Level38MapLen
	cmp r3,#39
	ldreq r4,=Level39Tiles
	ldreq r5,=Level39TilesLen
	ldreq r6,=Level39Map
	ldreq r7,=Level39MapLen
	cmp r3,#40
	ldreq r4,=Level40Tiles
	ldreq r5,=Level40TilesLen
	ldreq r6,=Level40Map
	ldreq r7,=Level40MapLen
	cmp r3,#41
	ldreq r4,=Level41Tiles
	ldreq r5,=Level41TilesLen
	ldreq r6,=Level41Map
	ldreq r7,=Level41MapLen	
	cmp r3,#42
	ldreq r4,=Level42Tiles
	ldreq r5,=Level42TilesLen
	ldreq r6,=Level42Map
	ldreq r7,=Level42MapLen	
	cmp r3,#43
	ldreq r4,=Level43Tiles
	ldreq r5,=Level43TilesLen
	ldreq r6,=Level43Map
	ldreq r7,=Level43MapLen	
	cmp r3,#44
	ldreq r4,=Level44Tiles
	ldreq r5,=Level44TilesLen
	ldreq r6,=Level44Map
	ldreq r7,=Level44MapLen	
	cmp r3,#45
	ldreq r4,=Level45Tiles
	ldreq r5,=Level45TilesLen
	ldreq r6,=Level45Map
	ldreq r7,=Level45MapLen	
	cmp r3,#46
	ldreq r4,=Level46Tiles
	ldreq r5,=Level46TilesLen
	ldreq r6,=Level46Map
	ldreq r7,=Level46MapLen	
	cmp r3,#47
	ldreq r4,=Level47Tiles
	ldreq r5,=Level47TilesLen
	ldreq r6,=Level47Map
	ldreq r7,=Level47MapLen	
	cmp r3,#48
	ldreq r4,=Level48Tiles
	ldreq r5,=Level48TilesLen
	ldreq r6,=Level48Map
	ldreq r7,=Level48MapLen	
	cmp r3,#49
	ldreq r4,=Level49Tiles
	ldreq r5,=Level49TilesLen
	ldreq r6,=Level49Map
	ldreq r7,=Level49MapLen		
	cmp r3,#50
	ldreq r4,=Level50Tiles
	ldreq r5,=Level50TilesLen
	ldreq r6,=Level50Map
	ldreq r7,=Level50MapLen	
	@ Draw main game map!
	mov r0,r4
	ldr r1, =BG_TILE_RAM_SUB(BG2_TILE_BASE_SUB)
	mov r2,r5
	bl decompressToVRAM
	mov r0,r6
	ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)	@ destination
	add r1,#(32*6)*2
	mov r2,r7
	bl dmaCopy

	@ draw the top status on bg1 sub (so that sprites can be behind for effects and stuff)
	
	ldr r0,=StatusMap							@ draw the air (full)
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
	add r1,#(32*4)*2
	mov r2,#128
	bl dmaCopy

	ldr r0,=StatusMap							@ draw the level name border
	add r0,#128
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
	mov r2,#256
	bl dmaCopy	
	
	bl drawLives

	ldmfd sp!, {r0-r10, pc}