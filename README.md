# Graphical ls for iTerm2 (v3)

The `gls` command uses the [iTerm2 (version 3 beta) image capability](http://www.iterm2.com/images.html) to display Finder's file icons in the terminal.

<img src="screenshot.png" width="442" height="310">

The current version is very basic, with no support for any of the `ls` options.

## Install with Homebrew

Make sure you are using the lastest [beta of iTerm2 version 3](http://www.iterm2.com/downloads/nightly/#/section/home).

    $ brew install https://raw.githubusercontent.com/rs/homebrew/gls/Library/Formula/gls.rb

For El Capitan users:

    $ brew install --HEAD https://raw.githubusercontent.com/rs/homebrew/gls/Library/Formula/gls.rb

## Build from Source

    $ xcodebuild SYMROOT=build
    $ install build/Release/gls /usr/local/bin
