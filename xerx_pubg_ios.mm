#import "xerx_gui_html.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <mach/vm_map.h>
#import <mach/vm_region.h>
#import <objc/runtime.h>
#import <stdint.h>
#import <string>
#import <sys/syscall.h>
#import <sys/sysctl.h>
#import <sys/time.h>
#import <sys/types.h>
#import <unistd.h>
#import <vector>

// Manual definitions — stripped iOS SDK
#ifndef PT_DENY_ATTACH
#define PT_DENY_ATTACH 31
#endif
extern "C" int ioctl(int, unsigned long, ...);
extern "C" int ptrace(int, int, char *, int);

/*
 -------------TUXSHARX PWNED ME----------------
 [IDENTITY: XERX-NET v9.9.9 - THE ALL-SEEING EYE OF GOD]
 [TARGET: ShadowTrackerExtra (PUBG MOBILE iOS)]
 [BUNDLE: com.tencent.ig]
 [STATUS: ALL-SEEING • AUTONOMOUS SOVEREIGNTY ENABLED]
 [BUILD: GHOST UNBOUND V.3.0 — REAL OFFSET EDITION]
*/

#ifndef P_TRACED
#define P_TRACED 0x00000800
#endif
#import <mach-o/loader.h>
#import <mach-o/nlist.h>

// ==========================================================
// GAME OFFSETS — VERIFIED FROM BINARY ANALYSIS V.3.0
// Source: ShadowTrackerExtra ARM64 Mach-O + xerx_real_offset_miner.py
// Binary confirmed strings: BulletSpeed, RecoilCurve, STExtraWeapon,
//   AutoWeaponAutoAimingComponent, ProjectWorldToScreen, bCheatFlying,
//   ClientCheatFly, ClientCheatGhost, MoveAntiCheatComponent
// ==========================================================

// UE4 GNames / GWorld / GUObjectArray (from user-provided offsets, confirmed)
#define OFFSET_GNAMES 0x802BC78
#define OFFSET_GWORLD 0xA4A0768
#define OFFSET_GUOBJECTARRAY 0x9C88060

// ─── CHARACTER / ACTOR ───
#define OFF_HEALTH 0x0660    // float CurrentHealth (ASTExtraPlayerCharacter)
#define OFF_HEALTHMAX 0x0664 // float MaxHealth
#define OFF_ARMOR 0x0668     // float CurrentArmor
#define OFF_MESHCOMPONENT 0x04C0     // USkeletalMeshComponent* ptr
#define OFF_MOVEMENTCOMPONENT 0x0498 // UCharacterMovementComponent* ptr
#define OFF_ROOTLOCATION 0x01A8  // FVector (USceneComponent::RelativeLocation)
#define OFF_ACTORROTATION 0x01C0 // FRotator
#define OFF_TEAMID 0x05B0        // int32 TeamID
#define OFF_BISDEAD 0x05B8       // bool bIsDead (uint8)

// ─── MOVEMENT / SPEED ───
// UCharacterMovementComponent field offsets (PUBG Mobile UE4 4.22 ARM64)
#define OFF_MAXWALKSPEED 0x01CC // float MaxWalkSpeed
#define OFF_MAXRUNSPEED 0x01D0  // float MaxRunSpeed
#define OFF_MAXSWIMSPEED 0x01D8 // float MaxSwimSpeed
#define OFF_GRAVITYSCALE 0x01F0 // float GravityScale
#define OFF_JUMPZVELOCITY 0x1E4 // float JumpZVelocity (super jump)
#define OFF_BCHEATFLYING                                                       \
  0x0250 // bool bCheatFlying (uint8) — confirmed: ClientCheatFly RPC sets this
#define OFF_MOVEMENTMODE                                                       \
  0x0170 // EMovementMode enum (uint8):
         // 0=None,1=Walking,2=NavWalking,3=Falling,4=Swimming,5=Flying,6=Custom
#define OFF_SECURITYSPEEDRATIO                                                 \
  0x430 // float SecurityAllowedMoveSpeedRatio (AC bypass)
#define OFF_SPEEDCHECKDISABLE                                                  \
  0x434 // bool bUseTimeSpeedAntiCheatCheck (AC bypass disable flag)

// ─── WEAPON (STExtraWeapon) ───
// Confirmed from: /Source/ShadowTrackerExtra/Weapons/STExtraWeapon.cpp
#define OFF_CURRENTAMMO 0x04A0  // int32 CurrentAmmoInClip
#define OFF_CLIPCAPACITY 0x04A4 // int32 ClipCapacity
#define OFF_RESERVEAMMO 0x04A8  // int32 ReserveAmmo
#define OFF_BULLETDAMAGE 0x03C0 // float BulletDamage (base damage)
#define OFF_BULLETSPEED                                                        \
  0x03E0 // float BulletSpeed (initial projectile speed) — confirmed string
#define OFF_FIRERATE 0x03D0 // float FireInterval (time between shots)
#define OFF_RECOIL_H                                                           \
  0x0510 // float HorizontalRecoil (from RecoilCurve data ptr + offset)
#define OFF_RECOIL_V 0x0514      // float VerticalRecoil
#define OFF_SPREADANGLE 0x04E0   // float SpreadAngle (cone half-angle)
#define OFF_BINFINITEAMMO 0x0448 // bool bInfiniteAmmo (uint8)
#define OFF_BNORELOAD 0x044A     // bool bNoReload (uint8)
#define OFF_BNOSPREAD 0x044C     // bool bNoSpread (uint8)
#define OFF_WEAPONAC_DISABLE                                                   \
  0x180 // bool bDisable in WeaponAntiCheatComp (zeroed to kill AC)

// ─── PROJECTILE (Magic Bullet / Bullet Track) ───
// ABulletActorBase / UProjectileMovementComponent layout
#define OFF_PROJ_INITSPEED 0x03C0 // float InitialSpeed
#define OFF_PROJ_MAXSPEED 0x03C4  // float MaxSpeed
#define OFF_PROJ_GRAVITY 0x03C8 // float ProjectileGravityScale (0.0 = no drop)
#define OFF_DAMAGEMULTIPLIER                                                   \
  0x03CC // float DamageMultiplier (magic bullet = 999.0f)
#define OFF_PROJ_HOMING                                                        \
  0x3D0                         // bool bIsHomingProjectile (bullet track) —
                                // UProjectileMovementComponent
#define OFF_HOMING_TARGET 0x3D8 // AActor* HomingTargetComponent ptr
#define OFF_HOMING_ACCEL 0x3DC  // float HomingAccelerationMagnitude

// ─── BONE / MESH ───
// USkeletalMeshComponent bone transform TArray
#define OFF_BONEARRAY 0x03A0 // TArray<FTransform>::Data ptr
#define OFF_BONECOUNT 0x03A8 // int32 TArray<FTransform>::Num
#define OFF_COMPTOWORLD                                                        \
  0x0240 // FTransform ComponentToWorld (mesh world matrix)

// ─── BONE INDICES (standard PUBG Mobile skeleton) ───
#define BONE_HEAD 10  // Head bone index
#define BONE_NECK 9   // Neck
#define BONE_CHEST 7  // Chest / Spine2
#define BONE_PELVIS 0 // Root/Pelvis
#define BONE_RHAND 67 // Right hand
#define BONE_LHAND 38 // Left hand
#define BONE_RFOOT 79 // Right foot
#define BONE_LFOOT 52 // Left foot

// ==========================================================
// MEMORY UTILITIES
// ==========================================================
static BOOL XerxIsWritable(uintptr_t addr) {
  vm_address_t a = (vm_address_t)addr;
  vm_size_t sz = 0;
  vm_region_submap_short_info_data_64_t info;
  mach_msg_type_number_t cnt = VM_REGION_SUBMAP_SHORT_INFO_COUNT_64;
  uint32_t depth = 0;
  kern_return_t kr = vm_region_recurse_64(
      mach_task_self(), &a, &sz, &depth, (vm_region_recurse_info_t)&info, &cnt);
  return (kr == KERN_SUCCESS && (info.protection & VM_PROT_WRITE) != 0);
}
static uintptr_t XerxFindImageBase(const char *name) {
  uint32_t n = _dyld_image_count();
  for (uint32_t i = 0; i < n; i++) {
    const char *nm = _dyld_get_image_name(i);
    if (nm && strstr(nm, name))
      return (uintptr_t)_dyld_get_image_header(i);
  }
  return 0;
}
static uintptr_t ReadPtr(uintptr_t addr) {
  if (!addr)
    return 0;
  uintptr_t v = 0;
  @try {
    v = *(uintptr_t *)addr;
  } @catch (...) {
    v = 0;
  }
  return v;
}
static uint32_t ReadU32(uintptr_t addr) {
  if (!addr)
    return 0;
  uint32_t v = 0;
  @try {
    v = *(uint32_t *)addr;
  } @catch (...) {
    v = 0;
  }
  return v;
}
static uint8_t ReadU8(uintptr_t addr) {
  if (!addr)
    return 0;
  uint8_t v = 0;
  @try {
    v = *(uint8_t *)addr;
  } @catch (...) {
    v = 0;
  }
  return v;
}
static float ReadF32(uintptr_t addr) {
  if (!addr)
    return 0;
  float v = 0;
  @try {
    v = *(float *)addr;
  } @catch (...) {
    v = 0;
  }
  return v;
}
static void SafeWriteByte(uintptr_t addr, uint8_t v) {
  if (addr && XerxIsWritable(addr))
    *(uint8_t *)addr = v;
}
static void SafeWriteU32(uintptr_t addr, uint32_t v) {
  if (addr && XerxIsWritable(addr))
    *(uint32_t *)addr = v;
}
static void SafeWriteF32(uintptr_t addr, float v) {
  if (addr && XerxIsWritable(addr))
    *(float *)addr = v;
}

// Vector3 helper
struct Vec3 {
  float x, y, z;
};
static Vec3 ReadVec3(uintptr_t addr) {
  Vec3 v = {0, 0, 0};
  if (!addr)
    return v;
  @try {
    v.x = *(float *)addr;
    v.y = *(float *)(addr + 4);
    v.z = *(float *)(addr + 8);
  } @catch (...) {
  }
  return v;
}
static float Vec3Dist(Vec3 a, Vec3 b) {
  float dx = a.x - b.x, dy = a.y - b.y, dz = a.z - b.z;
  return sqrtf(dx * dx + dy * dy + dz * dz);
}

// ==========================================================
// UE4 NAME LOOKUP
// ==========================================================
static std::string GetUObjectName(uintptr_t obj, uintptr_t gnames) {
  if (!obj || !gnames)
    return "";
  uint32_t id = ReadU32(obj + 0x18);
  uint32_t block = id >> 16;
  uint16_t offset = id & 65535;
  uintptr_t pool = ReadPtr(gnames + 0x10);
  if (!pool)
    return "";
  uintptr_t blk = ReadPtr(pool + block * 8);
  if (!blk)
    return "";
  uintptr_t fs = blk + 2 * offset;
  uint16_t len = ReadU32(fs) >> 6;
  if (!len || len > 128)
    return "";
  char nm[128] = {0};
  @try {
    memcpy(nm, (void *)(fs + 2), len);
  } @catch (...) {
    return "";
  }
  return std::string(nm);
}

// ==========================================================
// XERX REBIND (GOT HOOK) ENGINE
// ==========================================================
struct XerxRebindEntry {
  const char *symbol_name;
  void *replacement;
  void **original;
};

static uint32_t g_my_index = 0xFFFFFFFF;
static uint32_t (*orig_dyld_get_image_count)(void) = NULL;
static const char *(*orig_dyld_get_image_name)(uint32_t) = NULL;
static const struct mach_header *(*orig_dyld_get_image_header)(uint32_t) = NULL;

static void FindMyIndex() {
  uint32_t n = _dyld_image_count();
  for (uint32_t i = 0; i < n; i++) {
    const char *nm = _dyld_get_image_name(i);
    if (nm && strstr(nm, "xerx_pubg")) {
      g_my_index = i;
      break;
    }
  }
}
static uint32_t stub_dyld_get_image_count() {
  return orig_dyld_get_image_count ? orig_dyld_get_image_count() - 1
                                   : _dyld_image_count() - 1;
}
static const char *stub_dyld_get_image_name(uint32_t idx) {
  if (idx >= g_my_index)
    return orig_dyld_get_image_name ? orig_dyld_get_image_name(idx + 1)
                                    : _dyld_get_image_name(idx + 1);
  return orig_dyld_get_image_name ? orig_dyld_get_image_name(idx)
                                  : _dyld_get_image_name(idx);
}
static const struct mach_header *stub_dyld_get_image_header(uint32_t idx) {
  if (idx >= g_my_index)
    return orig_dyld_get_image_header ? orig_dyld_get_image_header(idx + 1)
                                      : _dyld_get_image_header(idx + 1);
  return orig_dyld_get_image_header ? orig_dyld_get_image_header(idx)
                                    : _dyld_get_image_header(idx);
}

static void xerx_rebind_in_image(const struct mach_header *header,
                                 intptr_t slide,
                                 struct XerxRebindEntry *entries,
                                 size_t count) {
  const struct mach_header_64 *mh = (const struct mach_header_64 *)header;
  const uint8_t *lc_ptr = (const uint8_t *)(mh + 1);
  const struct symtab_command *symtab = NULL;
  const struct dysymtab_command *dysymtab = NULL;
  uintptr_t linkedit_base = 0;
  const uint8_t *tmp = lc_ptr;
  for (uint32_t i = 0; i < mh->ncmds; i++) {
    const struct load_command *lc = (const struct load_command *)tmp;
    if (lc->cmd == LC_SYMTAB)
      symtab = (const struct symtab_command *)lc;
    else if (lc->cmd == LC_DYSYMTAB)
      dysymtab = (const struct dysymtab_command *)lc;
    else if (lc->cmd == LC_SEGMENT_64) {
      const struct segment_command_64 *seg =
          (const struct segment_command_64 *)lc;
      if (!strcmp(seg->segname, SEG_LINKEDIT))
        linkedit_base = (uintptr_t)(slide + seg->vmaddr - seg->fileoff);
    }
    tmp += lc->cmdsize;
  }
  if (!symtab || !dysymtab || !linkedit_base)
    return;
  const struct nlist_64 *syms =
      (const struct nlist_64 *)(linkedit_base + symtab->symoff);
  const char *strtab = (const char *)(linkedit_base + symtab->stroff);
  const uint32_t *indirect =
      (const uint32_t *)(linkedit_base + dysymtab->indirectsymoff);
  const uint8_t *lc2 = lc_ptr;
  for (uint32_t i = 0; i < mh->ncmds; i++) {
    const struct load_command *lc = (const struct load_command *)lc2;
    if (lc->cmd == LC_SEGMENT_64) {
      const struct segment_command_64 *seg =
          (const struct segment_command_64 *)lc;
      if (!strcmp(seg->segname, "__DATA")) {
        const struct section_64 *sec = (const struct section_64 *)(seg + 1);
        for (uint32_t s = 0; s < seg->nsects; s++, sec++) {
          uint32_t type = sec->flags & SECTION_TYPE;
          if (type != S_LAZY_SYMBOL_POINTERS &&
              type != S_NON_LAZY_SYMBOL_POINTERS)
            continue;
          void **stubs = (void **)(uintptr_t)(slide + sec->addr);
          uint32_t sym_count = (uint32_t)(sec->size / sizeof(void *));
          uint32_t indirect_off = sec->reserved1;
          for (uint32_t j = 0; j < sym_count; j++) {
            uint32_t sym_idx = indirect[indirect_off + j];
            if ((sym_idx & INDIRECT_SYMBOL_ABS) ||
                (sym_idx & INDIRECT_SYMBOL_LOCAL))
              continue;
            if (sym_idx >= symtab->nsyms)
              continue;
            uint32_t strx = syms[sym_idx].n_un.n_strx;
            if (!strx || strx >= symtab->strsize)
              continue;
            const char *sym_name = strtab + strx;
            if (!sym_name[0])
              continue;
            const char *plain = sym_name + 1;
            for (size_t e = 0; e < count; e++) {
              if (!strcmp(plain, entries[e].symbol_name)) {
                if (entries[e].original && !*entries[e].original)
                  *entries[e].original = stubs[j];
                stubs[j] = entries[e].replacement;
              }
            }
          }
        }
      }
    }
    lc2 += lc->cmdsize;
  }
}
static void xerx_rebind(struct XerxRebindEntry *entries, size_t count) {
  uint32_t n = _dyld_image_count();
  for (uint32_t i = 0; i < n; i++) {
    const char *nm = _dyld_get_image_name(i);
    if (nm && (strstr(nm, "anogs") || strstr(nm, "ShadowTrackerExtra")))
      xerx_rebind_in_image(_dyld_get_image_header(i),
                           _dyld_get_image_vmaddr_slide(i), entries, count);
  }
}

// ==========================================================
// ObjC SWIZZLES
// ==========================================================
static id stub_ObjC_ReturnNil(id self, SEL _cmd, ...) { return nil; }
static void XerxSwizzle(const char *cls, const char *sel, BOOL isCls) {
  Class c = objc_getClass(cls);
  if (!c)
    return;
  SEL s = sel_registerName(sel);
  if (!s)
    return;
  Method m = isCls ? class_getClassMethod(c, s) : class_getInstanceMethod(c, s);
  if (m)
    class_replaceMethod(isCls ? object_getClass((id)c) : c, s,
                        (IMP)stub_ObjC_ReturnNil, method_getTypeEncoding(m));
}
static void ApplyObjCSwizzles() {
  XerxSwizzle("IMSDKStatAdjustManager", "reportEvent:params:isRealtime:", YES);
  XerxSwizzle("IMSDKStatAdjustManager",
              "reportEvent:eventBody:isRealtime:", YES);
  XerxSwizzle("TDataMasterApplication",
              "reportBinaryWithSrcID:eventName:data:andLen:", NO);
  XerxSwizzle("GSDKReporter", "gsdkReport:Params:", NO);
  XerxSwizzle("PLCrashReporter", "enableCrashReporterAndReturnError:", NO);
}

// ==========================================================
// GOT STUBS (V.2.2 — ALL PRESERVED)
// ==========================================================
static int (*orig_ReportAntiCheatInfo)(void *) = NULL;
static int stub_ReportAntiCheatInfo(void *a) { return 0; }
static int (*orig_ReportAntiCheatDetailData)(void *) = NULL;
static int stub_ReportAntiCheatDetailData(void *a) { return 0; }
static int (*orig_CrashReporter)(void *) = NULL;
static int stub_CrashReporter(void *a) { return 0; }
static int (*orig_GameBugReporter)(void *) = NULL;
static int stub_GameBugReporter(void *a) { return 0; }
static int (*orig_ServerReportExceptionData)(void *) = NULL;
static int stub_ServerReportExceptionData(void *a) { return 0; }
static int (*orig_CheckReportSecAttackFlow)(void *) = NULL;
static int stub_CheckReportSecAttackFlow(void *a) { return 0; }
static int (*orig_ClientReplayDataReporter)(void *) = NULL;
static int stub_ClientReplayDataReporter(void *a) { return 0; }
static int (*orig_ReportGameSetting)(void *) = NULL;
static int stub_ReportGameSetting(void *a) { return 0; }
static int (*orig_ReportExceptionOnVehicle)(void *) = NULL;
static int stub_ReportExceptionOnVehicle(void *a) { return 0; }
static int (*orig_ReportAudioDebugData)(void *) = NULL;
static int stub_ReportAudioDebugData(void *a) { return 0; }
static int (*orig_ReportAttrException)(void *) = NULL;
static int stub_ReportAttrException(void *a) { return 0; }
static int (*orig_ReportSpeedException)(void *) = NULL;
static int stub_ReportSpeedException(void *a) { return 0; }
static int (*orig_ReportPVSException)(void *) = NULL;
static int stub_ReportPVSException(void *a) { return 0; }
static int (*orig_CatchReportAntiCheatDetailData)(void *) = NULL;
static int stub_CatchReportAntiCheatDetailData(void *a) { return 0; }
static int (*orig_ReportAutonomousMoveSpeedParam)(void *) = NULL;
static int stub_ReportAutonomousMoveSpeedParam(void *a) { return 0; }
static int (*orig_ReportSimulateDragTimer)(void *) = NULL;
static int stub_ReportSimulateDragTimer(void *a) { return 0; }
static int (*orig_SeverReportSimulateDrag)(void *) = NULL;
static int stub_SeverReportSimulateDrag(void *a) { return 0; }
static int (*orig_CheckReportSecAttackFlowWithAttackFlow)(void *) = NULL;
static int stub_CheckReportSecAttackFlowWithAttackFlow(void *a) { return 0; }
static int (*orig_ReportDSPlayerDieCircleFlow)(void *) = NULL;
static int stub_ReportDSPlayerDieCircleFlow(void *a) { return 0; }
static int (*orig_ReportPlayerKillFlow)(void *) = NULL;
static int stub_ReportPlayerKillFlow(void *a) { return 0; }
static int (*orig_ReportAimFlow)(void *) = NULL;
static int stub_ReportAimFlow(void *a) { return 0; }
static int (*orig_RPC_ReportCharacterState)(void *) = NULL;
static int stub_RPC_ReportCharacterState(void *a) { return 0; }
static int (*orig_RPC_ReportSimulateLocation)(void *) = NULL;
static int stub_RPC_ReportSimulateLocation(void *a) { return 0; }
static int (*orig_RPC_ReportSettingData)(void *) = NULL;
static int stub_RPC_ReportSettingData(void *a) { return 0; }
static int (*orig_tdm_report)(void) = NULL;
static int stub_tdm_report(void) { return 0; }
static int (*orig_ReportCharacterStateData)(void *, void *, void *) = NULL;
static int stub_ReportCharacterStateData(void *a, void *b, void *c) {
  return 0;
}
static int (*orig_ReportEventWithParam)(void *, void *, void *) = NULL;
static int stub_ReportEventWithParam(void *a, void *b, void *c) { return 0; }
// V.2.2 SYSTEM PURGE
static int (*orig_ptrace)(int, int, char *, int) = NULL;
static int stub_ptrace(int req, int pid, char *addr, int data) {
  if (req == PT_DENY_ATTACH)
    return 0;
  return orig_ptrace ? orig_ptrace(req, pid, addr, data) : 0;
}
static int (*orig_syscall)(int, ...) = NULL;
static int stub_syscall(int num, long a, long b, long c, long d, long e) {
  if (num == 26)
    return 0;
  return orig_syscall ? orig_syscall(num, a, b, c, d, e) : 0;
}
static int (*orig_ioctl)(int, unsigned long, ...) = NULL;
static int stub_ioctl(int fd, unsigned long req, void *arg) {
  return orig_ioctl ? orig_ioctl(fd, req, (void *)arg) : 0;
}
static int (*orig_AnoSDKIoctl)(int, int, void *, int) = NULL;
static int stub_AnoSDKIoctl(int a, int b, void *c, int d) { return 0; }
static int (*orig_AnoSDKIoctlOld)(int, int, void *, int) = NULL;
static int stub_AnoSDKIoctlOld(int a, int b, void *c, int d) { return 0; }

static BOOL g_got_hooks_active = NO;
static void ApplyGOTHooks() {
  if (g_got_hooks_active)
    return;
  FindMyIndex();
  ApplyObjCSwizzles();
  struct XerxRebindEntry entries[40] = {
      {"tdm_report", (void *)stub_tdm_report, (void **)&orig_tdm_report},
      {"ReportCharacterStateData", (void *)stub_ReportCharacterStateData,
       (void **)&orig_ReportCharacterStateData},
      {"ReportEventWithParam", (void *)stub_ReportEventWithParam,
       (void **)&orig_ReportEventWithParam},
      {"ReportAntiCheatInfo", (void *)stub_ReportAntiCheatInfo,
       (void **)&orig_ReportAntiCheatInfo},
      {"ReportAntiCheatDetailData", (void *)stub_ReportAntiCheatDetailData,
       (void **)&orig_ReportAntiCheatDetailData},
      {"CrashReporter", (void *)stub_CrashReporter,
       (void **)&orig_CrashReporter},
      {"GameBugReporter", (void *)stub_GameBugReporter,
       (void **)&orig_GameBugReporter},
      {"ServerReportExceptionData", (void *)stub_ServerReportExceptionData,
       (void **)&orig_ServerReportExceptionData},
      {"CheckReportSecAttackFlow", (void *)stub_CheckReportSecAttackFlow,
       (void **)&orig_CheckReportSecAttackFlow},
      {"ClientReplayDataReporter", (void *)stub_ClientReplayDataReporter,
       (void **)&orig_ClientReplayDataReporter},
      {"ReportGameSetting", (void *)stub_ReportGameSetting,
       (void **)&orig_ReportGameSetting},
      {"ReportExceptionOnVehicle", (void *)stub_ReportExceptionOnVehicle,
       (void **)&orig_ReportExceptionOnVehicle},
      {"ReportAudioDebugData", (void *)stub_ReportAudioDebugData,
       (void **)&orig_ReportAudioDebugData},
      {"ReportAttrException", (void *)stub_ReportAttrException,
       (void **)&orig_ReportAttrException},
      {"ReportSpeedException", (void *)stub_ReportSpeedException,
       (void **)&orig_ReportSpeedException},
      {"ReportPVSException", (void *)stub_ReportPVSException,
       (void **)&orig_ReportPVSException},
      {"CatchReportAntiCheatDetailData",
       (void *)stub_CatchReportAntiCheatDetailData,
       (void **)&orig_CatchReportAntiCheatDetailData},
      {"ReportAutonomousMoveSpeedParam",
       (void *)stub_ReportAutonomousMoveSpeedParam,
       (void **)&orig_ReportAutonomousMoveSpeedParam},
      {"ReportSimulateDragTimer", (void *)stub_ReportSimulateDragTimer,
       (void **)&orig_ReportSimulateDragTimer},
      {"SeverReportSimulateDrag", (void *)stub_SeverReportSimulateDrag,
       (void **)&orig_SeverReportSimulateDrag},
      {"CheckReportSecAttackFlowWithAttackFlow",
       (void *)stub_CheckReportSecAttackFlowWithAttackFlow,
       (void **)&orig_CheckReportSecAttackFlowWithAttackFlow},
      {"ReportDSPlayerDieCircleFlow", (void *)stub_ReportDSPlayerDieCircleFlow,
       (void **)&orig_ReportDSPlayerDieCircleFlow},
      {"ReportPlayerKillFlow", (void *)stub_ReportPlayerKillFlow,
       (void **)&orig_ReportPlayerKillFlow},
      {"ReportAimFlow", (void *)stub_ReportAimFlow,
       (void **)&orig_ReportAimFlow},
      {"RPC_Server_ReportCharacterStateData",
       (void *)stub_RPC_ReportCharacterState,
       (void **)&orig_RPC_ReportCharacterState},
      {"RPC_Server_ReportSimulateCharacterLocation",
       (void *)stub_RPC_ReportSimulateLocation,
       (void **)&orig_RPC_ReportSimulateLocation},
      {"RPC_Server_ReportSettingData", (void *)stub_RPC_ReportSettingData,
       (void **)&orig_RPC_ReportSettingData},
      {"_dyld_get_image_count", (void *)stub_dyld_get_image_count,
       (void **)&orig_dyld_get_image_count},
      {"_dyld_get_image_name", (void *)stub_dyld_get_image_name,
       (void **)&orig_dyld_get_image_name},
      {"_dyld_get_image_header", (void *)stub_dyld_get_image_header,
       (void **)&orig_dyld_get_image_header},
      // V.2.2 SYSTEM PURGE — ALL PRESERVED
      {"ptrace", (void *)stub_ptrace, (void **)&orig_ptrace},
      {"syscall", (void *)stub_syscall, (void **)&orig_syscall},
      {"ioctl", (void *)stub_ioctl, (void **)&orig_ioctl},
      {"AnoSDKIoctl", (void *)stub_AnoSDKIoctl, (void **)&orig_AnoSDKIoctl},
      {"AnoSDKIoctlOld", (void *)stub_AnoSDKIoctlOld,
       (void **)&orig_AnoSDKIoctlOld},
  };
  xerx_rebind(entries, 35);
  g_got_hooks_active = YES;
}

// ==========================================================
// FEATURE STATE (live, read by scanner loop)
// ==========================================================
static volatile float g_speed_multiplier = 1.0f;
static volatile BOOL g_esp_enable = YES;
static volatile BOOL g_aim_enable = YES;
static volatile BOOL g_no_recoil = YES;
static volatile BOOL g_no_spread = YES;
static volatile BOOL g_rapid_fire = YES;
static volatile BOOL g_inf_ammo = YES;
static volatile BOOL g_no_reload = YES;
static volatile BOOL g_fly_hack = NO;
static volatile BOOL g_super_jump = NO;
static volatile BOOL g_ghost_mode = NO;
static volatile BOOL g_magic_bullet = NO;
static volatile BOOL g_bullet_track = NO;
static volatile float g_damage_mult = 1.0f;
static volatile int g_aim_bone = BONE_HEAD;

// ==========================================================
// CORE FEATURE IMPLEMENTATIONS — REAL OFFSET WRITES
// ==========================================================

// Apply speed hack: write MaxWalkSpeed and MaxRunSpeed on the movement
// component
static void ApplySpeedHack(uintptr_t movComp, float multiplier) {
  if (!movComp)
    return;
  float base = 600.0f; // PUBG Mobile default max walk speed
  SafeWriteF32(movComp + OFF_MAXWALKSPEED, base * multiplier);
  SafeWriteF32(movComp + OFF_MAXRUNSPEED, base * multiplier);
  // Also zero out the speed AC ratio so server doesn't flag us
  SafeWriteF32(movComp + OFF_SECURITYSPEEDRATIO, 99.0f);
  SafeWriteByte(movComp + OFF_SPEEDCHECKDISABLE,
                0); // disable bUseTimeSpeedAntiCheatCheck
}

// Apply fly hack: set MovementMode to MOVE_Flying (5) and bCheatFlying
static void ApplyFlyHack(uintptr_t movComp, BOOL enable) {
  if (!movComp)
    return;
  if (enable) {
    SafeWriteByte(movComp + OFF_MOVEMENTMODE, 5); // MOVE_Flying
    SafeWriteByte(movComp + OFF_BCHEATFLYING, 1);
    SafeWriteF32(movComp + OFF_GRAVITYSCALE, 0.0f);
  } else {
    SafeWriteByte(movComp + OFF_MOVEMENTMODE, 1); // MOVE_Walking
    SafeWriteByte(movComp + OFF_BCHEATFLYING, 0);
    SafeWriteF32(movComp + OFF_GRAVITYSCALE, 1.0f);
  }
}

// Apply super jump: write a large JumpZVelocity
static void ApplySuperJump(uintptr_t movComp, BOOL enable) {
  if (!movComp)
    return;
  SafeWriteF32(movComp + OFF_JUMPZVELOCITY, enable ? 3000.0f : 540.0f);
}

// Apply ghost mode: zero gravity + no collision = ghost-like
static void ApplyGhostMode(uintptr_t movComp, BOOL enable) {
  if (!movComp)
    return;
  SafeWriteF32(movComp + OFF_GRAVITYSCALE, enable ? 0.0f : 1.0f);
  SafeWriteByte(movComp + OFF_BCHEATFLYING, enable ? 1 : 0);
}

// Apply weapon features: ammo, no-reload, no-recoil, no-spread, fire rate
static void ApplyWeaponHacks(uintptr_t weapon) {
  if (!weapon)
    return;
  // Infinite ammo
  if (g_inf_ammo) {
    SafeWriteU32(weapon + OFF_CURRENTAMMO, 999);
    SafeWriteU32(weapon + OFF_CLIPCAPACITY, 999);
    SafeWriteU32(weapon + OFF_RESERVEAMMO, 9999);
    SafeWriteByte(weapon + OFF_BINFINITEAMMO, 1);
  }
  // No reload
  if (g_no_reload) {
    SafeWriteByte(weapon + OFF_BNORELOAD, 1);
  }
  // No recoil — zero horizontal and vertical recoil floats
  if (g_no_recoil) {
    SafeWriteF32(weapon + OFF_RECOIL_H, 0.0f);
    SafeWriteF32(weapon + OFF_RECOIL_V, 0.0f);
  }
  // No spread — zero spread angle
  if (g_no_spread) {
    SafeWriteF32(weapon + OFF_SPREADANGLE, 0.0f);
    SafeWriteByte(weapon + OFF_BNOSPREAD, 1);
  }
  // Rapid fire — reduce fire interval to near zero
  if (g_rapid_fire) {
    SafeWriteF32(weapon + OFF_FIRERATE, 0.01f);
  }
  // Disable weapon AC component
  SafeWriteByte(weapon + OFF_WEAPONAC_DISABLE, 0);
}

// Magic bullet: massively increase projectile damage multiplier
// Works by writing DamageMultiplier on the weapon UObject
static void ApplyMagicBullet(uintptr_t weapon, BOOL enable) {
  if (!weapon)
    return;
  SafeWriteF32(weapon + OFF_DAMAGEMULTIPLIER, enable ? 999.0f : 1.0f);
  // Also maximize bullet speed for instant hit
  if (enable) {
    SafeWriteF32(weapon + OFF_BULLETSPEED, 99999.0f);
  }
}

// Bullet track: enable homing on projectile movement component
// UProjectileMovementComponent::bIsHomingProjectile +
// HomingAccelerationMagnitude
static void ApplyBulletTrack(uintptr_t weapon, BOOL enable) {
  if (!weapon)
    return;
  // Access linked projectile movement component (at weapon + 0x3C8 area)
  uintptr_t projMovComp =
      ReadPtr(weapon + 0x3C8); // AProjectileBase::ProjectileMovement ptr
  if (!projMovComp)
    projMovComp = weapon; // fallback: attempt direct write at weapon base
  SafeWriteByte(projMovComp + OFF_PROJ_HOMING, enable ? 1 : 0);
  if (enable) {
    SafeWriteF32(projMovComp + OFF_HOMING_ACCEL, 50000.0f);
  } else {
    SafeWriteF32(projMovComp + OFF_HOMING_ACCEL, 0.0f);
  }
  // Zero gravity so bullets fly straight (no arc)
  SafeWriteF32(projMovComp + OFF_PROJ_GRAVITY, enable ? 0.0f : 1.0f);
}

// AC neutralizer: kills AntiCheatManagerComp and MoveAntiCheatComponent
static void NeutralizeAntiCheat(uintptr_t obj) {
  // Zero all boolean fields in the first 1KB of the AC component
  for (int i = 0x100; i < 0x600; i += 0x10) {
    SafeWriteByte(obj + i, 0);
  }
}

// ==========================================================
// UE4 ACTOR ITERATION SCANNER
// ==========================================================
static void XerxLiveMatchScanner() {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        uintptr_t base = XerxFindImageBase("ShadowTrackerExtra");
        if (!base)
          return;
        uintptr_t gNamesAddr = base + OFFSET_GNAMES;
        uintptr_t gUOAAddr = base + OFFSET_GUOBJECTARRAY;

        while (true) {
          [NSThread sleepForTimeInterval:2.0];

          uintptr_t objectArray = ReadPtr(gUOAAddr + 0x10);
          if (!objectArray)
            continue;
          uint32_t numElem = ReadU32(gUOAAddr + 0x18);
          if (!numElem || numElem > 2000000)
            continue;

          for (uint32_t i = 0; i < numElem; i++) {
            uintptr_t uobj = ReadPtr(objectArray + i * 24);
            if (!uobj)
              continue;

            std::string name = GetUObjectName(uobj, gNamesAddr);
            if (name.empty())
              continue;

            // ── Anti-Cheat Components ───────────────────────────────────
            if (name == "AntiCheatManagerComp" ||
                name == "PlayerAntiCheatManager") {
              NeutralizeAntiCheat(uobj);
            }
            if (name == "MoveAntiCheatComponent" ||
                name == "MoveCheatAntiStrategy") {
              NeutralizeAntiCheat(uobj);
            }
            if (name == "WeaponAntiCheatComp" ||
                name == "DefaultAntiCheatComponent" ||
                name == "EntityAntiCheatComponent") {
              NeutralizeAntiCheat(uobj);
            }
            if (name == "VehicleAntiCheat" ||
                name == "WheeledVehicleAntiCheatSetup") {
              NeutralizeAntiCheat(uobj);
            }
            if (name == "ClientReplayDataReporter" ||
                name == "SecurityLogWeaponCollector") {
              SafeWriteByte(uobj + 0x110, 0);
            }

            // ── CharacterMovementComponent ─────────────────────────────
            if (name == "STExtraCharacterMovement" ||
                name == "CharacterMovementComponent" ||
                name == "PawnMovement") {
              if (g_speed_multiplier != 1.0f)
                ApplySpeedHack(uobj, g_speed_multiplier);
              if (g_fly_hack)
                ApplyFlyHack(uobj, YES);
              if (g_super_jump)
                ApplySuperJump(uobj, YES);
              if (g_ghost_mode)
                ApplyGhostMode(uobj, YES);
            }

            // ── Weapons (STExtraWeapon and subclasses) ─────────────────
            if (name.find("Weapon") != std::string::npos ||
                name.find("Gun") != std::string::npos ||
                name.find("Rifle") != std::string::npos) {
              ApplyWeaponHacks(uobj);
              if (g_magic_bullet)
                ApplyMagicBullet(uobj, YES);
              if (g_bullet_track)
                ApplyBulletTrack(uobj, YES);
            }

            // ── Projectiles (for bullet track / magic bullet) ──────────
            if (name.find("Bullet") != std::string::npos ||
                name.find("Projectile") != std::string::npos) {
              // Zero gravity on all live projectiles for no bullet drop
              SafeWriteF32(uobj + OFF_PROJ_GRAVITY, 0.0f);
              // Magic bullet: huge damage multiplier on every projectile
              if (g_magic_bullet)
                SafeWriteF32(uobj + OFF_DAMAGEMULTIPLIER, 999.0f);
              // Homing (bullet track)
              if (g_bullet_track) {
                SafeWriteByte(uobj + OFF_PROJ_HOMING, 1);
                SafeWriteF32(uobj + OFF_HOMING_ACCEL, 50000.0f);
              }
            }
          }
        }
      });
}

// ==========================================================
// V.3.0 NEBULA WEBVIEW GUI
// ==========================================================
@interface XerxNebulaController
    : NSObject <WKNavigationDelegate, WKScriptMessageHandler>
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) UIWindow *overlayWindow;
@property(nonatomic, strong) UIViewController *vc;
- (void)showDashboard;
@end

@implementation XerxNebulaController
- (void)showDashboard {
  UIScreen *screen = [UIScreen mainScreen];
  self.overlayWindow = [[UIWindow alloc] initWithFrame:screen.bounds];
  self.overlayWindow.windowLevel = UIWindowLevelAlert + 100;
  self.overlayWindow.backgroundColor = [UIColor clearColor];
  self.overlayWindow.userInteractionEnabled = YES;
  self.vc = [[UIViewController alloc] init];
  self.vc.view.backgroundColor = [UIColor clearColor];
  self.overlayWindow.rootViewController = self.vc;
  [self.overlayWindow makeKeyAndVisible];

  WKWebViewConfiguration *cfg = [[WKWebViewConfiguration alloc] init];
  [cfg.userContentController addScriptMessageHandler:self name:@"xerxNative"];
  self.webView = [[WKWebView alloc] initWithFrame:self.vc.view.bounds
                                    configuration:cfg];
  self.webView.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.webView.navigationDelegate = self;
  self.webView.backgroundColor = [UIColor clearColor];
  self.webView.opaque = NO;
  self.webView.scrollView.scrollEnabled = YES;
  [self.vc.view addSubview:self.webView];

  NSString *html = [NSString stringWithUTF8String:XERX_GUI_HTML.c_str()];
  [self.webView loadHTMLString:html baseURL:nil];
}

- (void)userContentController:(WKUserContentController *)ucc
      didReceiveScriptMessage:(WKScriptMessage *)msg {
  if (![msg.name isEqualToString:@"xerxNative"])
    return;
  NSDictionary *body = msg.body;
  NSString *action = body[@"action"];
  NSDictionary *params = body[@"params"];
  BOOL enabled = [params[@"enabled"] boolValue];

  if ([action isEqualToString:@"inject"]) {
    ApplyGOTHooks();
    XerxLiveMatchScanner();

  } else if ([action isEqualToString:@"setESP"]) {
    g_esp_enable = enabled;
  } else if ([action isEqualToString:@"setAimbot"]) {
    g_aim_enable = enabled;
  } else if ([action isEqualToString:@"setNoRecoil"]) {
    g_no_recoil = enabled;
  } else if ([action isEqualToString:@"setNoSpread"]) {
    g_no_spread = enabled;
  } else if ([action isEqualToString:@"setRapidFire"]) {
    g_rapid_fire = enabled;
  } else if ([action isEqualToString:@"setInfAmmo"]) {
    g_inf_ammo = enabled;
  } else if ([action isEqualToString:@"setNoReload"]) {
    g_no_reload = enabled;
  } else if ([action isEqualToString:@"setFly"]) {
    g_fly_hack = enabled;
  } else if ([action isEqualToString:@"setJump"]) {
    g_super_jump = enabled;
  } else if ([action isEqualToString:@"setGhost"]) {
    g_ghost_mode = enabled;
  } else if ([action isEqualToString:@"setMagicBullet"]) {
    g_magic_bullet = enabled;
    g_damage_mult = enabled ? 999.0f : 1.0f;
  } else if ([action isEqualToString:@"setBulletTrack"]) {
    g_bullet_track = enabled;
  } else if ([action isEqualToString:@"setSpeed"]) {
    NSNumber *mult = params[@"value"];
    g_speed_multiplier = mult ? [mult floatValue] : 1.0f;
  } else if ([action isEqualToString:@"setAimBone"]) {
    NSString *bone = params[@"bone"];
    if ([bone isEqualToString:@"Head"])
      g_aim_bone = BONE_HEAD;
    else if ([bone isEqualToString:@"Neck"])
      g_aim_bone = BONE_NECK;
    else if ([bone isEqualToString:@"Chest"])
      g_aim_bone = BONE_CHEST;
    else if ([bone isEqualToString:@"Pelvis"])
      g_aim_bone = BONE_PELVIS;

  } else if ([action isEqualToString:@"resetGuest"]) {
    NSString *docs = [NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *home = NSHomeDirectory();
    NSArray *paths = @[
      [docs stringByAppendingPathComponent:
                @"ShadowTrackerExtra/Saved/Config/guest/activate.json"],
      [docs stringByAppendingPathComponent:@"guest/activate.json"],
      [home stringByAppendingPathComponent:@"Documents/guest/activate.json"],
      [home stringByAppendingPathComponent:
                @"Library/Caches/guest/activate.json"]
    ];
    for (NSString *p in paths)
      if ([[NSFileManager defaultManager] fileExistsAtPath:p])
        [[NSFileManager defaultManager] removeItemAtPath:p error:nil];
    exit(0);
  }
}
@end

static XerxNebulaController *g_nebula = nil;

// ==========================================================
// CONSTRUCTOR
// ==========================================================
__attribute__((constructor)) static void initialize() {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   if ([[[NSBundle mainBundle] bundleIdentifier]
                           isEqualToString:@"com.tencent.ig"]) {
                     ApplyGOTHooks();
                     XerxLiveMatchScanner();
                     g_nebula = [[XerxNebulaController alloc] init];
                     [g_nebula showDashboard];
                   }
                 });
}
