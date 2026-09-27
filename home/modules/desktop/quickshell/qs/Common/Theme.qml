pragma Singleton
import QtQuick
import Quickshell
import qs.Config

Singleton {
    readonly property color background: Env.colors.base00
    readonly property color text: Env.colors.base05
    readonly property color muted: Env.colors.base04
    readonly property color accent: Env.colors.base0D
    readonly property color accentAlt: Env.colors.base09
    readonly property color warning: Env.colors.base0A
    readonly property color urgent: Env.colors.base08
    readonly property color low: Env.colors.base03
    readonly property color border: Env.colors.base02
    // A step up from the border: hover has to read against the background on
    // its own, and base02 is close enough to base00 to disappear against it.
    readonly property color hover: Env.colors.base03

    readonly property string fontFamily: Env.fontFamily
    readonly property int fontSize: Env.fontSize
    readonly property string popupFontFamily: Env.popupFontFamily
    readonly property int popupFontSize: Env.popupFontSize
    readonly property int popupLabelFontSize: popupFontSize - 2
    readonly property int emphasisWeight: Font.DemiBold

    // The bar tracks the font so a larger desktop size cannot clip glyphs.
    readonly property int barHeight: Math.round(Env.fontSize * 3)
    readonly property int itemPadding: 6
    // Gaps between the items in a bar row, and between the outermost item and
    // the screen edge. Groups that read as one widget (workspaces, tray) stay
    // tight inside themselves and only take this gap from their neighbours.
    readonly property int itemSpacing: 8
    readonly property int barMargin: 12
    readonly property int radius: 4

    readonly property int popupPadding: 10
    readonly property int popupRadius: 4
    // One clickable line in a popup, and the width every popup body gets: the
    // bar is a row of unrelated widgets, and popups that each sized themselves
    // to their own contents made it look like one.
    readonly property int popupRowHeight: Math.round(popupFontSize * 2.4)
    readonly property int popupWidth: 240
    readonly property int tooltipMaxWidth: 480

    readonly property int notificationWidth: 380
    readonly property int notificationMaxHeight: 180
    readonly property int notificationBorder: 2
    readonly property int notificationTimeout: 10000
    readonly property int notificationMaxVisible: 5
    // How tall the history list in the center may grow before it scrolls.
    readonly property int notificationCenterMaxHeight: 520
    readonly property int notificationHistory: 20
}
