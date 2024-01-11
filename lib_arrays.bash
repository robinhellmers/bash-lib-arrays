#####################
### Guard library ###
#####################
guard_source_max_once() {
    local file_name="$(basename "${BASH_SOURCE[0]}")"
    local guard_var="guard_${file_name%.*}" # file_name wo file extension

    [[ "${!guard_var}" ]] && return 1
    [[ "$guard_var" =~ ^[_a-zA-Z][_a-zA-Z0-9]*$ ]] \
        || { echo "Invalid guard: '$guard_var'"; exit 1; }
    declare -gr "$guard_var=true"
}

guard_source_max_once || return 0

##############################
### Library initialization ###
##############################
init_lib()
{
    # Unset as only called once and most likely overwritten when sourcing libs
    unset -f init_lib

    if ! [[ -d "$LIB_PATH" ]]
    then
        echo "LIB_PATH is not defined to a directory for the sourced script."
        echo "LIB_PATH: '$LIB_PATH'"
        exit 1
    fi

    ### Source libraries ###
    #
    # Always start sourcing 'lib_core.bash' with the command
    # source "$LIB_PATH/lib_core.bash" || exit 1
    # Libraries thereafter should be sourced with the command
    # source_lib "$LIB_PATH/<lib_name>"
    source "$LIB_PATH/lib_core.bash" || exit 1
    source_lib "$LIB_PATH/lib_handle_input.bash"
    source_lib "$LIB_PATH/lib_dynamic_variables.bash"
}

init_lib

#####################
### Library start ###
#####################

###
# List of functions for usage outside of lib
#
# - find_array_index_by_value()
###

register_help_text 'find_array_index_by_value' \
'find_array_index_by_value <value> <array_len> <array>

Find the first index of the array, which stores the given value.

Input:
<value>: The value to find in the array
<array_len>: The length of the array ( ${#array[@]} )
<array>: The array values ( ${array[@]} )

Output:
Variable <found_index>: Index of first array element containing <value>

Return value:
0 if found
1 if not found'

# No flags
register_function_flags 'find_array_index_by_value' \
                        '-v' '--verbose' 'false' 'Verbose output'

find_array_index_by_value()
{
    local input_value
    local input_array=()
    _handle_args_find_array_index_by_value "$@"

    local i
    for i in "${!input_array[@]}"
    do
        if [[ "${input_array[i]}" == "$input_value" ]]
        then
            index_found=$i
            return 0
        fi
    done

    return 1
}

_handle_args_find_array_index_by_value()
{
    _handle_args 'find_array_index_by_value' "$@"

    ###
    # Arguments - Singular values
    input_value="${non_flagged_args[0]}"
    non_flagged_args=("${non_flagged_args[@]:1}")
    #
    ###

    ###
    # Arguments - Arrays
    local dynamic_array_prefix="input_array"
    handle_input_arrays_dynamically "$dynamic_array_prefix" \
                                    "${non_flagged_args[@]}"

    get_dynamic_array "${dynamic_array_prefix}1"
    input_array=("${dynamic_array[@]}")
    #
    ###
}
