#!/bin/bash

#### colour specifications./te
RED=$'\033[0;31m'
GRN=$'\033[0;32m'
BL=$'\033[0;33m'
NC=$'\033[0m'

#### constants
INPUT_FILE=""
INPUT_DIR=""
OUTPUT_DIR=""
OUTPUT_FILE_DIR=""
PLUGIN_DIR=""
PLUGIN_BIT=""
FILE_EXT=""
RECURSIVE_SEARCH=0
HELP_REQ=0
VERBOSE=0
NUM_FILES=0
NUM_PROCESSED_FILES=0
NUM_COMPLETED_FILES=0

#### functions

# displays the -h option
show_help()
{
  printf "\nFor the extended help view, run with -h full or --help full\n"
  printf "\nUsage: %s <options>\n" "$0"
  printf "\nOptions:\n"
  printf "\n%s--file     -f%s   <argument> : path of input file" "${BL}" "${NC}"
  printf "\n%s--dir      -d%s   <argument> : path of top level file directory" "${BL}" "${NC}"
  printf "\n%s--ext      -x%s   <argument> : searched file extension" "${BL}" "${NC}"
  printf "\n%s--output   -o%s   <argument> : path of output directory" "${BL}" "${NC}"
  printf "\n%s--outputF  -of%s  <argument> : path of output file" "${BL}" "${NC}"
  printf "\n%s--plugin   -p%s   <argument> : path of plugin(s)" "${BL}" "${NC}"
  printf "\n%s--pluginB  -pb%s  <argument> : 32 or 64" "${BL}" "${NC}"
  printf "\n%s--help     -h%s   <argument> : 'full'" "${BL}" "${NC}"
  printf "\n%s--rec      -r%s"   "${BL}" "${NC}"
  printf "\n%s--verbose      -v%s"   "${BL}" "${NC}"
  printf "\nAll options require mandatory arguments except for -h, -r, and -v\n"
  printf "\n\n"
  exit
}

# displays the -h full option
show_help_full()
{

  printf "\nUsage: %s <options>\n" "$0"

  printf "\noptions:\n"
  printf "\n%s-file     -f%s    ......................  use to specify the path for a single file" "${BL}" "${NC}"
  printf "\n\n    - If no output option is given, processed file will be saved to the same directory"
  printf "\n    - One of -f or -d is mandatory\n"

  printf "\n%s-dir      -d%s    ......................  use to specify a directory. All subfolders within the directory will also be searched for files" "${BL}" "${NC}"
  printf "\n\n    - If no output option is given, processed files will be saved to their respective directories\n"
  printf "    - One of -f or -d is mandatory\n"

  printf "\n%s-rec      -r%s    ......................  use to search a directory and its subdirectories recursively for a file format" "${BL}" "${NC}"
  printf "\n\n    - If the option is not present, only the top level directory will be searched"
  printf "\n\n    - If this option is present, so must a -d option\n"
  printf "    - This option is not mandatory\n"

  printf "\n%s-ext      -x%s    ......................  specify an extension of files to search for in a given directory" "${BL}" "${NC}"
  printf "\n\n    - If this option is present, so must a -d option\n"
  printf "    - This option is not mandatory\n"

  printf "\n%s-output   -o%s    ......................  use to specify an output directory" "${BL}" "${NC}"
  printf "\n\n    - If used along with -d option, all files within the specified dir will be saved to the specified directory"
  printf "\n    - If used along with -f option, chosen file will be processed and saved to the specified directory"
  printf "\n    - This option is not mandatory\n"

  printf "\n%s-outputF  -of%s  .......................  use to specify a complete path for output, including filename" "${BL}" "${NC}"
  printf "\n\n    - Has to be used with the -f option, and correct format should be specified for the output file"
  printf "\n    - This option is not mandatory\n"

  printf "\n%s-verbose  -v%s  .......................  use to get verbose logging" "${BL}" "${NC}"
  printf "\n\n    - Does not have an argument. Displays processing of each audio file"
  printf "\n    - This option is not mandatory\n"

  printf "\n%s-plugin   -p%s    ......................  use to specify the path or paths of desired plugins to be applied" "${BL}" "${NC}"
  printf "\n\n    - If you would like to attach multiple plugins, use a single -p or --plugin option keyword and enter desired plugins separated by a +"
  printf "\n    - If you would like to attach a preset .fxp file, enter a plugin name then the path of the .fxp file, separated by a comma"
  printf "\n    - If no fxp file specified, default values of the plugin will be used"
  printf "\n    - This option is mandatory\n"

  printf "\n%s-pluginB  -pb%s  ......................  use to specify a whether to use a 32bit or 64 bit plugin" "${BL}" "${NC}"
  printf "\n    - This option is mandatory\n"

  printf "\n\n%sExamples%s:\n\n" "${BL}" "${NC}"

  printf "\n  - Applies 32 bit effect.so plugin to piano.wav, outputs to /home/user/outputs:\n"
  printf "\n  %s -f piano.wav -o /home/user/outputs -p effect.so -pb 32\n\n" "$0"

  printf "\n  - Applies 64 bit effect.so plugin to piano.wav, outputs to piano_output.wav in /home/user/outputs:\n"
  printf "\n  %s -f piano.wav -o /home/user/outputs/piano_output.wav -p effect.so -pb 64\n\n" "$0"

  printf "\n  - Applies 64 bit effect.so plugin to all .wav files in top directory /home/user/Desktop, outputs all to /home/user/outputs:\n"
  printf "\n  %s -d /home/user/Desktop -x .wav -o /home/user/outputs -p effect.so -pb 64\n\n" "$0"

  printf "\n  - Applies 64 bit effect.so plugin to piano.wav, using the effect.fxp preset file. Output is saved to input directory:\n"
  printf "\n  %s -f /home/user/sounds/piano.wav -p /home/user/plugins/effect.so,/home/user/plugins/effect.fxp -pb 64\n\n" "$0"

  printf "\n  - Applies 64 bit plugins effect1.so with effect1.fxp preset, effect2.so and effect3.so with default parameters"
  printf "\n  to all files recursively in specified directory and its subdirectories, outputs to /home/user/outputs:\n"
  printf "\n  %s -d /home/user/Desktop -x .wav -r -o /home/user/outputs -p effect1.so,preset1.fxp effect2.so effect3.so -pb 64\n" "$0"

  printf "\n\n"
  exit
}

# checks if options were used correctly
validate_args()
{
  if [[ -z $HELP_REQ ]]
  then
    show_help
  fi

  if [[ $HELP_REQ == "full" ]]
  then
    show_help_full
  fi

  if [[ -z $INPUT_FILE ]] && [[ -n $OUTPUT_FILE_DIR ]]
  then
    printf "\nWrong options used: You must provide an input file when specifying an output file"
    show_help
  fi

  if [[ -z $INPUT_FILE ]] && [[ -z $INPUT_DIR ]]
  then
    printf "\nWrong options used: You must provide an input file or input directory"
    show_help
  fi

  if [[ -n $INPUT_FILE ]] && [[ -n $INPUT_DIR ]]
  then
    printf "\nWrong options used: You may provide either a file or a directory path, but not both"
    show_help
  fi

  if [[ -n $OUTPUT_DIR ]] && [[ -n $OUTPUT_FILE_DIR ]]
  then
    printf "\nWrong options used: You may provide either a full output path or an output directory, but not both"
    show_help
  fi

  if [[ -z $INPUT_DIR ]] && [[ $RECURSIVE_SEARCH -eq 1 ]]
  then
    printf "\nWrong options used: You may must provide an input directory when using the recursive option"
    show_help
  fi

  if [[ -z $INPUT_DIR ]] && [[ -n $FILE_EXT ]]
  then
    printf "\nWrong options used: You may must provide an input directory when searching for a format of files"
    show_help
  fi

  if [[ -n $INPUT_DIR ]] && [[ -z $FILE_EXT ]]
  then
    printf "\nWrong options used: You may must provide a file extension to search for when specifying an input directory"
    show_help
  fi

  if [[ -z $PLUGIN_DIR ]]
  then
    printf "\nWrong options used: No plugin provided"
    show_help
  fi

  if [[ $PLUGIN_BIT -ne 32 ]] && [[ $PLUGIN_BIT -ne 64 ]]
  then
    printf "\nWrong options used: Plugin version 32 or 64 must be selected"
    show_help
  fi
}


#### entry point
while [ $# -gt 0 ]; do
    case $1 in
        -h | --help )
          # HELP_REQ is initially 0
          # in case -h or --help is requested by user, HELP_REQ becomes the argument provided
          # the argument is an empty string when full help isn't requested, and "full" if full help is requested
          # validate_args checks whether HELP_REQ is an empty string or "full", outputs help accordingly
          # if neither is the case, this means HELP_REQ is 0, and help is not shown
          shift
          HELP_REQ=$1
          ;;
        -f | --file )
          shift
          INPUT_FILE=$1
          ;;
        -d | --dir )
          shift
          INPUT_DIR=$1
          ;;
        -o | --output )
          shift
          OUTPUT_DIR=$1
          ;;
        -of | --outputF )
          shift
          OUTPUT_FILE_DIR=$1
          ;;
        -p | --plugin )
          shift
          PLUGIN_DIR=$1
          #replaces the + in plugin command with a semicolon for MrsWatson processing
          PLUGIN_DIR=${PLUGIN_DIR//"+"/";"}
          ;;
        -pb | --pluginB )
          shift
          PLUGIN_BIT=$1
          ;;
        -r | --rec )
          RECURSIVE_SEARCH=1
          ;;
        -v | --verbose )
          VERBOSE=1
          ;;
        -x | --ext )
          shift
          FILE_EXT=$1
          ;;
        * )
        printf "\nWrong options used: %s is not recognized as an option" "$1"
        show_help
        exit
    esac
    shift
done

# executes MrsWatson command
run_mrswatson_command()
{

  # the plugin directory, input directory, and output directory are passed as parameters,
  # as they individually need to be quoted in the MrsWatson command in order to avoid whitespace issues
  # parameters:
  # $0: script name
  # $1: MrsWatson base command ('mrswatson' for 32 bit, 'mrswatson64' for 64 bit processing)
  # $2: plugin directory
  # $3: input directory
  # $4: output directory

  if [ $VERBOSE -gt 0 ]
  then
    printf "\nMrsWatson Command: %s -p %s -i %s -o %s\n\n" "${1}" "${2}" "${3}" "${4}"
    "${1}" -p "${2}" -i "${3}" -o "${4}"
  else
    #runs command without output (directs output to null) and checks if it succeeded
    "${1}" -p "${2}" -i "${3}" -o "${4}" -q 2>/dev/null
    if [ $? -eq 0 ]; then
        #printf "${GRN}\nSuccessfully wrote file %s\n${RED}" "$2"
        NUM_COMPLETED_FILES=$(( NUM_COMPLETED_FILES + 1 ))
    fi
    NUM_PROCESSED_FILES=$(( NUM_PROCESSED_FILES + 1 ))
    perc_completed=$(( NUM_PROCESSED_FILES * 100 / NUM_FILES ))

    printf "Processing files: %d%% completed\r" $perc_completed

    if [ $perc_completed == 100 ]
    then
      perc_successful=$(( NUM_COMPLETED_FILES * 100 / NUM_FILES ))
      if [ $perc_successful -lt 50 ]
      then
        printf "\n${RED}%d/%d${NC} files processed successfully\n" $NUM_COMPLETED_FILES $NUM_FILES
      elif [ $perc_successful -lt 80 ]
      then
        printf "\n${BL}%d/%d${NC} files processed successfully\n" $NUM_COMPLETED_FILES $NUM_FILES
      else
        printf "\n${GRN}%d/%d${NC} files processed successfully\n" $NUM_COMPLETED_FILES $NUM_FILES
      fi
    fi
  fi

}

# handles processing for when an input file is provided
construct_input_file_command()
{
    #obtains input and plugin file names to construct output file name
    input_filename="${INPUT_FILE##*/}"
    plugin_filename_with_format="${PLUGIN_DIR##*/}"
    plugin_filename=${plugin_filename_with_format%.*}
    output_filename="/${plugin_filename}_${input_filename}"
    # replaces ';' with '-' in output filename
    # this is used only when multiple plugins are applied
    output_filename=${output_filename//";"/"-"}

    # sets the number of files to 1 for progress bar processing
    NUM_FILES=1

    # checks if an output dir was provided
    if [[ -n $OUTPUT_DIR ]] &&  [[ -z $OUTPUT_FILE_DIR ]]
    then
      #creates output dir if it doesn't exist
      if [ ! -d "$OUTPUT_DIR" ]
      then
        mkdir "$OUTPUT_DIR"
      fi
      output_file_path="$OUTPUT_DIR${output_filename}"
      run_mrswatson_command "$mrs_watson_base_command" "$PLUGIN_DIR" "$INPUT_FILE" "$output_file_path"
      printf "\n"
      exit
    # checks if no -o was provided
    elif [[ -z $OUTPUT_DIR ]] && [[ -z $OUTPUT_FILE_DIR ]]
    then
      input_file_path="$(dirname "${INPUT_FILE}")"
      output_file_path=${input_file_path}${output_filename}
      mrs_watson_command+=" -o $output_file_path"
      run_mrswatson_command "$mrs_watson_base_command" "$PLUGIN_DIR" "$INPUT_FILE" "$output_file_path"
      printf "\n"
      exit
    # checks if output file was provided
    elif [[ -n $OUTPUT_FILE_DIR ]] &&  [[ -z $OUTPUT_DIR ]]
    then
      run_mrswatson_command "$mrs_watson_base_command" "$PLUGIN_DIR" "$INPUT_FILE" "$OUTPUT_FILE_DIR"
      printf "\n"
      exit
    fi
}

# handles processing for when an input directory is provided
construct_input_dir_command()
{
    input_path_collection=()
    # if recursive option is selected, list of files is set to all files in this directory and its subdirectories
    # Otherwise, only the files in the top level dir are used
    if [[ RECURSIVE_SEARCH -eq 1 ]]
      then
        while IFS= read -r -d '' file_path; do
          input_path_collection=("${input_path_collection[@]}" "${file_path}")
        done < <(find "$INPUT_DIR" -name "*$FILE_EXT" -type f -print0)

    elif [[ RECURSIVE_SEARCH -eq 0 ]]
      then
        while IFS= read -r -d '' file_path; do
          input_path_collection=("${input_path_collection[@]}" "${file_path}")
        done < <(find "$INPUT_DIR" -maxdepth 1 -name "*$FILE_EXT" -type f -print0)
      fi

    # obtains the number of total files to be processed
    NUM_FILES=${#input_path_collection[@]}

    for file_path in "${input_path_collection[@]}"
      do
        output_file_path=""
        input_file_path=""
        #obtains input and plugin file names to construct output file name
        input_filename="${file_path##*/}"
        plugin_filename_with_format="${PLUGIN_DIR##*/}"
        plugin_filename=${plugin_filename_with_format%.*}
        output_filename="/${plugin_filename}_${input_filename}"
        # replaces ';' with '-' in output filename
        # this is used only when multiple plugins are applied
        output_filename=${output_filename//";"/"-"}

        # checks if an output dir was provided
        if [[ -n $OUTPUT_DIR ]]
        then

          #gets absolute paths for the new path calculation
          abs_input_path=$(realpath "${INPUT_DIR}")
          current_file_path=$(realpath "${file_path}")
          abs_output_path=$(realpath --relative-to="./" "${OUTPUT_DIR}")

          #contains the difference of above, removes original filename from path
          naked_path=${current_file_path#"$abs_input_path"}
          naked_path=${naked_path%"/$input_filename"}

          #if current file is inside subdirectory, it is created in the output folder
          if [ -n "$naked_path" ] && [ ! -d "$abs_output_path$naked_path" ]
          then
            mkdir -p "$abs_output_path$naked_path"
          fi

          #adds new filename
          naked_path+=$output_filename
          #concatenates requested output path with original dir structure
          output_file_path="$abs_output_path$naked_path"
          run_mrswatson_command "$mrs_watson_base_command" "$PLUGIN_DIR" "$file_path" "$output_file_path"
        elif [[ -z $OUTPUT_DIR ]] && [[ -z $OUTPUT_FILE_DIR ]]
        then
          input_file_path="$(dirname "${file_path}")"
          output_file_path=${input_file_path}${output_filename}
          run_mrswatson_command "$mrs_watson_base_command" "$PLUGIN_DIR" "$file_path" "$output_file_path"
        fi
      done
    printf "\n"
    exit

}


# constructs MrsWatson command
construct_mrswatson_command()
{

  # checks for 32bit vs 64bit plugin request
  mrs_watson_base_command="mrswatson"
  if [[ PLUGIN_BIT -eq 64 ]]
  then
    mrs_watson_base_command="mrswatson64"
  fi

  if [[ -n $INPUT_FILE ]] && [[ -z $INPUT_DIR ]]
  then
    construct_input_file_command "$mrs_watson_base_command"
  elif [[ -n $INPUT_DIR ]] && [[ -z $INPUT_FILE ]]
  then
    construct_input_dir_command "$mrs_watson_base_command"
  fi
}

validate_args
construct_mrswatson_command