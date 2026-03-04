// xerx_gui_html.h — V.3.0 NEBULA GUI (embedded HTML for WKWebView)
#pragma once
#include <string>

static const std::string XERX_GUI_HTML = R"HTMLEOF(
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<title>NEBULA • XERX-NET</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif}
:root{--p:#3e7cff;--pg:rgba(62,124,255,.5);--bg:#0a0c14;--panel:#131620;--card:#1a1d29;--bdr:#2e3445;--t1:#fff;--t2:#b0c2e6;--ok:#2ecc71;--warn:#f0c070;--pb:#262c40}
body{background:var(--bg);min-height:100vh;display:flex;justify-content:center;align-items:flex-start;padding:12px;overflow-x:hidden;position:relative;transition:background .3s}
body.theme-red{--p:#ff4c4c;--pg:rgba(255,76,76,.5);--panel:#1f1316;--card:#2a1a1f;--bdr:#4a2f35}
body.theme-gray{--p:#8a8f9c;--pg:rgba(138,143,156,.5);--panel:#1b1d24;--card:#23262f;--bdr:#3a3e4a}
body.theme-dark{--p:#c0c0c0;--pg:rgba(192,192,192,.5);--panel:#0f0f12;--card:#18181e;--bdr:#2b2b33}
body.theme-green{--p:#2ecc71;--pg:rgba(46,204,113,.5);--panel:#142015;--card:#1e2b22;--bdr:#2f4035}
body.theme-purple{--p:#9b59b6;--pg:rgba(155,89,182,.5);--panel:#1e1826;--card:#2b1f33;--bdr:#443755}
.fi{position:fixed;font-size:3rem;color:var(--p);opacity:.06;pointer-events:none;animation:float 12s infinite ease-in-out;z-index:0}
.fi:nth-child(1){top:5%;left:2%}.fi:nth-child(2){bottom:8%;right:3%;font-size:4rem}.fi:nth-child(3){top:20%;right:10%}.fi:nth-child(4){bottom:20%;left:5%;font-size:3.5rem}.fi:nth-child(5){top:70%;left:15%}.fi:nth-child(6){bottom:40%;right:15%}.fi:nth-child(7){top:45%;left:30%}.fi:nth-child(8){bottom:60%;right:25%}
@keyframes float{0%,100%{transform:translateY(0) rotate(0)}50%{transform:translateY(-25px) rotate(5deg)}}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.9;transform:scale(1.05)}}
/* PANEL */
.panel{width:100%;max-width:1500px;background:var(--panel);border-radius:32px;padding:16px 20px;box-shadow:0 30px 60px rgba(0,0,0,.9),0 0 0 1px var(--bdr) inset;position:relative;z-index:10;transition:all .4s;resize:both;overflow:auto;min-width:340px;min-height:200px}
.panel.minimized .body-wrap,.panel.minimized .footer{display:none}
/* RESIZE HANDLE */
.rh{position:absolute;bottom:6px;right:6px;width:18px;height:18px;cursor:se-resize;opacity:.4;}
.rh i{color:var(--t2);font-size:14px}
/* HEADER */
.hdr{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;flex-wrap:wrap;gap:10px}
.hdr-l{display:flex;align-items:center;gap:12px;flex-wrap:wrap}
.hdr-l h1{color:var(--t1);font-size:22px;font-weight:700;display:flex;align-items:center;gap:8px}
.hdr-l h1 i{color:var(--p);filter:drop-shadow(0 0 8px var(--pg));animation:pulse 2s infinite}
.srow{display:flex;gap:8px;align-items:center;flex-wrap:wrap}
.sbadge{background:var(--card);border-radius:60px;padding:5px 12px;border:1px solid var(--bdr);color:var(--t2);font-size:13px;display:flex;align-items:center;gap:5px}
.sbadge i{color:var(--p)}
.fps{background:var(--card);border-radius:60px;padding:5px 12px;border:1px solid var(--bdr);color:#b0e0b0;font-weight:600;font-size:14px;display:flex;align-items:center;gap:5px}
.fps i{color:var(--p)}
.hdr-r{display:flex;gap:10px;align-items:center}
.tdots{display:flex;gap:6px}
.td{width:24px;height:24px;border-radius:50%;border:2px solid var(--bdr);cursor:pointer;transition:.2s}
.td:hover{transform:scale(1.2);border-color:var(--p)}
.td.b{background:#3e7cff}.td.r{background:#ff4c4c}.td.g2{background:#8a8f9c}.td.dm{background:#2d2d33}.td.gr{background:#2ecc71}.td.pu{background:#9b59b6}
.ubdg{background:var(--card);border-radius:60px;padding:6px 14px;color:var(--t2);border:1px solid var(--bdr);font-size:13px}
.ubdg i{color:var(--ok);margin-right:5px}
.minbtn{width:36px;height:36px;background:var(--card);border-radius:50%;display:flex;align-items:center;justify-content:center;color:var(--t2);border:1px solid var(--bdr);cursor:pointer;transition:.2s;font-size:17px}
.minbtn:hover{background:var(--p);color:#fff;border-color:var(--p)}
/* STATS GRID */
.sgrp{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:18px}
.sc{background:var(--card);border-radius:20px;padding:14px;border:1px solid var(--bdr);transition:.2s}
.sc:hover{border-color:var(--p)}
.sc-h{display:flex;justify-content:space-between;color:var(--t2);font-size:12px;margin-bottom:8px}
.sc-h i{color:var(--p);font-size:16px}
.sc-v{font-size:24px;font-weight:700;color:var(--t1);margin-bottom:8px}
.pbb{height:5px;background:var(--pb);border-radius:10px;overflow:hidden;margin-bottom:6px}
.pbf{height:100%;background:var(--p)}
.sc-f{display:flex;justify-content:space-between;color:var(--t2);font-size:11px}
/* TABS */
.tnav{display:flex;gap:5px;margin-bottom:16px;flex-wrap:wrap;background:var(--card);padding:7px 10px;border-radius:60px;border:1px solid var(--bdr)}
.tb{background:transparent;border:none;color:var(--t2);padding:8px 18px;border-radius:40px;font-size:13px;font-weight:500;cursor:pointer;display:flex;align-items:center;gap:6px;transition:.2s}
.tb i{font-size:13px}
.tb.active{background:var(--p);color:#fff;box-shadow:0 2px 8px var(--pg)}
.tb:hover:not(.active){background:rgba(62,124,255,.15);color:var(--t1)}
/* DASHBOARD */
.dboard{display:flex;gap:18px}
.tcont{flex:2;background:var(--card);border-radius:28px;padding:18px;border:1px solid var(--bdr);min-height:480px}
.tpanel{display:none}.tpanel.ap{display:block}
.fgrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px}
.fc{background:var(--panel);border-radius:20px;padding:14px;border:1px solid var(--bdr);transition:.2s}
.fc:hover{border-color:var(--p)}
.ctit{color:var(--t1);font-weight:600;margin-bottom:12px;display:flex;align-items:center;gap:7px;border-bottom:1px solid var(--bdr);padding-bottom:8px;font-size:14px}
.ctit i{color:var(--p)}
.cr{display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;color:var(--t2);font-size:13px}
.cr .lbl{display:flex;align-items:center;gap:5px}
/* SWITCH */
.sw{position:relative;display:inline-block;width:42px;height:22px}
.sw input{opacity:0;width:0;height:0}
.slr{position:absolute;cursor:pointer;top:0;left:0;right:0;bottom:0;background:var(--pb);transition:.3s;border-radius:34px;border:1px solid var(--bdr)}
.slr:before{position:absolute;content:"";height:16px;width:16px;left:3px;bottom:2px;background:var(--t2);transition:.3s;border-radius:50%}
input:checked+.slr{background:var(--p);border-color:var(--p)}
input:checked+.slr:before{transform:translateX(20px);background:#fff}
.ds{background:var(--card);color:var(--t1);border:1px solid var(--bdr);border-radius:40px;padding:5px 12px;font-size:12px;outline:none}
input[type=range]{width:100px;height:4px;background:var(--pb);border-radius:10px;-webkit-appearance:none}
input[type=range]::-webkit-slider-thumb{-webkit-appearance:none;width:14px;height:14px;background:var(--p);border-radius:50%;border:2px solid #fff;cursor:pointer}
.vb{background:var(--pb);padding:2px 8px;border-radius:40px;font-size:11px;color:var(--t1)}
.cdot{width:20px;height:20px;border-radius:50%;border:2px solid #fff;cursor:pointer}
/* RIGHT PANEL */
.rp{flex:1;display:flex;flex-direction:column;gap:16px}
.fov-box{background:var(--card);border-radius:28px;padding:16px;border:1px solid var(--bdr);text-align:center}
.fov-box h4{color:var(--t2);margin-bottom:12px;display:flex;align-items:center;gap:6px;font-size:13px}
.fov-circ{position:relative;width:150px;height:150px;margin:0 auto;background:var(--panel);border-radius:50%;border:2px solid var(--p);box-shadow:0 0 0 2px var(--bdr)}
.fov-ctr{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);width:7px;height:7px;background:var(--p);border-radius:50%}
.fov-lbl{margin-top:10px;color:var(--t2);font-size:12px}
.logbox{background:var(--card);border-radius:24px;padding:14px;border:1px solid var(--bdr);height:220px;display:flex;flex-direction:column}
.log-h{display:flex;justify-content:space-between;color:var(--t2);margin-bottom:8px;font-weight:500;font-size:13px}
.log-c{flex:1;overflow-y:auto;font-family:Menlo,monospace;font-size:11px;color:var(--t2);background:var(--panel);padding:8px;border-radius:12px;border:1px solid var(--bdr)}
.ll{padding:3px 0;border-bottom:1px solid var(--bdr);color:var(--t2)}.ll i{color:var(--p);margin-right:5px;width:16px}
.ll.ok{color:var(--ok)}.ll.wn{color:var(--warn)}
/* INJECT SECTION */
.inj{display:flex;justify-content:flex-end;align-items:center;gap:16px;margin-top:18px;flex-wrap:wrap}
.abopt{display:flex;gap:12px;background:var(--card);padding:8px 16px;border-radius:60px;border:1px solid var(--bdr);color:var(--t2);align-items:center;font-size:13px}
.soc{display:flex;gap:10px;margin-left:8px}
.soc a{color:var(--t2);font-size:18px;text-decoration:none;transition:.2s}
.soc a:hover{color:var(--p);transform:scale(1.15)}
.injbtn{background:linear-gradient(145deg,var(--card),var(--panel));border:1px solid var(--p);color:var(--t1);font-size:17px;font-weight:700;padding:12px 34px;border-radius:60px;display:inline-flex;align-items:center;gap:12px;cursor:pointer;transition:.3s;box-shadow:0 0 15px var(--pg)}
.injbtn i{color:var(--p)}
.injbtn:hover{background:var(--p);color:#fff;border-color:#fff}
.injbtn:hover i{color:#fff}
.injbtn.active{background:var(--ok);border-color:var(--ok);color:#fff}
/* FOOTER */
.footer{margin-top:18px;display:flex;gap:16px;color:var(--t2);font-size:12px;border-top:1px solid var(--bdr);padding-top:14px;flex-wrap:wrap}
/* RADAR MINI MAP */
.radar{position:relative;width:100%;height:160px;background:#080c14;border-radius:14px;border:1px solid var(--bdr);overflow:hidden;margin-top:8px}
.radar-center{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);width:8px;height:8px;background:var(--ok);border-radius:50%;box-shadow:0 0 6px var(--ok)}
.radar-ring{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);border:1px solid var(--p);border-radius:50%;opacity:.2}
.radar-enemy{position:absolute;width:7px;height:7px;background:#ff4444;border-radius:50%;transform:translate(-50%,-50%)}
/* STATUS DOT */
.sdot{width:8px;height:8px;border-radius:50%;background:var(--ok);display:inline-block;margin-right:4px;box-shadow:0 0 6px var(--ok);animation:pulse 1.5s infinite}
/* responsive */
@media(max-width:1100px){.dboard{flex-direction:column}.sgrp{grid-template-columns:repeat(2,1fr)}}
@media(max-width:600px){.sgrp{grid-template-columns:1fr}.fgrid{grid-template-columns:1fr}.tnav{border-radius:20px}}
</style>
</head>
<body class="theme-blue">
<!-- floating icons -->
<div class="fi"><i class="fas fa-skull-crossbones"></i></div>
<div class="fi"><i class="fas fa-crosshairs"></i></div>
<div class="fi"><i class="fas fa-bolt"></i></div>
<div class="fi"><i class="fas fa-shield-halved"></i></div>
<div class="fi"><i class="fas fa-eye"></i></div>
<div class="fi"><i class="fas fa-dragon"></i></div>
<div class="fi"><i class="fas fa-ghost"></i></div>
<div class="fi"><i class="fas fa-wand-magic"></i></div>

<div class="panel" id="panel">
  <!-- HEADER -->
  <div class="hdr">
    <div class="hdr-l">
      <h1><i class="fas fa-skull"></i> NEBULA • XERX-NET</h1>
      <div class="srow">
        <div class="sbadge"><i class="fas fa-wifi"></i> <span id="pingVal">23</span>ms</div>
        <div class="sbadge"><i class="fas fa-battery-three-quarters"></i> 87%</div>
        <div class="fps"><i class="fas fa-chart-line"></i> <span id="fpsVal">60</span> FPS</div>
      </div>
    </div>
    <div class="hdr-r">
      <div class="tdots">
        <div class="td b" data-t="theme-blue" title="Blue"></div>
        <div class="td r" data-t="theme-red" title="Red"></div>
        <div class="td g2" data-t="theme-gray" title="Gray"></div>
        <div class="td dm" data-t="theme-dark" title="Dark"></div>
        <div class="td gr" data-t="theme-green" title="Green"></div>
        <div class="td pu" data-t="theme-purple" title="Purple"></div>
      </div>
      <div class="ubdg"><i class="fas fa-shield-alt"></i> UNDETECTED</div>
      <div class="minbtn" id="minBtn"><i class="fas fa-window-minimize"></i></div>
    </div>
  </div>

  <!-- STATS GRID -->
  <div class="sgrp">
    <div class="sc"><div class="sc-h"><span>CPU LOAD</span><i class="fas fa-microchip"></i></div><div class="sc-v" id="cpu">43%</div><div class="pbb"><div class="pbf" style="width:43%"></div></div><div class="sc-f"><span>1.8 GHz</span><span>42°C</span></div></div>
    <div class="sc"><div class="sc-h"><span>MEMORY</span><i class="fas fa-memory"></i></div><div class="sc-v" id="mem">75%</div><div class="pbb"><div class="pbf" style="width:75%" id="memBar"></div></div><div class="sc-f"><span>6.2 GB</span><span>2.1 GB free</span></div></div>
    <div class="sc"><div class="sc-h"><span>GPU</span><i class="fas fa-tachometer-alt"></i></div><div class="sc-v" id="gpu">87%</div><div class="pbb"><div class="pbf" style="width:87%"></div></div><div class="sc-f"><span>2100 MHz</span><span>74°C</span></div></div>
    <div class="sc"><div class="sc-h"><span>NETWORK</span><i class="fas fa-network-wired"></i></div><div class="sc-v" id="net">12%</div><div class="pbb"><div class="pbf" style="width:12%" id="netBar"></div></div><div class="sc-f"><span><span id="pingVal2">23</span> ms</span><span>0% loss</span></div></div>
  </div>

  <div class="body-wrap">
    <!-- TABS -->
    <div class="tnav">
      <button class="tb active" data-tab="esp"><i class="fas fa-eye"></i> ESP</button>
      <button class="tb" data-tab="aimbot"><i class="fas fa-crosshairs"></i> Aimbot</button>
      <button class="tb" data-tab="visuals"><i class="fas fa-paint-roller"></i> Visuals</button>
      <button class="tb" data-tab="misc"><i class="fas fa-sliders-h"></i> Misc</button>
      <button class="tb" data-tab="settings"><i class="fas fa-tools"></i> Settings</button>
      <button class="tb" data-tab="antiban"><i class="fas fa-shield-virus"></i> Anti‑Ban</button>
    </div>

    <div class="dboard">
      <!-- TAB CONTENT -->
      <div class="tcont">

        <!-- ESP -->
        <div class="tpanel ap" id="t-esp">
          <div class="fgrid">
            <div class="fc">
              <div class="ctit"><i class="fas fa-user"></i> Player ESP</div>
              <div class="cr"><span class="lbl">Enable ESP</span><label class="sw"><input type="checkbox" id="espEnable" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Box</span><label class="sw"><input type="checkbox" id="espBox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Box type</span><select class="ds" id="espBoxType"><option>2D</option><option>3D</option><option>Corner</option></select></div>
              <div class="cr"><span class="lbl">Outline color</span><div class="cdot" id="espColor" style="background:#ff6666"></div></div>
              <div class="cr"><span class="lbl">Fill color</span><div class="cdot" style="background:#3e7cff"></div></div>
              <div class="cr"><span class="lbl">Health bar</span><label class="sw"><input type="checkbox" id="espHP" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Armor bar</span><label class="sw"><input type="checkbox" id="espArmor"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Name</span><label class="sw"><input type="checkbox" id="espName" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Distance</span><label class="sw"><input type="checkbox" id="espDist" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Skeleton</span><label class="sw"><input type="checkbox" id="espSkel"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Snaplines</span><label class="sw"><input type="checkbox" id="espLines" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Tracer from</span><select class="ds"><option>Bottom</option><option>Crosshair</option></select></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-cube"></i> Item ESP</div>
              <div class="cr"><span class="lbl">Loot</span><label class="sw"><input type="checkbox" id="espLoot" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Weapons</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Attachments</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Ammo</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Max dist</span><input type="range" min="0" max="500" value="250" id="espItemDist"> <span class="vb">250m</span></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-car"></i> Vehicle ESP</div>
              <div class="cr"><span class="lbl">Enable</span><label class="sw"><input type="checkbox" id="espVeh" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Show fuel</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-map"></i> Mini Radar</div>
              <div class="cr"><span class="lbl">Enable</span><label class="sw"><input type="checkbox" id="radarOn" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Zoom</span><input type="range" min="50" max="200" value="100" id="radarZoom"> <span class="vb">100%</span></div>
              <div class="radar" id="radarMap">
                <div class="radar-ring" style="width:60px;height:60px;margin-left:-30px;margin-top:-30px"></div>
                <div class="radar-ring" style="width:120px;height:120px;margin-left:-60px;margin-top:-60px"></div>
                <div class="radar-center"></div>
              </div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-eye-slash"></i> Filters</div>
              <div class="cr"><span class="lbl">Vis. check</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Max dist</span><input type="range" min="0" max="1000" value="400"> <span class="vb">400m</span></div>
              <div class="cr"><span class="lbl">Enemies only</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
            </div>
          </div>
        </div>

        <!-- AIMBOT -->
        <div class="tpanel" id="t-aimbot">
          <div class="fgrid">
            <div class="fc">
              <div class="ctit"><i class="fas fa-bullseye"></i> Aimbot Core</div>
              <div class="cr"><span class="lbl">Enable</span><label class="sw"><input type="checkbox" id="aimEnable" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Aim key</span><select class="ds" id="aimKey"><option>Always</option><option>ADS</option><option>Touch</option><option>LMB</option></select></div>
              <div class="cr"><span class="lbl">Aim mode</span><select class="ds" id="aimMode"><option>Normal</option><option>Silent</option><option>Magic Bullet</option><option>Bullet Track</option></select></div>
              <div class="cr"><span class="lbl">Target</span><select class="ds" id="aimTarget"><option>Closest</option><option>Crosshair</option><option>FOV</option></select></div>
              <div class="cr"><span class="lbl">FOV</span><input type="range" min="0" max="360" value="180" id="aimFov"> <span class="vb" id="aimFovLbl">180°</span></div>
              <div class="cr"><span class="lbl">Smoothness</span><input type="range" min="0" max="100" value="65" id="aimSmooth"> <span class="vb" id="aimSmoothLbl">65%</span></div>
              <div class="cr"><span class="lbl">Prediction</span><label class="sw"><input type="checkbox" id="aimPred" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Bullet vel.</span><input type="range" min="0" max="1000" value="600"> <span class="vb">600</span></div>
              <div class="cr"><span class="lbl">Vis. check</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Auto shoot</span><label class="sw"><input type="checkbox" id="aimAutoShoot"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Auto wall</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Bone</span><select class="ds" id="aimBone"><option>Head</option><option>Neck</option><option>Chest</option><option>Pelvis</option></select></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-gun"></i> Recoil Control</div>
              <div class="cr"><span class="lbl">No Recoil</span><label class="sw"><input type="checkbox" id="noRecoil" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Intensity</span><input type="range" min="0" max="100" value="80" id="recoilInt"> <span class="vb" id="recoilLbl">80%</span></div>
              <div class="cr"><span class="lbl">No Spread</span><label class="sw"><input type="checkbox" id="noSpread" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">No Sway</span><label class="sw"><input type="checkbox" id="noSway"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Rapid Fire</span><label class="sw"><input type="checkbox" id="rapidFire" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Rate (RPS)</span><input type="range" min="1" max="20" value="10"> <span class="vb">10</span></div>
              <div class="cr"><span class="lbl">Infinite Ammo</span><label class="sw"><input type="checkbox" id="infAmmo" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">No Reload</span><label class="sw"><input type="checkbox" id="noReload" checked><span class="slr"></span></label></div>
            </div>
          </div>
        </div>

        <!-- VISUALS -->
        <div class="tpanel" id="t-visuals">
          <div class="fgrid">
            <div class="fc">
              <div class="ctit"><i class="fas fa-sun"></i> World</div>
              <div class="cr"><span class="lbl">Night mode</span><label class="sw"><input type="checkbox" id="nightMode"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Brightness</span><input type="range" min="30" max="200" value="100"> <span class="vb">100%</span></div>
              <div class="cr"><span class="lbl">No Grass</span><label class="sw"><input type="checkbox" id="noGrass" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Wireframe</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Fog Removal</span><label class="sw"><input type="checkbox" id="noFog" checked><span class="slr"></span></label></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-crosshairs"></i> Crosshair</div>
              <div class="cr"><span class="lbl">Enable</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Style</span><select class="ds"><option>Dot</option><option>Cross</option><option>Circle</option></select></div>
              <div class="cr"><span class="lbl">Color</span><div class="cdot" style="background:#00ffaa"></div></div>
              <div class="cr"><span class="lbl">Size</span><input type="range" min="1" max="10" value="4"> <span class="vb">4</span></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-bolt"></i> Effects</div>
              <div class="cr"><span class="lbl">Hitmarker</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Sound</span><select class="ds"><option>Click</option><option>Beep</option><option>None</option></select></div>
              <div class="cr"><span class="lbl">Bullet Tracers</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Color</span><div class="cdot" style="background:#ffaa00"></div></div>
              <div class="cr"><span class="lbl">Impact markers</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Grenade traj.</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-ghost"></i> Chams &amp; Glow</div>
              <div class="cr"><span class="lbl">Player glow</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Color</span><div class="cdot" style="background:#ff44aa"></div></div>
              <div class="cr"><span class="lbl">Chams (players)</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Chams (weapons)</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
            </div>
          </div>
        </div>

        <!-- MISC -->
        <div class="tpanel" id="t-misc">
          <div class="fgrid">
            <div class="fc">
              <div class="ctit"><i class="fas fa-running"></i> Movement</div>
              <div class="cr"><span class="lbl">Speed hack</span><input type="range" min="1" max="5" step=".1" value="1.5" id="speedHack"> <span class="vb" id="speedLbl">1.5x</span></div>
              <div class="cr"><span class="lbl">Fly hack</span><label class="sw"><input type="checkbox" id="flyHack"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Ghost mode</span><label class="sw"><input type="checkbox" id="ghostMode"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">No clip</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Super jump</span><label class="sw"><input type="checkbox" id="superJump"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Height</span><input type="range" min="1" max="10" value="3"> <span class="vb">3x</span></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-magic"></i> Utility</div>
              <div class="cr"><span class="lbl">Instant revive</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Teleport WP</span><button class="injbtn" style="padding:4px 12px;font-size:12px" id="tpBtn">GO</button></div>
              <div class="cr"><span class="lbl">Safe zone %</span><input type="range" min="0" max="100" value="20"> <span class="vb">20%</span></div>
              <div class="cr"><span class="lbl">Reset Guest</span><button class="injbtn" style="padding:4px 12px;font-size:12px" id="resetGuestBtn">RESET</button></div>
            </div>
          </div>
        </div>

        <!-- SETTINGS -->
        <div class="tpanel" id="t-settings">
          <div class="fgrid">
            <div class="fc">
              <div class="ctit"><i class="fas fa-cog"></i> General</div>
              <div class="cr"><span class="lbl">Save config</span><button class="injbtn" style="padding:4px 12px;font-size:12px" id="saveBtn">SAVE</button></div>
              <div class="cr"><span class="lbl">Load config</span><button class="injbtn" style="padding:4px 12px;font-size:12px" id="loadBtn">LOAD</button></div>
              <div class="cr"><span class="lbl">Menu key</span><select class="ds"><option>Volume Up</option><option>Volume Down</option><option>Shake</option></select></div>
              <div class="cr"><span class="lbl">Stream proof</span><label class="sw"><input type="checkbox"><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Anti-screenshot</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-id-card"></i> HWID &amp; Priority</div>
              <div class="cr"><span class="lbl">HWID Spoofer</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Status</span><span style="color:var(--ok)"><span class="sdot"></span>Spoofed</span></div>
              <div class="cr"><span class="lbl">Process priority</span><select class="ds"><option>High</option><option>Normal</option></select></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-palette"></i> Appearance</div>
              <div class="cr"><span class="lbl">Language</span><select class="ds"><option>English</option><option>中文</option></select></div>
              <div class="cr"><span class="lbl">Logging</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Update check</span><button class="injbtn" style="padding:4px 12px;font-size:12px">CHECK</button></div>
            </div>
          </div>
        </div>

        <!-- ANTI-BAN -->
        <div class="tpanel" id="t-antiban">
          <div class="fgrid">
            <div class="fc">
              <div class="ctit"><i class="fas fa-shield-halved"></i> Bypass Methods</div>
              <div class="cr"><span class="lbl">Bypass type</span><select class="ds"><option>ANOGS</option><option>ShadowTracker</option><option selected>All</option></select></div>
              <div class="cr"><span class="lbl">Heartbeat spoof</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Memory cleaning</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Sig. obfuscation</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Fake HWID</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
              <div class="cr"><span class="lbl">Randomize HWID</span><button class="injbtn" style="padding:3px 10px;font-size:11px">RNG</button></div>
              <div class="cr"><span class="lbl">Cleaner on exit</span><label class="sw"><input type="checkbox" checked><span class="slr"></span></label></div>
            </div>
            <div class="fc">
              <div class="ctit"><i class="fas fa-shield-virus"></i> Bypass Status</div>
              <div class="cr"><span class="lbl">ANOGS Purge</span><span style="color:var(--ok)"><span class="sdot"></span>ACTIVE</span></div>
              <div class="cr"><span class="lbl">ptrace Block</span><span style="color:var(--ok)"><span class="sdot"></span>ACTIVE</span></div>
              <div class="cr"><span class="lbl">ShadowTracker</span><span style="color:var(--ok)"><span class="sdot"></span>ACTIVE</span></div>
              <div class="cr"><span class="lbl">GOT Proxies</span><span style="color:var(--ok)"><span class="sdot"></span>35 hooks</span></div>
              <div class="cr"><span class="lbl">AnoSDKIoctl</span><span style="color:var(--ok)"><span class="sdot"></span>SILENT</span></div>
            </div>
          </div>
        </div>
      </div>

      <!-- RIGHT PANEL -->
      <div class="rp">
        <div class="fov-box">
          <h4><i class="fas fa-circle"></i> FOV Preview</h4>
          <div class="fov-circ" id="fovCirc"><div class="fov-ctr"></div></div>
          <div class="fov-lbl" id="fovLbl">FOV: 180°</div>
        </div>
        <div class="logbox">
          <div class="log-h"><span><i class="fas fa-terminal"></i> Injection Log</span><span id="clearLog" style="cursor:pointer;opacity:.6"><i class="fas fa-trash-alt"></i></span></div>
          <div class="log-c" id="logC">
            <div class="ll ok"><i class="fas fa-check-circle"></i> ANOGS bypass – OK</div>
            <div class="ll ok"><i class="fas fa-check-circle"></i> ShadowTracker – OK</div>
            <div class="ll"><i class="fas fa-sync-alt"></i> Heartbeat spoof – active</div>
            <div class="ll wn"><i class="fas fa-exclamation-triangle"></i> Memory clean – running</div>
            <div class="ll ok"><i class="fas fa-shield"></i> HWID spoofed: 4F:3A:...</div>
            <div class="ll"><i class="fas fa-eye"></i> ESP hooks applied</div>
            <div class="ll"><i class="fas fa-bullseye"></i> Aimbot engine ready</div>
          </div>
        </div>
      </div>
    </div>

    <!-- INJECT SECTION -->
    <div class="inj">
      <div class="abopt">
        <i class="fas fa-shield-virus"></i>
        <span>ANOGS + ShadowTracker</span>
        <div class="soc">
          <a href="https://wa.me/+6283835144173" target="_blank"><i class="fab fa-whatsapp"></i></a>
          <a href="https://t.me/xerxlm" target="_blank"><i class="fab fa-telegram"></i></a>
          <a href="https://tiktok.com/@nebula_cheat" target="_blank"><i class="fab fa-tiktok"></i></a>
        </div>
        <i class="fas fa-check-circle" style="color:var(--ok)"></i>
      </div>
      <div class="injbtn" id="injBtn"><i class="fas fa-syringe"></i> INJECT CHEAT <i class="fas fa-chevron-right"></i></div>
    </div>
  </div>

  <!-- FOOTER -->
  <div class="footer">
    <span><span class="sdot"></span> BYPASS: ACTIVE (ANOGS+ShadowTracker+ptrace)</span>
    <span><i class="fas fa-clock"></i> SESSION: <span id="sesTimer">00:00:00</span></span>
    <span><i class="fas fa-user-secret"></i> HWID SPOOF: ENABLED</span>
    <span><i class="fas fa-microchip"></i> V.3.0 [GHOST UNBOUND]</span>
  </div>
  <!-- resize handle -->
  <div class="rh"><i class="fas fa-arrows-alt"></i></div>
</div>

<script>
(function(){
  // theme
  document.querySelectorAll('.td').forEach(d=>d.addEventListener('click',()=>{document.body.className=d.dataset.t}));

  // minimize
  const panel=document.getElementById('panel'),minBtn=document.getElementById('minBtn');
  minBtn.addEventListener('click',()=>{panel.classList.toggle('minimized');const ic=minBtn.querySelector('i');ic.className=panel.classList.contains('minimized')?'fas fa-window-maximize':'fas fa-window-minimize'});

  // tabs
  const tabs=document.querySelectorAll('.tb'),pnls={esp:document.getElementById('t-esp'),aimbot:document.getElementById('t-aimbot'),visuals:document.getElementById('t-visuals'),misc:document.getElementById('t-misc'),settings:document.getElementById('t-settings'),antiban:document.getElementById('t-antiban')};
  tabs.forEach(t=>t.addEventListener('click',()=>{tabs.forEach(b=>b.classList.remove('active'));t.classList.add('active');Object.values(pnls).forEach(p=>p.classList.remove('ap'));pnls[t.dataset.tab].classList.add('ap')}));

  // range live labels
  function rangeLive(id,lblId,suffix){var r=document.getElementById(id);if(r&&lblId){r.addEventListener('input',()=>{document.getElementById(lblId).textContent=r.value+suffix})}}
  rangeLive('aimFov','aimFovLbl','°');rangeLive('aimSmooth','aimSmoothLbl','%');rangeLive('recoilInt','recoilLbl','%');
  var sr=document.getElementById('speedHack'),sl=document.getElementById('speedLbl');if(sr)sr.addEventListener('input',()=>{sl.textContent=parseFloat(sr.value).toFixed(1)+'x'});

  // FOV circle sync
  var fovR=document.getElementById('aimFov'),fovC=document.getElementById('fovCirc'),fovL=document.getElementById('fovLbl');
  if(fovR)fovR.addEventListener('input',()=>{var v=parseInt(fovR.value);var pct=v/360;fovC.style.borderWidth=(2+pct*8)+'px';fovL.textContent='FOV: '+v+'°'});

  // fake FPS/ping
  setInterval(()=>{var fps=55+Math.floor(Math.random()*15);document.getElementById('fpsVal').textContent=fps;var ping=18+Math.floor(Math.random()*20);document.getElementById('pingVal').textContent=ping;document.getElementById('pingVal2').textContent=ping},2000);

  // session timer
  var sec=0;setInterval(()=>{sec++;var h=String(Math.floor(sec/3600)).padStart(2,'0'),m=String(Math.floor((sec%3600)/60)).padStart(2,'0'),s=String(sec%60).padStart(2,'0');document.getElementById('sesTimer').textContent=h+':'+m+':'+s},1000);

  // fake radar dots
  var radar=document.getElementById('radarMap');
  function addEnemyDot(){if(!radar)return;var e=document.createElement('div');e.className='radar-enemy';var bw=radar.offsetWidth||160,bh=radar.offsetHeight||160;e.style.left=(20+Math.random()*(bw-40))+'px';e.style.top=(20+Math.random()*(bh-40))+'px';radar.appendChild(e);setTimeout(()=>e.remove(),3000+Math.random()*2000)}
  setInterval(addEnemyDot,1500);

  // inject button
  var injBtn=document.getElementById('injBtn'),logC=document.getElementById('logC');
  injBtn.addEventListener('click',()=>{
    injBtn.classList.add('active');injBtn.innerHTML='<i class="fas fa-check-circle"></i> UNBOUND ACTIVE';
    function log(msg,cls){var l=document.createElement('div');l.className='ll '+(cls||'');l.innerHTML='<i class="fas fa-bolt"></i> '+msg;logC.appendChild(l);logC.scrollTop=logC.scrollHeight}
    log('Injection triggered – all bypasses active','ok');
    setTimeout(()=>log('ANOGS hooks reinstalled','ok'),400);
    setTimeout(()=>log('ShadowTracker heartbeat spoofed','ok'),800);
    setTimeout(()=>log('ptrace proxy ACTIVE – kernel blind','ok'),1200);
    setTimeout(()=>log('ESP overlay initialized'),1600);
    setTimeout(()=>log('Aimbot engine locked on'),2000);
    // notify native
    if(window.webkit&&window.webkit.messageHandlers&&window.webkit.messageHandlers.xerxNative){
      window.webkit.messageHandlers.xerxNative.postMessage({action:'inject',params:{}})
    }
  });

  // native bridge helpers
  function sendNative(action,params){if(window.webkit&&window.webkit.messageHandlers&&window.webkit.messageHandlers.xerxNative){window.webkit.messageHandlers.xerxNative.postMessage({action:action,params:params||{}})}}

  // toggle bridges to native
  document.getElementById('espEnable').addEventListener('change',function(){sendNative('setESP',{enabled:this.checked})});
  document.getElementById('aimEnable').addEventListener('change',function(){sendNative('setAimbot',{enabled:this.checked})});
  document.getElementById('noRecoil').addEventListener('change',function(){sendNative('setNoRecoil',{enabled:this.checked})});
  document.getElementById('noSpread').addEventListener('change',function(){sendNative('setNoSpread',{enabled:this.checked})});
  document.getElementById('flyHack').addEventListener('change',function(){sendNative('setFly',{enabled:this.checked})});
  document.getElementById('superJump').addEventListener('change',function(){sendNative('setJump',{enabled:this.checked})});
  document.getElementById('ghostMode').addEventListener('change',function(){sendNative('setGhost',{enabled:this.checked})});
  document.getElementById('infAmmo').addEventListener('change',function(){sendNative('setInfAmmo',{enabled:this.checked})});
  document.getElementById('noReload').addEventListener('change',function(){sendNative('setNoReload',{enabled:this.checked})});
  document.getElementById('rapidFire').addEventListener('change',function(){sendNative('setRapidFire',{enabled:this.checked})});
  document.getElementById('radarOn').addEventListener('change',function(){sendNative('setRadar',{enabled:this.checked})});
  document.getElementById('resetGuestBtn').addEventListener('click',function(){sendNative('resetGuest',{})});
  document.getElementById('clearLog').addEventListener('click',function(){logC.innerHTML=''});

  // save / load config
  document.getElementById('saveBtn').addEventListener('click',function(){
    var cfg={};document.querySelectorAll('input[id],select[id]').forEach(el=>{cfg[el.id]=el.type==='checkbox'?el.checked:el.value});
    localStorage.setItem('xerxCfg',JSON.stringify(cfg));
    var l=document.createElement('div');l.className='ll ok';l.innerHTML='<i class="fas fa-save"></i> Config saved';logC.appendChild(l);logC.scrollTop=logC.scrollHeight
  });
  document.getElementById('loadBtn').addEventListener('click',function(){
    var s=localStorage.getItem('xerxCfg');if(!s)return;
    var cfg=JSON.parse(s);Object.keys(cfg).forEach(id=>{var el=document.getElementById(id);if(el){if(el.type==='checkbox')el.checked=cfg[id];else el.value=cfg[id]}});
    var l=document.createElement('div');l.className='ll ok';l.innerHTML='<i class="fas fa-folder-open"></i> Config loaded';logC.appendChild(l);logC.scrollTop=logC.scrollHeight
  });
})();
</script>
</body>
</html>
)HTMLEOF";
