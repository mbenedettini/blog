---
title: Python implementation of Mifare AES-128 simmetric key diversification
author: Mariano Benedettini
date: 2011-11-30
hero: 
excerpt: as described in document AN10922 
---


https://gist.github.com/mbenedettini/1409585


```python
from Crypto.Cipher import AES
from bitstring import BitArray, Bits

(key, m) = (BitArray(hex='00112233445566778899AABBCCDDEEFF'), BitArray(hex='00000000000000000000000000000000'))
const_rb = BitArray(hex='00000000000000000000000000000087')


k0 = BitArray(hex=AES.new(key.bytes).encrypt(m.bytes).encode('hex'))


k0_msb = k0.bin[2:][0:1]

k1 = None

if k0_msb == '0':
    k1 = k0 << 1
else:
    k1 = (k0 << 1) ^ const_rb

print "K0: {k0}, K1: {k1}".format(k0=k0, k1=k1)

k1_msb = k1.bin[2:][0:1]

k2 = None

if k1_msb == '0':
    k2 = k1 << 1
else:
    k2 = (k1 << 1) ^ const_rb
    
print "K2: {k2}".format(k2=k2)

div_constant = BitArray(hex='01')
uid = BitArray(hex='04782E21801D80')
aid = BitArray(hex='3042F5')
sysid = BitArray(hex='4E585020416275')

m = BitArray().join([uid, aid, sysid])
d = BitArray().join([div_constant, m])

# Pad it up to 32 bytes, starting with 0x80 and continuing with 0x00
padded = False
if len(d.bytes) < 32:
    # Padding is needed
    padded = True
    d.append('0x80')
    while len(d.bytes) < 32:
        d.append('0x00')
        
print "d size: %s" % len(d.bytes)

xor_component = None
if padded:
    xor_component = k2
else:
    xor_component = k1
    
xored_d = BitArray().join([ d[0:16*8], d[16*8:] ^ xor_component ])

print "xored_d: %s" % xored_d

ek_xored_d = BitArray()
BLOCK_SIZE = 16 * 8 # Constant

        
# Split data in 16-bytes long pieces
data_blocks = [xored_d[i:i+BLOCK_SIZE] for i in range(0, len(xored_d), BLOCK_SIZE)]

c = AES.new(key.bytes, AES.MODE_CBC, BitArray(hex='00'*16).bytes)
for block in data_blocks:
    ek_xored_d.append(BitArray(hex=c.encrypt(block.bytes).encode('hex')))

print "ek_xored_d: %s" % ek_xored_d

cmac = ek_xored_d[-16*8:]

print "cmac: ", cmac

```
