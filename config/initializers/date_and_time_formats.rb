# Add consistent default time formats for use by presentation layer
# `my_date.to_fs(:stamp)`
# instead of
# `my_date.to_fs(:stamp)`
#
Date::DATE_FORMATS[:stamp] = '%-d %B %Y' # DD MONTH YYYY
Time::DATE_FORMATS[:stamp] = '%-d %B %Y' # DD MONTH YYYY
Time::DATE_FORMATS[:time_of_day] = '%-I:%M%P' # H:MM with am/pm
