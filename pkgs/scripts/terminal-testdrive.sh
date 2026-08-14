#!/usr/bin/env bash
# ST is ESC-backslash, so trailing backslashes in format strings are intentional
# shellcheck disable=SC1003
set -eu

# Exercises well-known terminal features - not only the ones our terminals support,
# so it doubles as a comparison sheet when trying a new one.
# Run it both inside and outside tmux and diff the two: anything that works outside
# but not inside means tmux is missing a terminal-feature or a passthrough
# (see options/tmux/config.nix and the ghostty/alacritty overrides).

esc=$'\033'
reset="${esc}[0m"
bold="${esc}[1m"
dim="${esc}[2m"

in_tmux=0
[[ -n ${TMUX:-} ]] && in_tmux=1
has_tty=0
[[ -t 0 && -t 1 ]] && has_tty=1

section() {
    printf '\n%s\n' "${bold}# $1${reset}"
}

note() {
    printf '%s\n' "${dim}  $1${reset}"
}

kv() {
    printf '  %-28s %s\n' "$1" "$2"
}

unsupported="${dim}no reply${reset}"

# Sends $1 to the terminal and reads the reply up to (and including) the first $2.
# Prints the reply with ESC rendered as ^[; returns non-zero when nothing answered.
query() {
    local seq=$1 term=$2 reply="" saved
    ((has_tty)) || return 1
    saved=$(stty -g </dev/tty 2>/dev/null) || return 1
    stty raw -echo </dev/tty 2>/dev/null || return 1
    printf '%s' "$seq" >/dev/tty
    IFS= read -r -d "$term" -t 0.4 reply </dev/tty 2>/dev/null || true
    stty "$saved" </dev/tty 2>/dev/null || true
    [[ -n $reply ]] || return 1
    reply=${reply//$esc/^[}
    printf '%s' "${reply//$'\r'/}"
}

# OSC replies end in either BEL or ST, so read until we see one of them.
query_osc() {
    local seq=$1 reply="" ch saved
    ((has_tty)) || return 1
    saved=$(stty -g </dev/tty 2>/dev/null) || return 1
    stty raw -echo </dev/tty 2>/dev/null || return 1
    printf '%s' "$seq" >/dev/tty
    while IFS= read -r -N1 -t 0.4 ch </dev/tty 2>/dev/null; do
        [[ $ch == $'\a' ]] && break
        reply+=$ch
        [[ $reply == *"${esc}\\" ]] && break
    done
    stty "$saved" </dev/tty 2>/dev/null || true
    [[ -n $reply ]] || return 1
    reply=${reply%"${esc}\\"}
    printf '%s' "${reply//$esc/^[}"
}

# XTGETTCAP: ask the terminal itself what terminfo capability $1 holds.
xtgettcap() {
    local cap=$1 hex reply value out=""
    hex=$(printf '%s' "$cap" | od -An -tx1 | tr -d ' \n' | tr 'a-f' 'A-F')
    reply=$(query "${esc}P+q${hex}${esc}\\" '\') || return 1
    [[ $reply == *=* ]] || return 1
    value=${reply#*=}
    value=${value%%'^['*}
    while [[ ${#value} -ge 2 ]]; do
        out+="\\x${value:0:2}"
        value=${value:2}
    done
    printf '%b' "$out"
}

decrqm_ok=1
# DECRQM: is the private mode $1 known to whatever is on the other end?
mode_report() {
    local mode=$1 name=$2 reply state
    ((decrqm_ok)) || return 0
    reply=$(query "${esc}[?${mode}\$p" 'y') || {
        kv "$name ($mode)" "$unsupported"
        return 0
    }
    state=${reply##*;}
    state=${state%%\$*}
    case $state in
    1) state="set" ;;
    2) state="reset (supported)" ;;
    3) state="permanently set" ;;
    4) state="permanently reset" ;;
    *) state="not recognized" ;;
    esac
    kv "$name ($mode)" "$state"
}

# tmux cannot parse every escape sequence; DCS-wrapping hands it to the host terminal
# verbatim (requires 'allow-passthrough on'). Only needed for sequences tmux has no
# support for at all - not for sixel, which tmux renders itself.
passthrough() {
    if ((in_tmux)); then
        printf '%sPtmux;%s%s\\' "$esc" "${1//$esc/$esc$esc}" "$esc"
    else
        printf '%s' "$1"
    fi
}

section "who am I"
kv "TERM" "${TERM:-<unset>}"
kv "COLORTERM" "${COLORTERM:-<unset>}"
kv "TERM_PROGRAM" "${TERM_PROGRAM:-<unset>} ${TERM_PROGRAM_VERSION:-}"
kv "inside tmux" "$( ((in_tmux)) && echo yes || echo no)"
kv "XTVERSION (CSI >q)" "$(query "${esc}[>q" '\' || echo "$unsupported")"
kv "primary DA (CSI c)" "$(query "${esc}[c" 'c' || echo "$unsupported")"
kv "secondary DA (CSI >c)" "$(query "${esc}[>c" 'c' || echo "$unsupported")"
kv "tertiary DA (CSI =c)" "$(query "${esc}[=c" '\' || echo "$unsupported")"
kv "XTGETTCAP TN" "$(xtgettcap TN || echo "$unsupported")"
note "primary DA lists ';4' when sixel is advertised"

section "window geometry (XTWINOPS)"
kv "text area, chars (CSI 18t)" "$(query "${esc}[18t" 't' || echo "$unsupported")"
kv "text area, px (CSI 14t)" "$(query "${esc}[14t" 't' || echo "$unsupported")"
kv "cell size, px (CSI 16t)" "$(query "${esc}[16t" 't' || echo "$unsupported")"
note "cell size is what image protocols need to place graphics on the grid"

if ((in_tmux)); then
    section "tmux's view of the host terminal"
    kv "client term" "$(tmux display-message -p '#{client_termname}')"
    kv "terminal-features" "$(tmux display-message -p '#{client_termfeatures}')"
    for opt in allow-passthrough set-clipboard; do
        kv "$opt" "$(tmux show-options -gv "$opt")"
    done
    kv "extended-keys" "$(tmux show-options -sv extended-keys)"
    note "features missing here are the ones to add via 'set -as terminal-features'"
fi

section "mode support (DECRQM)"
if ((has_tty)) && ! query "${esc}[?2004\$p" 'y' >/dev/null; then
    decrqm_ok=0
    note "no DECRQM support on this end (tmux does not answer it), skipping"
fi
mode_report 7 "autowrap"
mode_report 12 "cursor blink"
mode_report 25 "cursor visible"
mode_report 69 "left/right margins"
mode_report 1000 "mouse: click"
mode_report 1002 "mouse: drag"
mode_report 1003 "mouse: any motion"
mode_report 1004 "focus events"
mode_report 1006 "mouse: SGR encoding"
mode_report 1049 "alternate screen"
mode_report 2004 "bracketed paste"
mode_report 2026 "synchronized output"
mode_report 2027 "grapheme clustering"
mode_report 2031 "color scheme updates"
mode_report 2048 "in-band resize"

section "keyboard protocols"
kv "kitty keyboard (CSI ?u)" "$(query "${esc}[?u" 'u' || echo "$unsupported")"
kv "modifyOtherKeys (CSI ?4m)" "$(query "${esc}[?4m" 'm' || echo "$unsupported")"
note "either one disambiguates ctrl-i from tab; tmux needs 'extkeys' to forward them"

section "color queries (OSC 4/10/11/12)"
kv "foreground (OSC 10)" "$(query_osc "${esc}]10;?${esc}\\" || echo "$unsupported")"
kv "background (OSC 11)" "$(query_osc "${esc}]11;?${esc}\\" || echo "$unsupported")"
kv "cursor (OSC 12)" "$(query_osc "${esc}]12;?${esc}\\" || echo "$unsupported")"
kv "palette 1 (OSC 4)" "$(query_osc "${esc}]4;1;?${esc}\\" || echo "$unsupported")"
note "OSC 11 is how programs detect a light vs dark theme"

section "16-color palette (should follow the base16 theme)"
for row in 0 8; do
    printf '  '
    for i in $(seq "$row" $((row + 7))); do
        printf '\e[48;5;%dm  \e[0m' "$i"
    done
    printf '  '
    for i in $(seq "$row" $((row + 7))); do
        printf '\e[38;5;%dm%3d\e[0m ' "$i" "$i"
    done
    printf '\n'
done

section "256-color cube and grayscale ramp"
for g in 0 1 2 3 4 5; do
    printf '  '
    for r in 0 1 2 3 4 5; do
        for b in 0 1 2 3 4 5; do
            printf '\e[48;5;%dm \e[0m' $((16 + r * 36 + g * 6 + b))
        done
        printf ' '
    done
    printf '\n'
done
printf '  '
for i in $(seq 232 255); do printf '\e[48;5;%dm \e[0m' "$i"; done
printf '\n'

section "24-bit (true-color)"
# based on: https://gist.github.com/XVilka/8346728
term_cols="$(tput cols || echo 80)"
cols=$(echo "2^((l($term_cols)/l(2))-1)" | bc -l 2>/dev/null)
rows=$((cols / 2))
awk -v cols="$cols" -v rows="$rows" 'BEGIN{
        s="  ";
        m=cols+rows;
        for (row = 0; row<rows; row++) {
          for (col = 0; col<cols; col++) {
              i = row+col;
              r = 255-(i*255/m);
              g = (i*510/m);
              b = (i*255/m);
              if (g>255) g = 510-g;
              printf "\033[48;2;%d;%d;%dm", r,g,b;
              printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
              printf "%s\033[0m", substr(s,(col+row)%2+1,1);
          }
          printf "\n";
        }
    }'
printf '  \e[38;2;255;0;0mcolon form\e[0m vs \e[38:2::255:0:0mcolon form with colorspace\e[0m\n'
note "both SGR 38;2;... and SGR 38:2::... should be red; the colon form is the ITU one"

section "text decorations"
printf '\e[1mbold\e[22m\n'
printf '\e[2mdim\e[22m\n'
printf '\e[1m\e[2mbold+dim\e[22m\n'
printf '\e[3mitalic\e[23m\n'
printf '\e[1m\e[3mbold italic\e[23m\e[22m\n'
printf '\e[4munderline\e[24m\n'
printf '\e[4:1mthis is also underline\e[24m\n'
printf '\e[21mdouble underline\e[24m\n'
printf '\e[4:2mthis is also double underline\e[24m\n'
printf '\e[4:3mcurly underline\e[24m\n'
printf '\e[4:4mdotted underline\e[24m\n'
printf '\e[4:5mdashed underline\e[24m\n'
printf '\e[4:3m\e[58:2:206:134:51mcolored curly underline (RGB)\e[0m\n'
printf '\e[58;5;10;4mcolored underline (256-color index)\e[59;24m\n'
printf '\e[5mblink\e[25m\n'
printf '\e[6mrapid blink\e[25m\n'
printf '\e[7mreverse\e[27m\n'
printf '\e[8minvisible\e[28m <- invisible (but copy-pasteable)\n'
printf '\e[9mstrikethrough\e[29m\n'
printf '\e[53moverline\e[55m\n'
printf '\e[51mframed\e[54m\n'
printf '\e[52mencircled\e[54m\n'
printf 'normal \e[73msuperscript\e[75m and \e[74msubscript\e[75m\n'
printf 'alternate fonts:'
for f in 1 2 3 4 5 6 7 8 9; do printf ' \e[1%dmfont%d\e[10m' "$f" "$f"; done
printf '\n'
note "styled/colored underlines need the 'usstyle' terminal-feature in tmux"
note "overline needs 'overline'; framed/encircled/super/subscript are rarely implemented"

section "DEC line attributes (double width/height)"
printf '  \e#6double width\e#5\n'
printf '  \e#3double height\e#5\n'
printf '  \e#4double height\e#5\n'
note "lines 2 and 3 are the top and bottom halves of one double-height line"

section "DEC special graphics charset (what tmux draws borders with)"
printf '  \e(0lqqqqqqqwqqqqqqqk\e(B\n'
printf '  \e(0x\e(B cell  \e(0x\e(B cell  \e(0x\e(B\n'
printf '  \e(0mqqqqqqqvqqqqqqqj\e(B\n'
note "if this shows letters instead of lines, charset switching is broken"

section "OSC 8 hyperlinks"
printf '  \033]8;;https://example.com\033\\This is a link\033]8;;\033\\\n'
printf '  \033]8;id=tt;file://%s\033\\%s\033]8;;\033\\\n' "$PWD" "$PWD"
note "needs the 'hyperlinks' terminal-feature in tmux"

section "magic string (see https://en.wikipedia.org/wiki/Unicode#Web)"
echo "  é Δ Й ק م ๗ あ 叶 葉 말"

section "grapheme clusters (each cell should end flush at the bar)"
while IFS='|' read -r what text; do
    printf '  %-22s [%s]\n' "$what" "$text"
done <<'EOF'
combining acute|é
emoji ZWJ family|👨‍👩‍👧‍👦
skin tone|👍🏽
regional flag|🇵🇱
variation selector|❤️
keycap|1️⃣
CJK wide|漢字
ambiguous width|±×÷°
zero width non-joiner|a‌b
EOF
note "misaligned bars usually mean the terminal and tmux disagree on width"
note "'grapheme clustering' (mode 2027) is what makes ZWJ sequences count as one cell"

section "emojis"
echo "  😃😱😵🤯🫠"

section "right-to-left ('ש' should be at the right side)"
echo "  שרה"

section "box drawing, blocks and powerline/nerd glyphs"
echo "  ┌───────┬───────┐  ╔═══════╗  ▁▂▃▄▅▆▇█  ⣿⣶⣤⣀"
echo "  │ cell  │ cell  │  ║ cell  ║  ░▒▓█▓▒░   ◢◣◤◥"
echo "  └───────┴───────┘  ╚═══════╝"
# written as codepoints so the source stays ascii: powerline separators + nerd icons
printf '  \e[7m\ue0b2\e[0m\e[7m powerline \e[0m\ue0b0  \ue0b1 \ue0b3   nerd: \ue0a0 \uf015 \uf07b \uf09b \uf121 \uf1d3\n'
note "boxes must join seamlessly; nerd glyphs render only with a patched font"

section "sixel graphics"
printf '\eP0;0;0q"1;1;64;64#0;2;0;0;0#1;2;100;100;100#1~{wo_!11?@FN^!34~^NB
@?_ow{~$#0?BFN^!11~}wo_!34?_o{}~^NFB-#1!5~}{o_!12?BF^!25~^NB@??ow{!6~$#0!5?
@BN^!12~{w_!25?_o{}~~NFB-#1!10~}w_!12?@BN^!15~^NFB@?_w{}!10~$#0!10?@F^!12~}
{o_!15?_ow{}~^FB@-#1!14~}{o_!11?@BF^!7~^FB??_ow}!15~$#0!14?@BN^!11~}{w_!7?_
w{~~^NF@-#1!18~}{wo!11?_r^FB@??ow}!20~$#0!18?@BFN!11~^K_w{}~~NF@-#1!23~M!4?
_oWMF@!6?BN^!21~$#0!23?p!4~^Nfpw}!6~{o_-#1!18~^NB@?_ow{}~wo!12?@BFN!17~$#0!
18?_o{}~^NFB@?FN!12~}{wo-#1!13~^NB@??_w{}!9~}{w_!12?BFN^!12~$#0!13?_o{}~~^F
B@!9?@BF^!12~{wo_-#1!8~^NFB@?_w{}!19~{wo_!11?@BN^!8~$#0!8?_ow{}~^FB@!19?BFN
^!11~}{o_-#1!4~^NB@?_ow{!28~}{o_!12?BF^!4~$#0!4?_o{}~^NFB!28?@BN^!12~{w_-#1
NB@???GM!38NMG!13?@BN$#0?KMNNNF@!38?@F!13NMK-\e\'
printf '\n'
note "not wrapped in a tmux passthrough on purpose: tmux renders sixel itself"

section "kitty graphics protocol (yazi previews use this)"
kitty_image() {
    local w=64 h=32 data chunk first=1 more
    data=$(LC_ALL=C awk -v w=$w -v h=$h 'BEGIN{
        for (y=0;y<h;y++) for (x=0;x<w;x++)
            printf "%c%c%c", int(255*x/(w-1)), int(255*y/(h-1)), 160
    }' | base64 | tr -d '\n')
    while [[ -n $data ]]; do
        chunk=${data:0:4000}
        data=${data:4000}
        more=1
        [[ -z $data ]] && more=0
        if ((first)); then
            passthrough "${esc}_Ga=T,f=24,s=$w,v=$h,c=32,r=8,m=$more;$chunk${esc}\\"
            first=0
        else
            passthrough "${esc}_Gm=$more;$chunk${esc}\\"
        fi
    done
    printf '\n'
}
kitty_image
note "a red/green gradient block; tmux needs 'allow-passthrough on' for this one"

section "iTerm2 inline image (OSC 1337)"
# a 64x32 paletted png of diagonal rainbow bands
png='iVBORw0KGgoAAAANSUhEUgAAAEAAAAAgCAMAAACVQ462AAAAGFBMVEUAAAD/AAD/gAD//wAAyAAAoP9QAMj///+Ur+B1AAAAaklEQVR42u3Vuw3DMBAE0WfJtvrvWNuBgkk16QEEedwP4zOOcY7v+I3/uMY7f56r56v3U9+n7kfdr/o/6v+q+lD1pepT1bfqD9Vfqj9Vf6v5oOaLmk9qvqn5qOarms9qvqv9oPaL2k9qv93OvxwBLO/SOgAAAABJRU5ErkJggg=='
passthrough "${esc}]1337;File=inline=1;width=32;height=8;preserveAspectRatio=0:${png}${esc}\\"
printf '\n'
note "the same picture as above, in iTerm2's protocol; wezterm and konsole speak it too"

section "cursor styles (DECSCUSR) and cursor color"
for style in 1 2 3 4 5 6; do
    case $style in
    1) label="blinking block" ;;
    2) label="steady block" ;;
    3) label="blinking underline" ;;
    4) label="steady underline" ;;
    5) label="blinking bar" ;;
    6) label="steady bar" ;;
    esac
    printf '  \e[%d q%-20s' "$style" "$label"
    sleep 0.3
    printf '\r'
done
printf '  \e[0 q%-26s\n' "back to default"
printf '\033]12;#ff0000\007'
sleep 0.3
printf '\033]112\007'
note "the cursor cycled through six shapes and flashed red via OSC 12 / OSC 112"

section "window title stack (XTWINOPS 22/23)"
printf '\033[22;0t'
printf '\033]2;terminal-testdrive\033\\'
sleep 0.4
printf '\033[23;0t'
note "the title was pushed, changed, then popped back"

section "side effects"
printf '\033]52;c;%s\007' "$(printf 'osc52-clipboard-works' | base64 | tr -d '\n')"
note "clipboard was overwritten via OSC 52: paste it, expect 'osc52-clipboard-works'"

printf '\033]9;terminal-testdrive: OSC 9 notification\033\\'
printf '\033]777;notify;terminal-testdrive;OSC 777 notification\033\\'
passthrough "${esc}]99;i=1:d=0;OSC 99 notification${esc}\\"
note "three notification dialects were sent: OSC 9 (iTerm2), OSC 777 (urxvt), OSC 99 (kitty)"

for pct in 15 45 75 100; do
    printf '\033]9;4;1;%d\033\\' "$pct"
    sleep 0.2
done
printf '\033]9;4;0;\033\\'
note "a progress bar was pushed via OSC 9;4 (tab/taskbar); needs 'progressbar' in tmux"

printf '\033]7;file://%s%s\033\\' "${HOSTNAME:-localhost}" "$PWD"
note "cwd was reported via OSC 7 (drives 'open new tab here'); needs 'osc7' in tmux"

printf '\033]133;A\033\\\033]133;B\033\\\033]133;C\033\\\033]133;D;0\033\\'
note "a balanced OSC 133 prompt/command/output sequence was emitted (jump-to-prompt)"

printf '\033]1337;SetUserVar=testdrive=%s\007' "$(printf 'ok' | base64 | tr -d '\n')"
note "OSC 1337 SetUserVar set testdrive=ok (readable from the terminal's own config)"

printf '\a'
note "and a bell was rung"

printf '\n'
