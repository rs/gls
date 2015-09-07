# Graphical ls for iTerm2

The `gls` command uses the [iTerm2 image capability](http://www.iterm2.com/images.html) to display Finder's file icons in the terminal.

<img src="screenshot.png" width="442" height="310">

The current version if very basic, with no support for any of the `ls` options.

## Build from Source

    $ xcodebuild SYMROOT=build
    $ install build/Release/gls /usr/local/bin
