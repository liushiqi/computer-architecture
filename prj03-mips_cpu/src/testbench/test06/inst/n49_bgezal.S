#include <asm.h>
#include <regdef.h>
#include <inst_test.h>

LEAF(n49_bgezal_test)
    .set noreorder
    addiu s0, s0 ,1
    li  s2, 0x0
###test inst
    TEST_BGEZAL(0x9ec9db66, 0x029aaf84, 0xb5a8cca0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x48f555d0, 0x288dbddc, 0xabcf87b8, 0x288dbddc, 0xabcf87b8)
    TEST_BGEZAL(0xe47b2aa0, 0xc6bf36e0, 0x1eb3e3a0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x5955ebd6, 0xa44467a3, 0xdbe004f7, 0xa44467a3, 0xdbe004f7)
    TEST_BGEZAL(0x3baa4ab0, 0x7998f600, 0xf047d898, 0x7998f600, 0xf047d898)
    TEST_BGEZAL(0xbff7aa00, 0x82bf9c2c, 0x68d44fa0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xf72cd104, 0x72df5726, 0xdfbd8610, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xd8b3ba00, 0x3c5ba4aa, 0x7af32580, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x7ade7232, 0xcc24a355, 0x38bd0e50, 0xcc24a355, 0x38bd0e50)
    TEST_BGEZAL(0x8ec77978, 0xb7b716b0, 0x88cb0974, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xc15efd20, 0x0ef69dd0, 0xfa8ce8f4, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x9c29f658, 0xee20a3d8, 0x2cb20ac8, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x1c624d80, 0x838d0cd4, 0xc0a5f39a, 0x838d0cd4, 0xc0a5f39a)
    TEST_BGEZAL(0xfafd1778, 0x2277d010, 0xa31858e4, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xb129bb70, 0x4e4cf3c3, 0x65cb3d2a, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x7ab4682c, 0x3b800bd9, 0xdc102e20, 0x3b800bd9, 0xdc102e20)
    TEST_BGEZAL(0xf0c23ef0, 0x3d762dfa, 0xbf9fbd50, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x3e78666e, 0x5116d1f8, 0xcdabd338, 0x5116d1f8, 0xcdabd338)
    TEST_BGEZAL(0x10331dba, 0x172c9ad7, 0x67ac49e0, 0x172c9ad7, 0x67ac49e0)
    TEST_BGEZAL(0x9af65ad8, 0xc9182114, 0x3db85058, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x8613d8e4, 0xd1796a5e, 0x3a497608, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x774d2398, 0x463c2acc, 0xa046b6ca, 0x463c2acc, 0xa046b6ca)
    TEST_BGEZAL(0xaaa490d0, 0xe3096291, 0x92d167d4, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x530cee60, 0xe2865f30, 0x10c8cf40, 0xe2865f30, 0x10c8cf40)
    TEST_BGEZAL(0x103d4d72, 0x801ced08, 0x12db7c88, 0x801ced08, 0x12db7c88)
    TEST_BGEZAL(0x75b35bb0, 0xb5f0b262, 0x61e02650, 0xb5f0b262, 0x61e02650)
    TEST_BGEZAL(0x558ac57d, 0x9b874393, 0x95482680, 0x9b874393, 0x95482680)
    TEST_BGEZAL(0xdf4f0f00, 0xddbb3172, 0x573c55da, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xd05951cb, 0x9adfc9b8, 0x8aa54cc9, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xb5128d6f, 0x1bfa1c20, 0x47ffc5a0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xdfd53a06, 0x63100e90, 0xd0f1231c, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x74ba0840, 0x209b93c8, 0x74521540, 0x209b93c8, 0x74521540)
    TEST_BGEZAL(0xe265cd50, 0x4098744a, 0x31b34048, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x6885271e, 0xc1dcfe80, 0x88a4cd80, 0xc1dcfe80, 0x88a4cd80)
    TEST_BGEZAL(0xefc36830, 0x54d12648, 0xe41af3f0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xad25a725, 0xe86ffef3, 0x6920e15c, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x771729a0, 0x52213f70, 0x1bbc4d28, 0x52213f70, 0x1bbc4d28)
    TEST_BGEZAL(0x051c0bc2, 0xc53e0410, 0x7c0d79e3, 0xc53e0410, 0x7c0d79e3)
    TEST_BGEZAL(0xad4ff0d4, 0x4309ff12, 0x3abf1fbc, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xe4dbf4b8, 0x1503ba59, 0x9628c7e0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xe65eaffc, 0x40ba9d66, 0x5fdbaae0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xbeb0f688, 0x52917aa4, 0xee0a26b0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xefdfd000, 0x7880b230, 0x1f93e14a, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xe0a736fb, 0x45c93fa8, 0xf646a898, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x6360c99b, 0xf368cb16, 0x8c03a3f8, 0xf368cb16, 0x8c03a3f8)
    TEST_BGEZAL(0x930cf074, 0x52d63224, 0xc7aabdc1, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xb03418d0, 0x096d96a0, 0xaec62677, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x79d1e580, 0x20bf711c, 0x1a2e2914, 0x20bf711c, 0x1a2e2914)
    TEST_BGEZAL(0x81e06df9, 0x212e0cec, 0x9ea07a8c, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x6a064cef, 0x18955140, 0x86b2e1f0, 0x18955140, 0x86b2e1f0)
    TEST_BGEZAL(0x204d8af0, 0xffc3f740, 0xbe11f92f, 0xffc3f740, 0xbe11f92f)
    TEST_BGEZAL(0x2d24d026, 0x760258c8, 0x771f9bc2, 0x760258c8, 0x771f9bc2)
    TEST_BGEZAL(0xdd6a4690, 0x85197cce, 0xf8c6da8e, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xe3a7803c, 0x29fdc410, 0x2c377344, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xb1d59e1c, 0xff2889a0, 0x47311a00, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xba405044, 0x70ba29d0, 0x665a0285, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x966c21d0, 0x95320960, 0x472b06c6, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x2640fab0, 0xd2c9245e, 0x261888e8, 0xd2c9245e, 0x261888e8)
    TEST_BGEZAL(0x8919d5ac, 0x8a0b4f16, 0x981f1b40, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xb4f05260, 0xea8b953c, 0xc7804f58, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x05cbb32d, 0x10e22c70, 0xe7772208, 0x10e22c70, 0xe7772208)
    TEST_BGEZAL(0xda6de980, 0xe0d533d6, 0xd48d1074, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x30043918, 0x6415db60, 0x73aaeff8, 0x6415db60, 0x73aaeff8)
    TEST_BGEZAL(0x3f598570, 0xb5adc358, 0x22f12300, 0xb5adc358, 0x22f12300)
    TEST_BGEZAL(0xd94a1fc4, 0xff41f972, 0xad185750, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x03070850, 0x60342c78, 0x8ae75d1c, 0x60342c78, 0x8ae75d1c)
    TEST_BGEZAL(0x9d6c5b50, 0x62d50b2c, 0xbf7bbbe0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xefc3fb6d, 0x41adc580, 0x44811cea, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x4461ad06, 0x8d1ebf10, 0x6cbe3a80, 0x8d1ebf10, 0x6cbe3a80)
    TEST_BGEZAL(0x3eea0f88, 0x16af2f88, 0x70e0f0c8, 0x16af2f88, 0x70e0f0c8)
    TEST_BGEZAL(0x00539980, 0x7419e600, 0x857ede78, 0x7419e600, 0x857ede78)
    TEST_BGEZAL(0x12755708, 0x7f8d4c60, 0x35baf096, 0x7f8d4c60, 0x35baf096)
    TEST_BGEZAL(0xa8566262, 0xa0dc0850, 0x935b76fc, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x4312482c, 0x3babfa88, 0x8c744b40, 0x3babfa88, 0x8c744b40)
    TEST_BGEZAL(0x7258b698, 0x37025294, 0x2442dc78, 0x37025294, 0x2442dc78)
    TEST_BGEZAL(0xc8112dce, 0xa7edf5bc, 0xf05ebc8a, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x76825d9a, 0x1a5e8a78, 0x8b96ed40, 0x1a5e8a78, 0x8b96ed40)
    TEST_BGEZAL(0xd5acf404, 0x3786e87b, 0x33e1ad01, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x2d684380, 0x353a658f, 0x3a78a716, 0x353a658f, 0x3a78a716)
    TEST_BGEZAL(0x6d24026c, 0x4c07aa70, 0x262d7a68, 0x4c07aa70, 0x262d7a68)
    TEST_BGEZAL(0xe781e987, 0xbb172b3f, 0x9506bf76, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x849e87e0, 0x95eae311, 0x2a431460, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xb77b8830, 0xb6cd8f00, 0x599c33ac, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x38b32afe, 0xcb06ea2a, 0x12b1bd66, 0xcb06ea2a, 0x12b1bd66)
    TEST_BGEZAL(0x364547e8, 0x9d0b2668, 0xe1c59c78, 0x9d0b2668, 0xe1c59c78)
    TEST_BGEZAL(0x9488b99c, 0x10cbe1b8, 0x407da648, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x45557d80, 0x2c5ffe58, 0x41c23300, 0x2c5ffe58, 0x41c23300)
    TEST_BGEZAL(0x4162a47e, 0x4859ca40, 0x62511bd0, 0x4859ca40, 0x62511bd0)
    TEST_BGEZAL(0xd40f9260, 0xbdc20ca8, 0x6ad8501b, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x21e007b0, 0x2f6840b0, 0xd69ebe4f, 0x2f6840b0, 0xd69ebe4f)
    TEST_BGEZAL(0xe3f7d594, 0x7c80bd20, 0xea950588, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x626f9ad8, 0x0f794fbe, 0xa51e32c5, 0x0f794fbe, 0xa51e32c5)
    TEST_BGEZAL(0x4f579ee1, 0x84707f22, 0x2986d290, 0x84707f22, 0x2986d290)
    TEST_BGEZAL(0x76bf3bd0, 0x7ef6f91e, 0x459f7678, 0x7ef6f91e, 0x459f7678)
    TEST_BGEZAL(0x7fefcdfc, 0xfbba8330, 0x67cc1de8, 0xfbba8330, 0x67cc1de8)
    TEST_BGEZAL(0xc7f97c10, 0x122c9730, 0x9d2d92cb, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x98067158, 0x84d71d28, 0x4fe8de78, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xccfee4dc, 0x522cff60, 0xacbe58f0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x8d4b877a, 0x387f5a58, 0x8ed62e39, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xf347705c, 0x72a1d604, 0xeea7aa9e, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x3be3db68, 0x9bdefb1c, 0x5996b860, 0x9bdefb1c, 0x5996b860)
    TEST_BGEZAL(0x6e8023a0, 0x7e166bf8, 0x26911a30, 0x7e166bf8, 0x26911a30)
    TEST_BGEZAL(0x3d5084b0, 0x81204f2e, 0x18c7f0aa, 0x81204f2e, 0x18c7f0aa)
    TEST_BGEZAL(0x861739d0, 0x62bf92bd, 0xb90f5834, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x26df39ca, 0x767dafc8, 0xcf001cc0, 0x767dafc8, 0xcf001cc0)
    TEST_BGEZAL(0xa06b4e88, 0xbed08880, 0x0677a59c, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x232859ce, 0x22a64fd2, 0x133f25e0, 0x22a64fd2, 0x133f25e0)
    TEST_BGEZAL(0x2b1b825c, 0x173bf5dc, 0x90d36ca0, 0x173bf5dc, 0x90d36ca0)
    TEST_BGEZAL(0x0b6a9780, 0xc1daa4c0, 0x43d23580, 0xc1daa4c0, 0x43d23580)
    TEST_BGEZAL(0x8f7e8f8c, 0x3426946d, 0x9913f9c6, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x1b2f92a4, 0xaa5510c0, 0x477026b8, 0xaa5510c0, 0x477026b8)
    TEST_BGEZAL(0x406f92c2, 0x7df268b0, 0xc8f7a25d, 0x7df268b0, 0xc8f7a25d)
    TEST_BGEZAL(0x5c221ab6, 0x455936a0, 0xd1133fb0, 0x455936a0, 0xd1133fb0)
    TEST_BGEZAL(0x2527510a, 0x19a60c80, 0x9659b2f4, 0x19a60c80, 0x9659b2f4)
    TEST_BGEZAL(0xa55ca800, 0xbc5f15c0, 0x36c63a7a, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xabe38b6a, 0xe6824b52, 0xd28b8008, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x0bfe49f4, 0x276596c8, 0x3cc61e70, 0x276596c8, 0x3cc61e70)
    TEST_BGEZAL(0xa46fdf48, 0x83a774f8, 0x5faba638, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x457d808b, 0xc70ffa10, 0xcbbce566, 0xc70ffa10, 0xcbbce566)
    TEST_BGEZAL(0x7d1e89e8, 0x6d04c2e4, 0x904db13e, 0x6d04c2e4, 0x904db13e)
    TEST_BGEZAL(0x2354ab07, 0x4e4e7f30, 0x3867d3c3, 0x4e4e7f30, 0x3867d3c3)
    TEST_BGEZAL(0x2afabf2c, 0xc62f9716, 0x8a69e0bc, 0xc62f9716, 0x8a69e0bc)
    TEST_BGEZAL(0xa27823c4, 0x623a5c87, 0x77ff0050, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xbbbbd5d8, 0x27c8b198, 0xab3cc6d1, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x72144dee, 0xf1f2eceb, 0x84cdc5c0, 0xf1f2eceb, 0x84cdc5c0)
    TEST_BGEZAL(0xbdc51fde, 0x64ff3a3c, 0xcf8014a7, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x5ba64bf2, 0x238ab968, 0xe3235e00, 0x238ab968, 0xe3235e00)
    TEST_BGEZAL(0xd7e5a6ce, 0xd2de3c44, 0x477539a5, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x4faa5480, 0x4e661200, 0x74883efc, 0x4e661200, 0x74883efc)
    TEST_BGEZAL(0x44bae210, 0xc34a99a0, 0x1e0830ef, 0xc34a99a0, 0x1e0830ef)
    TEST_BGEZAL(0x61e7c0fd, 0xb8026130, 0xd3fb617c, 0xb8026130, 0xd3fb617c)
    TEST_BGEZAL(0x180e3fdc, 0x90216418, 0x5b65ccfc, 0x90216418, 0x5b65ccfc)
    TEST_BGEZAL(0xf51d4eae, 0xc221096a, 0xec0fec6c, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xdebfa252, 0x76e76d08, 0x4216c340, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xc80f06a0, 0x96de4250, 0x7dd7b2d0, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xda25c957, 0x869e74b0, 0x9f657c90, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xe2c16e00, 0x753518e8, 0xc36e7a80, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x8493ac53, 0xeda6f700, 0x023bb300, 0x00000000, 0x00000000)
    TEST_BGEZAL(0xce17d056, 0x73e8ac0c, 0x52136032, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x1732bc45, 0xd513fa00, 0xed7448b8, 0xd513fa00, 0xed7448b8)
    TEST_BGEZAL(0x179839ac, 0x066aa5c6, 0x0296d70d, 0x066aa5c6, 0x0296d70d)
    TEST_BGEZAL(0x221b14f9, 0xcb26ec57, 0x1633f6be, 0xcb26ec57, 0x1633f6be)
    TEST_BGEZAL(0x68f6e51f, 0x629967a0, 0xa5936df4, 0x629967a0, 0xa5936df4)
    TEST_BGEZAL(0xf624bdb0, 0xaaa3de30, 0x7e6ddd50, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x82f5a6f0, 0xb188d600, 0x206fa380, 0x00000000, 0x00000000)
    TEST_BGEZAL(0x00000000, 0x36a36650, 0x44fa7d50, 0x36a36650, 0x44fa7d50)
###detect exception
    bne s2, zero, inst_error
    nop
###score ++
    addiu s3, s3, 1
###output (s0<<24)|s3
inst_error:  
    sll t1, s0, 24
    or t0, t1, s3 
    sw t0, 0(s1)
    jr ra
    nop
END(n49_bgezal_test)
