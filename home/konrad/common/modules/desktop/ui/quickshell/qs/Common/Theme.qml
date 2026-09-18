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
    readonly property color hover: Env.colors.base02

    readonly property string fontFamily: Env.fontFamily
    readonly property int fontSize: Env.fontSize
    readonly property string popupFontFamily: Env.popupFontFamily
    readonly property int popupFontSize: Env.popupFontSize

    // The bar tracks the font so a larger desktop size cannot clip glyphs.
    readonly property int barHeight: Math.round(Env.fontSize * 3)
    readonly property int itemPadding: 6
    readonly property int radius: 4

    readonly property int popupPadding: 10
    readonly property int popupRadius: 4
    readonly property int tooltipMaxWidth: 480

    readonly property int notificationWidth: 380
    readonly property int notificationMaxHeight: 180
    readonly property int notificationBorder: 2
    readonly property int notificationTimeout: 10000
    readonly property int notificationMaxVisible: 5
    readonly property int notificationHistory: 20
}
