# Theme based on Bira theme from oh-my-zsh: https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/bira.zsh-theme
# Some code stolen from oh-my-fish clearance theme: https://github.com/bpinto/oh-my-fish/blob/master/themes/clearance/

set -g theme_date_format "+%T"

function __col_res -d "Rest background and foreground colors"
  set_color -b normal
  set_color normal
end

function _col                                     #Set Color 'name b u' bold, underline
  set -l col; set -l bold; set -l under
  if [ -n "$argv[1]" ];       set col   $argv[1]; end
  if [ (count $argv) -gt 1 ]; set bold  "-"(string replace b o $argv[2] 2>/dev/null); end
  if [ (count $argv) -gt 2 ]; set under "-"$argv[3]; end
  set_color $bold $under $argv[1]
end

function __user_host
  set -l content 
  if [ (id -u) = "0" ];
    echo -n (set_color --bold red)
  else
    echo -n (set_color --bold green)
  end
  echo -n $USER@(hostname|cut -d . -f 1) (set color normal)
end

function __current_path
  echo -n (set_color --bold blue) (pwd) (set_color normal) 
end

function __git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function __git_is_dirty
  echo (command git status -s --ignore-submodules=dirty ^/dev/null)
end

function __prompt_git -a current_dir -d 'Display the actual git state'
  if [ (__git_branch_name) ]
    set -l flag_fg (_col brgreen)
    if [ "$dirty" -o "$staged" ]                                      # if either dirty or staged
      set flag_fg (_col yellow)
    else if [ "$stashed" ]
      set flag_fg (_col brred)
    end

    echo -sn $flag_fg'< '(__git_branch_name)(__git_status)$flag_fg' >'(__col_res)  #add space if dirty to separate from icons "$dirty"
  end
end

function __git_status -d 'Check git status'
  set -l git_status (command git status --porcelain ^/dev/null | cut -c 1-2)
  set -l ahead (__git_ahead); echo -n $ahead                                    #show # of commits ahead/behind

  set -l added (echo -sn $git_status\n | egrep -c "\?\?")
  if [ $added -gt 0 ]                      #untracked (new) files
    echo -n ' '
    echo -n (_col green)$added$ICON_VCS_STAGED
  end

  set -l modified (echo -sn $git_status\n | egrep -c ".[MT]|R.|[ ACMRT]D|AA|DD|U.|.U|[ACDMT][ MT]|[ACMT]D")
  if [ $modified -gt 0 ]
    echo -n ' '
    echo -n (_col $ORANGE)$modified$ICON_VCS_DELETED
  end
  
  if test (command git rev-parse --verify --quiet refs/stash >/dev/null)
    echo -n (_col brred)$ICON_VCS_STASH
  end

  echo ''
end

function __is_git_folder     -d "Check if current folder is a git folder"
  git status 1>/dev/null 2>/dev/null
end

function __git_ahead -d         'Print the ahead/behind state for the current branch'
  if [ "$theme_display_git_ahead_verbose" = 'yes' ]
    __git_ahead_verbose
    return
  end
  command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null | awk '/>/ {a += 1} /</ {b += 1} {if (a > 0 && b > 0) nextfile} END {if (a > 0 && b > 0) print "⇕"; else if (a > 0) print ""; else if (b > 0) print ""}' #↑↓⇕⬍↕
end

function __git_ahead_verbose -d 'Print a more verbose ahead/behind state for the current branch'
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null)
  if [ $status != 0 ]
    return
  end
  set -l behind (count (for arg in $commits; echo $arg; end | grep '^<'))
  set -l ahead  (count (for arg in $commits; echo $arg; end | grep -v '^<'))
  switch "$ahead $behind"
    case ''     # no upstream
    case '0 0'  # equal to upstream
      return
    case '* 0'  # ahead of upstream
      echo (_col blue)"$ICON_ARROW_UP$ahead"
    case '0 *'  # behind upstream
      echo (_col red)"$ICON_ARROW_DOWN$behind"
    case '*'    # diverged from upstream
      echo (_col blue)"$ICON_ARROW_UP$ahead"(_col red)"$ICON_ARROW_DOWN$behind"
  end
end

function fish_prompt
  __icons_initialize
  echo -n (set_color white)"╭─"(set_color normal)
  __user_host
  __current_path
  __prompt_git
  echo -e ''
  echo (set_color white)"╰─>"(set_color --bold white)" "(set_color normal)
end

function __timestamp -S -d 'Show the current timestamp'
  set -q theme_date_format or set -l theme_date_format "+%c"

  echo -n ' '
  date $theme_date_format
end

function fish_right_prompt
  set_color $fish_color_autosuggestion

  __timestamp
  set_color normal
end

function __icons_initialize
  #echo \Uf00a \ue709 \ue791 \ue739 \uF0DD \UF020 \UF01F \UF07B \UF015 \UF00C \UF00B \UF06B \UF06C \UF06E \UF091 \UF02C \UF026 \UF06D \UF0CF \UF03A \UF03D \UF081 \UF02A \UE606 \UE73C      #\UF005 bugs in fish
  set -g ORANGE                     FF8C00        #FF8C00 dark orange, FFA500 orange, another one fa0 o
  set -g ICON_NODE                  \UE718" "     #  from Devicons or ⬢
  set -g ICON_RUBY                  \UE791" "     # \UE791 from Devicons; \UF047; \UE739; 💎
  set -g ICON_PYTHON                \UE606" "     # \UE606; \UE73C
  #set -g ICON_PERL                  \UE606" "     # \UE606; \UE73C
  set -g ICON_TEST                  \UF091        # 
  set -g ICON_VCS_UNTRACKED         \UF02C" "     #    #●: there are untracked (new) files
  set -g ICON_VCS_UNMERGED          \UF026" "     #    #═: there are unmerged commits
  set -g ICON_VCS_MODIFIED          \UF06D" "     # 
  set -g ICON_VCS_STAGED            \UF06B" "     #  (added) →
  set -g ICON_VCS_DELETED           \UF06C" "     # 
  set -g ICON_VCS_DIFF              \UF06B" "     # 
  set -g ICON_VCS_RENAME            \UF06E" "     # 
  set -g ICON_VCS_STASH             \UF0CF" "     #      #✭: there are stashed commits
  set -g ICON_VCS_INCOMING_CHANGES  \UF00B" "     #  or \UE1EB or \UE131
  set -g ICON_VCS_OUTGOING_CHANGES  \UF00C" "     #  or \UE1EC or 
  set -g ICON_VCS_TAG               \UF015" "     # 
  set -g ICON_VCS_BOOKMARK          \UF07B" "     # 
  set -g ICON_VCS_COMMIT            \UF01F" "     # 
  set -g ICON_VCS_BRANCH            \UE0A0        # \UE0A0 or \UF020
  set -g ICON_VCS_REMOTE_BRANCH     \UE804" "     #  not displayed, should be branch icon on a book
  set -g ICON_VCS_DETACHED_BRANCH   \U27A6" "     # ➦
  set -g ICON_VCS_GIT               \UF00A" "     #  from Octicons
  set -g ICON_VCS_HG                \F0DD" "      # Got cut off from Octicons on patching
  set -g ICON_VCS_CLEAN             \UF03A        # 
  set -g ICON_VCS_PUSH              printf "\UF005 " # bugs out in fish: \UF005 (printf "\UF005")
  set -g ICON_VCS_DIRTY             ±             #
  set -g ICON_ARROW_UP              \UF03D""      #  ↑
  set -g ICON_ARROW_DOWN            \UF03F""      #  ↓
  set -g ICON_OK                    \UF03A        # 
  set -g ICON_FAIL                  \UF081        # 
  set -g ICON_STAR                  \UF02A        # 
  set -g ICON_JOBS                  \U2699" "     # ⚙
  set -g ICON_VIM                   \UE7C5" "     # 
  set -g symbols_style                        'symbols'
  set -g theme_display_git_ahead_verbose      yes
end
