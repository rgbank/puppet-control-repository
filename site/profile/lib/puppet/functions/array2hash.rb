#
# array2hash.rb
#

Puppet::Functions.create_function(:to_hash) do
  dispatch :to_hash do
    param 'Array', :array
  end

  def to_hash(array) do
    Hash[*array.flatten]
  end
end
# vim: set ts=2 sw=2 et :
