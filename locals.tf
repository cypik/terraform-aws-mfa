locals {
  iam_users_list = sort(tolist(data.aws_iam_users.all_users.names))

  # tflint-ignore: terraform_unused_declarations
  current_timestamp = timestamp()

  # Get password last used information from external data source
  user_last_used_info = {
    for user_name in local.iam_users_list :
    user_name => {
      password_last_used = data.external.password_last_used[user_name].result.password_last_used
    }
  }

  removed_users_list = fileexists("${path.root}/removed_users.txt") ? compact(split("\n", file("${path.root}/removed_users.txt"))) : []

  # Get current users by subtracting removed ones
  current_users = setsubtract(data.aws_iam_users.all_users.names, local.removed_users_list)
  # Convert current timestamp to Unix timestamp for calculations
  current_unix_timestamp = timecmp(timestamp(), "1970-01-01T00:00:00Z")
  user_ages = {
    for user_name, info in local.user_last_used_info :
    user_name => (
      info.password_last_used != "Never" && info.password_last_used != "None" ?
      floor(
        (
          timecmp(info.password_last_used, "1970-01-01T00:00:00Z")
          -local.current_unix_timestamp
        ) / -86400
      ) :
      var.inactive_days + 1 # Force them as inactive
    )
  }

  user_is_inactive = {
    for user_name in local.iam_users_list :
    user_name => local.user_ages[user_name] > var.inactive_days
  }

  # Calculate key ages - only for keys we can actually access
  key_ages = {
    for user_name in local.iam_users_list :
    user_name => [
      for key in data.aws_iam_access_keys.user_keys[user_name].access_keys : {
        access_key_id = key.access_key_id
        status        = key.status
        create_date   = key.create_date
        age_days = try(
          # Calculate days between key creation and now
          floor((local.current_unix_timestamp - tonumber(timeadd(key.create_date, "0s"))) / 86400),
          0
        )
      }
    ]
  }

  inactive_users = [
    for user_name in local.current_users : user_name
    if fileexists("${path.root}/user_status/${user_name}") &&
    trimspace(file("${path.root}/user_status/${user_name}")) == "inactive"
  ]

  # Identify users needing key rotation (keys older than specified days)
  users_needing_rotation = [
    for user_name in local.iam_users_list : user_name
    if length([for key in local.key_ages[user_name] :
      key if key.status == "Active" && key.age_days > var.key_rotation_days
    ]) > 0
  ]

  # Active users list
  active_users = [for user in local.iam_users_list : user if !contains(local.inactive_users, user)]

  # Enhanced user access information with actual password last used
  user_access_info = [for user_name in local.iam_users_list :
    format("%s: Password last used: %s",
      user_name,
      local.user_last_used_info[user_name].password_last_used
    )
  ]

  # Key age information
  key_age_info = [for user_name in local.iam_users_list :
    format("%s: %s",
      user_name,
      join(", ", [for key in local.key_ages[user_name] :
        format("Key %s: %d days old",
          substr(key.access_key_id, 0, 8), # Show only first 8 chars for security
          key.age_days
        )
      ])
    )
  ]

  # Inactive user ages
  # tflint-ignore: terraform_unused_declarations
  inactive_user_ages = {
    for user in local.inactive_users : user => local.user_ages[user]
  }
}