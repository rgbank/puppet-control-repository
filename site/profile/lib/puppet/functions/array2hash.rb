#
# array2hash.rb
#

module Puppet::Parser::Functions
  newfunction(:array2hash, :type => :rvalue, :doc => <<-EOS
This converts any array to a hash.
For example: [ [a,b], [c,d] ] => {a => b, c => d}
Another example: [a, b, c, d] => {a => b, c => d}
    EOS
  ) do |arguments|

    if arguments.empty?
        return []
    end

    if arguments.length == 1
        if arguments[0].kind_of?(Array)
            return Hash[*arguments[0].flatten]
        else
            raise "The array2hash method only accepts arrays"
        end
    end

    return arguments
  end
end

# vim: set ts=2 sw=2 et :
