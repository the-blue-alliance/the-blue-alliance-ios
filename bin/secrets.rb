#!/usr/bin/env ruby

require 'json'

header = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
EOF

footer = <<EOF
</dict>
</plist>
EOF

values = []

# Decrypt secrets
secrets_ejson_path = `find . -name secrets.ejson`.strip
puts "Found secrets at #{secrets_ejson_path}"
secrets = `ejson decrypt #{secrets_ejson_path}`
puts 'Successfully decrypted'

# Parse secrets
json_secrets = JSON.parse(secrets)
json_secrets.collect do |key, value|
  next if key == '_public_key'
  values << "  <key>#{key}</key>"
  values << "  <string>#{value}</string>"
end

# Write secrets to PList file
secrets_plist_path = `find . -name Secrets.plist`.strip
File.write(secrets_plist_path, header + values.join("\n") + footer)
