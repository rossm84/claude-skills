---
name: web-audio-synthesis
description: Use when creating UI sound effects, notification sounds, or audio feedback without external audio files. Use when the user wants procedural audio, Web Audio API, synthesized sounds, beeps, clicks, chimes, or retro sound effects in a web app.
---

# Web Audio API — Procedural Sound Synthesis

## Overview

Generate sound effects entirely in code using the Web Audio API. No audio files needed — sounds are synthesized from oscillators, noise buffers, and filters. Works in all modern browsers.

## Setup

```javascript
const AudioCtx = window.AudioContext || window.webkitAudioContext;
let audioCtx = null;

function ensureAudio() {
    if (!audioCtx) audioCtx = new AudioCtx();
    return audioCtx;
}
```

**Important:** AudioContext must be created after a user gesture (click/tap). Call `ensureAudio()` inside event handlers, not at page load.

## Building Blocks

### Oscillator (tonal sounds)

```javascript
const ctx = ensureAudio();
const osc = ctx.createOscillator();
const gain = ctx.createGain();
osc.type = 'sine';           // sine, square, sawtooth, triangle
osc.frequency.value = 440;   // Hz
gain.gain.value = 0.1;       // Volume (0-1, keep low)
osc.connect(gain).connect(ctx.destination);
osc.start();
osc.stop(ctx.currentTime + 0.5);  // Always schedule stop
```

### Noise Buffer (clicks, static, percussion)

```javascript
const ctx = ensureAudio();
const bufSize = ctx.sampleRate * 0.02;  // 20ms
const buf = ctx.createBuffer(1, bufSize, ctx.sampleRate);
const data = buf.getChannelData(0);
for (let i = 0; i < bufSize; i++) {
    data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / bufSize, 8);
    //         ↑ white noise              ↑ exponential decay (higher = sharper)
}
const src = ctx.createBufferSource();
src.buffer = buf;
src.connect(ctx.destination);
src.start();
```

### Filter (shape the tone)

```javascript
const filter = ctx.createBiquadFilter();
filter.type = 'bandpass';       // lowpass, highpass, bandpass
filter.frequency.value = 1800;  // Center frequency
filter.Q.value = 2;             // Resonance (higher = narrower)
osc.connect(filter).connect(gain).connect(ctx.destination);
```

### Envelope (volume over time)

```javascript
const gain = ctx.createGain();
const now = ctx.currentTime;
gain.gain.setValueAtTime(0.1, now);                      // Start volume
gain.gain.exponentialRampToValueAtTime(0.001, now + 0.3); // Fade out
// Note: exponentialRamp target must be > 0 (use 0.001, not 0)
```

## Ready-Made Sound Recipes

### Click (keyboard/button)

```javascript
function playClick() {
    const ctx = ensureAudio();
    const bufSize = ctx.sampleRate * 0.02;
    const buf = ctx.createBuffer(1, bufSize, ctx.sampleRate);
    const data = buf.getChannelData(0);
    for (let i = 0; i < bufSize; i++) {
        data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / bufSize, 8);
    }
    const src = ctx.createBufferSource();
    src.buffer = buf;
    const gain = ctx.createGain();
    gain.gain.value = 0.08;
    const filter = ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.value = 1800 + Math.random() * 600;
    filter.Q.value = 2;
    src.connect(filter).connect(gain).connect(ctx.destination);
    src.start();
}
```

### Success / Error Beep

```javascript
function playBeep(success) {
    const ctx = ensureAudio();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = 'square';
    osc.frequency.value = success ? 880 : 220;
    gain.gain.setValueAtTime(0.06, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.08);
    osc.connect(gain).connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + 0.08);
}
```

### Chime (multi-note ascending)

```javascript
function playChime() {
    const ctx = ensureAudio();
    const notes = [523.25, 659.25, 783.99]; // C5, E5, G5
    notes.forEach((freq, i) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.value = freq;
        const t = ctx.currentTime + i * 0.12;
        gain.gain.setValueAtTime(0.1, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.4);
        osc.connect(gain).connect(ctx.destination);
        osc.start(t);
        osc.stop(t + 0.4);
    });
}
```

### Power-On Hum

```javascript
function playPowerOn() {
    const ctx = ensureAudio();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(40, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(120, ctx.currentTime + 0.3);
    osc.frequency.exponentialRampToValueAtTime(60, ctx.currentTime + 0.8);
    gain.gain.setValueAtTime(0.12, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.8);
    osc.connect(gain).connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + 0.8);
}
```

## Quick Reference

| Sound Type | Wave | Frequency | Duration | Decay |
|-----------|------|-----------|----------|-------|
| Click | Noise buffer | 1800Hz bandpass | 20ms | pow(8) |
| Beep (success) | Square | 880Hz | 80ms | exponential |
| Beep (error) | Square | 220Hz | 80ms | exponential |
| Chime | Sine | C5-E5-G5 | 400ms/note | exponential |
| Hum | Sawtooth | 40→120→60Hz | 800ms | exponential |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Creating AudioContext at page load | Create on first user gesture (click handler) |
| `exponentialRampToValueAtTime(0, ...)` | Use `0.001` — exponential ramp can't reach zero |
| Not calling `osc.stop()` | Always schedule stop — oscillators run forever otherwise |
| Volume too loud (gain > 0.3) | Keep gain at 0.05-0.15 for UI sounds |
| No filter on noise | Raw noise is harsh — add bandpass or highpass |
| Not connecting to destination | Chain must end at `ctx.destination` |
