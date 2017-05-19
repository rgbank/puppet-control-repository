#
# to_hash
#
Puppet::Functions.create_function(:to_hash) do
  dispatch :to_hash do
    param 'Array', :array
  end

  def to_hash(array)
    Hash[*array.flatten]
  end
end
# vim: set ts=2 sw=2 et :
