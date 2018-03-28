#
# Written by Rolando Muñoz A. (28 March 2018)
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.
#
form Create corpus table
  comment The directories where your files are stored...
  sentence TextGrid_folder
  sentence Sound_folder
  word Audio_extension .wav
  comment Search inside TextGrids? (leave empty if not)
  sentence All_tier_names
endform

deep_search= if all_tier_names$ <> "" then 1 else 0 fi
column_names$= if deep_search then "sound_file annotation tiers" else "sound_file annotation" fi

# List all files in a Strings object, then build a Table corpus
fileList= Create Strings as file list: "fileList", sound_folder$ + "/*" + audio_extension$
number_of_files = Get number of strings

## Create Corpus table
tb_corpus= Create Table with column names: "corpus", number_of_files, column_names$

if !number_of_files
  removeObject: fileList
  selectObject: tb_corpus
  writeInfoLine: "No audio files in the audio folder"
  exitScript()
endif

if deep_search
  tierList= Create Strings as tokens: all_tier_names$, " "
  n_tierList= Get number of strings
endif

for i to number_of_files
  sd_name$= object$[fileList, i]
  tg_name$= sd_name$ - audio_extension$ + ".TextGrid"
  tg_dir$= textGrid_folder$+ "/"+ tg_name$

  selectObject: tb_corpus
  Set string value: i, "sound_file", sd_name$
  is_tg= if fileReadable(tg_dir$) then 1 else 0 fi 
  Set numeric value: i, "annotation", is_tg
  
  if deep_search
    for i_tier to n_tierList
      tier$= object$[tierList, i_tier]
      tier[tier$]= 1
    endfor
  
    tg= Read from file: tg_dir$
    n_tg_tier = Get number of tiers
    for i_tg_tier to n_tg_tier
      tg_tier$= Get tier name: i_tg_tier
      tier[tg_tier$]= 0
    endfor

    sum=0
    for i_tier to n_tierList
      tier$= object$[tierList, i_tier]
      sum+= tier[tier$]
    endfor
    
    missing_tier= if sum then 0 else 1 fi
    selectObject: tb_corpus
    Set numeric value: i, "tiers", missing_tier

    removeObject: tg
  endif
endfor

if deep_search
  removeObject: tierList
endif
removeObject: fileList