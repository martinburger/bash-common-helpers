Describe "bash-common-helpers' function"
  Include ./bash-common-helpers.sh

  Describe "cmn_echo_ ..."

    Parameters
      "info()" cmn_echo_info
      "important()" cmn_echo_important
      "warn()" cmn_echo_warn
    End

    It "$1 outputs single given string without space character"
      When call $2 "abcdef"
      The output should include "abcdef"
    End
    It "$1 outputs single given string with space character"
      When call $2 "abc def"
      The output should include "abc def"
    End
    It "$1 outputs two given strings each one without space character"
      When call $2 "abc" "def"
      The output should include "abc def"
    End
    It "$1 outputs two given strings each one with space character"
      When call $2 "abc " " def"
      The output should include "abc   def"
    End

  End

  Describe "cmn_die()"
    It "exits"
      When run cmn_die "exited with status 1"
      The error should include "exited with status 1"
      The status should be failure
    End
  End

End
