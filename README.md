# Framework
A Commodore 128 software framework for enabling high-level development of C128 programs.

## Integrate c128lib
* Create a *build.gradle* file with this content
``` Gradle
plugins {
    id "com.github.c64lib.retro-assembler" version "1.7.6"
}

repositories {
    mavenCentral()
}

apply plugin: "com.github.c64lib.retro-assembler"

retroProject {
    dialect = "KickAssembler"
    dialectVersion = "5.25"
    libDirs = [".ra/deps/c128lib", ".."]
    srcDirs = ["."]
    excludes = ["**/_*.asm", ".ra/**/*", "libs/*"]

    // dependencies
    libFromGitHub "c128lib/common", "0.6.0"
    libFromGitHub "c128lib/chipset", "0.7.1"
}
```
  * check for *retro-assembler* plugin latest version [here](https://github.com/c64lib/gradle-retro-assembler-plugin)
  * check for *KickAssembler* latest version [here](http://theweb.dk/KickAssembler/Main.html#frontpage) (set it on *dialectVersion* field)
* set *libDirs* where libraries should live
* set *srcDirs* where your source code should be
* set *excludes* to indicate which files should be compiled
* set a *libFromGitHub* row for every dependecies you need (with the right
version)
* install JDK
* install Gradle
* type *gradle* on command prompt and let the magic happens


## Z80 code integration

Starting with v0.2.0 (still unreleased) are available some macros for Z80 code integration.
Macros will help developers to setup Z80 code and prepare programs to start execution.

**The code for Z80 will not run in parallel with the code for 8502** but there will only be preemptive multitasking.
To understand mechanism for Z80 and 8502 switchover [look at this post](https://intoinside.github.io/2023/07/07/running-z80/).

### Macros
There are two kind of macros:
* c128lib_PreZ80Code() and c128lib_PostZ80Code()
* c128lib_RunZ80Code(z80CodeAddress)

The first two macros are needed to *decorate* your Z80 code (setup Mmu at start
and jmp to bootlink routine at the end to consent 8502 restart).
They must be called before and after your Z80 code.

The last macro will prepare environment to start Z80 code execution and handles
return from z80 code.

Here an example of entry point to call Z80 code:

<pre><code>
c128lib_BasicUpstart128($2000)

* = $2000 "Entry"
Entry: {
  // Some code executed on 8502

  c128lib_RunZ80Code(z80CodeAddress)

  // Other code executed on 8502

  rts
}
</code></pre>

Then, you can define an area (called z80CodeAddress on the example above) and
call macros to decorate it:

<pre><code>
* = * "z80CodeAddress"
z80CodeAddress:
  c128lib_PreZ80Code()

  .byte $3E, $08        // LD A, #$08   -- load up the #$08 (H) byte
  .byte $32, $00, $04   // LD ($0400),A -- write on screen
  .byte $3C             // INC A
  .byte $32, $01, $04   // LD ($0401),A -- write on screen
  .byte $3E, $21        // LD A, #$21   -- load up the #$21 (!) byte
  .byte $32, $02, $04   // LD ($0402),A -- write on screen

  c128lib_PostZ80Code()
</code></pre>

If you run this script, you'll see "HI!" printed on the 40 col screen by
Z80 processor. At this time, z80 code must be written as a byte sequence of
machine language instruction. I hope I can change that soon.

PS: i'm not an expert of z80 code... so that code it's quite stupid, probably not
optimized etc..., take it just as an example.

I suggest to use [GlassZ80](http://www.grauw.nl/projects/glass/) as assembler
to generate machine language code. Code can be assembled on external file and
imported with <i>.import binary "file"</i> to make code more readable and separate
concerns.
Z80 code can be assembled like:

<pre>java -jar glass.jar test.zasm test.bin</pre>

and then importing with:

<pre>.import binary "test.bin"</pre>
