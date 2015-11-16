local Bit = require("lockbox.util.bit");
local String = require("string");
local Stream = require("lockbox.util.stream");
local Array = require("lockbox.util.array");

local Queue = require("lockbox.util.queue");

local HMAC = require("lockbox.mac.hmac");

local MD5 = require("lockbox.digest.md5");
local SHA1 = require("lockbox.digest.sha1");
local SHA2_224 = require("lockbox.digest.sha2_224");
local SHA2_256 = require("lockbox.digest.sha2_256");

local tests = {
	{	digest = MD5,
		blockSize = 64,
		key = {	0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,
				0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,},
		message = Stream.fromString("Hi There"),
		hmac = "9294727a3638bb1c13f48ef8158bfc9d"
	},
	{	digest = MD5,
		blockSize = 64,
		key = Array.fromString("Jefe"),
		message = Stream.fromString("what do ya want for nothing?"),
		hmac = "750c783e6ab0b503eaa86e310a5db738"
	},
	{	digest = MD5,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,},
		message = Stream.fromArray({0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,}),
		hmac = "56be34521d144c88dbb8c733f0e8b3f6"
	},
	{	digest = MD5,
		blockSize = 64,
		key = {	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,
				0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,
				0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19},
		message = Stream.fromArray({0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,}),
		hmac = "697eaf0aca3a3aea3a75164746ffaa79"
	},
	{	digest = MD5,
		blockSize = 64,
		key = {	0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,
				0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,},
		message = Stream.fromString("Test With Truncation"),
		hmac = "56461ef2342edc00f9bab995690efd4c"
	},
	{	digest = MD5,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,},
		message = Stream.fromString("Test Using Larger Than Block-Size Key - Hash Key First"),
		hmac = "6b1ab7fe4bd7bf8f0b62e6ce61b9d0cd"
	},
	{	digest = MD5,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,},
		message = Stream.fromString("Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data"),
		hmac = "6f630fad67cda0ee1fb1f562db3aa53e"
	},




	{	digest = SHA1,
		blockSize = 64,
		key = {	0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,
				0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,},
		message = Stream.fromString("Hi There"),
		hmac = "b617318655057264e28bc0b6fb378c8ef146be00"
	},
	{	digest = SHA1,
		blockSize = 64,
		key = Array.fromString("Jefe"),
		message = Stream.fromString("what do ya want for nothing?"),
		hmac = "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79"
	},
	{	digest = SHA1,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,},
		message = Stream.fromArray({0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,}),
		hmac = "125d7342b9ac11cd91a39af48aa17b4f63f175d3"
	},
	{	digest = SHA1,
		blockSize = 64,
		key = {	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,
				0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,
				0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19},
		message = Stream.fromArray({0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,}),
		hmac = "4c9007f4026250c6bc8414f9bf50c86c2d7235da"
	},
	{	digest = SHA1,
		blockSize = 64,
		key = {	0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,
				0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,},
		message = Stream.fromString("Test With Truncation"),
		hmac = "4c1a03424b55e07fe7f27be1d58bb9324a9a5a04"
	},
	{	digest = SHA1,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,},
		message = Stream.fromString("Test Using Larger Than Block-Size Key - Hash Key First"),
		hmac = "aa4ae5e15272d00e95705637ce8a3b55ed402112"
	},
	{	digest = SHA1,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,},
		message = Stream.fromString("Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data"),
		hmac = "e8e99d0f45237d786d6bbaa7965c7808bbff1a91"
	},




	{	digest = SHA2_224,
		blockSize = 64,
		key = {	0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,
				0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,},
		message = Stream.fromString("Hi There"),
		hmac = "896fb1128abbdf196832107cd49df33f47b4b1169912ba4f53684b22"
	},
	{	digest = SHA2_224,
		blockSize = 64,
		key = Array.fromString("Jefe"),
		message = Stream.fromString("what do ya want for nothing?"),
		hmac = "a30e01098bc6dbbf45690f3a7e9e6d0f8bbea2a39e6148008fd05e44"
	},
	{	digest = SHA2_224,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,},
		message = Stream.fromArray({0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,}),
		hmac = "7fb3cb3588c6c1f6ffa9694d7d6ad2649365b0c1f65d69d1ec8333ea"
	},
	{	digest = SHA2_224,
		blockSize = 64,
		key = {	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,
				0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,
				0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19},
		message = Stream.fromArray({0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,}),
		hmac = "6c11506874013cac6a2abc1bb382627cec6a90d86efc012de7afec5a"
	},
--	{	digest = SHA2_224,
--		blockSize = 64,
--		key = {	0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,
--				0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,},
--		message = Stream.fromString("Test With Truncation"),
--		hmac = "0e2aea68a90c8d37c988bcdb9fca6fa8"
--	},
	{	digest = SHA2_224,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa},
		message = Stream.fromString("Test Using Larger Than Block-Size Key - Hash Key First"),
		hmac = "95e9a0db962095adaebe9b2d6f0dbce2d499f112f2d2b7273fa6870e"
	},
	{	digest = SHA2_224,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa},
		message = Stream.fromString("This is a test using a larger than block-size key and a larger than block-size data. The key needs to be hashed before being used by the HMAC algorithm."),
		hmac = "3a854166ac5d9f023f54d517d0b39dbd946770db9c2b95c9f6f565d1"
	},




	{	digest = SHA2_256,
		blockSize = 64,
		key = {	0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,
				0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,0x0b,},
		message = Stream.fromString("Hi There"),
		hmac = "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7"
	},
	{	digest = SHA2_256,
		blockSize = 64,
		key = Array.fromString("Jefe"),
		message = Stream.fromString("what do ya want for nothing?"),
		hmac = "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843"
	},
	{	digest = SHA2_256,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,},
		message = Stream.fromArray({0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,
									0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,0xdd,}),
		hmac = "773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe"
	},
	{	digest = SHA2_256,
		blockSize = 64,
		key = {	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,
				0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,
				0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19},
		message = Stream.fromArray({0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,
									0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,0xcd,}),
		hmac = "82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b"
	},
--	{	digest = SHA2_256,
--		blockSize = 64,
--		key = {	0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,
--				0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,},
--		message = Stream.fromString("Test With Truncation"),
--		hmac = "a3b6167473100ee06e0c796c2955552b"
--	},
	{	digest = SHA2_256,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa},
		message = Stream.fromString("Test Using Larger Than Block-Size Key - Hash Key First"),
		hmac = "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54"
	},
	{	digest = SHA2_256,
		blockSize = 64,
		key = {	0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,
				0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa},
		message = Stream.fromString("This is a test using a larger than block-size key and a larger than block-size data. The key needs to be hashed before being used by the HMAC algorithm."),
		hmac = "9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2"
	},

};

local hash = HMAC();

for k,v in pairs(tests) do
	local res = hash
				.setBlockSize(v.blockSize)
				.setDigest(v.digest)
				.setKey(v.key)
				.init()
				.update(v.message)
				.finish()
				.asHex();

	assert(res == v.hmac, String.format(
		"TEST FAILED! MESSAGE(%s) EXPECTED(%s) ACTUAL(%s)",
		v.message,
		v.hmac,
		res));

end
