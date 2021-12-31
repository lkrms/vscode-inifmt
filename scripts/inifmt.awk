BEGIN {
  # Leave tabs alone
  FS = " +"
  # Replace processed fields with something unprintable to maintain numbering
  placeholder = "\33"
  # Disable column alignment by default
  align_all_columns = get_var(align_all_columns, 0)
  align_columns_if_first_matches = align_all_columns ? 0 : get_var(align_columns_if_first_matches, 0)
  align_columns = align_all_columns || align_columns_if_first_matches
  # Align comments by default
  align_comments = get_var(align_comments, 1)
  comment_regex = align_comments ? get_var(comment_regex, "[#;]") : ""
}

/^[[:blank:]]*$/ {
  # Collapse subsequent empty lines
  if (!last_empty) {
    print_section()
    # Remove empty lines from start of input
    if (output_lines) {
      empty_pending = 1
    }
  }
  last_empty = 1
  next
}

{
  # Remove leading and trailing spaces
  gsub("(^(" FS ")+|(" FS ")+$)", "")
  if (empty_pending) {
    print ""
    empty_pending = 0
  }
  last_empty = 0
  if (align_columns_if_first_matches && actual_lines && (! comment_regex || $1 !~ "^" comment_regex "([^[:blank:]]|$)") && $1 != setting) {
    queue_entries()
  }
  entry_line++
  section_line++
  field_count[entry_line] = 0
  comment[section_line] = ""
  for (i = 1; i <= NF; i++) {
    if (process_regex("[\"'\\\\]", "(([^ \"'\\\\]|\\\\.)*(\"([^\"]|\\\\\")*\"|'([^']|\\\\')*'))+([^ \"'\\\\]|\\\\.)*")) {
      store_field(field_value)
    } else if (comment_regex && (process_regex(comment_regex, comment_regex ".*", 1))) {
      comment[section_line] = field_value
    } else {
      store_field($i "")
      $i = placeholder
    }
  }
  if (field_count[entry_line]) {
    if (!actual_lines) {
      setting = entry[entry_line, 1]
    }
    actual_lines++
  }
}

END {
  print_section()
}

function process_regex(field_regex, value_regex, split_field, _pending) {
  if (match($i, field_regex)) {
    if (split_field && RSTART > 1) {
      $i = substr($i, 1, RSTART - 1) " " substr($i, RSTART)
      $0 = $0
      return
    }
    _pending = $0
    sub("^( |" placeholder ")*", "", _pending)
    if (match(_pending, "^" value_regex)) {
      field_value = substr(_pending, RSTART, RLENGTH)
      return sub(value_regex, placeholder)
    }
  }
}

function store_field(value, _length) {
  field_count[entry_line] = i
  entry[entry_line, i] = value
  _length = length(value)
  field_width[i] = _length > field_width[i] ? _length : field_width[i]
}

function queue_entries(_offset, _i, _j, _l) {
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
    sub(" +$", "", _l)
    section[_offset + _i] = _l
  }
  entry_line = 0
  actual_lines = 0
  for (_j in field_width) { delete field_width[_j] }
}

function print_section(_i, _length, _max_length, _l) {
  queue_entries()
  for (_i = 1; _i <= section_line; _i++) {
    _length = length(section[_i])
    _max_length = _length > _max_length ? _length : _max_length
  }
  for (_i = 1; _i <= section_line; _i++) {
    _l = section[_i]
    if (comment[_i]) {
      _l = (_l ? sprintf("%-" _max_length "s ", _l) : "") comment[_i]
    }
    print _l
    output_lines++
  }
  section_line = 0
}

function is_set(var) {
  return ! (var == "" && var == 0)
}

function get_var(var, default) {
  return is_set(var) ? var : default
}
