<div align="center">

<img src="assets/icons/appIcon.png" width="150">

# Openlib

An Open source app to download and read books from shadow library ([Anna’s Archive](https://annas-archive.org/))

[![made-with-flutter](https://img.shields.io/badge/Made%20with-Flutter-4361ee.svg?style=for-the-badge)](https://flutter.dev/)
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-e63946.svg?style=for-the-badge)](https://opensource.org/licenses/)
[![Latest release](https://img.shields.io/github/release/MeatBag69/Openlib_reborn.svg?style=for-the-badge)](https://github.com/MeatBag69/Openlib_reborn/releases)

[<img src="github_releases.png"
     alt="Get it on GitHub"
     height="60">](https://github.com/MeatBag69/Openlib_reborn/releases)
</div>

## Note 📝

**WARNING:** This App Is In Beta Stage, So You May Encounter Bugs. If You Do, Open An Issue In the Github Repository.

**Publishing Openlib, Or Any Fork Of It In The Google Play Store Violates Their Terms And Conditions**

## Screenshots 🖼️

<!-- TODO: Update these screenshots with the latest version of the app -->
<div align="center">
    <img src="screenshots/Screenshot_1.png" width=160>
    <img src="screenshots/Screenshot_2.png" width=160>
    <img src="screenshots/Screenshot_3.png" width=160>
    <img src="screenshots/Screenshot_4.png" width=160>
    <img src="screenshots/Screenshot_5.png" width=160>
    <img src="screenshots/Screenshot_6.png" width=160>
    <img src="screenshots/Screenshot_7.png" width=160>
    <img src="screenshots/Screenshot_8.png" width=160>
</div>

## Description 📖

Openlib Is An Open Source App To Download And Read Books From Shadow Library ([Anna’s Archive](https://annas-archive.org/)). The App Has Built-In Reader to Read Books.

As [Anna’s Archive](https://annas-archive.org/) Doesn't Have An API, The App Works By Sending Requests To Anna’s Archive And Parsing The DOM Response. To ensure reliability, the app now supports **Multiple Mirrors** and will automatically switch to a working mirror if the primary one is blocked or down.

## Features ✨

- **Multi-Mirror Support**: Automatically switches between `.li`, `.se`, `.org`, and others if one fails.
- Trending Books
- Download And Read Books With In-Built Viewer
- Supports Epub And Pdf Formats
- Open Books In Your Favourite Ebook Reader
- Filter Books
- Sort Books

## Roadmap 🎯

- Adding More Book Format supports (cbz,cbr,azw3,etc...)
- Adding Support For Background Downloads
- Adding Support For Multiple Downloads
- Move existing books when changing the storage path

## Building from Source

- If you don't have Flutter SDK installed, please visit official [Flutter](https://flutter.dev) site.

- Git Clone The Repo

     ```sh
     git clone https://github.com/MeatBag69/Openlib_reborn.git
     ```

- Run the app with Android Studio or VS Code. Or the command line:

     ```sh
     flutter pub get
     flutter run
     ```

- To Build App Run:

     ```sh
     flutter build apk
     ```

- The Build Will Be In `./build/app/outputs/flutter-apk/app-release.apk`

### Android

Make sure that `android/local.properties` has `flutter.minSdkVersion=21` or above.
For setup guide see [SETUP.md](./SETUP.md)

## Contributor required 🚧

We are actively seeking contributors. Whether you're a seasoned developer or just starting out, we welcome your contributions to help make this project even better!

## Contribution 💝

Whether you have ideas, design changes or even major code changes, help is always welcome. The app gets better and better with each contribution, no matter how big or small!

If you'd like to get involved See [CONTRIBUTING.md](./CONTRIBUTING.md) for the guidelines.

## Issues 🚩

Please report bugs via the [issue tracker](https://github.com/MeatBag69/Openlib_reborn/issues).

## Donate 🎁

If you like Openlib, you're welcome to send a donation to the original developers or support Anna's Archive directly.

[Donate To Anna’s Archive.](https://annas-archive.org/donate?tier=1)

## License 📜

[![GNU GPLv3 Image](https://www.gnu.org/graphics/gplv3-127x51.png)](https://www.gnu.org/licenses/gpl-3.0.en.html)  

Openlib is a free software licensed under GPL v3.0 It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY. [GNU General Public License](https://www.gnu.org/licenses/gpl.html) as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

## Disclaimer ⚠️

Openlib does not own or have any affiliation with the books available through the app. All books are the property of their respective owners and are protected by copyright law. Openlib is not responsible for any infringement of copyright or other intellectual property rights that may result from the use of the books available through the app. By using the app, you agree to use the books only for personal, non-commercial purposes and in compliance with all applicable laws and regulations.
