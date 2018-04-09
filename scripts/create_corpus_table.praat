# Create a Table named Corpus which includes a detailed list of all audio and annotation files
# Written by Rolando Muñoz A. (29 March 2018)
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
  comment Search inside TextGrids?
  sentence All_tier_names
  boolean Yes
endform

# List all files in a Strings object, then build a Table corpus
fileList= Create Strings as file list: "fileList", sound_folder$ + "/*" + audio_extension$
nFiles = Get number of strings

## Create Corpus table
tbCorpus= Create Table with column names: "corpus", nFiles, "sound_file annotation all_tiers"

if !nFiles
  removeObject: fileList
  selectObject: tbCorpus
  writeInfoLine: "No audio files in the audio folder"
  exitScript()
endif

deepSearch= if yes then 1 else 0 fi
deepSearch= if all_tier_names$ == "" then 0 else 1 fi
if deepSearch
  strTiers= Create Strings as tokens: all_tier_names$, " "
  str_nTiers= Get number of strings
endif

for i to nFiles
  sd$= object$[fileList, i]
  tg$= sd$ - audio_extension$ + ".TextGrid"
  tgDir$= textGrid_folder$+ "/"+ tg$

  isAnnotation= if fileReadable(tgDir$) then 1 else 0 fi
  isAllTier= 0
  
  if isAnnotation
    if deepSearch
      tg= Read from file: tgDir$
      @_isAnyMissingTier: strTiers, str_nTiers
      isAllTier= if '_isAnyMissingTier.return' then 0 else 1 fi
      removeObject: tg
    endif
  endif
  
  selectObject: tbCorpus
  Set string value: i, "sound_file", sd$
  Set numeric value: i, "annotation", isAnnotation
  Set numeric value: i, "all_tiers", isAllTier
endfor

if deepSearch
  removeObject: strTiers
endif
removeObject: fileList

procedure _isAnyMissingTier: .stringsID, .strings_n
  .n_tgTiers= Get number of tiers
  .tier= 1
  .counter= 0
  for .i to .strings_n
    .strTier$= object$[.stringsID, .i]
    for .j from .tier to .n_tgTiers
      .tgTier$= Get tier name: .j
      if .strTier$ == .tgTier$
        .tier= .j
        .j= .n_tgTiers
        .counter+=1
      endif
    endfor
  endfor
  
  .return= if .counter = .strings_n then 0 else 1 fi
endproc