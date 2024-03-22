module NameConstructable
  def construct_name(item, prefix: nil)
    item["#{prefix}full_name"] || "#{item["#{prefix}first_name"]} #{item["#{prefix}last_name"]}"
  end
end
