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
#include "dma.h"
#include "ipc.h"

	#define STOP_SOUND			-1
	#define FIND_FREE_CHANNEL	0x80

	.arm
	.align
	.text
	
	.global stopSound
	.global playDead
	.global playJump
	.global playTone
	.global playFall
	.global playLevelEnd
	.global playClick
	.global playKey
	.global playExplode
	.global playSplat
	.global playFallThing
	.global playFanFare
	.global playKeyClick
	.global playCrackle
	.global playMeteor

stopSound:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_DATA(0)							@ Get the IPC sound data address
	mov r1, #STOP_SOUND									@ Stop sound value
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playDead:

	@ 'CHANNEL 1'

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(0)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(0)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(0)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(0)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(0)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(0)							@ Get the IPC sound length address
	ldr r1, =dead_raw_end								@ Get the sample end
	ldr r2, =dead_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)							@ Get the IPC sound data address
	ldr r1, =dead_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playTone:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(0)							@ Frequency
	ldr r1, =44100
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(0)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(0)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(0)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(0)						@ Format
	ldrb r1, =IPC_SOUND_16BIT
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(0)							@ Get the IPC sound length address
	ldr r1, =tone_raw_end								@ Get the sample end
	ldr r2, =tone_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)							@ Get the IPC sound data address
	ldr r1, =tone_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playJump:					

	@ 'CHANNEL 0'

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =jumpCount									@ 22050 + 1500 * (9 - Sqr((jumpCount - 9) ^ 2))
	ldr r0, [r0]
	@sub r0, #9
	mov r1, #1
	lsl r1, #2
	bl sqrt32
	mov r1, #9
	sub r1, r0
	ldr r2, =1500
	ldr r3, =22050
	mul r1, r2
	add r1, r3
	ldr r0, =IPC_SOUND_RATE(1)							@ Frequency
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(1)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]

	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(1)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(1)							@ Channel
	ldrb r1, =0
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(1)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =jump_raw_end								@ Get the sample end
	ldr r2, =jump_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =jump_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(1)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r3, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playFall:

	@ 'CHANNEL 0'
	
	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =fallCount
	ldr r0, [r0]
	
	mov r1, #1
	lsl r1, #2
	bl sqrt32
	sub r1, r0
	ldr r2, =1500
	ldr r3, =22050
	mul r1, r2
	add r1, r3
	ldr r0, =IPC_SOUND_RATE(0)							@ Frequency
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(0)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(0)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(0)							@ Channel
	ldrb r1, =0
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(0)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(0)							@ Get the IPC sound length address
	ldr r1, =jump_raw_end								@ Get the sample end
	ldr r2, =jump_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)							@ Get the IPC sound data address
	ldr r1, =jump_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r3, pc} 							@ restore registers and return
	
	@ ---------------------------------------------


playLevelEnd:

	@ 'CHANNEL - FIND FREE'

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(0)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(0)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(0)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(0)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(0)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(0)							@ Get the IPC sound length address
	ldr r1, =levelend_raw_end							@ Get the sample end
	ldr r2, =levelend_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)							@ Get the IPC sound data address
	ldr r1, =levelend_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------


playClick:

	@ 'CHANNEL - FIND FREE'


	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(0)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(0)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(0)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(0)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(0)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(0)							@ Get the IPC sound length address
	ldr r1, =click_raw_end								@ Get the sample end
	ldr r2, =click_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)							@ Get the IPC sound data address
	ldr r1, =click_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------


playKey:

	@ 'CHANNEL - FIND FREE'


	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(0)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(0)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(0)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(0)							@ Channel
	ldrb r1, =FIND_FREE_CHANNEL
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(0)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(0)							@ Get the IPC sound length address
	ldr r1, =key_raw_end								@ Get the sample end
	ldr r2, =key_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)							@ Get the IPC sound data address
	ldr r1, =key_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return

	@ ---------------------------------------------


playExplode:

	@ 'CHANNEL - 3'


	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(4)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(4)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(4)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(4)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(4)							@ Channel
	ldrb r1, =3
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(4)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(4)							@ Get the IPC sound length address
	ldr r1, =explode_raw_end							@ Get the sample end
	ldr r2, =explode_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(4)							@ Get the IPC sound data address
	ldr r1, =explode_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(4)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return

	@ ---------------------------------------------

playFallThing:

	@ 'CHANNEL 0'

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(0)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(0)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(0)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(0)							@ Channel
	ldrb r1, =0
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(0)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(0)							@ Get the IPC sound length address
	ldr r1, =fallthing_raw_end							@ Get the sample end
	ldr r2, =fallthing_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)							@ Get the IPC sound data address
	ldr r1, =fallthing_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playSplat:

	@ 'CHANNEL 0'

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(0)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(0)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(0)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(0)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(0)							@ Channel
	ldrb r1, =1
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(0)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(0)							@ Get the IPC sound length address
	ldr r1, =splat_raw_end								@ Get the sample end
	ldr r2, =splat_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)							@ Get the IPC sound data address
	ldr r1, =splat_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	@ ---------------------------------------------


playFanFare:

	@ 'CHANNEL - 3'


	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(4)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(4)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(4)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(4)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(4)							@ Channel
	ldrb r1, =3
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(4)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(4)							@ Get the IPC sound length address
	ldr r1, =fanfare_raw_end							@ Get the sample end
	ldr r2, =fanfare_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(4)							@ Get the IPC sound data address
	ldr r1, =fanfare_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(4)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return

	@ ---------------------------------------------


playKeyClick:

	@ 'CHANNEL - 3'


	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(4)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(4)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(4)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(4)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(4)							@ Channel
	ldrb r1, =3
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(4)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(4)							@ Get the IPC sound length address
	ldr r1, =keyclick_raw_end							@ Get the sample end
	ldr r2, =keyclick_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(4)							@ Get the IPC sound data address
	ldr r1, =keyclick_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(4)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return

	@ ---------------------------------------------


playCrackle:

	@ 'CHANNEL - 4'

	stmfd sp!, {r0-r2, lr}
	
	ldr r0,=gameMode
	ldr r0,[r0]
	cmp r0,#GAMEMODE_TITLE_SCREEN
	beq crackleFail
	
	ldr r0, =IPC_SOUND_DATA(5)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(5)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(5)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(5)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(5)							@ Channel
	ldrb r1, =4
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(5)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(5)							@ Get the IPC sound length address
	ldr r1, =crackle_raw_end							@ Get the sample end
	ldr r2, =crackle_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(5)							@ Get the IPC sound data address
	ldr r1, =crackle_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(5)
	strh r1, [r0]
	
	crackleFail:
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	@ ---------------------------------------------


playMeteor:

	@ 'CHANNEL - 5'

	stmfd sp!, {r0-r2, lr}
	
	ldr r0,=gameMode
	ldr r0,[r0]
	cmp r0,#GAMEMODE_TITLE_SCREEN
	beq meteorFail
	
	ldr r0, =IPC_SOUND_DATA(6)
	ldr r1, =0x10
	bl DC_FlushRange
	
	ldr r0, =IPC_SOUND_RATE(6)							@ Frequency
	ldr r1, =22050
	str r1, [r0]
	
	ldr r0, =IPC_SOUND_VOL(6)							@ Volume
	ldr r2,=audioSFXVol
	ldr r1,[r2]
	ldr r2,=sfxValues
	ldrb r1,[r2,r1]
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_PAN(6)							@ Pan
	ldrb r1, =64
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_CHAN(6)							@ Channel
	ldrb r1, =5
	strb r1, [r0]
	
	ldr r0, =IPC_SOUND_FORMAT(6)						@ Format
	ldrb r1, =0
	strb r1, [r0]

	ldr r0, =IPC_SOUND_LEN(6)							@ Get the IPC sound length address
	ldr r1, =meteor_raw_end							@ Get the sample end
	ldr r2, =meteor_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(6)							@ Get the IPC sound data address
	ldr r1, =meteor_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldr r0, =REG_IPC_SYNC
	ldr r1, =IPC_SEND_SYNC(6)
	strh r1, [r0]
	
	meteorFail:
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return

	@ ---------------------------------------------