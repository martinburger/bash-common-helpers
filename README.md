# Bash Common Helpers

This repository contains Bash utility functions I use in my Bash (and Zsh)
scripts regularly. These functions are provided through a small library
called `bash-common-helpers`. The library saves the trouble to redefine
commonly used helper functions every time you write a shell script &ndash; be it
a simple, quickly written script or a more elaborate utility. Especially in the
first case, the library may save a great part of the development time.

## Overview

The library currently provides the following helper functions:

### Script Initialization

- `cmn_init` &ndash; supposed to be called at the beginning of every script.
  Makes scripts more robust by setting various shell options.
- `cmn_assert_running_as_root` &ndash; makes sure that the script is run as
  root.

### Printing to the Screen

- `cmn_echo_info` &ndash; prints informative message in green letters.
- `cmn_echo_important` &ndash; prints message of higher importance in yellow
  letters.
- `cmn_echo_warn` &ndash; prints warning in red letters.

### Error Handling

- `cmn_die` &ndash; writes message in red letters to standard error and exits.

### Availability of Commands and Files

- `cmn_assert_command_is_available` &ndash; makes sure that the given command is
  available.
- `cmn_assert_file_exists` &ndash; makes sure that the given regular file
  exists.
- `cmn_assert_file_does_not_exist` &ndash; makes sure that the given file does
  not exist.

### User Interaction

- `cmn_ask_to_continue` &ndash; asks the user whether to continue or not.
- `cmn_ask_for_password` &ndash; prompts the user for a password. Instead of
  echoing the entered characters, asterisks (`*`) are printed.
- `cmn_ask_for_password_twice` &ndash; asks the user for her password twice and
  checks if both inputs match.

### File Utilities

- `cmn_replace_in_files` &ndash; replaces given string in files. The function
  uses perl to provide a robust implementation.

### Parsing INI Files

- `cmn_parse_ini_file` &ndash; parses INI file using Ruediger Meier's "simple
  INI file parser".
- `cmn_assert_ini_variables_exist` &ndash; makes sure that the given INI
  variables exist and provides feedback to the user if not.

Note prefix `cmn_` which is supposed to avoid clashes with the names of
functions defined in your script or in any other included script.

## Installation

In a nutshell: just make a clone of this repository on your harddisk and load
the library by [sourcing](http://ss64.com/bash/source.html) it.

For instance, go to directory `~/local/lib` and clone the repository there. In
this case, the library files will end up in directory
`~/local/lib/bash-common-helpers`.

Now, you have to `source` the main library file in your scripts. This basically
reads and executes the commands in the library files in your script's context
and thus makes all the library helper functions available to your script.

### Using an Environment Variable

I prefer to set an environment variable that refers to the library path and
to use that variable to `source` the library file in my scripts. This way, when
I move the library on my hard disk, I do not have to adapt all my scripts but
the environment variable only.

To set the environment variable, add the following line to your `.bashrc`,
`.zshrc`, or whatever rcfile file you are using:

    export BASH_COMMON_HELPERS_LIB="~/local/lib/bash-common-helpers/bash-common-helpers.sh"

Then, use the following header in your scripts:

    #!/bin/bash

    # BEGIN: Read functions from bash-common-helpers library.
    if [[ -z "${BASH_COMMON_HELPERS_LIB}" ]]; then
      echo "Required environment variable is not set: BASH_COMMON_HELPERS_LIB"
      exit 1
    fi
    if [[ ! -f "${BASH_COMMON_HELPERS_LIB}" ]]; then
      echo "Required file does not exist: ${BASH_COMMON_HELPERS_LIB}"
      exit 2
    fi
    source "${BASH_COMMON_HELPERS_LIB}"
    cmn_init || exit 3
    # END: Read functions from bash-common-helpers library.

    # Your actual script starts here.
    cmn_echo_info "Could source lib file successfully."

### Using Path to Library Directly

Of course, you can omit the above environment variable and refer to the library
directly:

    #!/bin/bash

    # BEGIN: Read functions from bash-common-helpers library.
    BASH_COMMON_HELPERS_LIB="~/local/lib/bash-common-helpers/bash-common-helpers.sh"
    if [[ ! -f "${BASH_COMMON_HELPERS_LIB}" ]]; then
      echo "Required file does not exist: ${BASH_COMMON_HELPERS_LIB}"
      exit 1
    fi
    source "${BASH_COMMON_HELPERS_LIB}"
    cmn_init || exit 2
    # END: Read functions from bash-common-helpers library.

    # Your actual script starts here.
    cmn_echo_info "Could source lib file successfully."

## Documentation

For the documentation of the library, please refer to the source code: each
function in the library has an explaining comment which is written above it.
That comment contains the purpose of the function as well as an example which
shows how to call the function.

## Credits

Many functions have their roots in various web pages, blog posts, and lastly
in answers provided by the phenomenal Stack Exchange Q&A communities. Whenever
possible, I refer to the most relevant source in the documentation of the
functions.

Function `cmn_parse_ini_file` uses Ruediger Meier's "simple INI file parser"
which is [available at GitHub](https://github.com/rudimeier/bash_ini_parser).
Actually, the library includes that parser for reasons of convenience.

Last but not least, the library contains valuable knowledge and experience
of coworkers who showed my one or two tricks.

## License

Released under the MIT License (MIT) &ndash; see file LICENSE in this software's
repository.
