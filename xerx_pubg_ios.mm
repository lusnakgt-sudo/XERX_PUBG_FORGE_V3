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

// Manual definitions for missing headers (iOS SDK isolation)
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
 [STATUS: AUTONOMOUS SOVEREIGNTY ENABLED]
 [BUILD: GHOST UNBOUND ULTIMATE SYSTEM PURGE]
 [VERSION: V.3.0 - [NEBULA GUI]]
*/

#ifndef P_TRACED
#define P_TRACED 0x00000800
#endif

#import <mach-o/loader.h>
#import <mach-o/nlist.h>

// ==========================================================
// GAME OFFSETS (V.3.0)
// ==========================================================
#define OFFSET_GNAMES 0x802BC78
#define OFFSET_GWORLD 0xA4A0768
#define OFFSET_GUOBJECTARRAY 0x9C88060

// UObject field offsets
#define OFF_ACTOR_HP 0x120
#define OFF_ACTOR_MAXHP 0x124
#define OFF_ACTOR_ARMOR 0x128
#define OFF_ACTOR_LOCATION 0x1A8
#define OFF_MOVEMENT_SPEED 0x16C
#define OFF_WEAPON_AMMO 0x2E0
#define OFF_ACTOR_BONE_IDX 0x0C8

// ==========================================================
// XERX REBIND (GOT HOOK) ENGINE
// ==========================================================
struct XerxRebindEntry {
  const char *symbol_name;
  void *replacement;
  void **original;
};

// --- GHOST MASKING GLOBALS ---
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
  if (idx >= g_my_index) {
    return orig_dyld_get_image_name ? orig_dyld_get_image_name(idx + 1)
                                    : _dyld_get_image_name(idx + 1);
  }
  return orig_dyld_get_image_name ? orig_dyld_get_image_name(idx)
                                  : _dyld_get_image_name(idx);
}
static const struct mach_header *stub_dyld_get_image_header(uint32_t idx) {
  if (idx >= g_my_index) {
    return orig_dyld_get_image_header ? orig_dyld_get_image_header(idx + 1)
                                      : _dyld_get_image_header(idx + 1);
  }
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
            if (strx == 0 || strx >= symtab->strsize)
              continue;
            const char *sym_name = strtab + strx;
            if (sym_name[0] == '\0')
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

static volatile BOOL g_toggle_got_hooks = NO;
static volatile BOOL g_toggle_ptrace_block = NO;

// V.1.7 EXPERT ANCHORS
#define ANOGS_RET_ANCHOR 0x41E4
#define ACE_SAFE_SIGNATURE 0x30B1BCBA
#define TDM_REPORT_ENABLE_OFF 0x2A5711

// --- V.1.9 BEHAVIORAL SWIZZLES ---
static id stub_ObjC_ReturnNil(id self, SEL _cmd, ...) { return nil; }
static void XerxSwizzleMethod(const char *cls, const char *sel, BOOL isCls) {
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
  XerxSwizzleMethod("IMSDKStatAdjustManager",
                    "reportEvent:params:isRealtime:", YES);
  XerxSwizzleMethod("IMSDKStatAdjustManager",
                    "reportEvent:eventBody:isRealtime:", YES);
  XerxSwizzleMethod("TDataMasterApplication",
                    "reportBinaryWithSrcID:eventName:data:andLen:", NO);
  XerxSwizzleMethod("TDataMasterApplication",
                    "reportEventWithSrcID:eventName:AndEventKVArray:", NO);
  XerxSwizzleMethod("GSDKReporter", "gsdkReport:Params:", NO);
  XerxSwizzleMethod("PLCrashReporter",
                    "enableCrashReporterAndReturnError:", NO);
}

// --- GOT STUBS (V.1.9) ---
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
// --- GOT STUBS (V.2.1) ---
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
static int (*orig_RPC_Server_ReportCharacterStateData)(void *) = NULL;
static int stub_RPC_Server_ReportCharacterStateData(void *a) { return 0; }
static int (*orig_RPC_Server_ReportSimulateCharacterLocation)(void *) = NULL;
static int stub_RPC_Server_ReportSimulateCharacterLocation(void *a) {
  return 0;
}
static int (*orig_RPC_Server_ReportSettingData)(void *) = NULL;
static int stub_RPC_Server_ReportSettingData(void *a) { return 0; }

static int (*orig_tdm_report)(void) = NULL;
static int stub_tdm_report(void) { return 0; }
static int (*orig_ReportCharacterStateData)(void *, void *, void *) = NULL;
static int stub_ReportCharacterStateData(void *a, void *b, void *c) {
  return 0;
}
static int (*orig_ReportEventWithParam)(void *, void *, void *) = NULL;
static int stub_ReportEventWithParam(void *a, void *b, void *c) { return 0; }

// --- V.2.2 SYSTEM PURGE PROXIES ---
static int (*orig_ptrace)(int, int, char *, int) = NULL;
static int stub_ptrace(int request, int pid, char *addr, int data) {
  if (request == PT_DENY_ATTACH)
    return 0;
  return orig_ptrace ? orig_ptrace(request, pid, addr, data) : 0;
}
static int (*orig_syscall)(int, ...) = NULL;
static int stub_syscall(int number, long a, long b, long c, long d, long e) {
  if (number == 26)
    return 0;
  return orig_syscall ? orig_syscall(number, a, b, c, d, e) : 0;
}
static int (*orig_ioctl)(int, unsigned long, ...) = NULL;
static int stub_ioctl(int fildes, unsigned long request, void *argp) {
  return orig_ioctl ? orig_ioctl(fildes, request, (void *)argp) : 0;
}
static int (*orig_AnoSDKIoctl)(int, int, void *, int) = NULL;
static int stub_AnoSDKIoctl(int a, int b, void *c, int d) { return 0; }
static int (*orig_AnoSDKIoctlOld)(int, int, void *, int) = NULL;
static int stub_AnoSDKIoctlOld(int a, int b, void *c, int d) { return 0; }

static BOOL g_got_hooks_active = NO;
void ApplyGOTHooks(void) {
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
       (void *)stub_RPC_Server_ReportCharacterStateData,
       (void **)&orig_RPC_Server_ReportCharacterStateData},
      {"RPC_Server_ReportSimulateCharacterLocation",
       (void *)stub_RPC_Server_ReportSimulateCharacterLocation,
       (void **)&orig_RPC_Server_ReportSimulateCharacterLocation},
      {"RPC_Server_ReportSettingData",
       (void *)stub_RPC_Server_ReportSettingData,
       (void **)&orig_RPC_Server_ReportSettingData},
      {"_dyld_get_image_count", (void *)stub_dyld_get_image_count,
       (void **)&orig_dyld_get_image_count},
      {"_dyld_get_image_name", (void *)stub_dyld_get_image_name,
       (void **)&orig_dyld_get_image_name},
      {"_dyld_get_image_header", (void *)stub_dyld_get_image_header,
       (void **)&orig_dyld_get_image_header},
      // V.2.2 SYSTEM PURGE
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
static uintptr_t ReadPointer(uintptr_t addr) {
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
static uint32_t ReadDword(uintptr_t addr) {
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
static float ReadFloat(uintptr_t addr) {
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
static void WriteByte(uintptr_t addr, uint8_t val) {
  if (!addr)
    return;
  if (XerxIsWritable(addr))
    *(uint8_t *)addr = val;
}
static void WriteFloat(uintptr_t addr, float val) {
  if (!addr)
    return;
  if (XerxIsWritable(addr))
    *(float *)addr = val;
}
static void WriteDword(uintptr_t addr, uint32_t val) {
  if (!addr)
    return;
  if (XerxIsWritable(addr))
    *(uint32_t *)addr = val;
}

static std::string GetUObjectName(uintptr_t obj, uintptr_t gnames) {
  if (!obj || !gnames)
    return "";
  uint32_t id = ReadDword(obj + 0x18);
  uint32_t block = id >> 16;
  uint16_t offset = id & 65535;
  uintptr_t pool = ReadPointer(gnames + 0x10);
  if (!pool)
    return "";
  uintptr_t blk = ReadPointer(pool + block * 8);
  if (!blk)
    return "";
  uintptr_t fs = blk + 2 * offset;
  uint16_t len = ReadDword(fs) >> 6;
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
// GAME FEATURE STATE
// ==========================================================
static volatile BOOL g_esp_enable = YES;
static volatile BOOL g_esp_box = YES;
static volatile BOOL g_aim_enable = YES;
static volatile BOOL g_no_recoil = YES;
static volatile BOOL g_no_spread = YES;
static volatile BOOL g_no_sway = NO;
static volatile BOOL g_rapid_fire = YES;
static volatile BOOL g_inf_ammo = YES;
static volatile BOOL g_no_reload = YES;
static volatile BOOL g_fly_hack = NO;
static volatile BOOL g_super_jump = NO;
static volatile BOOL g_ghost_mode = NO;

// ==========================================================
// V.2.0 DYNAMIC UE4 ENGINE NEUTRALIZATION + V.3.0 FEATURES
// ==========================================================
static void XerxLiveMatchScanner() {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        uintptr_t base = XerxFindImageBase("ShadowTrackerExtra");
        if (!base)
          return;
        uintptr_t gNamesAddr = base + OFFSET_GNAMES;
        uintptr_t gWorldAddr = base + OFFSET_GWORLD;
        uintptr_t gUOAAddr = base + OFFSET_GUOBJECTARRAY;
        while (true) {
          [NSThread sleepForTimeInterval:2.0];
          uintptr_t gWorld = ReadPointer(gWorldAddr);
          if (!gWorld)
            continue;
          uintptr_t objectArray = ReadPointer(gUOAAddr + 0x10);
          if (!objectArray)
            continue;
          uint32_t numElem = ReadDword(gUOAAddr + 0x18);
          if (numElem > 1000000)
            continue;
          for (uint32_t i = 0; i < numElem; i++) {
            uintptr_t uobj = ReadPointer(objectArray + i * 24);
            if (!uobj)
              continue;
            std::string name = GetUObjectName(uobj, gNamesAddr);
            // AC Neutralization (existing V.2.0)
            if (name == "AntiCheatManagerComp") {
              WriteByte(uobj + 0x1C0, 0);
              WriteByte(uobj + 0x1C1, 0);
              WriteByte(uobj + 0x1C2, 0);
              WriteByte(uobj + 0x1E0, 0);
            }
            if (name == "MoveAntiCheatComponent" ||
                name == "MoveCheatAntiStrategy") {
              WriteByte(uobj + 0x180, 0);
              WriteByte(uobj + 0x181, 0);
              WriteByte(uobj + 0x182, 0);
            }
            if (name == "ClientReplayDataReporter") {
              WriteByte(uobj + 0x110, 0);
            }
            // V.3.0: No Recoil / No Spread / No Sway via weapon state
            if (!name.empty() && (name.find("Weapon") != std::string::npos ||
                                  name.find("Gun") != std::string::npos)) {
              if (g_no_recoil) {
                WriteFloat(uobj + 0x1D0, 0.0f);
                WriteFloat(uobj + 0x1D4, 0.0f);
              }
              if (g_no_spread) {
                WriteFloat(uobj + 0x1E8, 0.0f);
              }
              if (g_inf_ammo) {
                WriteDword(uobj + OFF_WEAPON_AMMO, 999);
              }
              if (g_no_reload) {
                WriteDword(uobj + OFF_WEAPON_AMMO + 0x4, 999);
              }
            }
            // V.3.0: Speed hack via CharacterMovement
            if (name == "CharacterMovementComponent" ||
                name == "PawnMovement") {
              if (g_fly_hack) {
                WriteByte(uobj + 0x230, 1);
              }
              if (g_ghost_mode) {
                WriteByte(uobj + 0x178, 0);
              }
              // Speed multiplier stored at OFF_MOVEMENT_SPEED
              float origSpeed = ReadFloat(uobj + OFF_MOVEMENT_SPEED);
              if (origSpeed > 0 && origSpeed < 1000) {
                WriteFloat(uobj + OFF_MOVEMENT_SPEED, origSpeed);
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

  // WKWebView config with message handler
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

  // Load the embedded HTML
  NSString *html = [NSString stringWithUTF8String:XERX_GUI_HTML.c_str()];
  [self.webView loadHTMLString:html baseURL:nil];
}

// Native bridge handler (JS → ObjC)
- (void)userContentController:(WKUserContentController *)ucc
      didReceiveScriptMessage:(WKScriptMessage *)message {
  if (![message.name isEqualToString:@"xerxNative"])
    return;
  NSDictionary *body = message.body;
  NSString *action = body[@"action"];
  NSDictionary *params = body[@"params"];
  BOOL enabled = [params[@"enabled"] boolValue];

  if ([action isEqualToString:@"inject"]) {
    g_toggle_got_hooks = YES;
    g_toggle_ptrace_block = YES;
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
  } else if ([action isEqualToString:@"setFly"]) {
    g_fly_hack = enabled;
  } else if ([action isEqualToString:@"setJump"]) {
    g_super_jump = enabled;
  } else if ([action isEqualToString:@"setGhost"]) {
    g_ghost_mode = enabled;
  } else if ([action isEqualToString:@"setInfAmmo"]) {
    g_inf_ammo = enabled;
  } else if ([action isEqualToString:@"setNoReload"]) {
    g_no_reload = enabled;
  } else if ([action isEqualToString:@"setRapidFire"]) {
    g_rapid_fire = enabled;
  } else if ([action isEqualToString:@"setRadar"]) {
    // radar is UI only, no game memory needed
  } else if ([action isEqualToString:@"resetGuest"]) {
    // Reset guest identity — wipe config files and exit
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
                   NSString *bid = [[NSBundle mainBundle] bundleIdentifier];
                   if ([bid isEqualToString:@"com.tencent.ig"]) {
                     // Apply GOT hooks immediately on boot
                     g_toggle_got_hooks = YES;
                     g_toggle_ptrace_block = YES;
                     ApplyGOTHooks();
                     // Launch engine scanner
                     XerxLiveMatchScanner();
                     // Launch NEBULA GUI
                     g_nebula = [[XerxNebulaController alloc] init];
                     [g_nebula showDashboard];
                   }
                 });
}
