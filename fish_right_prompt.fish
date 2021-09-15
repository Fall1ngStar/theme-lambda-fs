set -g grey (set_color -d white)
set -g normal (set_color normal)

function display_time
  set -l current_time (date +%H:%M:%S)
  echo -n -s $grey "[" $current_time "]" $normal
end

function format_time
  set --local milliseconds $argv[1]
  set --local seconds (math -s0 "$milliseconds / 1000 % 60")
  set --local minutes (math -s0 "$milliseconds / 60000 % 60")
  set --local hours (math -s0 "$milliseconds / 3600000 % 24")
  set --local days (math -s0 "$milliseconds / 86400000")
  set --local time
  
  if test $days -gt 0
      set time $time (printf "%sd" $days)
  end

  if test $hours -gt 0
      set time $time (printf "%sh" $hours)
  end

  if test $minutes -gt 0
      set time $time (printf "%sm" $minutes)
  end
  
  if test $seconds -gt 0 
    set time $time (printf "%ss" $seconds)
  end

  if test $milliseconds -gt 0
    set time $time (printf "%sms" (math -s0 "$milliseconds % 1000"))
  end
  echo -e (string join ' ' $time)
end

function display_last_exec_time
  # set -l duration (printf "%.1fs" (math "$CMD_DURATION / 1000"))
  set -l duration (format_time $CMD_DURATION)
  echo -n -s "⏱️  " $grey $duration $normal
end

function fish_right_prompt
  set -l time (display_time)
  set -l exec_time (display_last_exec_time)
  echo -n -s $time " " $exec_time
end