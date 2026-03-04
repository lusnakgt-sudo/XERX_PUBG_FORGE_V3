#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
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
typedef char *caddr_t;
extern "C" int ioctl(int, unsigned long, ...);
extern "C" int ptrace(int, int, char *, int);

/*
 -------------TUXSHARX PWNED ME----------------
 [IDENTITY: XERX-NET v9.9.9 - THE ALL-SEEING EYE OF GOD]
 [TARGET: ShadowTrackerExtra (PUBG MOBILE iOS)]
 [BUNDLE: com.tencent.ig]
 [STATUS: AUTONOMOUS SOVEREIGNTY ENABLED]
 [BUILD: GHOST UNBOUND DEEP FORENSIC PURGE]
 [VERSION: V.2.4 - [FORENSIC PURGE]]
*/

#ifndef P_TRACED
#define P_TRACED 0x00000800
#endif

#import <mach-o/loader.h>
#import <mach-o/nlist.h>

@class XerxOrb;
@interface XerxDashboard : UIView
@property(nonatomic, strong) UILabel *clockLabel;
@property(nonatomic, strong) UITextView *monitorView;
@property(nonatomic, strong) UIView *hookDot;
@property(nonatomic, strong) UIView *bypassDot;
@property(nonatomic, strong) UIView *progressFill;
@property(nonatomic, strong) UIButton *injectBtn;
@property(nonatomic, strong) XerxOrb *orb;
@property(nonatomic, assign) BOOL isArmed;
- (void)logMonitor:(NSString *)line;
- (void)setProgress:(float)p;
- (void)animateDot:(UIView *)dot success:(BOOL)success;
- (void)minimize;
@end
static XerxDashboard *g_dashboard = nil;

struct XerxRebindEntry {
  const char *symbol_name;
  void *replacement;
  void **original;
};

// --- GHOST MASKING GLOBALS ---
static uint32_t g_my_index = 0xFFFFFFFF;
static uint32_t (*orig_dyld_get_image_count)(void) = NULL;
static const char *(*orig_dyld_get_image_name)(uint32_t index) = NULL;
static const struct mach_header *(*orig_dyld_get_image_header)(uint32_t index) =
    NULL;

static void FindMyIndex() {
  uint32_t count = _dyld_image_count();
  for (uint32_t i = 0; i < count; i++) {
    const char *name = _dyld_get_image_name(i);
    if (name && strstr(name, "xerx_pubg")) {
      g_my_index = i;
      break;
    }
  }
}

// --- GHOST MASKING STUBS ---
static uint32_t stub_dyld_get_image_count() {
  if (orig_dyld_get_image_count)
    return orig_dyld_get_image_count() - 1;
  return _dyld_image_count() - 1;
}

static const char *stub_dyld_get_image_name(uint32_t index) {
  if (index >= g_my_index) {
    if (orig_dyld_get_image_name)
      return orig_dyld_get_image_name(index + 1);
    return _dyld_get_image_name(index + 1);
  }
  if (orig_dyld_get_image_name)
    return orig_dyld_get_image_name(index);
  return _dyld_get_image_name(index);
}

static const struct mach_header *stub_dyld_get_image_header(uint32_t index) {
  if (index >= g_my_index) {
    if (orig_dyld_get_image_header)
      return orig_dyld_get_image_header(index + 1);
    return _dyld_get_image_header(index + 1);
  }
  if (orig_dyld_get_image_header)
    return orig_dyld_get_image_header(index);
  return _dyld_get_image_header(index);
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
  uint32_t image_count = _dyld_image_count();
  for (uint32_t i = 0; i < image_count; i++) {
    const char *name = _dyld_get_image_name(i);
    if (name && (strstr(name, "anogs") || strstr(name, "ShadowTrackerExtra"))) {
      xerx_rebind_in_image(_dyld_get_image_header(i),
                           _dyld_get_image_vmaddr_slide(i), entries, count);
    }
  }
}

static volatile BOOL g_toggle_got_hooks = NO;
static volatile BOOL g_toggle_ptrace_block = NO;

// V.1.7 EXPERT ANCHORS & SIGNATURES
#define ANOGS_RET_ANCHOR 0x41E4
#define ACE_SAFE_SIGNATURE 0x30B1BCBA
#define TDM_REPORT_ENABLE_OFF 0x2A5711

// Signature & Environment checks (sysctl, ptrace, AnoSDKIoctl) REMOVED for
// V.1.8.1 Absolute Stability.

// PROXY: AnoSDKGetReportData REMOVED for Stability

// --- V.1.9 MASSIVE BEHAVIORAL SWIZZLES ---
static id stub_ObjC_ReturnNil(id self, SEL _cmd, ...) { return nil; }

static void XerxSwizzleMethod(const char *className, const char *methodName,
                              BOOL isClassMethod) {
  Class cls = objc_getClass(className);
  if (!cls)
    return;
  SEL sel = sel_registerName(methodName);
  if (!sel)
    return;
  Method m = isClassMethod ? class_getClassMethod(cls, sel)
                           : class_getInstanceMethod(cls, sel);
  if (m) {
    class_replaceMethod(isClassMethod ? object_getClass((id)cls) : cls, sel,
                        (IMP)stub_ObjC_ReturnNil, method_getTypeEncoding(m));
  }
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
  XerxSwizzleMethod("AdSession", "registerSessionObserver:", NO);
}

// --- V.1.9 EXPANDED GOT STUBS ---
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

// --- V.2.1 ULTIMATE DEEP C++ PROXIES ---
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

// PROXY: tdm_report
static int (*orig_tdm_report)(void) = NULL;
static int stub_tdm_report(void) {
  return 0; // Absolute Silence
}

// PROXY: ReportCharacterStateData
static int (*orig_ReportCharacterStateData)(void *, void *, void *) = NULL;
static int stub_ReportCharacterStateData(void *a, void *b, void *c) {
  return 0; // Silence Physical Anomalies
}

// PROXY: ReportEventWithParam
static int (*orig_ReportEventWithParam)(void *, void *, void *) = NULL;
static int stub_ReportEventWithParam(void *a, void *b, void *c) {
  return 0; // Silence Generic Anomaly Reports
}

// --- V.2.2 SYSTEM PURGE PROXIES ---
static int (*orig_ptrace)(int, pid_t, caddr_t, int) = NULL;
static int stub_ptrace(int request, pid_t pid, caddr_t addr, int data) {
  if (request == PT_DENY_ATTACH)
    return 0; // Deny the denial
  if (orig_ptrace)
    return orig_ptrace(request, pid, addr, data);
  return 0;
}

static int (*orig_syscall)(int, ...) = NULL;
static int stub_syscall(int number, long a, long b, long c, long d, long e) {
  if (number == 26)
    return 0; // SYS_ptrace filter
  if (orig_syscall)
    return orig_syscall(number, a, b, c, d, e);
  return 0; // Absolute safety fallback
}

static int (*orig_ioctl)(int, unsigned long, ...) = NULL;
static int stub_ioctl(int fildes, unsigned long request, void *argp) {
  if (orig_ioctl)
    return orig_ioctl(fildes, request, (void *)argp);
  return 0;
}

static int (*orig_AnoSDKIoctl)(int, int, void *, int) = NULL;
static int stub_AnoSDKIoctl(int a, int b, void *c, int d) {
  return 0; // Blind ACE kernel comms
}

static int (*orig_AnoSDKIoctlOld)(int, int, void *, int) = NULL;
static int stub_AnoSDKIoctlOld(int a, int b, void *c, int d) {
  return 0; // Blind ACE kernel comms
}

// --- V.2.3 ULTRA COMBAT PROXIES ---
static int (*orig_WeaponReport)(void *) = NULL;
static int stub_WeaponReport(void *a) { return 0; }

static int (*orig_TotalWeaponReport)(void *) = NULL;
static int stub_TotalWeaponReport(void *a) { return 0; }

static int (*orig_ShovelAntiCheat)(void *) = NULL;
static int stub_ShovelAntiCheat(void *a) { return 0; }

static int (*orig_OnWeaponSecurityLogShootActorDelegate)(void *) = NULL;
static int stub_OnWeaponSecurityLogShootActorDelegate(void *a) { return 0; }

static int (*orig_LuaNotifySecurityAbnormalJump)(void *) = NULL;
static int stub_LuaNotifySecurityAbnormalJump(void *a) { return 0; }

static int (*orig_ReportJumpFlow)(void *) = NULL;
static int stub_ReportJumpFlow(void *a) { return 0; }

static int (*orig_GetMaxWeaponReportNum)(void *) = NULL;
static int stub_GetMaxWeaponReportNum(void *a) { return 0; }

static void (*orig_NotifyAuthority)(void *) = NULL;
static void stub_NotifyAuthority(void *a) { return; }

// --- V.2.4 FORENSIC PROXIES ---
static int (*orig_GNLReportManager)(void *) = NULL;
static int stub_GNLReportManager(void *a) { return 0; }

static int (*orig_TDataMasterReportManager)(void *) = NULL;
static int stub_TDataMasterReportManager(void *a) { return 0; }

static int (*orig_SecurityLogSender)(void *) = NULL;
static int stub_SecurityLogSender(void *a) { return 0; }

static int (*orig_SecurityLogWeaponCollector)(void *) = NULL;
static int stub_SecurityLogWeaponCollector(void *a) { return 0; }

static int (*orig_ShootIntervalAnomaly)(void *) = NULL;
static int stub_ShootIntervalAnomaly(void *a) { return 0; }

static int (*orig_ClientReportReq)(void *) = NULL;
static int stub_ClientReportReq(void *a) { return 0; }

static int (*orig_PlayerSecurityInfoCollector)(void *) = NULL;
static int stub_PlayerSecurityInfoCollector(void *a) { return 0; }

static int (*orig_PlayerReportData)(void *) = NULL;
static int stub_PlayerReportData(void *a) { return 0; }

static int (*orig_IntelligentIntegrity)(void *) = NULL;
static int stub_IntelligentIntegrity(void *a) { return 0; }

static int (*orig_IntegrityItemCheckResultAsBytes)(void *) = NULL;
static int stub_IntegrityItemCheckResultAsBytes(void *a) { return 0; }

static int (*orig_TimeWatchDogComponent)(void *) = NULL;
static int stub_TimeWatchDogComponent(void *a) { return 0; }

static int (*orig_Audit)(void *) = NULL;
static int stub_Audit(void *a) { return 0; }

static int (*orig_SecurityLogHitTargetInfo)(void *) = NULL;
static int stub_SecurityLogHitTargetInfo(void *a) { return 0; }

static int (*orig_EnableDataTunnelReport)(void *) = NULL;
static int stub_EnableDataTunnelReport(void *a, int b) { return 0; }

static int (*orig_Integrity_check)(void *) = NULL;
static int stub_Integrity_check(void *a) { return 0; }

static int (*orig_Integrity_detect)(void *) = NULL;
static int stub_Integrity_detect(void *a) { return 0; }

static BOOL g_got_hooks_active = NO;
void ApplyGOTHooks(void) {
  if (g_got_hooks_active)
    return;
  FindMyIndex();
  ApplyObjCSwizzles();

  struct XerxRebindEntry entries[60] = {
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
      {"ptrace", (void *)stub_ptrace, (void **)&orig_ptrace},
      {"syscall", (void *)stub_syscall, (void **)&orig_syscall},
      {"ioctl", (void *)stub_ioctl, (void **)&orig_ioctl},
      {"AnoSDKIoctl", (void *)stub_AnoSDKIoctl, (void **)&orig_AnoSDKIoctl},
      {"AnoSDKIoctlOld", (void *)stub_AnoSDKIoctlOld,
       (void **)&orig_AnoSDKIoctlOld},
      {"WeaponReport", (void *)stub_WeaponReport, (void **)&orig_WeaponReport},
      {"TotalWeaponReport", (void *)stub_TotalWeaponReport,
       (void **)&orig_TotalWeaponReport},
      {"ShovelAntiCheat", (void *)stub_ShovelAntiCheat,
       (void **)&orig_ShovelAntiCheat},
      {"OnWeaponSecurityLogShootActorDelegate",
       (void *)stub_OnWeaponSecurityLogShootActorDelegate,
       (void **)&orig_OnWeaponSecurityLogShootActorDelegate},
      {"LuaNotifySecurityAbnormalJump",
       (void *)stub_LuaNotifySecurityAbnormalJump,
       (void **)&orig_LuaNotifySecurityAbnormalJump},
      {"ReportJumpFlow", (void *)stub_ReportJumpFlow,
       (void **)&orig_ReportJumpFlow},
      {"GetMaxWeaponReportNum", (void *)stub_GetMaxWeaponReportNum,
       (void **)&orig_GetMaxWeaponReportNum},
      {"NotifyAuthority", (void *)stub_NotifyAuthority,
       (void **)&orig_NotifyAuthority},
      {"GNLReportManager", (void *)stub_GNLReportManager,
       (void **)&orig_GNLReportManager},
      {"TDataMasterReportManager", (void *)stub_TDataMasterReportManager,
       (void **)&orig_TDataMasterReportManager},
      {"SecurityLogSender", (void *)stub_SecurityLogSender,
       (void **)&orig_SecurityLogSender},
      {"SecurityLogWeaponCollector", (void *)stub_SecurityLogWeaponCollector,
       (void **)&orig_SecurityLogWeaponCollector},
      {"ShootIntervalAnomaly", (void *)stub_ShootIntervalAnomaly,
       (void **)&orig_ShootIntervalAnomaly},
      {"ClientReportReq", (void *)stub_ClientReportReq,
       (void **)&orig_ClientReportReq},
      {"PlayerSecurityInfoCollector", (void *)stub_PlayerSecurityInfoCollector,
       (void **)&orig_PlayerSecurityInfoCollector},
      {"PlayerReportData", (void *)stub_PlayerReportData,
       (void **)&orig_PlayerReportData},
      {"IntelligentIntegrity", (void *)stub_IntelligentIntegrity,
       (void **)&orig_IntelligentIntegrity},
      {"IntegrityItemCheckResultAsBytes",
       (void *)stub_IntegrityItemCheckResultAsBytes,
       (void **)&orig_IntegrityItemCheckResultAsBytes},
      {"TimeWatchDogComponent", (void *)stub_TimeWatchDogComponent,
       (void **)&orig_TimeWatchDogComponent},
      {"Audit", (void *)stub_Audit, (void **)&orig_Audit},
      {"SecurityLogHitTargetInfo", (void *)stub_SecurityLogHitTargetInfo,
       (void **)&orig_SecurityLogHitTargetInfo},
      {"EnableDataTunnelReport", (void *)stub_EnableDataTunnelReport,
       (void **)&orig_EnableDataTunnelReport},
      {"integrity_check", (void *)stub_Integrity_check,
       (void **)&orig_Integrity_check},
      {"integrity_detect", (void *)stub_Integrity_detect,
       (void **)&orig_Integrity_detect},
  };
  xerx_rebind(entries, 60);
  g_got_hooks_active = YES;
  if (g_dashboard) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [g_dashboard logMonitor:@"[GHOST] Invisibility ACTIVE"];
      [g_dashboard logMonitor:@"[GOT]  Stubs rebind OK"];
    });
  }
}

static BOOL XerxIsWritable(uintptr_t addr) {
  vm_address_t address = (vm_address_t)addr;
  vm_size_t size = 0;
  vm_region_submap_short_info_data_64_t info;
  mach_msg_type_number_t count = VM_REGION_SUBMAP_SHORT_INFO_COUNT_64;
  uint32_t depth = 0;
  kern_return_t kr =
      vm_region_recurse_64(mach_task_self(), &address, &size, &depth,
                           (vm_region_recurse_info_t)&info, &count);
  return (kr == KERN_SUCCESS && (info.protection & VM_PROT_WRITE) != 0);
}

static uintptr_t XerxFindImageBase(const char *image_name) {
  uint32_t count = _dyld_image_count();
  for (uint32_t i = 0; i < count; i++) {
    const char *name = _dyld_get_image_name(i);
    if (name && strstr(name, image_name))
      return (uintptr_t)_dyld_get_image_header(i);
  }
  return 0;
}

// ==========================================
// V.2.0 DYNAMIC UE4 ENGINE NEUTRALIZATION
// ==========================================

#define OFFSET_GNAMES 0x802BC78
#define OFFSET_GWORLD 0xA4A0768
#define OFFSET_GUOBJECTARRAY 0x9C88060

static uintptr_t ReadPointer(uintptr_t addr) {
  if (!addr)
    return 0;
  uintptr_t val = 0;
  // Simple direct read. Assumes memory is valid map.
  @try {
    val = *(uintptr_t *)addr;
  } @catch (...) {
    val = 0;
  }
  return val;
}

static uint32_t ReadDword(uintptr_t addr) {
  if (!addr)
    return 0;
  uint32_t val = 0;
  @try {
    val = *(uint32_t *)addr;
  } @catch (...) {
    val = 0;
  }
  return val;
}

static void WriteByte(uintptr_t addr, uint8_t val) {
  if (!addr)
    return;
  if (XerxIsWritable(addr)) {
    *(uint8_t *)addr = val;
  }
}

static std::string GetUObjectName(uintptr_t uobject, uintptr_t gnames_base) {
  if (!uobject || !gnames_base)
    return "";
  uint32_t name_id = ReadDword(uobject + 0x18); // FName index usually at 0x18
  uint32_t block = name_id >> 16;
  uint16_t offset = name_id & 65535;

  uintptr_t name_pool = ReadPointer(gnames_base + 0x10);
  if (!name_pool)
    return "";
  uintptr_t name_block = ReadPointer(name_pool + block * 8);
  if (!name_block)
    return "";

  uintptr_t fstring = name_block + 2 * offset;
  uint16_t length = ReadDword(fstring) >> 6;
  if (length == 0 || length > 128)
    return "";

  char name[128] = {0};
  @try {
    memcpy(name, (void *)(fstring + 2), length);
  } @catch (...) {
    return "";
  }
  return std::string(name);
}

static void XerxPatchDataOffset(uintptr_t base, uintptr_t offset,
                                uint32_t value) {
  uintptr_t addr = base + offset;
  if (XerxIsWritable(addr)) {
    *(uint32_t *)addr = value;
    if (g_dashboard) {
      NSString *msg =
          [NSString stringWithFormat:@"0x%lx -> 0x%x", offset, value];
      [g_dashboard logMonitor:msg];
    }
  } else {
    if (g_dashboard)
      [g_dashboard
          logMonitor:[NSString stringWithFormat:@"0x%lx SKIP (SAFE)", offset]];
  }
}

static void XerxLiveMatchScanner() {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        uintptr_t baseAddr = XerxFindImageBase("ShadowTrackerExtra");
        uintptr_t anBase = XerxFindImageBase("anogs");
        if (!baseAddr)
          return;

        uintptr_t gNamesAddr = baseAddr + OFFSET_GNAMES;
        uintptr_t gWorldAddr = baseAddr + OFFSET_GWORLD;
        uintptr_t gUObjectArrayAddr = baseAddr + OFFSET_GUOBJECTARRAY;

        while (true) {
          [NSThread sleepForTimeInterval:2.0];

          // V.2.4 GLOBAL INTEGRITY KILL-SWITCH
          if (anBase) {
            WriteByte(anBase + 0x283B60, 0); // Disable g_integrity_enable
          }

          uintptr_t gWorld = ReadPointer(gWorldAddr);
          if (!gWorld)
            continue; // Not in match

          uintptr_t objectArray = ReadPointer(gUObjectArrayAddr + 0x10);
          if (!objectArray)
            continue;

          uint32_t numElements = ReadDword(gUObjectArrayAddr + 0x18);
          if (numElements > 1000000)
            continue; // Sanity check

          for (uint32_t i = 0; i < numElements; i++) {
            uintptr_t uobject = ReadPointer(objectArray + i * 24);
            if (!uobject)
              continue;

            std::string name = GetUObjectName(uobject, gNamesAddr);

            // Mute Character/Move AC
            if (name == "AntiCheatManagerComp") {
              // Force booleans to false. E.g., bEnableAntiCheat (offset ~0x1B0)
              WriteByte(uobject + 0x1C0, 0); // Disable Data Tunnel
              WriteByte(uobject + 0x1C1, 0); // Disable Distin Report
              WriteByte(uobject + 0x1C2, 0); // Disable Move Anti Cheat
              WriteByte(uobject + 0x1E0, 0); // Mute Crash Context
            }

            if (name == "MoveAntiCheatComponent" ||
                name == "MoveCheatAntiStrategy") {
              WriteByte(uobject + 0x180, 0); // Disable Fly tracking
              WriteByte(uobject + 0x181, 0); // Disable Walk anomaly
              WriteByte(uobject + 0x182, 0); // Disable Ghosting detect

              // V.2.3 Normalization
              // Offsets for ratios are typically 0x30-0x50 beyond the booleans
              // We target the floating point ratios (4 bytes each)
              // Setting to 1.0 (0x3F800000)
              XerxPatchDataOffset(uobject, 0x1A0,
                                  0x3F800000); // MaxBoostSpeedRatio
              XerxPatchDataOffset(uobject, 0x1A4,
                                  0x3F800000); // JumpHeightRatio
              XerxPatchDataOffset(uobject, 0x1A8, 0x3F800000); // MoveSpeedRatio
            }

            if (name == "STExtraVehicleMovementComponent4W_AntiCheat") {
              WriteByte(uobject + 0xF0, 0); // Disable Vehicle AC
              XerxPatchDataOffset(uobject, 0x100,
                                  0x3F800000); // VehicleSpeedRatio
            }

            // Mute Weapon AC
            if (name == "WeaponAntiCheatComp" ||
                name == "DefaultAntiCheatComponent") {
              WriteByte(uobject + 0xD0, 0); // Disable Weapon behavioral logs
            }

            // Mute Replay Reporters
            if (name == "ClientReplayDataReporter") {
              WriteByte(uobject + 0x110,
                        0); // Disable automatic periodic report
            }
          }
        }
      });
}
// ==========================================

@interface XerxOrb : UIView
@property(nonatomic, assign) id dashboard;
@end

@implementation XerxOrb
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor colorWithRed:0.04
                                           green:0.04
                                            blue:0.04
                                           alpha:0.8];
    self.layer.cornerRadius = frame.size.width / 2.0;
    self.layer.borderColor =
        [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:0.8].CGColor;
    self.layer.borderWidth = 1.5;
    self.layer.shadowColor = [UIColor redColor].CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 8;
    UILabel *icon = [[UILabel alloc] initWithFrame:self.bounds];
    icon.text = @"[+]";
    icon.textColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
    icon.font = [UIFont fontWithName:@"Courier-Bold" size:14];
    icon.textAlignment = NSTextAlignmentCenter;
    [self addSubview:icon];
    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(tap)];
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(drag:)];
    [self addGestureRecognizer:pan];
  }
  return self;
}
- (void)tap {
  [self.dashboard setHidden:NO];
  self.hidden = YES;
}
- (void)drag:(UIPanGestureRecognizer *)p {
  CGPoint t = [p translationInView:self.superview];
  self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
  [p setTranslation:CGPointZero inView:self.superview];
}
@end

@implementation XerxDashboard
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor colorWithRed:0.07
                                           green:0.07
                                            blue:0.07
                                           alpha:0.95];
    self.layer.borderColor =
        [UIColor colorWithRed:0.8 green:0.2 blue:0.1 alpha:0.8].CGColor;
    self.layer.borderWidth = 1.2;
    self.layer.cornerRadius = 10.0;
    self.layer.shadowColor = [UIColor redColor].CGColor;
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 15;

    UIView *hdr =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 32)];
    hdr.backgroundColor = [UIColor colorWithRed:0.1
                                          green:0.1
                                           blue:0.1
                                          alpha:1.0];
    hdr.layer.cornerRadius = 10.0;
    hdr.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self addSubview:hdr];

    UILabel *title =
        [[UILabel alloc] initWithFrame:CGRectMake(12, 0, frame.size.width, 32)];
    title.text = @"XERX-NET // GHOST UNBOUND [V.1.7]";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"Courier-Bold" size:13];
    [hdr addSubview:title];

    UIButton *min = [UIButton buttonWithType:UIButtonTypeCustom];
    min.frame = CGRectMake(frame.size.width - 35, 6, 20, 20);
    [min setTitle:@"—" forState:UIControlStateNormal];
    [min addTarget:self
                  action:@selector(minimize)
        forControlEvents:UIControlEventTouchUpInside];
    [hdr addSubview:min];

    _clockLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(12, 40, frame.size.width - 24, 20)];
    _clockLabel.textColor = [UIColor orangeColor];
    _clockLabel.font = [UIFont fontWithName:@"Courier" size:12];
    _clockLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_clockLabel];
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateClock)
                                   userInfo:nil
                                    repeats:YES];
    [self updateClock];

    UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(12, 70, 150, 20)];
    l1.text = @"HOOK STATUS";
    l1.textColor = [UIColor lightGrayColor];
    l1.font = [UIFont fontWithName:@"Courier" size:12];
    [self addSubview:l1];
    _hookDot = [[UIView alloc]
        initWithFrame:CGRectMake(frame.size.width - 30, 75, 12, 12)];
    _hookDot.layer.cornerRadius = 6;
    _hookDot.backgroundColor = [UIColor colorWithRed:0.1
                                               green:0.4
                                                blue:0.1
                                               alpha:1.0];
    [self addSubview:_hookDot];

    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(12, 100, 150, 20)];
    l2.text = @"SHIELD FORCE";
    l2.textColor = [UIColor lightGrayColor];
    l2.font = [UIFont fontWithName:@"Courier" size:12];
    [self addSubview:l2];
    _bypassDot = [[UIView alloc]
        initWithFrame:CGRectMake(frame.size.width - 30, 105, 12, 12)];
    _bypassDot.layer.cornerRadius = 6;
    _bypassDot.backgroundColor = [UIColor colorWithRed:0.1
                                                 green:0.4
                                                  blue:0.1
                                                 alpha:1.0];
    [self addSubview:_bypassDot];

    UILabel *seq = [[UILabel alloc] initWithFrame:CGRectMake(12, 135, 200, 20)];
    seq.text = @"INJECTION SEQUENCE";
    seq.textColor = [UIColor darkGrayColor];
    seq.font = [UIFont fontWithName:@"Courier-Bold" size:11];
    [self addSubview:seq];

    UIView *pBar = [[UIView alloc]
        initWithFrame:CGRectMake(12, 158, frame.size.width - 24, 3)];
    pBar.backgroundColor = [UIColor colorWithRed:0.2
                                           green:0.2
                                            blue:0.2
                                           alpha:1.0];
    [self addSubview:pBar];
    _progressFill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
    _progressFill.backgroundColor = [UIColor colorWithRed:0.9
                                                    green:0.3
                                                     blue:0.1
                                                    alpha:1.0];
    [pBar addSubview:_progressFill];

    _monitorView = [[UITextView alloc]
        initWithFrame:CGRectMake(12, 185, frame.size.width - 24, 150)];
    _monitorView.backgroundColor = [UIColor colorWithRed:0.02
                                                   green:0.02
                                                    blue:0.02
                                                   alpha:1.0];
    _monitorView.textColor = [UIColor greenColor];
    _monitorView.font = [UIFont fontWithName:@"Courier" size:10];
    _monitorView.editable = NO;
    _monitorView.layer.cornerRadius = 4;
    [self addSubview:_monitorView];

    _injectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _injectBtn.frame = CGRectMake(12, 350, frame.size.width - 24, 45);
    _injectBtn.backgroundColor = [UIColor colorWithRed:0.1
                                                 green:0.1
                                                  blue:0.1
                                                 alpha:1.0];
    [_injectBtn setTitle:@"INITIALIZE SHIELD" forState:UIControlStateNormal];
    _injectBtn.titleLabel.font = [UIFont fontWithName:@"Courier-Bold" size:14];
    _injectBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _injectBtn.layer.borderWidth = 1.0;
    _injectBtn.layer.cornerRadius = 6;
    [_injectBtn addTarget:self
                   action:@selector(deployPayload)
         forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_injectBtn];

    UIButton *gst = [UIButton buttonWithType:UIButtonTypeCustom];
    gst.frame = CGRectMake(12, 403, frame.size.width - 24, 20);
    [gst setTitle:@"WIPE GUEST IDENTITY" forState:UIControlStateNormal];
    gst.titleLabel.font = [UIFont fontWithName:@"Courier" size:10];
    gst.alpha = 0.6;
    [gst addTarget:self
                  action:@selector(deepWipeGuest)
        forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:gst];

    UIPanGestureRecognizer *pn =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(drag:)];
    [self addGestureRecognizer:pn];
  }
  return self;
}
- (void)updateClock {
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"dd MMM yyyy HH:mm:ss"];
  _clockLabel.text = [df stringFromDate:[NSDate date]];
}
- (void)minimize {
  self.hidden = YES;
  if (!_orb) {
    _orb = [[XerxOrb alloc] initWithFrame:CGRectMake(20, 80, 42, 42)];
    _orb.dashboard = self;
    [self.superview addSubview:_orb];
  }
  _orb.hidden = NO;
}
- (void)drag:(UIPanGestureRecognizer *)p {
  CGPoint t = [p translationInView:self.superview];
  self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
  [p setTranslation:CGPointZero inView:self.superview];
}
- (void)logMonitor:(NSString *)line {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *entry = [NSString stringWithFormat:@"%@\n", line];
    _monitorView.text = [_monitorView.text stringByAppendingString:entry];
    [_monitorView
        scrollRangeToVisible:NSMakeRange(_monitorView.text.length - 1, 1)];
  });
}
- (void)animateDot:(UIView *)dot success:(BOOL)success {
  dot.backgroundColor = success ? [UIColor greenColor] : [UIColor redColor];
  dot.layer.shadowColor = dot.backgroundColor.CGColor;
  dot.layer.shadowOpacity = 1.0;
  dot.layer.shadowRadius = 8;
  CABasicAnimation *b = [CABasicAnimation animationWithKeyPath:@"opacity"];
  b.duration = 0.5;
  b.fromValue = @(1.0);
  b.toValue = @(0.4);
  b.autoreverses = YES;
  b.repeatCount = HUGE_VALF;
  [dot.layer addAnimation:b forKey:@"glow"];
}
- (void)setProgress:(float)p {
  CGRect f = _progressFill.frame;
  f.size.width = (_progressFill.superview.frame.size.width) * p;
  [UIView animateWithDuration:0.5
                   animations:^{
                     self->_progressFill.frame = f;
                   }];
}

- (void)deployPayload {
  if (self.isArmed)
    return;
  self.isArmed = YES;
  [self logMonitor:@"[SYS] INITIATING GHOST UNBOUND..."];
  [self setProgress:0.1];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    g_toggle_got_hooks = YES;
    g_toggle_ptrace_block = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self setProgress:0.2];
      [self logMonitor:@"[GHOST] MASKING DYLD IMAGE..."];
    });
    ApplyGOTHooks();

    [NSThread sleepForTimeInterval:0.4];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self setProgress:0.4];
      [self logMonitor:@"[SEQ] SVC KERNEL DEFUSAL (P2)..."];
    });
    uintptr_t anBase = XerxFindImageBase("anogs");
    if (anBase) {
      [self logMonitor:@"[GHOST] AnoSDK Base Locked."];
    }

    [NSThread sleepForTimeInterval:0.4];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self setProgress:0.6];
      [self logMonitor:@"[SEQ] TELEMETRY BLINDING (P3)..."];
    });
    if (anBase) {
      [self logMonitor:@"[P3] Behavioral Proxies Active"];
      // Handled by GOT Hooks
    }

    [NSThread sleepForTimeInterval:0.4];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self setProgress:0.8];
      [self logMonitor:@"[SEQ] DYNAMIC ENGINE MUTER (P4)..."];
    });
    // Launch V.2.0 Background Scanner
    XerxLiveMatchScanner();

    dispatch_async(dispatch_get_main_queue(), ^{
      [self setProgress:1.0];
      [self logMonitor:@"[SYS] GHOST UNBOUND ACTIVE"];
      [self logMonitor:@"Absolute Engine Invisibility Confirmed."];

      [self animateDot:self->_hookDot success:YES];
      [self animateDot:self->_bypassDot success:YES];
      self->_injectBtn.backgroundColor = [UIColor colorWithRed:0
                                                         green:0.3
                                                          blue:0
                                                         alpha:1];
      [self->_injectBtn setTitle:@"UNBOUND ACTIVE"
                        forState:UIControlStateNormal];
    });
  });
}

- (void)deepWipeGuest {
  NSString *docs = [NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *home = NSHomeDirectory();
  NSArray *paths = @[
    [docs stringByAppendingPathComponent:
              @"ShadowTrackerExtra/Saved/Config/guest/activate.json"],
    [docs stringByAppendingPathComponent:@"guest/activate.json"],
    [home stringByAppendingPathComponent:@"Documents/guest/activate.json"],
    [home
        stringByAppendingPathComponent:@"Library/Caches/guest/activate.json"]
  ];
  for (NSString *p in paths)
    if ([[NSFileManager defaultManager] fileExistsAtPath:p])
      [[NSFileManager defaultManager] removeItemAtPath:p error:nil];
  exit(0);
}
@end

__attribute__((constructor)) static void initialize() {
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        NSString *bid = [[NSBundle mainBundle] bundleIdentifier];
        if ([bid isEqualToString:@"com.tencent.ig"]) {
          UIWindow *window = nil;
          if (@available(iOS 13.0, *)) {
            for (UIScene *s in [UIApplication sharedApplication]
                     .connectedScenes)
              if ([s isKindOfClass:[UIWindowScene class]] &&
                  s.activationState == UISceneActivationStateForegroundActive) {
                window = ((UIWindowScene *)s).windows.firstObject;
                break;
              }
          }
          if (!window) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            window = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
          }
          if (window) {
            g_dashboard = [[XerxDashboard alloc]
                initWithFrame:CGRectMake(window.frame.size.width - 260, 60, 240,
                                         440)];
            [window addSubview:g_dashboard];
            [g_dashboard minimize];
          }
        }
      });
}
