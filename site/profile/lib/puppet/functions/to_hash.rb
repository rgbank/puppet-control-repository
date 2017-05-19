#
# to_hash
#
Puppet::Functions.create_function(:to_hash) do
  dispatch :to_hash do
    param 'Array', :array
  end

  def to_hash(array)
    h = Hash.new

    array.each do |value|
      h[value.keys[0]] = value.values[0]
    end

    h
  end
end
# vim: set ts=2 sw=2 et :
