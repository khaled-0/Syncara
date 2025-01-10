<script setup lang="ts">
import {
  ArrowDownTrayIcon,
  ArrowPathIcon,
  RocketLaunchIcon,
  PlayPauseIcon,
  LanguageIcon,
  ComputerDesktopIcon,
  DevicePhoneMobileIcon,
  DeviceTabletIcon,
} from '@heroicons/vue/24/outline'

import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
  CarouselPreviousInner,
  CarouselNextInner,
} from '@/components/ui/carousel'
import TonalButton from './components/ui/TonalButton.vue'
import FilledButton from './components/ui/FilledButton.vue'

const screenshots = [
  '1.jpg',
  '2.jpg',
  '3.jpg',
  '4.jpg',
  '5.jpg',
  '6.jpg'
]

const desktopScreenshots = [
  'https://raw.githubusercontent.com/khaled-0/Syncara/refs/heads/main/docs/screenshots/linux_1.png',
  'https://raw.githubusercontent.com/khaled-0/Syncara/refs/heads/main/docs/screenshots/linux_2.png',
  'https://raw.githubusercontent.com/khaled-0/Syncara/refs/heads/main/docs/screenshots/linux_3.png',
  /*
  {
    src: 'https://raw.githubusercontent.com/khaled-0/Syncara/refs/heads/main/docs/screenshots/macos_1.png',
    alt: 'Syncara screenshot',
  },*/
]

const bigScreen = screen.width > 1024

if (bigScreen) {
  desktopScreenshots.push('https://raw.githubusercontent.com/khaled-0/Syncara/refs/heads/main/docs/screenshots/macos_1.png')
}
</script>
<template>
  <link rel="dns-prefetch" href="https://fonts.gstatic.com" />


  <body class="flex flex-col w-screen h-fit root text-[var(--md-sys-color-on-background)]">
    <header class="flex items-center justify-between p-4">
      <div class="flex items-center">
        <img fetchpriority="high" src='/logo.svg' alt="Syncara logo" class="h-12 w-12 lg:h-14 lg:w-14 me-4" />
        <h1 class="title">Syncara</h1>
      </div>
    </header>

    <main class="flex flex-col flex-grow scroll-smooth">
      <section class="flex flex-col items-center gap-8">
        <div class="flex flex-col lg:flex-row items-center gap-8 justify-evenly w-full pb-20">
          <div class="flex flex-col items-center mt-24 mb-24 lg:mt-0 lg:mb-0">
            <img src="/logo.svg" alt="Syncara logo" class="h-24 w-24 lg:h-32 lg:w-32 mb-2" />
            <h1 class="title text-3xl font-semibold">Syncara</h1>
            <h2 class="text-md lg:text-lg text-[var(--md-sys-color-on-surface-variant)] text-pretty mb-1">
              v0.1.7
            </h2>
            <p class="text-xl text-pretty text-center lg:text-start">
              Carry your playlists everywhere, even when offline
            </p>

            <div class="flex gap-4 mt-4 justify-between">
              <FilledButton href="#download" title="Download" />

              <TonalButton href="https://github.com/khaled-0/Syncara" title="GitHub" />
            </div>
          </div>
          <img fetchpriority="high" src='/1.jpg'
            alt="Syncara screenshot" class="w-[60vw] lg:w-fit lg:h-[40vw] rounded-3xl" />
        </div>
      </section>

      <section class="flex flex-col items-center gap-4 lg:gap-8">
        <h1 class="heading decoration-inherit underline underline-offset-4">Features</h1>

        <div
          class="grid grid-cols-1 lg:grid-cols-2 items-center text-center justify-center gap-8 ps-8 pe-8 lg:ps-24 lg:pe-24 w-full">
          <div class="flex flex-col items-center rounded-3xl p-8 hover:bg-[var(--md-sys-color-surface-container-high)]">
            <arrow-down-tray-icon class="size-10 mb-1" />

            <h2 class="text-2xl text-pretty font-medium mb-2">Offline Downloads</h2>
            <p
              class="text-lg lg:text-start text-pretty lg:antialiased font-normal text-[var(--md-sys-color-on-surface-variant)]">
              Carry your playlists everywhere, even when offline
            </p>
          </div>
          <div class="flex flex-col items-center rounded-3xl p-8 hover:bg-[var(--md-sys-color-surface-container-high)]">
            <arrow-path-icon class="size-10 mb-1" />

            <h2 class="text-2xl text-pretty font-medium mb-2">Background Playback</h2>
            <p
              class="text-lg lg:text-start text-pretty lg:antialiased font-normal text-[var(--md-sys-color-on-surface-variant)]">
              Listen to your favorite music while using other apps
            </p>
          </div>
          <div class="flex flex-col items-center rounded-3xl p-8 hover:bg-[var(--md-sys-color-surface-container-high)]">
            <rocket-launch-icon class="size-10 mb-1" />

            <h2 class="text-2xl text-pretty font-medium mb-2">Fluid Gesture Navigations</h2>
            <p
              class="text-lg lg:text-start text-pretty lg:antialiased font-normal text-[var(--md-sys-color-on-surface-variant)]">
              Fluid gesture navigations for a seamless experience
            </p>
          </div>

          <div class="flex flex-col items-center rounded-3xl p-8 hover:bg-[var(--md-sys-color-surface-container-high)]">
            <language-icon class="size-10 mb-1" />

            <h2 class="text-2xl text-pretty font-medium mb-2">Realtime Lyrics</h2>
            <p
              class="text-lg lg:text-start text-pretty lg:antialiased font-normal text-[var(--md-sys-color-on-surface-variant)]">
              Sing along with the lyrics in realtime
            </p>
          </div>

          <div class="flex flex-col items-center rounded-3xl p-8 hover:bg-[var(--md-sys-color-surface-container-high)]">
            <computer-desktop-icon class="size-10 mb-1" />

            <h2 class="text-2xl text-pretty font-medium mb-2">Cross Platform</h2>
            <p
              class="text-lg lg:text-start text-pretty lg:antialiased font-normal text-[var(--md-sys-color-on-surface-variant)]">
              Syncara is available on Android, iOS, Windows, macOS, and Linux
            </p>
          </div>

          <div class="flex flex-col items-center rounded-3xl p-8 hover:bg-[var(--md-sys-color-surface-container-high)]">
            <play-pause-icon class="size-10 mb-1" />

            <h2 class="text-2xl text-pretty font-medium mb-2">No Ads</h2>
            <p
              class="text-lg lg:text-start text-pretty lg:antialiased font-normal text-[var(--md-sys-color-on-surface-variant)]">
              Enjoy your music without any interruptions
            </p>
          </div>
        </div>
      </section>

      <section class="flex flex-col items-center gap-4 lg:gap-8 h-full">
        <h1 class="heading pt-8">Screenshots</h1>

        <h2 class="text-xl text-pretty font-medium mb-2 decoration-inherit underline underline-offset-4">
          Android
        </h2>

        <div v-if="bigScreen" class="flex gap-8 ps-8 pe-8 h-fit w-screen overflow-auto no-scrollbar">
          <img v-for="ss in screenshots" v-bind:key="ss" :src="ss"
            class="h-[38vw] hover:scale-110 transform transition duration-300 rounded-2xl mt-8 mb-8"
            alt="Syncara screenshot" />
        </div>

        <div v-else class="flex gap-8 ps-24 pe-24">
          <Carousel class="relative w-fit lg:hidden">
            <CarouselContent>
              <CarouselItem v-for="ss in screenshots" v-bind:key="ss">
                <img :src="ss" alt="Syncara screenshot" class="w-[60vw] rounded-2xl" />
              </CarouselItem>
            </CarouselContent>

            <CarouselPrevious />
            <CarouselNext />
          </Carousel>

        </div>

        <h2 class="text-xl text-pretty font-medium mt-4 mb-2 decoration-inherit underline underline-offset-4">
          Desktop
        </h2>

        <div v-if="bigScreen" class="grid grid-cols-2 items-center gap-10 ps-22 pe-22">
          <img v-for="ss in desktopScreenshots" v-bind:key="ss" :src="ss"
            class="w-[42vw] h-fit rounded-2xl hover:scale-110 transform transition duration-300"
            alt="Syncara screenshot" />
        </div>

          <Carousel v-else class="relative w-fit lg:hidden p-4">
            <CarouselContent>
              <CarouselItem v-for="ss in desktopScreenshots" v-bind:key="ss">
                <img :src="ss" alt="Syncara screenshot" class="w-full rounded-2xl" />
              </CarouselItem>
            </CarouselContent>

            <CarouselPreviousInner />
            <CarouselNextInner />
          </Carousel>
      </section>

      <section id="download" class="flex flex-col items-center gap-8 h-full">
        <h1 class="heading pt-8">Download</h1>

        <div class="grid lg:grid-cols-2 items-center gap-8 ps-8 pe-8 lg:ps-24 lg:pe-24">
          <div class="flex flex-col h-full items-center rounded-3xl p-8 hover:bg-[var(--md-sys-color-surface-container-high)]">
            <device-tablet-icon class="size-10 mb-1" />

            <h2 class="text-2xl text-pretty font-medium mb-2">Android</h2>
            <p class="text-lg text-center lg:text-start text-pretty antialiased font-normal text-[var(--md-sys-color-on-surface-variant)]">
              Download Syncara on your Android device
            </p>

            <FilledButton target="_blank"
              href="https://github.com/khaled-0/Syncara/releases/latest/download/app-release.apk" class="mt-4"
              title="Download"/>
          </div>

          <div class="flex flex-col h-full items-center rounded-3xl p-8 hover:bg-[var(--md-sys-color-surface-container-high)]">
            <device-phone-mobile-icon class="size-10 mb-1" />

            <h2 class="text-2xl text-pretty font-medium mb-2">iOS</h2>
            <p class="text-lg text-center lg:text-start text-pretty antialiased font-normal text-[var(--md-sys-color-on-surface-variant)]">
              Unsigned (.ipa) builds are available.
              <br />
              Note: Use
              <a class="text-[var(--md-sys-color-primary)] font-medium hover:underline" target="_blank"
                href="https://sideloadly.io">Sideloadly</a>
              to install it. Here's a
              <a class="text-[var(--md-sys-color-primary)] font-medium hover:underline" target="_blank"
                href="https://youtube.com/watch?v=r91iJ6KRcUs">video tutorial by @ilyassesalama</a>
            </p>

            <FilledButton target="_blank"
              href="https://github.com/khaled-0/Syncara/releases/latest/download/syncara_ios_unsigned.ipa"
              class="mt-4"
              title="Download" />
          </div>
        </div>

        <div class="flex flex-col h-full items-center rounded-3xl p-8 hover:bg-[var(--md-sys-color-surface-container-high)]">
          <computer-desktop-icon class="size-10 mb-1" />

          <h2 class="text-2xl text-pretty font-medium mb-2">Desktop</h2>
          <p class="text-lg text-center lg:text-start text-pretty antialiased font-normal text-[var(--md-sys-color-on-surface-variant)]">
            Download Syncara on your desktop
          </p>

          <div class="flex gap-4 mt-4">
            <TonalButton target="_blank"
              href="https://github.com/khaled-0/Syncara/releases/latest/download/syncara_linux.zip"
              class="mt-4"
              title="Linux" />

            <FilledButton target="_blank"
              href="https://github.com/khaled-0/Syncara/releases/latest/download/syncara_macos.zip"
              class="mt-4"
              title="macOS" />
          </div>
        </div>
      </section>

      <section class="flex flex-col items-center gap-8 h-full">
        <h1 class="heading pt-8 text-center lg:text-start ps-8 pe-8 lg:ps-16 lg:pe-16">Also available on your favourite App Stores</h1>

        <h2 class="text-xl text-pretty font-medium mb-2 decoration-inherit underline underline-offset-4">
          Android
        </h2>

        <div class="flex flex-col lg:flex-row gap-6 justify-center items-center content-center">
          <a href="https://apt.izzysoft.de/fdroid/index/apk/syncara.app">
            <img src='https://raw.githubusercontent.com/khaled-0/Syncara/main/docs/badges/get-it-on-izzy.png'
              alt="Izzys F-Droid Repository" class="h-16" />
          </a>
          <a
            href="http://apps.obtainium.imranr.dev/redirect.html?r=obtainium://app/%7B%22id%22%3A%22syncara.app%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2Fkhaled-0%2FTubeSync%22%2C%22author%22%3A%22Khaled%22%2C%22name%22%3A%22Syncara%22%2C%22additionalSettings%22%3A%22%7B%5C%22includePrereleases%5C%22%3Afalse%7D%22%7D">
            <img src='https://raw.githubusercontent.com/khaled-0/Syncara/main/docs/badges/badge_obtainium.png'
              alt="Obtainium" class="h-16" />
          </a>
          <a href="https://www.openapk.net/syncara/syncara.app">
            <img src='https://raw.githubusercontent.com/khaled-0/Syncara/main/docs/badges/openapk-badge.png'
              alt="OpenAPK" class="h-16" />
          </a>
          <a href="https://www.androidfreeware.net/download-syncara-apk.html">
            <img src='https://raw.githubusercontent.com/khaled-0/Syncara/main/docs/badges/android-freeware.png'
              alt="Android Freeware" class="h-16" />
          </a>
        </div>

        <h2 class="text-xl text-pretty font-medium mb-2 decoration-inherit underline underline-offset-4">
          Linux
        </h2>

        <div class="flex gap-6 justify-center items-center content-center">
          <a href="https://flathub.org/apps/io.github.khaled_0.TubeSync">
            <img src="https://raw.githubusercontent.com/khaled-0/Syncara/main/docs/badges/flathub.png" alt="Flathub"
              class="h-16" />
          </a>
        </div>
      </section>

      <footer class="flex flex-col items-center justify-center p-4">
        <p class="text-md text-[var(--md-sys-color-on-surface-variant)]">
          Made by
          <a href="https://github.com/PranavPurwar" class="text-[var(--md-sys-color-primary)] hover:underline"
            target="_blank" rel="noopener noreferrer">
            Pranav Purwar
          </a>
        </p>
      </footer>
    </main>
  </body>
</template>
