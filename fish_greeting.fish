function fish_greeting -d "Greeting message on shell session start up"
  set_color $fish_color_autosuggestion
  echo (set_color $fish_color_autosuggestion) (uname -a)
  echo (set_color $fish_color_autosuggestion) (perl /home/kwasiu/Skrypty/check_updates.pl)
end
