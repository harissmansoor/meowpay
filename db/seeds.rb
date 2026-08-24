[
  { name: "Whiskers", treats_balance: 100 },
  { name: "Mittens", treats_balance: 50 },
  { name: "Boots", treats_balance: 25 },
  { name: "Jackie", treats_balance: 10 },
  { name: "Snowball", treats_balance: 0 }
].each do |attrs|
  Cat.find_or_create_by!(name: attrs[:name]) do |cat|
    cat.treats_balance = attrs[:treats_balance]
  end
end
