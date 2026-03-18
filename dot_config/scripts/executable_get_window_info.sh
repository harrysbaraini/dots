#!/usr/bin/env zsh

app_name="$1"

if [[ -z "$app_name" ]]; then
  echo "Usage: $0 <app_name>"
  exit 1
fi

osascript <<EOF
tell application "System Events"
  repeat with theProcess in application processes
    say name of theProcess
  end repeat
end tell
EOF

apple_result=$(
  osascript <<EOF
try
    tell application "System Events"
        -- Find the process whose name matches the app name
        if (count of application processes whose name is "$app_name") is 0 then
            return "No running app named $app_name" & return
        end if

        set appProc to first application process whose name is "$app_name"

        if (count of windows of appProc) is 0 then
            return "No windows for $app_name" & return
        end if

        set outputLines to {}
        set idx to 1

        repeat with w in windows of appProc
            set winTitle to ""
            try
                set winTitle to name of w
            on error
                set winTitle to "<unknown title>"
            end try

            set xPos to "?"
            set yPos to "?"
            try
                set {xPos, yPos} to position of w
            end try

            set wSize to "?"
            set hSize to "?"
            try
                set {wSize, hSize} to size of w
            end try

            set end of outputLines to ("WIN|" & idx & "|" & winTitle & "|" & xPos & "," & yPos & "|" & wSize & "," & hSize)
            set idx to idx + 1
        end repeat

        return outputLines as string
    end tell
on error errMsg number errNum
    return "ERR|AppleScript error " & errNum & ": " & errMsg & return
end try
EOF
)

echo $apple_result

if [[ "$apple_result" == ERR\|* ]]; then
  echo "$apple_result"
  exit 1
fi

# Each window line is separated by commas because AppleScript "as string"
# We will split by ", WIN|" safely by normalizing first token
normalized="${apple_result/WIN|/WIN|}" # ensure first line starts with WIN|
# Replace ", WIN|" with newline + "WIN|" for splitting
normalized="${normalized//, WIN|/\\
WIN|}"

while IFS='|' read -r prefix idx title pos size; do
  [[ "$prefix" != "WIN" ]] && continue
  echo "Window #$idx"
  echo "  Title: $title"
  echo "  Position: {$pos}"
  echo "  Size: {$size}"
done <<<"$normalized"
