# name: zephyr
set fish_color_command green
set fish_color_error red

set set_cyan (set_color -o cyan)
set set_yellow (set_color -o yellow)
set set_red (set_color -o red)
set set_blue (set_color -o blue)
set set_green (set_color -o green)
set set_magenta (set_color -o magenta)
set set_normal (set_color normal)

# prompt symbols
set zephyr_PROMPT_SYMBOL "➜ $set_normal"
set zephyr_PROMPT_SYMBOL_ROOT "\$ $set_normal"

# node symbols
set zephyr_NODE_SYMBOL "$set_green⬢ $set_normal"

# git symbols
set zephyr_GIT_BEHIND "$set_magenta ⇣$set_normal"
set zephyr_GIT_AHEAD "$set_cyan ⇡$set_normal"
set zephyr_GIT_DIVERGED "$set_cyan ⇡$set_magenta⇣$set_normal"

# git
function _is_git_dirty
    echo (command git status -s --ignore-submodules=dirty 2>/dev/null)
end

function _git_branch_name
    echo (command git symbolic-ref HEAD 2>/dev/null | sed -e 's|^refs/heads/||')
end

# node version getter
function _get_node_version
    if [ (command which node) ]
        echo (command node -v)
    end
end

function fish_prompt
    set -l last_status $status

    set -l cwd $set_cyan(prompt_pwd)

    if [ (_get_node_version) ]
        set -l node_version (string replace -r "\Av(\d*\.\d*.(0|[1-9]{1,}))\Z" '$1' (node -v))
        set node_info " $zephyr_NODE_SYMBOL$set_green $node_version$set_normal"
    end

    set -l push_or_pull (command git status --porcelain 2>/dev/null -b)
    set -l is_behind
    set -l is_ahead
    set -l git_on 'on '

    if test (string match '*behind*' $push_or_pull)
        set is_behind true
    end

    if test (string match '*ahead*' $push_or_pull)
        set is_ahead true
    end

    if test "$is_ahead" = true -a "$is_behind" = true
        set git_diverged_status "$zephyr_GIT_DIVERGED"
    else if test "$is_ahead" = true
        set git_diverged_status "$zephyr_GIT_AHEAD"
    else if test "$is_behind" = true
        set git_diverged_status "$zephyr_GIT_BEHIND"
    end

    if [ (_git_branch_name) ]
        set -l git_branch (_git_branch_name)

        # Set git icon red if git has changes
        if [ (_is_git_dirty) ]
            set git_powerline $set_red""
        else
            set git_powerline $set_green""$set_green
        end

        
        if test (_git_branch_name) = 'master'
            set git_info "$set_normal $set_cyan$git_on$git_powerline $git_branch$set_normal$git_diverged_status$set_cyan"
        else
            set git_info "$set_normal $set_cyan$git_on$git_powerline $git_branch$set_normal$git_diverged_status$set_cyan"
        end
    end

    set zephyr_GIT_USER_NAME (command git config user.name)
    set zephyr_GIT_USER_EMAIL (command git config user.email)

    set zephyr_GIT_USER_INFO "$set_cyan by $set_green$zephyr_GIT_USER_NAME ( $set_magenta$zephyr_GIT_USER_EMAIL$set_green ) $set_normal"
    
    # Check is user has superpower
    if test $USER = 'root'
        if test $last_status = 0
            set _prompt_symbol $set_green$zephyr_PROMPT_SYMBOL_ROOT
        else
            set _prompt_symbol $set_red$zephyr_PROMPT_SYMBOL_ROOT
        end
    else
        if test $last_status = 0
            set _prompt_symbol $set_green$zephyr_PROMPT_SYMBOL
        else
            set _prompt_symbol $set_red$zephyr_PROMPT_SYMBOL
        end
    end

    if test $CMD_DURATION -lt 1000
        set duration ''
    else
        set duration $set_magenta ' ' (math "$CMD_DURATION/1000")'s'
    end

    echo ''
    echo -s $cwd $git_info $normal '' $node_info '' $duration ''

    echo -s $_prompt_symbol ' '
end
