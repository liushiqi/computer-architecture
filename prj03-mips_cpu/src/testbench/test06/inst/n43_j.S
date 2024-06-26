#include <asm.h>
#include <regdef.h>
#include <inst_test.h>

LEAF(n43_j_test)
    .set noreorder
    addiu s0, s0 ,1
    li  s2, 0x0
###test inst
    TEST_J(0x42ea6edf, 0x24071ba8, 0x42ea6edf, 0x24071ba8)
    TEST_J(0xac275df0, 0x83f0722c, 0xac275df0, 0x83f0722c)
    TEST_J(0x58b91ef0, 0x226861f5, 0x58b91ef0, 0x226861f5)
    TEST_J(0xfc34d5d0, 0x47107652, 0xfc34d5d0, 0x47107652)
    TEST_J(0x997888c0, 0x4980d790, 0x997888c0, 0x4980d790)
    TEST_J(0x60af9fa4, 0x35dd2200, 0x60af9fa4, 0x35dd2200)
    TEST_J(0x47a35d90, 0xcf599ca0, 0x47a35d90, 0xcf599ca0)
    TEST_J(0x91f7d314, 0x568ed358, 0x91f7d314, 0x568ed358)
    TEST_J(0x35d76d80, 0xb40df682, 0x35d76d80, 0xb40df682)
    TEST_J(0x2bfdaf46, 0x71b52e90, 0x2bfdaf46, 0x71b52e90)
    TEST_J(0x3edce843, 0x9244bb18, 0x3edce843, 0x9244bb18)
    TEST_J(0x5273fd08, 0x17358743, 0x5273fd08, 0x17358743)
    TEST_J(0xfb4a4134, 0xf1c26750, 0xfb4a4134, 0xf1c26750)
    TEST_J(0xa359f930, 0x84e5dfc4, 0xa359f930, 0x84e5dfc4)
    TEST_J(0x8be3e4cf, 0xb44d32db, 0x8be3e4cf, 0xb44d32db)
    TEST_J(0x20a63240, 0x4c3fee78, 0x20a63240, 0x4c3fee78)
    TEST_J(0x479b3d54, 0x46df1dfb, 0x479b3d54, 0x46df1dfb)
    TEST_J(0x518a4940, 0x5e1d0288, 0x518a4940, 0x5e1d0288)
    TEST_J(0x36237e64, 0x1330ac2a, 0x36237e64, 0x1330ac2a)
    TEST_J(0xad066b28, 0xffead346, 0xad066b28, 0xffead346)
    TEST_J(0x4ee3ba5a, 0xb0423218, 0x4ee3ba5a, 0xb0423218)
    TEST_J(0x0347dbc4, 0xbb5ecfa8, 0x0347dbc4, 0xbb5ecfa8)
    TEST_J(0x67ae1e29, 0xed141958, 0x67ae1e29, 0xed141958)
    TEST_J(0x8a3807b8, 0xb277f404, 0x8a3807b8, 0xb277f404)
    TEST_J(0x8f4179d4, 0xe0bd7f4c, 0x8f4179d4, 0xe0bd7f4c)
    TEST_J(0x278a8400, 0x33969970, 0x278a8400, 0x33969970)
    TEST_J(0x99197cc8, 0x1e7bbe50, 0x99197cc8, 0x1e7bbe50)
    TEST_J(0x744fe304, 0x117dcc70, 0x744fe304, 0x117dcc70)
    TEST_J(0xd014a370, 0x5df62270, 0xd014a370, 0x5df62270)
    TEST_J(0xcf8c7a04, 0x4aaf34b6, 0xcf8c7a04, 0x4aaf34b6)
    TEST_J(0x8e288160, 0x7b400fc6, 0x8e288160, 0x7b400fc6)
    TEST_J(0xaa291a98, 0x1baf3e24, 0xaa291a98, 0x1baf3e24)
    TEST_J(0x3ee454a0, 0x5114e086, 0x3ee454a0, 0x5114e086)
    TEST_J(0xfedcb9f2, 0x3ce0752c, 0xfedcb9f2, 0x3ce0752c)
    TEST_J(0x8eeb4886, 0x1f690472, 0x8eeb4886, 0x1f690472)
    TEST_J(0xdf3cde26, 0x5fa66dd0, 0xdf3cde26, 0x5fa66dd0)
    TEST_J(0xb34017a8, 0x04ab056a, 0xb34017a8, 0x04ab056a)
    TEST_J(0xb83c5dc0, 0x3ec8df21, 0xb83c5dc0, 0x3ec8df21)
    TEST_J(0xf2d38780, 0x38dacda4, 0xf2d38780, 0x38dacda4)
    TEST_J(0x78c3b84c, 0xf01d03e0, 0x78c3b84c, 0xf01d03e0)
    TEST_J(0xdf1c051e, 0x480657c0, 0xdf1c051e, 0x480657c0)
    TEST_J(0x019cd5bc, 0x81b219e2, 0x019cd5bc, 0x81b219e2)
    TEST_J(0x46073400, 0x14116cee, 0x46073400, 0x14116cee)
    TEST_J(0xf90abd90, 0xe3ae9e38, 0xf90abd90, 0xe3ae9e38)
    TEST_J(0x2f595748, 0x322f3db0, 0x2f595748, 0x322f3db0)
    TEST_J(0x4f7064d0, 0xd19d40bb, 0x4f7064d0, 0xd19d40bb)
    TEST_J(0xb0a61578, 0x9b7cab12, 0xb0a61578, 0x9b7cab12)
    TEST_J(0x37d9cf70, 0x14fbed08, 0x37d9cf70, 0x14fbed08)
    TEST_J(0xaefbfe00, 0x2ce81d90, 0xaefbfe00, 0x2ce81d90)
    TEST_J(0x33bb8cf0, 0x81818a0c, 0x33bb8cf0, 0x81818a0c)
    TEST_J(0xe2d0fb60, 0xc6564330, 0xe2d0fb60, 0xc6564330)
    TEST_J(0x75f3e4f8, 0xe296a2e0, 0x75f3e4f8, 0xe296a2e0)
    TEST_J(0xcec98738, 0xabf2004c, 0xcec98738, 0xabf2004c)
    TEST_J(0x2a8d7670, 0x342c7e80, 0x2a8d7670, 0x342c7e80)
    TEST_J(0x1718b9de, 0x62a3cb74, 0x1718b9de, 0x62a3cb74)
    TEST_J(0x8bc8b000, 0xf5037c60, 0x8bc8b000, 0xf5037c60)
    TEST_J(0x1d349520, 0x42aaf6d0, 0x1d349520, 0x42aaf6d0)
    TEST_J(0x9f7ceda0, 0x097ed578, 0x9f7ceda0, 0x097ed578)
    TEST_J(0xaa064de0, 0xb2b82ebc, 0xaa064de0, 0xb2b82ebc)
    TEST_J(0xa2679b76, 0xab833f68, 0xa2679b76, 0xab833f68)
    TEST_J(0x18b2564a, 0xe9ca8b40, 0x18b2564a, 0xe9ca8b40)
    TEST_J(0x7d87fdbc, 0x5068c898, 0x7d87fdbc, 0x5068c898)
    TEST_J(0xa64d68a9, 0xb99102ac, 0xa64d68a9, 0xb99102ac)
    TEST_J(0x4c13501c, 0x9789f15c, 0x4c13501c, 0x9789f15c)
    TEST_J(0x0b9ffea0, 0x9b377696, 0x0b9ffea0, 0x9b377696)
    TEST_J(0x64987db5, 0xabc9fd50, 0x64987db5, 0xabc9fd50)
    TEST_J(0xfcc12490, 0x164d033e, 0xfcc12490, 0x164d033e)
    TEST_J(0x7be14bd0, 0xb0d07790, 0x7be14bd0, 0xb0d07790)
    TEST_J(0x05f42d30, 0xa0012600, 0x05f42d30, 0xa0012600)
    TEST_J(0x5bd825c0, 0xc036f1ce, 0x5bd825c0, 0xc036f1ce)
    TEST_J(0x71cc9e50, 0xf9de6878, 0x71cc9e50, 0xf9de6878)
    TEST_J(0xcef20400, 0x74a2f96f, 0xcef20400, 0x74a2f96f)
    TEST_J(0x30356457, 0x018af932, 0x30356457, 0x018af932)
    TEST_J(0xd445509d, 0x86fadf44, 0xd445509d, 0x86fadf44)
    TEST_J(0xd37d9980, 0x75bdd728, 0xd37d9980, 0x75bdd728)
    TEST_J(0x0a830f74, 0x721b2040, 0x0a830f74, 0x721b2040)
    TEST_J(0x5a78ba00, 0xf0e751e6, 0x5a78ba00, 0xf0e751e6)
    TEST_J(0x8b5a7614, 0x53349d74, 0x8b5a7614, 0x53349d74)
    TEST_J(0x9a10a8ec, 0xa8f81690, 0x9a10a8ec, 0xa8f81690)
    TEST_J(0xaf1b1580, 0x666a108a, 0xaf1b1580, 0x666a108a)
    TEST_J(0x2f922960, 0x79bca7e0, 0x2f922960, 0x79bca7e0)
    TEST_J(0x6222b470, 0x473df7a0, 0x6222b470, 0x473df7a0)
    TEST_J(0xcfeb11f8, 0xe80900f0, 0xcfeb11f8, 0xe80900f0)
    TEST_J(0x85d4b680, 0x2b490cfe, 0x85d4b680, 0x2b490cfe)
    TEST_J(0xa333bf20, 0x5f1c6698, 0xa333bf20, 0x5f1c6698)
    TEST_J(0x69efcf00, 0x2fa1d3dc, 0x69efcf00, 0x2fa1d3dc)
    TEST_J(0x8959486f, 0x8590fce0, 0x8959486f, 0x8590fce0)
    TEST_J(0xa24e76a0, 0x8b1d9dea, 0xa24e76a0, 0x8b1d9dea)
    TEST_J(0xdef254e6, 0xe9637dea, 0xdef254e6, 0xe9637dea)
    TEST_J(0x09d2dbc2, 0xd72fc808, 0x09d2dbc2, 0xd72fc808)
    TEST_J(0xb3aec756, 0x52d4a080, 0xb3aec756, 0x52d4a080)
    TEST_J(0x25078274, 0xac5ee0c0, 0x25078274, 0xac5ee0c0)
    TEST_J(0x4e132415, 0x7db7b048, 0x4e132415, 0x7db7b048)
    TEST_J(0xb4bfffe0, 0x584af448, 0xb4bfffe0, 0x584af448)
    TEST_J(0x95550edf, 0x70bf3aff, 0x95550edf, 0x70bf3aff)
    TEST_J(0x37c9b418, 0x1edea5ab, 0x37c9b418, 0x1edea5ab)
    TEST_J(0xfeb6f680, 0x87997a49, 0xfeb6f680, 0x87997a49)
    TEST_J(0xd062c193, 0xc5a1ccf0, 0xd062c193, 0xc5a1ccf0)
    TEST_J(0x16486a7c, 0x512e7094, 0x16486a7c, 0x512e7094)
    TEST_J(0x3dcadb74, 0x18932800, 0x3dcadb74, 0x18932800)
    TEST_J(0x1d42afc0, 0xfd7e0f80, 0x1d42afc0, 0xfd7e0f80)
    TEST_J(0x3f87c62c, 0x317dbeb0, 0x3f87c62c, 0x317dbeb0)
    TEST_J(0x57742340, 0xff7f31e8, 0x57742340, 0xff7f31e8)
    TEST_J(0x53470066, 0x8918c70c, 0x53470066, 0x8918c70c)
    TEST_J(0x2b88e2d8, 0x1956758a, 0x2b88e2d8, 0x1956758a)
    TEST_J(0x26155744, 0x4641aed8, 0x26155744, 0x4641aed8)
    TEST_J(0xa42620c5, 0x8d9ccc00, 0xa42620c5, 0x8d9ccc00)
    TEST_J(0x56ad76b4, 0x41dbbf00, 0x56ad76b4, 0x41dbbf00)
    TEST_J(0xd77256b8, 0x75dff4ee, 0xd77256b8, 0x75dff4ee)
    TEST_J(0xe85fbe40, 0xd0089c1c, 0xe85fbe40, 0xd0089c1c)
    TEST_J(0x5cc63d8f, 0x59ddec46, 0x5cc63d8f, 0x59ddec46)
    TEST_J(0x42479810, 0x335c1280, 0x42479810, 0x335c1280)
    TEST_J(0xd81949c0, 0xe6b6c9a0, 0xd81949c0, 0xe6b6c9a0)
    TEST_J(0xc49c14c8, 0xb60250e0, 0xc49c14c8, 0xb60250e0)
    TEST_J(0x02b295e0, 0x442430f0, 0x02b295e0, 0x442430f0)
    TEST_J(0x3ee9f35c, 0x2ac4d9cc, 0x3ee9f35c, 0x2ac4d9cc)
    TEST_J(0xa53d5f40, 0x5e997488, 0xa53d5f40, 0x5e997488)
    TEST_J(0x442ab5dd, 0xc36f026b, 0x442ab5dd, 0xc36f026b)
    TEST_J(0x3322fda8, 0x9400f0a0, 0x3322fda8, 0x9400f0a0)
    TEST_J(0xd0e25fc8, 0x34a6c1ec, 0xd0e25fc8, 0x34a6c1ec)
    TEST_J(0x7b07c5ea, 0x22f0cf9c, 0x7b07c5ea, 0x22f0cf9c)
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
END(n43_j_test)
