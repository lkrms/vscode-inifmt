BEGIN {
  # Leave tabs alone
  FS = " +"
  # Replace processed fields with something unprintable to maintain numbering
  placeholder = "\033"
  # Disable column alignment by default
  align_all_columns = z_get_var(align_all_columns, 0)
  align_columns_if_first_matches = align_all_columns ? 0 : z_get_var(align_columns_if_first_matches, 0)
  align_columns = align_all_columns || align_columns_if_first_matches
  # Align comments by default
  align_comments = z_get_var(align_comments, 1)
  comment_regex = align_comments ? z_get_var(comment_regex, "[#;]") : ""
}

/^[[:blank:]]*$/ {
  # Collapse subsequent empty lines
  if (! last_empty) {
    c_print_section()
    # Remove empty lines from start of input
    if (output_lines) {
      empty_pending = 1
    }
  }
  last_empty = 1
  next
}

{
  # Remove leading spaces
  sub(/^ +/, "", $0)
  if (empty_pending) {
    print ""
    empty_pending = 0
  }
  last_empty = 0
  if (align_columns_if_first_matches && actual_lines && (! comment_regex || $1 !~ ("^" comment_regex "([^[:blank:]]|$)")) && $1 != setting) {
    b_queue_entries()
  }
  entry_line++
  section_line++
  field_count[entry_line] = 0
  comment[section_line] = ""
  for (i = 1; i <= NF; i++) {
    if (a_process_regex("[\"'\\\\]", "(([^ \"'\\\\]|\\\\.)*(\"([^\"]|\\\\\")*\"|'([^']|\\\\')*'))*([^ \\\\]|\\\\.|\\\\$)*")) {
      a_store_field(field_value)
    } else if (comment_regex && (a_process_regex(comment_regex, comment_regex ".*", 1))) {
      sub(/ +$/, "", field_value)
      comment[section_line] = field_value
    } else if (length($i)) {
      a_store_field($i "")
      a_replace_field(placeholder)
    }
  }
  if (field_count[entry_line]) {
    if (! actual_lines) {
      setting = entry[entry_line, 1]
    }
    actual_lines++
  }
}

END {
  c_print_section()
}


function a_process_regex(field_regex, value_regex, split_field, _pending, _delta)
{
  if (match($i, field_regex)) {
    if (split_field && RSTART > 1) {
      a_replace_field(substr($i, 1, RSTART - 1) " " substr($i, RSTART))
      return
    }
    _pending = $0
    sub("^( |" placeholder ")*", "", _pending)
    if (match(_pending, "^" value_regex)) {
      field_value = substr(_pending, RSTART, RLENGTH)
      _delta = length($0) - length(_pending)
      $0 = substr($0, 1, RSTART - 1 + _delta) placeholder substr($0, RSTART + RLENGTH + _delta)
      return 1
    }
  }
}

function a_replace_field(value, _next)
{
  if (! match($0, "^ *[^ ]+( +[^ ]+){" (i - 1) "}")) {
    # Last resort; should never be reached
    $i = value
    return
  }
  # Save text after $i, then remove it from the line
  _next = substr($0, RLENGTH + 1)
  $0 = (substr($0, 1, RLENGTH))
  # Set $i to "", reconstructing $0 using OFS to separate fields
  $i = ""
  # Append new value of $i and text after it, preserving whitespace in both
  $0 = $0 value _next
}

function a_store_field(value, _length)
{
  field_count[entry_line] = i
  entry[entry_line, i] = value
  _length = length(value)
  field_width[i] = _length > field_width[i] ? _length : field_width[i]
}

function b_queue_entries(_offset, _i, _j, _l)
{
  _offset = section_line - entry_line
  for (_i = 1; _i <= entry_line; _i++) {
    _l = ""
    for (_j = 1; _j <= field_count[_i]; _j++) {
      if (align_columns && actual_lines > 1 && setting) {
        _l = _l sprintf("%-" field_width[_j] "s ", entry[_i, _j])
      } else {
        _l = _l sprintf("%s ", entry[_i, _j])
      }
    }
    sub(" $", "", _l)
    section[_offset + _i] = _l
  }
  entry_line = 0
  actual_lines = 0
  for (_j in field_width) {
    delete field_width[_j]
  }
}

function c_print_section(_i, _length, _max_length, _l)
{
  b_queue_entries()
  for (_i = 1; _i <= section_line; _i++) {
    _length = length(section[_i])
    _max_length = _length > _max_length ? _length : _max_length
  }
  for (_i = 1; _i <= section_line; _i++) {
    _l = section[_i]
    if (comment[_i]) {
      _l = (_l ~ /[^\t]/ ? sprintf("%-" _max_length "s ", _l) : _l) comment[_i]
    }
    print _l
    output_lines++
  }
  section_line = 0
}

function z_get_var(var, default)
{
  return (z_is_set(var) ? var : default)
}

function z_is_set(var)
{
  return ! (var == "" && var == 0)
}
